import 'package:flutter/material.dart';
import '../services/app_localizations.dart';

class PostarPage extends StatefulWidget {
  const PostarPage({super.key});

  @override
  State<PostarPage> createState() => _PostarPage();
}

class _PostarPage extends State<PostarPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context).post),
    );
  }
}
