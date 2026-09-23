import 'package:flutter/material.dart';
import '../../services/app_localizations.dart';

class DumpPage extends StatefulWidget {
  const DumpPage({super.key});

  @override
  State<DumpPage> createState() => _DumpPage();
}

class _DumpPage extends State<DumpPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context).dump),
    );
  }
}
