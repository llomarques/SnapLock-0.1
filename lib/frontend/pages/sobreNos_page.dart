import 'package:flutter/material.dart';

class SobreNosPage extends StatelessWidget {
  const SobreNosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E9DC),
      appBar: AppBar(
        title: const Text('Sobre nós'),
        backgroundColor: const Color(0xFFF3E9DC),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          margin: EdgeInsets.zero,
          color: const Color(0xFFFFFBF7),
          elevation: 3,
          shadowColor: const Color(0xFF895737).withValues(alpha: 0.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: Color(0xFFD7CBBD),
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Text(
              '''Sobre o SnapLock 

Memórias que ficam entre quem importa.

O SnapLock é uma rede social privada criada para compartilhar momentos especiais com pessoas de confiança.

Acreditamos que suas memórias não precisam ser expostas para todo mundo. Por isso, o SnapLock foi pensado para oferecer um espaço mais privado, seguro e tranquilo, onde você decide quem pode fazer parte dos seus momentos.

Nossa missão

Criar uma experiência de compartilhamento mais íntima e consciente, colocando privacidade, segurança e conexões reais em primeiro lugar.

O que torna o SnapLock diferente?

Privacidade em primeiro lugar
Suas publicações são compartilhadas apenas com pessoas que você aprovou.

Conexões de confiança
Você decide quem pode fazer parte do seu círculo de amigos.

Interações positivas
Reações simples e positivas para valorizar os momentos sem transformar a experiência em uma competição.

Ambiente mais seguro
Recursos de denúncia e moderação ajudam a manter a comunidade mais respeitosa.

Suas memórias organizadas
O recurso Dump reúne momentos para você reviver suas lembranças de forma especial.

Nossa visão

Construir uma rede social onde compartilhar não significa se expor, e onde cada memória possa ser vivida e guardada com mais segurança.

SnapLock

For You Only!

Versão do aplicativo: 1.0.0
Desenvolvido com carinho pela equipe CyberSisters.

contato: 
snaplock.support@gmail.com

© 2026 SnapLock. Todos os direitos reservados.''',
              style: const TextStyle(
                color: Color(0xFF3E3A36),
                fontSize: 15,
                height: 1.55,
              ),
            ),
          ),
        ),
      ),
    );
  }
}