import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../blocs/raffle_bloc/raffle_bloc.dart';
import '../../blocs/raffle_bloc/raffle_event.dart';
import '../common/network_image_widget.dart';

/// Widget for selecting and configuring a custom logo for the raffle.
class LogoSelectorWidget extends StatefulWidget {
  final String? currentLogoUrl;

  const LogoSelectorWidget({super.key, this.currentLogoUrl});

  @override
  State<LogoSelectorWidget> createState() => _LogoSelectorWidgetState();
}

class _LogoSelectorWidgetState extends State<LogoSelectorWidget> {
  late final TextEditingController _urlController;
  bool _isValidUrl = true;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.currentLogoUrl ?? '');
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _validateAndSetLogo() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      // Remove logo if URL is empty
      context.read<RaffleBloc>().add(RemoveRaffleLogo());
      Navigator.of(context).pop();
      return;
    }

    // Basic URL validation
    final urlPattern = RegExp(
      r'^https?://.*\.(jpg|jpeg|png|gif|bmp|webp)(\?.*)?$',
      caseSensitive: false,
    );

    if (urlPattern.hasMatch(url)) {
      setState(() => _isValidUrl = true);
      context.read<RaffleBloc>().add(SetRaffleLogo(url));
      Navigator.of(context).pop();
    } else {
      setState(() => _isValidUrl = false);
    }
  }

  void _removeLogo() {
    context.read<RaffleBloc>().add(RemoveRaffleLogo());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.selectLogo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.logoUrlHint,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.logoUrl,
              hintText: 'https://example.com/logo.png',
              errorText: _isValidUrl
                  ? null
                  : AppLocalizations.of(context)!.invalidLogoUrl,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.link),
            ),
            onChanged: (_) {
              if (!_isValidUrl) {
                setState(() => _isValidUrl = true);
              }
            },
          ),
          const SizedBox(height: 16),

          // Preview section
          if (_urlController.text.isNotEmpty) ...[
            Text(
              AppLocalizations.of(context)!.logoPreview,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: NetworkImageWidget(
                  imageUrl: _urlController.text,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[100],
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey[400],
                      size: 32,
                    ),
                  ),
                  loadingBuilder: (context) => Container(
                    color: Colors.grey[100],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
      actions: [
        if (widget.currentLogoUrl != null)
          TextButton(
            onPressed: _removeLogo,
            child: Text(
              AppLocalizations.of(context)!.removeLogo,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _validateAndSetLogo,
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}
