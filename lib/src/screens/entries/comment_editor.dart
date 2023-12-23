import 'package:flutter/material.dart';

class CommentEditor extends StatefulWidget {
  final String? initValue;
  final Function(String) onSave;

  const CommentEditor({super.key, this.initValue, required this.onSave});

  @override
  State<CommentEditor> createState() => _CommentEditorState();
}

class _CommentEditorState extends State<CommentEditor> {
  final textController = TextEditingController();

  @override
  void initState() {
    if (widget.initValue != null) {
      setState(() {
        textController.text = widget.initValue ?? '';
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: textController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), hintText: 'Type comment here...'),
        ),
        Row(
          children: [
            const Spacer(),
            FilledButton(
                onPressed: () {
                  widget.onSave(textController.text);
                },
                child: const Text('Save'))
          ],
        )
      ],
    );
  }
}
