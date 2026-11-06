import 'package:flutter/material.dart';
import 'package:snaplock/models/post_model.dart';
import 'package:snaplock/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class DumpPage extends StatefulWidget {
  const DumpPage({super.key});

  @override
  State<DumpPage> createState() => _DumpPage();
}

class _DumpPage extends State<DumpPage> {
  static const _months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro'
  ];

  bool _loading = true;
  String? _error;
  final Map<String, List<PostModel>> _monthlyAlbums = {};
  final Map<String, String> _coverPhotoIds = {};
  final Map<String, bool> _visibleToFriends = {};
  List<Map<String, dynamic>> _friendDumps = [];
  bool _loadingFriends = false;
  static const _coverPreferencePrefix = 'dump_cover_';
  static const _visiblePreferencePrefix = 'dump_visible_';
  static const _legacyDeletedDumpPrefix = 'dump_deleted_';

  String _preferenceKey(String prefix, String dumpKey) {
    final userId = ApiService.currentUser?.id ?? 'current';
    return '$prefix${userId}_$dumpKey';
  }

  Future<void> _removeLegacyDeletionFlags(SharedPreferences preferences) async {
    final keys = preferences
        .getKeys()
        .where((key) => key.startsWith(_legacyDeletedDumpPrefix));
    for (final key in keys.toList()) {
      await preferences.remove(key);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAlbums();
    _loadFriendDumps();
  }

  Future<void> _loadFriendDumps() async {
    setState(() => _loadingFriends = true);
    try {
      final dumps = await ApiService.getFriendDumps();
      if (!mounted) return;
      setState(() {
        _friendDumps = dumps;
        _loadingFriends = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingFriends = false);
    }
  }

  Future<void> _loadAlbums() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final photos = await ApiService.getMyGallery();
      final preferences = await SharedPreferences.getInstance();
      await _removeLegacyDeletionFlags(preferences);
      final serverVisibility = <String, bool>{};
      var serverVisibilityLoaded = false;
      try {
        final settings = await ApiService.getMyDumpSettings();
        serverVisibilityLoaded = true;
        for (final dump in settings) {
          final year = dump['ano']?.toString() ?? '';
          final month = dump['mes']?.toString() ?? '';
          if (year.isEmpty || month.isEmpty) continue;
          final monthNumber = int.tryParse(month);
          if (monthNumber == null) continue;
          final value = dump['visivel'];
          final isVisible = value == true ||
              value?.toString() == '1' ||
              value?.toString().toLowerCase() == 'true';
          serverVisibility['$year-${monthNumber.toString().padLeft(2, '0')}'] =
              isVisible;
        }
      } catch (_) {
        // Mantém as preferências locais quando o servidor estiver indisponível.
      }
      final albums = <String, List<PostModel>>{};
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);

      for (final photo in photos) {
        final date = DateTime.tryParse(photo.createdAt);
        if (date == null) continue;

        final photoMonth = DateTime(date.year, date.month);
        if (!photoMonth.isBefore(currentMonth)) {
          continue;
        }

        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        albums.putIfAbsent(key, () => []).add(photo);
      }

      final sortedKeys = albums.keys.toList()..sort((a, b) => b.compareTo(a));
      final sortedAlbums = <String, List<PostModel>>{};
      _coverPhotoIds.clear();
      for (final key in sortedKeys) {
        sortedAlbums[key] = albums[key]!;
        final savedPhotoId =
            preferences.getString(_preferenceKey(_coverPreferencePrefix, key));
        if (savedPhotoId != null) {
          _coverPhotoIds[key] = savedPhotoId;
        }
        final isVisible = serverVisibilityLoaded
            ? serverVisibility[key] ?? false
            : preferences
                    .getBool(_preferenceKey(_visiblePreferencePrefix, key)) ??
                false;
        _visibleToFriends[key] = isVisible;
        await preferences.setBool(
          _preferenceKey(_visiblePreferencePrefix, key),
          isVisible,
        );
      }

      if (!mounted) return;
      setState(() {
        _monthlyAlbums
          ..clear()
          ..addAll(sortedAlbums);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  String _albumTitle(String key) {
    final parts = key.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    return '${_months[month - 1]} $year';
  }

  String _monthName(String key) {
    final month = int.parse(key.split('-')[1]);
    return _months[month - 1].toUpperCase();
  }

  Future<void> _editCover(String key, List<PostModel> photos) async {
    var visible = _visibleToFriends[key] ?? false;
    final parts = key.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    final selected = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF7F2EA),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(sheetContext).height * 0.72,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Editar capa do dump',
                      style: TextStyle(
                          color: Color(0xFF3E3A36),
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Escolher foto da galeria do celular'),
                      onPressed: () async {
                        final file = await ImagePicker().pickImage(
                            source: ImageSource.gallery, imageQuality: 90);
                        if (file != null && sheetContext.mounted) {
                          Navigator.pop(sheetContext, file);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8),
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(sheetContext, photo),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(photo.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const ColoredBox(
                                  color: Color(0xFFDDD1C2),
                                  child: Icon(Icons.broken_image_outlined))),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(
        _preferenceKey(_visiblePreferencePrefix, key), visible);
    if (!mounted) return;
    setState(() => _visibleToFriends[key] = visible);

    if (selected is PostModel) {
      await preferences.setString(
          _preferenceKey(_coverPreferencePrefix, key), selected.id);
      if (mounted) setState(() => _coverPhotoIds[key] = selected.id);
      try {
        await ApiService.setDumpVisibility(
          year: year,
          month: month,
          visible: visible,
          coverUrl: selected.imageUrl,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Capa do dump atualizada.')),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(error.toString().replaceAll('Exception: ', ''))));
        }
      }
    } else if (selected is XFile) {
      try {
        final bytes = await selected.readAsBytes();
        final coverUrl = await ApiService.uploadDumpCover(
          year: year,
          month: month,
          imageBytes: bytes,
          fileName: selected.name,
        );
        await ApiService.setDumpVisibility(
          year: year,
          month: month,
          visible: visible,
          coverUrl: coverUrl,
        );
        await preferences.setString(
            _preferenceKey(_coverPreferencePrefix, key), coverUrl);
        if (mounted) {
          setState(() => _coverPhotoIds[key] = coverUrl);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Capa do dump atualizada.')),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(error.toString().replaceAll('Exception: ', ''))));
        }
      }
    }
  }

  Future<void> _toggleVisibility(String key, List<PostModel> photos) async {
    final parts = key.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final visible = !(_visibleToFriends[key] ?? false);

    String? coverUrl;
    final coverPhotoId = _coverPhotoIds[key];
    if (coverPhotoId != null && coverPhotoId.startsWith('http')) {
      coverUrl = coverPhotoId;
    } else if (coverPhotoId != null) {
      final matchingPhoto = photos.where((photo) => photo.id == coverPhotoId);
      if (matchingPhoto.isNotEmpty) {
        coverUrl = matchingPhoto.first.imageUrl;
      }
    } else if (photos.isNotEmpty) {
      coverUrl = photos.first.imageUrl;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(
        _preferenceKey(_visiblePreferencePrefix, key), visible);
    if (!mounted) return;
    setState(() => _visibleToFriends[key] = visible);

    try {
      await ApiService.setDumpVisibility(
        year: year,
        month: month,
        visible: visible,
        coverUrl: coverUrl,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(visible
                ? 'Dump agora está visível para os amigos.'
                : 'Dump ocultado dos amigos.'),
          ),
        );
      }
    } catch (error) {
      await preferences.setBool(
        _preferenceKey(_visiblePreferencePrefix, key),
        !visible,
      );
      if (mounted) setState(() => _visibleToFriends[key] = !visible);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceAll('Exception: ', '')),
        ),
      );
    }
  }

  void _openAlbum(String title, List<PostModel> photos) {
    showDialog<void>(
      context: context,
      barrierColor: const Color(0xFFF3E9DC).withValues(alpha: 0.96),
      builder: (dialogContext) => _MonthlyPhotoCarousel(
        title: title,
        photos: photos,
      ),
    );
  }

  Widget _buildFriendDumps() {
    if (_loadingFriends) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFA77C5B)));
    }
    if (_friendDumps.isEmpty) {
      return const Center(
          child: Text('Nenhum amigo compartilhou dumps ainda.',
              textAlign: TextAlign.center));
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72),
      itemCount: _friendDumps.length,
      itemBuilder: (context, index) {
        final dump = _friendDumps[index];
        final cover = dump['capa_url']?.toString();
        final month = int.parse(dump['mes'].toString());
        final photos = (dump['photos'] as List)
            .map((item) => PostModel.fromJson({
                  'id': item['id_foto'],
                  'userId': item['id_usuario'] ?? dump['id_usuario'],
                  'imageUrl': item['midia_url'],
                  'caption': item['legenda'] ?? '',
                  'createdAt': item['data_postagem'] ?? '',
                }))
            .toList();
        return Material(
          color: const Color(0xFFDDD1C2),
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openAlbum(_months[month - 1], photos),
            child: Stack(fit: StackFit.expand, children: [
              if (cover == null || cover.isEmpty)
                const Center(
                    child: Icon(Icons.photo_library_outlined,
                        size: 42, color: Color(0xFFA77C5B)))
              else
                Image.network(cover,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: Color(0xFFDDD1C2))),
              const DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black26)),
              Positioned(
                  left: 12,
                  right: 12,
                  bottom: 14,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_months[month - 1].toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontFamily: 'serif',
                                fontWeight: FontWeight.w700,
                                shadows: [
                                  Shadow(color: Colors.black54, blurRadius: 4)
                                ])),
                        Text(dump['nome']?.toString() ?? 'Amigo',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ])),
            ]),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(children: [
        const TabBar(
          labelColor: Color(0xFF3E3A36),
          unselectedLabelColor: Color(0xFF77716C),
          indicatorColor: Color(0xFFA77C5B),
          tabs: [Tab(text: 'Meus dumps'), Tab(text: 'Dumps de amigos')],
        ),
        Expanded(
            child: TabBarView(children: [
          RefreshIndicator(
            onRefresh: _loadAlbums,
            color: const Color(0xFFA77C5B),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                if (_monthlyAlbums.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 218, 206, 191),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 4,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('O que é um Dump?',
                            style: TextStyle(
                                color: Color(0xFFA77C5B),
                                fontSize: 20,
                                height: 1.2)),
                        SizedBox(height: 10),
                        Text(
                          'O Dump é um álbum criado com as fotos que você publicou. Ele ajuda você a guardar e revisitar suas memórias de forma organizada. Toque em um dump para ver suas memórias do mês.',
                          style: TextStyle(
                              color: Color(0xFF77716C),
                              fontSize: 16,
                              height: 1.15),
                        ),
                      ],
                    ),
                  ),
                if (_loading)
                  const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFA77C5B))))
                else if (_error != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Center(
                          child: Text(_error!,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(color: Color(0xFF77716C)))))
                else if (_monthlyAlbums.isEmpty)
                  const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(
                          child: Text('Você ainda não publicou fotos.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF77716C)))))
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72),
                    itemCount: _monthlyAlbums.length,
                    itemBuilder: (context, index) {
                      final key = _monthlyAlbums.keys.elementAt(index);
                      final photos = _monthlyAlbums[key]!;
                      final title = _albumTitle(key);
                      final coverPhotoId = _coverPhotoIds[key];
                      PostModel? coverPhoto;
                      String cover = '';
                      if (coverPhotoId != null &&
                          coverPhotoId.startsWith('http')) {
                        cover = coverPhotoId;
                      } else {
                        coverPhoto = coverPhotoId == null
                            ? photos.first
                            : photos.cast<PostModel?>().firstWhere(
                                  (photo) => photo?.id == coverPhotoId,
                                  orElse: () => photos.first,
                                );
                        cover = coverPhoto?.imageUrl ?? '';
                      }

                      return Material(
                        color: const Color(0xFFDDD1C2),
                        borderRadius: BorderRadius.circular(18),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _openAlbum(title, photos),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (cover.isEmpty)
                                const Center(
                                  child: Icon(Icons.photo_library_outlined,
                                      size: 42, color: Color(0xFFA77C5B)),
                                )
                              else
                                Image.network(
                                  cover,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.broken_image_outlined,
                                        size: 42, color: Color(0xFFA77C5B)),
                                  ),
                                ),
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.black12, Colors.black45],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Material(
                                  color: Colors.black38,
                                  shape: const CircleBorder(),
                                  child: PopupMenuButton<String>(
                                    tooltip: 'Opções do dump',
                                    color: const Color(0xFF3E3A36),
                                    surfaceTintColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    icon: const Icon(Icons.more_horiz,
                                        color: Colors.white, size: 22),
                                    onSelected: (option) {
                                      if (option == 'edit') {
                                        _editCover(key, photos);
                                      } else if (option == 'visibility') {
                                        _toggleVisibility(key, photos);
                                      }
                                    },
                                    itemBuilder: (menuContext) {
                                      final isVisible =
                                          _visibleToFriends[key] ?? false;
                                      return [
                                        const PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.photo_library_outlined,
                                                  size: 20,
                                                  color: Color(0xFFF3E9DC)),
                                              SizedBox(width: 10),
                                              Text(
                                                'Editar capa',
                                                style: TextStyle(
                                                  color: Color(0xFFF3E9DC),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'visibility',
                                          child: Row(
                                            children: [
                                              Icon(
                                                isVisible
                                                    ? Icons
                                                        .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                size: 20,
                                                color: const Color(0xFFF3E9DC),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                isVisible
                                                    ? 'Ocultar Dump'
                                                    : 'Mostrar para amigos',
                                                style: const TextStyle(
                                                  color: Color(0xFFF3E9DC),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ];
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 12,
                                right: 12,
                                bottom: 14,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _monthName(key),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'serif',
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700,
                                        shadows: [
                                          Shadow(
                                              color: Colors.black54,
                                              blurRadius: 4)
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${photos.length} ${photos.length == 1 ? 'foto' : 'fotos'}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        shadows: [
                                          Shadow(
                                              color: Colors.black54,
                                              blurRadius: 3)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          RefreshIndicator(
              onRefresh: _loadFriendDumps, child: _buildFriendDumps()),
        ])),
      ]),
    );
  }
}

class _MonthlyPhotoCarousel extends StatefulWidget {
  const _MonthlyPhotoCarousel({required this.title, required this.photos});

  final String title;
  final List<PostModel> photos;

  @override
  State<_MonthlyPhotoCarousel> createState() => _MonthlyPhotoCarouselState();
}

class _MonthlyPhotoCarouselState extends State<_MonthlyPhotoCarousel> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _moveTo(int page) {
    if (page < 0 || page >= widget.photos.length) return;
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_currentPage];

    return Dialog.fullscreen(
      backgroundColor: const Color(0xFFF3E9DC),
      child: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.photos.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final url = widget.photos[index].imageUrl;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 72, 16, 110),
                  child: InteractiveViewer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Color(0xFFEADBCB),
                        ),
                        child: Image.network(
                          url,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Color(0xFF895737),
                              size: 64,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            if (widget.photos.length > 1) ...[
              Positioned(
                left: 4,
                top: 0,
                bottom: 72,
                child: Center(
                  child: Opacity(
                    opacity: _currentPage > 0 ? 1 : 0.35,
                    child: IconButton.filledTonal(
                      onPressed: _currentPage > 0
                          ? () => _moveTo(_currentPage - 1)
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFF3E9DC).withValues(alpha: 0.92),
                        foregroundColor: const Color(0xFF895737),
                      ),
                      icon: const Icon(Icons.chevron_left_rounded, size: 32),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 4,
                top: 0,
                bottom: 72,
                child: Center(
                  child: Opacity(
                    opacity: _currentPage < widget.photos.length - 1 ? 1 : 0.35,
                    child: IconButton.filledTonal(
                      onPressed: _currentPage < widget.photos.length - 1
                          ? () => _moveTo(_currentPage + 1)
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFF3E9DC).withValues(alpha: 0.92),
                        foregroundColor: const Color(0xFF895737),
                      ),
                      icon: const Icon(Icons.chevron_right_rounded, size: 32),
                    ),
                  ),
                ),
              ),
            ],
            Positioned(
              top: 0,
              left: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E9DC).withValues(alpha: 0.96),
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFFD7CBBD)),
                  ),
                ),
                child: Row(children: [
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF895737))),
                  const Spacer(),
                  Text(widget.title,
                      style: const TextStyle(
                          color: Color(0xFF895737),
                          fontFamily: 'serif',
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 48),
                ]),
              ),
            ),
            Positioned(
              bottom: 28,
              left: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (photo.caption.isNotEmpty)
                    Text(
                      photo.caption,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF895737),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.photos.length,
                      (index) => Container(
                        width: _currentPage == index ? 18 : 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF895737)
                              : const Color(0xFFD7CBBD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
