import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class DumpsScreen extends StatefulWidget {
  const DumpsScreen({super.key});

  @override
  State<DumpsScreen> createState() => _DumpsScreenState();
}

class _DumpsScreenState extends State<DumpsScreen> {
  List<Map<String, dynamic>> _dumps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDumps();
  }

  Future<void> _loadDumps() async {
    setState(() => _isLoading = true);
    try {
      final dumps = await ApiService.getMonthlyDumps();
      setState(() {
        _dumps = dumps;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _triggerDump() async {
    try {
      final res = await ApiService.generateMonthlyDump();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dump gerado com sucesso! Total de fotos no período: ${res['postCount']}')),
        );
      }
      _loadDumps();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Galeria Dump', style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.darkBrown))
          : RefreshIndicator(
              onRefresh: _loadDumps,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Explicativo Oficial do Figma: "O que é um Dump?"
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.help_outline, color: AppTheme.darkBrown, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'O que é um Dump?',
                                style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'O Dump é um álbum criado com as fotos que você publicou no mês, de forma que você guarde e controle suas memórias de forma organizada (RN15). A geração ocorre no último dia do mês às 23:59.',
                            style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkBrown),
                            icon: const Icon(Icons.flash_on, color: Colors.white, size: 16),
                            label: Text('Gerar Dump do Mês Atual', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                            onPressed: _triggerDump,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'Álbuns de Dumps Mensais',
                      style: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 12),

                    _dumps.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'Nenhum Dump gerado ainda no sistema.',
                                style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                              ),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: _dumps.length,
                            itemBuilder: (context, index) {
                              final dump = _dumps[index];
                              final month = dump['month'];
                              final year = dump['year'];
                              final postCount = dump['postCount'];

                              return Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.cardBorder),
                                ),
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.surfaceLight,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.collections_bookmark, color: AppTheme.darkBrown, size: 32),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Dump $month/$year',
                                      style: GoogleFonts.cormorantGaramond(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$postCount fotos salvas',
                                      style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
                                    ),
                                  ],
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
}
