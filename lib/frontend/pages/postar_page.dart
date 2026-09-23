import 'package:flutter/material.dart';

class PostarPage extends StatefulWidget {
  const PostarPage({super.key});

  @override
  State<PostarPage> createState() => _PostarPage();
}

class _PostarPage extends State<PostarPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: const Text('Postar'),
    );
  }
}
