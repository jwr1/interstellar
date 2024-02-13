import 'package:flutter/material.dart';

class TextEditor extends StatelessWidget {
  final TextEditingController controller;
  final bool isMarkdown;
  final TextInputType? keyboardType;
  final String? label;
  final String? hint;
  final void Function(String)? onChanged;
  final bool? enabled;

  const TextEditor(
    this.controller, {
    this.isMarkdown = false,
    this.keyboardType,
    this.label,
    this.hint,
    this.onChanged,
    this.enabled,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType:
          keyboardType ?? (isMarkdown ? TextInputType.multiline : null),
      minLines: isMarkdown ? 2 : null,
      maxLines: isMarkdown ? null : 1,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        label: label != null ? Text(label!) : null,
        hintText: hint ?? (isMarkdown ? 'Markdown here...' : null),
      ),
      onChanged: onChanged,
      enabled: enabled,
    );
  }
}
