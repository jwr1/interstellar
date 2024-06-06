import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:provider/provider.dart';

import './markdown.dart';

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
  final _focusNodeTextField = FocusNode();
  final _focusNodePreviewButton = FocusNode();

  bool enablePreview = false;

  final togglePreviewShortcut =
      const SingleActivator(LogicalKeyboardKey.space, control: true);
  void togglePreview() {
    setState(() {
      enablePreview = !enablePreview;

      (enablePreview ? _focusNodePreviewButton : _focusNodeTextField)
          .requestFocus();
    });
  }

  void execAction(_MarkdownEditorActionBase action) {
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
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: enablePreview
                          ? null
                          : Border(
                              right: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant),
                            ),
                    ),
                    child: Tooltip(
                      message: readableShortcut(togglePreviewShortcut),
                      child: CallbackShortcuts(
                        bindings: <ShortcutActivator, VoidCallback>{
                          togglePreviewShortcut: togglePreview,
                        },
                        child: SizedBox(
                          height: 40,
                          child: TextButton.icon(
                            label: Text(enablePreview ? 'Edit' : 'Preview'),
                            icon: Icon(
                                enablePreview ? Icons.edit : Icons.preview),
                            onPressed: togglePreview,
                            style: TextButton.styleFrom(
                                shape: const LinearBorder()),
                            focusNode: _focusNodePreviewButton,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!enablePreview)
                    ..._actions.map(
                      (action) => DecoratedBox(
                        decoration: BoxDecoration(
                          border: action.showDivider
                              ? Border(
                                  right: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant),
                                )
                              : null,
                        ),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: IconButton(
                            onPressed: () {
                              _focusNodeTextField.requestFocus();

                              execAction(action.action);
                            },
                            icon: Icon(action.icon),
                            tooltip: action.tooltip +
                                (action.shortcut == null
                                    ? ''
                                    : ' (${readableShortcut(action.shortcut!)})'),
                            style: TextButton.styleFrom(
                                shape: const LinearBorder()),
                          ),
                        ),
                      ),
                    ),
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
                  : CallbackShortcuts(
                      bindings: <ShortcutActivator, VoidCallback>{
                        togglePreviewShortcut: togglePreview,
                        const SingleActivator(LogicalKeyboardKey.enter): () =>
                            execAction(const _MarkdownEditorActionEnter()),
                        for (var action in _actions
                            .where((action) => action.shortcut != null))
                          action.shortcut!: () => execAction(action.action)
                      },
                      child: TextField(
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
                        focusNode: _focusNodeTextField,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

const List<_MarkdownEditorActionInfo> _actions = [
  _MarkdownEditorActionInfo(
    action: _MarkdownEditorActionBlock('### '),
    icon: Icons.title,
    tooltip: 'Heading',
    shortcut: SingleActivator(LogicalKeyboardKey.keyH, control: true),
    showDivider: true,
  ),
  _MarkdownEditorActionInfo(
    action: _MarkdownEditorActionInline('**'),
    icon: Icons.format_bold,
    tooltip: 'Bold',
    shortcut: SingleActivator(LogicalKeyboardKey.keyB, control: true),
  ),
  _MarkdownEditorActionInfo(
    action: _MarkdownEditorActionInline('_'),
    icon: Icons.format_italic,
    tooltip: 'Italic',
    shortcut: SingleActivator(LogicalKeyboardKey.keyI, control: true),
  ),
  _MarkdownEditorActionInfo(
    action: _MarkdownEditorActionInline('~~'),
    icon: Icons.strikethrough_s,
    tooltip: 'Strikethrough',
    shortcut:
        SingleActivator(LogicalKeyboardKey.keyX, control: true, alt: true),
    showDivider: true,
  ),
  _MarkdownEditorActionInfo(
    action: _MarkdownEditorActionInline('`'),
    icon: Icons.code,
    tooltip: 'Inline Code',
    shortcut: SingleActivator(LogicalKeyboardKey.keyE, control: true),
  ),
  _MarkdownEditorActionInfo(
    action: _MarkdownEditorActionInline('\n```\n'),
    icon: Icons.segment,
    tooltip: 'Code Block',
    shortcut:
        SingleActivator(LogicalKeyboardKey.keyE, control: true, alt: true),
    showDivider: true,
  ),
  _MarkdownEditorActionInfo(
    action: _MarkdownEditorActionLink(),
    icon: Icons.link,
    tooltip: 'Link',
    shortcut: SingleActivator(LogicalKeyboardKey.keyK, control: true),
  ),
  _MarkdownEditorActionInfo(
    action: _MarkdownEditorActionLink(isImage: true),
    icon: Icons.image,
    tooltip: 'Image',
    shortcut:
        SingleActivator(LogicalKeyboardKey.keyK, control: true, alt: true),
    showDivider: true,
  ),
  _MarkdownEditorActionInfo(
    action: _MarkdownEditorActionInline('~'),
    icon: Icons.subscript,
    tooltip: 'Subscript',
    shortcut: SingleActivator(LogicalKeyboardKey.comma, control: true),
  ),
  _MarkdownEditorActionInfo(
    action: _MarkdownEditorActionInline('^'),
    icon: Icons.superscript,
    tooltip: 'Superscript',
    shortcut: SingleActivator(LogicalKeyboardKey.period, control: true),
    showDivider: true,
  ),
  _MarkdownEditorActionInfo(
    action: _MarkdownEditorActionBlock('> '),
    icon: Icons.format_quote,
    tooltip: 'Quote',
    shortcut:
        SingleActivator(LogicalKeyboardKey.keyQ, control: true, alt: true),
  ),
  _MarkdownEditorActionInfo(
    action: _MarkdownEditorActionHorizontalRule(),
    icon: Icons.horizontal_rule,
    tooltip: 'Horizontal Rule',
    shortcut:
        SingleActivator(LogicalKeyboardKey.keyH, control: true, alt: true),
    showDivider: true,
  ),
  _MarkdownEditorActionInfo(
    action: _MarkdownEditorActionBlock('- '),
    icon: Icons.format_list_bulleted,
    tooltip: 'Bulleted List',
    shortcut: SingleActivator(LogicalKeyboardKey.keyL, control: true),
  ),
  _MarkdownEditorActionInfo(
    action: _MarkdownEditorActionBlock('1. '),
    icon: Icons.format_list_numbered,
    tooltip: 'Numbered List',
    shortcut:
        SingleActivator(LogicalKeyboardKey.keyL, control: true, alt: true),
    showDivider: true,
  ),
  _MarkdownEditorActionInfo(
    action:
        _MarkdownEditorActionBlock('\n::: spoiler PREVIEW_HERE\n', '\n:::\n'),
    icon: Icons.warning,
    tooltip: 'Spoiler',
    shortcut:
        SingleActivator(LogicalKeyboardKey.keyS, control: true, alt: true),
    showDivider: true,
  ),
];

class _MarkdownEditorActionInfo {
  final _MarkdownEditorActionBase action;
  final IconData icon;
  final String tooltip;
  final SingleActivator? shortcut;
  final bool showDivider;

  const _MarkdownEditorActionInfo({
    required this.action,
    required this.icon,
    required this.tooltip,
    this.shortcut,
    this.showDivider = false,
  });
}

abstract class _MarkdownEditorActionBase {
  const _MarkdownEditorActionBase();

  _MarkdownEditorData run(_MarkdownEditorData input);

  _MarkdownEditorData getCurrentLine(_MarkdownEditorData input) {
    final endIndex = input.text.indexOf('\n', input.selectionStart);
    final startIndex = input.selectionStart == 0
        ? -1
        : input.text.lastIndexOf('\n', input.selectionStart - 1);

    final lineEnd = endIndex == -1 ? input.text.length : endIndex;
    final lineStart = startIndex == -1
        ? 0
        : (lineEnd >= startIndex + 1 ? startIndex + 1 : startIndex);

    return _MarkdownEditorData(
      text: input.text,
      selectionStart: lineStart,
      selectionEnd: lineEnd,
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

  const _MarkdownEditorActionInline(this.startChars, [String? endChars])
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
  const _MarkdownEditorActionBlock(this.startChars, [this.endChars = '']);

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
  final bool isImage;

  const _MarkdownEditorActionLink({this.isImage = false});

  @override
  _MarkdownEditorData run(_MarkdownEditorData input) {
    final imageStartChar = isImage ? '!' : '';

    final helpMessage = isImage ? 'altr' : 'text';

    var text = input.text;

    if (input.selectionText.isEmpty) {
      text = text.replaceRange(input.selectionStart, input.selectionStart,
          '$imageStartChar[$helpMessage](url)');

      return _MarkdownEditorData(
        text: text,
        selectionStart: input.selectionStart + 7 + imageStartChar.length,
        selectionEnd: input.selectionStart + 10 + imageStartChar.length,
      );
    }

    if (isValidUrl(input.selectionText)) {
      text = text.replaceRange(input.selectionEnd, input.selectionEnd, ')');
      text = text.replaceRange(input.selectionStart, input.selectionStart,
          '$imageStartChar[$helpMessage](');

      return _MarkdownEditorData(
        text: text,
        selectionStart: input.selectionStart + 1 + imageStartChar.length,
        selectionEnd: input.selectionStart + 5 + imageStartChar.length,
      );
    } else {
      text =
          text.replaceRange(input.selectionEnd, input.selectionEnd, '](url)');
      text = text.replaceRange(
          input.selectionStart, input.selectionStart, '$imageStartChar[');

      return _MarkdownEditorData(
        text: text,
        selectionStart: input.selectionEnd + 3 + imageStartChar.length,
        selectionEnd: input.selectionEnd + 6 + imageStartChar.length,
      );
    }
  }
}

class _MarkdownEditorActionHorizontalRule extends _MarkdownEditorActionBase {
  const _MarkdownEditorActionHorizontalRule();

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

class _MarkdownEditorActionEnter extends _MarkdownEditorActionBase {
  const _MarkdownEditorActionEnter();

  @override
  _MarkdownEditorData run(_MarkdownEditorData input) {
    var text = input.text;

    final line = getCurrentLine(input);

    // Bulleted list
    if (line.selectionText.startsWith('- ') ||
        line.selectionText.startsWith('* ') ||
        line.selectionText.startsWith('+ ')) {
      final style = line.selectionText[0];

      // Empty item
      if (line.selectionText.length == 2) {
        return _MarkdownEditorData(
          text: text.replaceRange(
              line.selectionStart, line.selectionStart + 2, ''),
          selectionStart: input.selectionStart - 2,
          selectionEnd: input.selectionEnd - 2,
        );
      }

      return _MarkdownEditorData(
        text: text.replaceRange(
            input.selectionStart, input.selectionStart, '\n$style '),
        selectionStart: input.selectionStart + 3,
        selectionEnd: input.selectionEnd + 3,
      );
    }

    // Numbered List
    final numberedListMatch =
        RegExp(r'(\d)+([.)]) ').matchAsPrefix(line.selectionText);
    if (numberedListMatch != null) {
      final currentNumber = numberedListMatch[1]!;
      final nextNumber = (int.parse(currentNumber) + 1).toString();
      final style = numberedListMatch[2];

      // Empty item
      final currentPrefixLength = currentNumber.length + 2;
      if (line.selectionText.length == currentPrefixLength) {
        return _MarkdownEditorData(
          text: text.replaceRange(line.selectionStart,
              line.selectionStart + currentPrefixLength, ''),
          selectionStart: input.selectionStart - currentPrefixLength,
          selectionEnd: input.selectionEnd - currentPrefixLength,
        );
      }

      final nextPrefixLength = nextNumber.length + 2;
      return _MarkdownEditorData(
        text: text.replaceRange(
            input.selectionStart, input.selectionStart, '\n$nextNumber$style '),
        selectionStart: input.selectionStart + 1 + nextPrefixLength,
        selectionEnd: input.selectionEnd + 1 + nextPrefixLength,
      );
    }

    return _MarkdownEditorData(
      text: text.replaceRange(input.selectionStart, input.selectionEnd, '\n'),
      selectionStart: input.selectionStart + 1,
      selectionEnd: input.selectionStart + 1,
    );
  }
}
