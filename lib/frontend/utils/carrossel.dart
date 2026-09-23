import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:snaplock/theme/app_fonts.dart';
import 'package:snaplock/services/app_localizations.dart';

class CarrosselDeInformacoes extends StatefulWidget {
  const CarrosselDeInformacoes({super.key});

  @override
  State<CarrosselDeInformacoes> createState() => _CarrosselDeInformacoesState();
}

class _CarrosselDeInformacoesState extends State<CarrosselDeInformacoes> {
  int paginaAtual = 0;

  @override
  Widget build(BuildContext context) {
    final listaDeTexto = [
      AppLocalizations.of(context).saveMemories,
      AppLocalizations.of(context).privacyPreserved,
      AppLocalizations.of(context).enjoyFriendsPhotos,
      AppLocalizations.of(context).continueLogin,
    ];
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 76,
            autoPlay: true,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            aspectRatio: 16 / 9,
            autoPlayInterval: const Duration(seconds: 3),
            onPageChanged: (index, reason) {
              setState(() => paginaAtual = index);
            },
          ),
          items: listaDeTexto.map((itemText) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    itemText,
                    textAlign: TextAlign.center,
                    style: AppFonts.poppinsRegular.copyWith(
                      color: Color(0xFF3E3A36),
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            listaDeTexto.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: paginaAtual == index ? 18 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: paginaAtual == index
                    ? const Color(0xFF895737)
                    : const Color(0xFFB9A18E),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 0),
      ],
    );
  }
}
