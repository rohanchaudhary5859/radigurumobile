import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final double borderRadius;
  final BorderSide? side;
  final bool isLoading;
  final double? loadingSize;
  final Color? loadingColor;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isFullWidth = true,
    this.padding,
    this.height,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.borderRadius = 12,
    this.side,
    this.isLoading = false,
    this.loadingSize,
    this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null;
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? theme.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: side ?? BorderSide.none,
      ),
      minimumSize: Size(
        isFullWidth ? double.infinity : (width ?? 0),
        height ?? 52,
      ),
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: isLoading
          ? SizedBox(
              width: loadingSize ?? 24,
              height: loadingSize ?? 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  loadingColor ?? Colors.white,
                ),
              ),
            )
          : child,
    );
  }
}
