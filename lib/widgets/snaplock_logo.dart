import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SnapLockLogo extends StatelessWidget {
  final double size;

  const SnapLockLogo({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.surfaceLight,
        border: Border.all(color: AppTheme.mediumBrown.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkBrown.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Borda sutil em leque interno
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.cardBorder, width: 1),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SnapLock',
                style: GoogleFonts.cormorantGaramond(
                  color: AppTheme.textPrimary,
                  fontSize: size * 0.19,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_rate_rounded, size: size * 0.09, color: AppTheme.mediumBrown),
                  const SizedBox(width: 2),
                  Text(
                    'FOR YOU ONLY',
                    style: GoogleFonts.cormorantGaramond(
                      color: AppTheme.textSecondary,
                      fontSize: size * 0.085,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.star_rate_rounded, size: size * 0.09, color: AppTheme.mediumBrown),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
