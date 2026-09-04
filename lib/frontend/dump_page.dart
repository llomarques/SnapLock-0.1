import 'package:flutter/material.dart';

class DumpPage extends StatefulWidget {
  const DumpPage({super.key});

  @override
  State<DumpPage> createState() => _DumpPage();
}

class _DumpPage extends State<DumpPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Dump"),
    );
  }
}
