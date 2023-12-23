import 'package:flutter/material.dart';

class MarkdownEditor extends StatelessWidget {
  final TextEditingController controller;

  const MarkdownEditor(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Type here...',
      ),
    );
  }
}
