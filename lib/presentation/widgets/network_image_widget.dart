import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A widget that handles network image loading with better web compatibility
class NetworkImageWidget extends StatefulWidget {
  final Uint8List imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget Function(BuildContext)? loadingBuilder;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  State<NetworkImageWidget> createState() => _NetworkImageWidgetState();
}

class _NetworkImageWidgetState extends State<NetworkImageWidget> {
  @override
  Widget build(BuildContext context) {
    return Image.memory(
      widget.imageUrl,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
    );
  }
}
