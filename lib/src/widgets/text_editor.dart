import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextEditor extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? label;
  final String? hint;
  final void Function(String)? onChanged;
  final bool? enabled;
  final int? maxLength;

  const TextEditor(
    this.controller, {
    this.keyboardType,
    this.label,
    this.hint,
    this.onChanged,
    this.enabled,
    this.maxLength,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        label: label != null ? Text(label!) : null,
        hintText: hint,
      ),
      onChanged: onChanged,
      enabled: enabled,
      maxLength: maxLength,
    );
  }
}
