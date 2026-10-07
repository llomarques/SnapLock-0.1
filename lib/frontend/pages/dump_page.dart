import 'package:flutter/material.dart';

class DumpPage extends StatefulWidget {
  const DumpPage({super.key});

  @override
  State<DumpPage> createState() => _DumpPage();
}

class _DumpPage extends State<DumpPage> {
  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 16),
        child: SizedBox(
          width: 305,
          height: 187,
          child: Card(
            color: Color.fromARGB(255, 218, 206, 191),
            margin: EdgeInsets.zero,
            elevation: 2,
            shadowColor: Color(0x33000000),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'O que é um Dump?',
                    style: TextStyle(
                      color: Color(0xFFA77C5B),
                      fontSize: 20,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'O Dump é um álbum criado com as fotos que você publicou. Ele ajuda você a guardar e revisitar suas memórias de forma organizada.',
                    style: TextStyle(
                      color: Color(0xFF77716C),
                      fontSize: 16,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
