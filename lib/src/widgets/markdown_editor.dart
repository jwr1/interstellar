import 'package:flutter/material.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/markdown.dart';
import 'package:provider/provider.dart';

class MarkdownEditor extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final bool? enabled;
  final String? label;
  final String? originInstance;

  const MarkdownEditor(
    this.controller, {
    this.originInstance,
    this.onChanged,
    this.enabled,
    this.label,
    super.key,
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  final _buttonStyle = TextButton.styleFrom(
    shape: const LinearBorder(),
  );
  final _textButtonStyle = TextButton.styleFrom(
    shape: const LinearBorder(),
    padding: const EdgeInsets.all(16),
  );
  final _textFocusNode = FocusNode();

  bool enablePreview = false;

  void execAction(_MarkdownEditorActionBase action) {
    _textFocusNode.requestFocus();

    final input = _MarkdownEditorData(
      text: widget.controller.text,
      selectionStart: widget.controller.selection.start,
      selectionEnd: widget.controller.selection.end,
    );
    final output = action.run(input);

    widget.controller.text = output.text;
    widget.controller.selection = widget.controller.selection.copyWith(
      baseOffset: output.selectionStart,
      extentOffset: output.selectionEnd,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 2),
            child: Text(widget.label!),
          ),
        Card.outlined(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                children: [
                  TextButton.icon(
                    label: Text(enablePreview ? 'Edit' : 'Preview'),
                    icon: Icon(enablePreview ? Icons.edit : Icons.preview),
                    onPressed: () {
                      _textFocusNode.requestFocus();

                      setState(() {
                        enablePreview = !enablePreview;
                      });
                    },
                    style: _textButtonStyle,
                  ),
                  if (!enablePreview) ...[
                    IconButton(
                      icon: const Icon(Icons.title),
                      onPressed: () =>
                          execAction(_MarkdownEditorActions.heading),
                      style: _buttonStyle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.format_bold),
                      onPressed: () => execAction(_MarkdownEditorActions.bold),
                      style: _buttonStyle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.format_italic),
                      onPressed: () =>
                          execAction(_MarkdownEditorActions.italic),
                      style: _buttonStyle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.format_quote),
                      onPressed: () => execAction(_MarkdownEditorActions.quote),
                      style: _buttonStyle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.code),
                      onPressed: () =>
                          execAction(_MarkdownEditorActions.inlineCode),
                      style: _buttonStyle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.link),
                      onPressed: () => execAction(_MarkdownEditorActions.link),
                      style: _buttonStyle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.horizontal_rule),
                      onPressed: () =>
                          execAction(_MarkdownEditorActions.divider),
                      style: _buttonStyle,
                    ),
                  ]
                ],
              ),
              const Divider(height: 1, thickness: 1),
              enablePreview
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Markdown(
                          widget.controller.text,
                          widget.originInstance ??
                              context.watch<SettingsController>().instanceHost),
                    )
                  : TextField(
                      controller: widget.controller,
                      keyboardType: TextInputType.multiline,
                      minLines: 2,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                      onChanged: widget.onChanged,
                      enabled: widget.enabled,
                      focusNode: _textFocusNode,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MarkdownEditorActions {
  static final heading = _MarkdownEditorActionBlock('### ');
  static final bold = _MarkdownEditorActionInline('**');
  static final italic = _MarkdownEditorActionInline('_');
  static final quote = _MarkdownEditorActionBlock('> ');
  static final inlineCode = _MarkdownEditorActionInline('`');
  static final link = _MarkdownEditorActionLink();
  static final divider = _MarkdownEditorActionDivider();
}

abstract class _MarkdownEditorActionBase {
  _MarkdownEditorData run(_MarkdownEditorData input);

  _MarkdownEditorData getCurrentLine(_MarkdownEditorData input) {
    final lineEnd = input.text.indexOf('\n', input.selectionStart);
    final lineStart = input.text.lastIndexOf('\n', input.selectionStart);

    final selectionEnd = lineEnd == -1 ? input.text.length : lineEnd;
    final selectionStart = lineStart == -1
        ? 0
        : (selectionEnd >= lineStart + 1 ? lineStart + 1 : lineStart);

    return _MarkdownEditorData(
      text: input.text,
      selectionStart: selectionStart,
      selectionEnd: selectionEnd,
    );
  }
}

class _MarkdownEditorData {
  String text;
  int selectionStart;
  int selectionEnd;
  String selectionText;

  _MarkdownEditorData({
    required this.text,
    required this.selectionStart,
    required this.selectionEnd,
  }) : selectionText = text.substring(selectionStart, selectionEnd);

  @override
  String toString() {
    return 'MarkdownEditorData(selectionStart: $selectionStart, selectionEnd: $selectionEnd, selectionText: "$selectionText")';
  }
}

class _MarkdownEditorActionInline extends _MarkdownEditorActionBase {
  final String startChars;
  final String endChars;

  _MarkdownEditorActionInline(this.startChars, [String? endChars])
      : endChars = endChars ?? startChars;

  @override
  _MarkdownEditorData run(_MarkdownEditorData input) {
    var text = input.text;

    final contextStart = input.selectionStart - startChars.length;
    final contextEnd = input.selectionEnd + endChars.length;
    if (contextStart >= 0 &&
        contextEnd <= text.length &&
        text.substring(contextStart, contextEnd).startsWith(startChars) &&
        text.substring(contextStart, contextEnd).endsWith(endChars)) {
      text = text.replaceRange(input.selectionEnd, contextEnd, '');
      text = text.replaceRange(contextStart, input.selectionStart, '');
      return _MarkdownEditorData(
        text: text,
        selectionStart: input.selectionStart - startChars.length,
        selectionEnd: input.selectionEnd - startChars.length,
      );
    } else {
      text =
          text.replaceRange(input.selectionEnd, input.selectionEnd, endChars);
      text = text.replaceRange(
          input.selectionStart, input.selectionStart, startChars);
      return _MarkdownEditorData(
        text: text,
        selectionStart: input.selectionStart + startChars.length,
        selectionEnd: input.selectionEnd + startChars.length,
      );
    }
  }
}

class _MarkdownEditorActionBlock extends _MarkdownEditorActionBase {
  final String startChars;
  final String endChars;

  // ignore: unused_element
  _MarkdownEditorActionBlock(this.startChars, [this.endChars = '']);

  @override
  _MarkdownEditorData run(_MarkdownEditorData input) {
    var text = input.text;

    _MarkdownEditorData line = getCurrentLine(input);

    if (line.selectionText.startsWith(startChars) &&
        line.selectionText.endsWith(endChars)) {
      text = text.replaceRange(
          line.selectionEnd - endChars.length, line.selectionEnd, '');
      text = text.replaceRange(
          line.selectionStart, line.selectionStart + startChars.length, '');
      return _MarkdownEditorData(
        text: text,
        selectionStart: input.selectionStart - startChars.length,
        selectionEnd: input.selectionEnd - startChars.length,
      );
    } else {
      text = text.replaceRange(line.selectionEnd, line.selectionEnd, endChars);
      text = text.replaceRange(
          line.selectionStart, line.selectionStart, startChars);
      return _MarkdownEditorData(
        text: text,
        selectionStart: input.selectionStart + startChars.length,
        selectionEnd: input.selectionEnd + startChars.length,
      );
    }
  }
}

class _MarkdownEditorActionLink extends _MarkdownEditorActionBase {
  _MarkdownEditorActionLink();

  @override
  _MarkdownEditorData run(_MarkdownEditorData input) {
    var text = input.text;

    if (input.selectionText.isEmpty) {
      text = text.replaceRange(
          input.selectionStart, input.selectionStart, '[text](url)');

      return _MarkdownEditorData(
        text: text,
        selectionStart: input.selectionStart + 7,
        selectionEnd: input.selectionStart + 10,
      );
    }

    if (isValidUrl(input.selectionText)) {
      text = text.replaceRange(input.selectionEnd, input.selectionEnd, ')');
      text = text.replaceRange(
          input.selectionStart, input.selectionStart, '[text](');

      return _MarkdownEditorData(
        text: text,
        selectionStart: input.selectionStart + 1,
        selectionEnd: input.selectionStart + 5,
      );
    } else {
      text =
          text.replaceRange(input.selectionEnd, input.selectionEnd, '](url)');
      text = text.replaceRange(input.selectionStart, input.selectionStart, '[');

      return _MarkdownEditorData(
        text: text,
        selectionStart: input.selectionEnd + 3,
        selectionEnd: input.selectionEnd + 6,
      );
    }
  }
}

class _MarkdownEditorActionDivider extends _MarkdownEditorActionBase {
  _MarkdownEditorActionDivider();

  @override
  _MarkdownEditorData run(_MarkdownEditorData input) {
    var text = input.text;

    int prefixNewlines = 2;
    if (input.selectionStart - 1 >= 0 &&
        text[input.selectionStart - 1] == '\n') {
      prefixNewlines--;

      if (input.selectionStart - 2 >= 0 &&
          text[input.selectionStart - 2] == '\n') {
        prefixNewlines--;
      }
    }

    int suffixNewlines = 2;
    if (input.selectionStart < text.length &&
        text[input.selectionStart] == '\n') {
      suffixNewlines--;

      if (input.selectionStart + 1 < text.length &&
          text[input.selectionStart + 1] == '\n') {
        suffixNewlines--;
      }
    }

    final newText = '${'\n' * prefixNewlines}---${'\n' * suffixNewlines}';

    text =
        text.replaceRange(input.selectionStart, input.selectionStart, newText);

    return _MarkdownEditorData(
      text: text,
      selectionStart: input.selectionStart + newText.length,
      selectionEnd: input.selectionEnd + newText.length,
    );
  }
}
