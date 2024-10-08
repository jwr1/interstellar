import 'package:flutter/material.dart';

class _LoadingButtonIndicator extends StatelessWidget {
  const _LoadingButtonIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      padding: const EdgeInsets.all(2.0),
      child: const CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 3,
      ),
    );
  }
}

class LoadingFilledButton extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final Widget label;
  final Widget? icon;
  final ButtonStyle? style;

  const LoadingFilledButton({
    required this.onPressed,
    required this.label,
    this.icon,
    this.style,
    super.key,
  });

  @override
  State<LoadingFilledButton> createState() => _LoadingFilledButtonState();
}

class _LoadingFilledButtonState extends State<LoadingFilledButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _isLoading || widget.onPressed == null
          ? null
          : () async {
              setState(() => _isLoading = true);
              await widget.onPressed!();
              if (mounted) setState(() => _isLoading = false);
            },
      label: widget.label,
      icon: _isLoading ? const _LoadingButtonIndicator() : widget.icon,
      style: widget.style,
    );
  }
}

class LoadingTonalButton extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final Widget label;
  final Widget? icon;
  final ButtonStyle? style;

  const LoadingTonalButton({
    required this.onPressed,
    required this.label,
    this.icon,
    this.style,
    super.key,
  });

  @override
  State<LoadingTonalButton> createState() => _LoadingTonalButtonState();
}

class _LoadingTonalButtonState extends State<LoadingTonalButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: _isLoading || widget.onPressed == null
          ? null
          : () async {
              setState(() => _isLoading = true);
              await widget.onPressed!();
              if (mounted) setState(() => _isLoading = false);
            },
      label: widget.label,
      icon: _isLoading ? const _LoadingButtonIndicator() : widget.icon,
      style: widget.style,
    );
  }
}

class LoadingOutlinedButton extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final Widget label;
  final Widget? icon;
  final ButtonStyle? style;

  const LoadingOutlinedButton({
    required this.onPressed,
    required this.label,
    this.icon,
    this.style,
    super.key,
  });

  @override
  State<LoadingOutlinedButton> createState() => _LoadingOutlinedButtonState();
}

class _LoadingOutlinedButtonState extends State<LoadingOutlinedButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _isLoading || widget.onPressed == null
          ? null
          : () async {
              setState(() => _isLoading = true);
              await widget.onPressed!();
              if (mounted) setState(() => _isLoading = false);
            },
      label: widget.label,
      icon: _isLoading ? const _LoadingButtonIndicator() : widget.icon,
      style: widget.style,
    );
  }
}

class LoadingTextButton extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final Widget label;
  final Widget? icon;
  final ButtonStyle? style;

  const LoadingTextButton({
    required this.onPressed,
    required this.label,
    this.icon,
    this.style,
    super.key,
  });

  @override
  State<LoadingTextButton> createState() => _LoadingTextButtonState();
}

class _LoadingTextButtonState extends State<LoadingTextButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _isLoading || widget.onPressed == null
          ? null
          : () async {
              setState(() => _isLoading = true);
              await widget.onPressed!();
              if (mounted) setState(() => _isLoading = false);
            },
      label: widget.label,
      icon: _isLoading ? const _LoadingButtonIndicator() : widget.icon,
      style: widget.style,
    );
  }
}

class LoadingIconButton extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final Widget icon;
  final ButtonStyle? style;
  final String? tooltip;

  const LoadingIconButton({
    required this.onPressed,
    required this.icon,
    this.style,
    this.tooltip,
    super.key,
  });

  @override
  State<LoadingIconButton> createState() => _LoadingIconButtonState();
}

class _LoadingIconButtonState extends State<LoadingIconButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _isLoading || widget.onPressed == null
          ? null
          : () async {
              setState(() => _isLoading = true);
              await widget.onPressed!();
              if (mounted) setState(() => _isLoading = false);
            },
      icon: _isLoading ? const _LoadingButtonIndicator() : widget.icon,
      style: widget.style,
      tooltip: widget.tooltip,
    );
  }
}
