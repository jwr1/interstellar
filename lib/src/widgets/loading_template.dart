import 'package:flutter/material.dart';

class LoadingTemplate extends StatelessWidget {
  final Widget? title;

  const LoadingTemplate({this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: title),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
