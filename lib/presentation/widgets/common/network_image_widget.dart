import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A widget that handles network image loading with better web compatibility
class NetworkImageWidget extends StatefulWidget {
  final String imageUrl;
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
  int _attemptCount = 0;
  static const int _maxAttempts = 2;

  /// For web, we can try using a CORS proxy as fallback
  String _getWebFriendlyUrl(String url, int attempt) {
    if (kIsWeb && attempt > 0) {
      // Try different approaches for web CORS issues
      switch (attempt) {
        case 1:
          // Attempt 1: Try with AllOrigins proxy (reliable service)
          return 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}';
        case 2:
          // Attempt 2: Try with ThingProxy (another reliable option)
          return 'https://thingproxy.freeboard.io/fetch/$url';
        default:
          return url;
      }
    }
    return url;
  }

  /// Provides a more informative error widget for web CORS issues
  Widget _buildWebErrorWidget(BuildContext context) {
    return Container(
      height: widget.height ?? 40,
      width: widget.width,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_not_supported,
            color: Colors.grey[600],
            size: (widget.height != null && widget.height! > 25) ? 16 : 12,
          ),
          if (widget.height == null || widget.height! > 35) ...[
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                'CORS blocked',
                style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _retryWithNextAttempt() {
    if (_attemptCount < _maxAttempts) {
      setState(() {
        _attemptCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final finalUrl = _getWebFriendlyUrl(widget.imageUrl, _attemptCount);

    // Debug log for understanding the context
    debugPrint(
      'NetworkImageWidget build: url=$finalUrl, height=${widget.height}, width=${widget.width}, attempt=$_attemptCount',
    );

    // For web, we need to handle CORS issues differently
    if (kIsWeb) {
      return Image.network(
        finalUrl,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        headers: const {
          'User-Agent': 'Quiz App Flutter Web',
          'Accept': 'image/*,*/*;q=0.8',
        },
        loadingBuilder: widget.loadingBuilder != null
            ? (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return widget.loadingBuilder!(context);
              }
            : (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  height: widget.height ?? 40,
                  width: widget.width,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              },
        errorBuilder: (context, error, stackTrace) {
          // Log the error for debugging
          debugPrint(
            'Image loading failed for $finalUrl (attempt ${_attemptCount + 1}): $error',
          );

          // Check if it's a network/CORS error and we can retry
          final errorString = error.toString().toLowerCase();
          final isNetworkError =
              errorString.contains('statuscode: 0') ||
              errorString.contains('statuscode: 403') ||
              errorString.contains('cors') ||
              errorString.contains('network') ||
              errorString.contains('failed to load');

          if (isNetworkError && _attemptCount < _maxAttempts) {
            // Try with a different proxy on next rebuild
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _retryWithNextAttempt();
            });
            return _buildWebErrorWidget(context);
          }

          // If custom error builder is provided, use it
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, error, stackTrace);
          }

          // Use our custom web error widget
          return _buildWebErrorWidget(context);
        },
      );
    } else {
      // For mobile platforms, use standard Image.network
      return Image.network(
        finalUrl,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        loadingBuilder: widget.loadingBuilder != null
            ? (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return widget.loadingBuilder!(context);
              }
            : null,
        errorBuilder: widget.errorBuilder,
      );
    }
  }
}
