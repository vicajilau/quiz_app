import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/presentation/blocs/raffle_bloc/raffle_bloc.dart';
import 'package:quiz_app/presentation/blocs/raffle_bloc/raffle_event.dart';
import 'package:quiz_app/presentation/blocs/raffle_bloc/raffle_state.dart';

class ParticipantInputWidget extends StatefulWidget {
  const ParticipantInputWidget({super.key});

  @override
  State<ParticipantInputWidget> createState() => _ParticipantInputWidgetState();
}

class _ParticipantInputWidgetState extends State<ParticipantInputWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    context.read<RaffleBloc>().add(UpdateParticipantText(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RaffleBloc, RaffleState>(
      listener: (context, state) {
        String participantText = '';

        if (state is RaffleLoaded) {
          participantText = state.session.participantText;
        } else if (state is RaffleWinnerSelected) {
          participantText = state.session.participantText;
        } else if (state is RaffleSelecting) {
          participantText = state.session.participantText;
        }

        // Update the text field if the text was updated programmatically
        if (_controller.text != participantText) {
          _controller.text = participantText;
        }
      },
      builder: (context, state) {
        // Initialize controller with current state on first build
        if (!_isInitialized) {
          String participantText = '';

          if (state is RaffleLoaded) {
            participantText = state.session.participantText;
          } else if (state is RaffleWinnerSelected) {
            participantText = state.session.participantText;
          } else if (state is RaffleSelecting) {
            participantText = state.session.participantText;
          }

          if (participantText.isNotEmpty ||
              state is RaffleLoaded ||
              state is RaffleWinnerSelected) {
            _controller.text = participantText;
            _isInitialized = true;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.participantListHint,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(
                    context,
                  )!.participantListPlaceholder,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}
