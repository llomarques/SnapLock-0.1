import 'package:flutter/material.dart';
import 'package:snaplock/models/post_model.dart';

class DumpPhotoCarousel extends StatefulWidget {
  const DumpPhotoCarousel(
      {super.key, required this.title, required this.photos});

  final String title;
  final List<PostModel> photos;

  @override
  State<DumpPhotoCarousel> createState() => _DumpPhotoCarouselState();
}

class _DumpPhotoCarouselState extends State<DumpPhotoCarousel> {
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

  String _photoDateLabel(String createdAt) {
    final date = DateTime.tryParse(createdAt);
    if (date == null) return 'Memória do mês';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final photoCount = widget.photos.length;

    return Dialog.fullscreen(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: photoCount == 0
            ? _buildEmptyState(context)
            : Stack(
                children: [
                  PageView.builder(
                    controller: _controller,
                    itemCount: photoCount,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final url = widget.photos[index].imageUrl;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 92, 16, 158),
                        child: Center(
                          child: InteractiveViewer(
                            minScale: 1,
                            maxScale: 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(26),
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  border: Border.all(
                                    color: colorScheme.outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                child: Image.network(
                                  url,
                                  fit: BoxFit.contain,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    final totalBytes =
                                        loadingProgress.expectedTotalBytes;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: totalBytes == null
                                            ? null
                                            : loadingProgress
                                                    .cumulativeBytesLoaded /
                                                totalBytes,
                                        color: colorScheme.primary,
                                      ),
                                    );
                                  },
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: colorScheme.primary,
                                      size: 64,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: _buildHeader(context, colorScheme),
                  ),
                  if (photoCount > 1) ...[
                    Positioned(
                      left: 12,
                      top: 0,
                      bottom: 126,
                      child: Center(
                        child: _buildNavigationButton(
                          colorScheme,
                          icon: Icons.chevron_left_rounded,
                          enabled: _currentPage > 0,
                          onPressed: () => _moveTo(_currentPage - 1),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 0,
                      bottom: 126,
                      child: Center(
                        child: _buildNavigationButton(
                          colorScheme,
                          icon: Icons.chevron_right_rounded,
                          enabled: _currentPage < photoCount - 1,
                          onPressed: () => _moveTo(_currentPage + 1),
                        ),
                      ),
                    ),
                  ],
                  Positioned(
                    bottom: 12,
                    left: 16,
                    right: 16,
                    child: _buildPhotoDetails(
                      colorScheme,
                      widget.photos[_currentPage],
                      photoCount,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Fechar álbum',
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest,
              foregroundColor: colorScheme.onSurface,
            ),
            icon: const Icon(Icons.close_rounded),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'MEMÓRIAS DO MÊS',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontFamily: 'serif',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
    ColorScheme colorScheme, {
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return IconButton.filledTonal(
      onPressed: enabled ? onPressed : null,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.94),
        foregroundColor: colorScheme.primary,
        disabledBackgroundColor: colorScheme.surface.withValues(alpha: 0.56),
        disabledForegroundColor:
            colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        minimumSize: const Size(44, 44),
      ),
      icon: Icon(icon, size: 28),
    );
  }

  Widget _buildPhotoDetails(
    ColorScheme colorScheme,
    PostModel photo,
    int photoCount,
  ) {
    final progress = (_currentPage + 1) / photoCount;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _photoDateLabel(photo.createdAt),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'FOTO ${_currentPage + 1} DE $photoCount',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          if (photo.caption.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(
              photo.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: IconButton(
              tooltip: 'Fechar álbum',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  color: colorScheme.primary,
                  size: 56,
                ),
                const SizedBox(height: 16),
                Text(
                  'Este álbum ainda não tem fotos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
