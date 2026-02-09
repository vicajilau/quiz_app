import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_event.dart';
import 'package:quiz_app/routes/app_router.dart';

class HomeFooterWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCreateTap;

  const HomeFooterWidget({
    super.key,
    required this.isLoading,
    required this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48, top: 32),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 200, minWidth: 160),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : onCreateTap,
                    icon: Icon(
                      LucideIcons.plus,
                      size: 22,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.create,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 200, minWidth: 160),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<FileBloc>().add(QuizFileReset());
                            context.read<FileBloc>().add(
                              QuizFilePickRequested(),
                            );
                          },
                    icon: const Icon(LucideIcons.folderOpen, size: 22),
                    label: Text(
                      AppLocalizations.of(context)!.load,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: isLoading ? null : () => context.go(AppRoutes.raffle),
            icon: Icon(
              LucideIcons.gift,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            label: Text(
              AppLocalizations.of(context)!.sorteosLabel,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
