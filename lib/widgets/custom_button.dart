import 'package:flutter/material.dart';

enum ButtonVariant { filled, outlined, text }

class CustomButton extends StatelessWidget {
  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final ButtonVariant variant;
  final Color? color;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool fullWidth;

  const CustomButton({
    super.key,
    this.label,
    this.child,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = ButtonVariant.filled,
    this.color,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
    this.fullWidth = false,
  }) : assert(label != null || child != null, 'Either label or child must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = color ?? const Color(0xFF1E88E5);
    final onPrimary = theme.colorScheme.onPrimary;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(onPrimary)),
          ),
          const SizedBox(width: 8),
        ],
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Flexible(child: child ?? Text(label!, textAlign: TextAlign.center)),
      ],
    );

    final ButtonStyle commonStyle = ButtonStyle(
      padding: MaterialStateProperty.all(padding),
      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))),
      minimumSize: MaterialStateProperty.all(fullWidth ? const Size.fromHeight(48) : Size.zero),
    );

    switch (variant) {
      case ButtonVariant.filled:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: (isLoading || onPressed == null) ? null : onPressed,
            style: commonStyle.merge(ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: onPrimary,
            )),
            child: content,
          ),
        );
      case ButtonVariant.outlined:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: (isLoading || onPressed == null) ? null : onPressed,
            style: commonStyle.merge(OutlinedButton.styleFrom(
              side: BorderSide(color: primary, width: 1.5),
              foregroundColor: primary,
            )),
            child: content,
          ),
        );
      case ButtonVariant.text:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: TextButton(
            onPressed: (isLoading || onPressed == null) ? null : onPressed,
            style: commonStyle.merge(TextButton.styleFrom(foregroundColor: primary)),
            child: content,
          ),
        );
    }
  }
}
