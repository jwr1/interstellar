import 'package:flutter/material.dart';

class MarkdownEditor extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;

  const MarkdownEditor(this.controller, {this.hintText, super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hintText ?? 'Type here...',
      ),
    );
  }
}
