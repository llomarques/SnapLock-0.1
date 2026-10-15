import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashedBorderButton extends StatelessWidget {
  final String text;
  final IconData icon;

  const DashedBorderButton({
    super.key,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFD7CBBD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            margin: const EdgeInsets.only(left: 8, right: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFE85A47),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
          ),
          Expanded(
            child: const Text(
              'Deletar conta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2F211C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeletarPage extends StatelessWidget {
  const DeletarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E9DC),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 430,
            color: const Color(0xFFF3E9DC),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Image.asset(
                  'assets/images/logo.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 18),
                DashedBorderButton(
                  text: 'Deletar conta',
                  icon: Icons.delete_outline,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 300,
                  child: Text(
                    'Sentiremos sua falta!\n\nAtenção: ao excluir sua conta, todos os seus dados serão apagados de forma definitiva e irreversível. Não será possível recuperar suas informações depois.\n\nCaso queira apenas se desconectar por um tempo, você pode escolher sair da conta e voltar quando quiser.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      height: 1.45,
                      color: const Color(0xFF2F211C),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: 250,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8D5C3B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Voltar',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {},
                  style: const ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(Size.zero),
                    padding: WidgetStatePropertyAll(EdgeInsets.zero),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Continuar',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2F211C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}