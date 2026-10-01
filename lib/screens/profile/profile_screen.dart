import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/api_config.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  List<PostModel> _gallery = [];
  List<UserModel> _friends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final gallery = await ApiService.getMyGallery();
      final friends = await ApiService.getFriends();
      setState(() {
        _user = ApiService.currentUser;
        _gallery = gallery;
        _friends = friends;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _showEditProfileDialog() {
    if (_user == null) return;
    final nameCtrl = TextEditingController(text: _user!.name);
    final bioCtrl = TextEditingController(text: _user!.bio);
    final genderCtrl = TextEditingController(text: _user!.gender);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Editar perfil (RF06)', style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold, fontSize: 22)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: nameCtrl,
                  label: 'Nome de Exibição',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: bioCtrl,
                  label: 'Biografia',
                  prefixIcon: Icons.description_outlined,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: genderCtrl,
                  label: 'Gênero',
                  prefixIcon: Icons.wc_outlined,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkBrown),
              onPressed: isSaving
                  ? null
                  : () async {
                      setDialogState(() => isSaving = true);
                      try {
                        final updated = await ApiService.updateProfile(
                          name: nameCtrl.text.trim(),
                          bio: bioCtrl.text.trim(),
                          gender: genderCtrl.text.trim(),
                        );
                        setState(() => _user = updated);
                        if (context.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        setDialogState(() => isSaving = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                          );
                        }
                      }
                    },
              child: isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Salvar', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Alterar senha (RN14)', style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold, fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: currentPassCtrl,
              label: 'Senha Atual',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: newPassCtrl,
              label: 'Nova Senha (RN07)',
              prefixIcon: Icons.lock_reset_outlined,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkBrown),
            onPressed: () async {
              try {
                await ApiService.changePassword(
                  currentPassCtrl.text,
                  newPassCtrl.text,
                );
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Senha alterada com sucesso!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                  );
                }
              }
            },
            child: Text('Alterar Senha', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Excluir conta (RN10)', style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold, color: AppTheme.danger)),
        content: Text(
          'Caso opte por excluir sua conta, todas as suas fotos serão removidas permanentemente do aplicativo (RN10).',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () async {
              try {
                await ApiService.deleteAccount();
                if (context.mounted) Navigator.pop(ctx);
                widget.onLogout();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                  );
                }
              }
            },
            child: Text('Excluir Conta', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _user ??= ApiService.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Perfil', style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textPrimary),
            onPressed: () {
              _showSettingsModal();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.darkBrown))
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Layout de Perfil do Figma (39 Amigos • Foto Perfil • 74 Memórias)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCounterItem(_friends.length.toString(), 'Amigos'),
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: AppTheme.darkBrown,
                                child: Text(
                                  (_user?.name ?? 'U')[0].toUpperCase(),
                                  style: GoogleFonts.cormorantGaramond(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              _buildCounterItem(_gallery.length.toString(), 'Memórias'),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _user?.name ?? 'Usuário SnapLock',
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          Text(
                            _user?.email ?? '',
                            style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                          if ((_user?.bio ?? '').isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _user!.bio,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 12),
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkBrown),
                                  icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                                  label: Text('Editar perfil', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
                                  onPressed: _showEditProfileDialog,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Grid de Fotos das Memórias
                    _gallery.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              'Você ainda não postou nenhuma memória.',
                              style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            itemCount: _gallery.length,
                            itemBuilder: (context, index) {
                              final post = _gallery[index];
                              final imageUrl = post.imageUrl.startsWith('http')
                                  ? post.imageUrl
                                  : '${ApiConfig.mediaBaseUrl}${post.imageUrl}';

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                    color: AppTheme.surfaceLight,
                                    child: const Icon(Icons.image, color: AppTheme.textSecondary),
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configurações', style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock_reset, color: AppTheme.darkBrown),
              title: Text('Alterar senha (RN14)', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(ctx);
                _showChangePasswordDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.mediumBrown),
              title: Text('Sair da conta', style: GoogleFonts.poppins()),
              onTap: () async {
                Navigator.pop(ctx);
                await ApiService.logout();
                widget.onLogout();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppTheme.danger),
              title: Text('Excluir conta (RN10)', style: GoogleFonts.poppins(color: AppTheme.danger)),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteAccountDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}
