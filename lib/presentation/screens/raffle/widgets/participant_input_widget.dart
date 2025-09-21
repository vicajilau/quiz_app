import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../blocs/raffle_bloc/raffle_bloc.dart';
import '../../../blocs/raffle_bloc/raffle_event.dart';
import '../../../blocs/raffle_bloc/raffle_state.dart';

class ParticipantInputWidget extends StatefulWidget {
  const ParticipantInputWidget({super.key});

  @override
  State<ParticipantInputWidget> createState() => _ParticipantInputWidgetState();
}

class _ParticipantInputWidgetState extends State<ParticipantInputWidget> {
  final TextEditingController _controller = TextEditingController();

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
    return BlocListener<RaffleBloc, RaffleState>(
      listener: (context, state) {
        if (state is RaffleLoaded) {
          // Update the text field if the text was updated programmatically
          if (_controller.text != state.session.participantText) {
            _controller.text = state.session.participantText;
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.participantListHint,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
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
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              _controller.clear();
              context.read<RaffleBloc>().add(ClearParticipants());
            },
            icon: const Icon(Icons.clear),
            label: Text(AppLocalizations.of(context)!.clearList),
          ),
        ],
      ),
    );
  }
}
