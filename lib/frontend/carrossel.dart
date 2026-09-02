import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarrosselDeInformacoes extends StatefulWidget {
  const CarrosselDeInformacoes({super.key});

  static const listaDeTexto = [
    'Em um clique, guarde memórias',
    'Aqui a sua privacidade é preservada',
    'Curta as fotos dos seus amigos',
    'Faça login ou crie sua conta para continuar'
  ];

  @override
  State<CarrosselDeInformacoes> createState() => _CarrosselDeInformacoesState();
}

class _CarrosselDeInformacoesState extends State<CarrosselDeInformacoes> {
  int paginaAtual = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 76,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            autoPlayInterval: const Duration(seconds: 3),
            onPageChanged: (index, reason) {
              setState(() => paginaAtual = index);
            },
          ),
          items: CarrosselDeInformacoes.listaDeTexto.map((itemText) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    itemText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF3E3A36),
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
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
            CarrosselDeInformacoes.listaDeTexto.length,
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
