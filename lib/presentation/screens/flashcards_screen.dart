// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/theme/extensions/custom_colors.dart';
import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/presentation/screens/widgets/common/quizdy_app_bar.dart';
import 'package:quizdy/presentation/screens/widgets/flashcard_widget.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';

class FlashcardsScreen extends StatefulWidget {
  final QuizFile quizFile;

  const FlashcardsScreen({super.key, required this.quizFile});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  final CardSwiperController _swiperController = CardSwiperController();
  
  late List<Question> _activeQueue;
  bool _isFinished = false;
  int _currentIndex = 0;
  
  // Track flip state so we know if they actually reviewed it
  // (Optional: enforce flipping before swiping, but let's keep it simple first)
  bool _currentCardFlipped = false;

  @override
  void initState() {
    super.initState();
    _initQueue();
  }

  void _initQueue() {
    // We start with a shuffled list to make studying more effective
    final shuffled = widget.quizFile.questions.toList()..shuffle();
    _activeQueue = List.from(shuffled);
    _isFinished = _activeQueue.isEmpty;
    _currentIndex = 0;
    _currentCardFlipped = false;
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (previousIndex >= _activeQueue.length) return false;

    final swipedQuestion = _activeQueue[previousIndex];

    if (direction == CardSwiperDirection.left) {
      // Incorrect / Hard -> Send to back of the queue
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _activeQueue.add(swipedQuestion);
          });
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentCardFlipped = false;
          // If we reached the end of the queue (including dynamically added ones)
          if (currentIndex == null || currentIndex >= _activeQueue.length) {
            _isFinished = true;
          } else {
            _currentIndex = currentIndex;
          }
        });
      }
    });

    return true;
  }

  Widget _buildFinishedState() {
    final localizations = AppLocalizations.of(context)!;
    final customColors = Theme.of(context).extension<CustomColors>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: customColors?.success?.withValues(alpha: 0.1) ?? AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.checkCircle2,
              size: 80,
              color: customColors?.success ?? AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            localizations.flashcardsCompletionMessage,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          QuizdyButton(
            title: localizations.flashcardsRestartButton,
            icon: LucideIcons.rotateCcw,
            onPressed: () {
              setState(() {
                _initQueue();
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final customColors = Theme.of(context).extension<CustomColors>();

    return Scaffold(
      appBar: QuizdyAppBar(
        title: Text(
          localizations.flashcardsModeTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            if (!_isFinished && _activeQueue.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _currentIndex / _activeQueue.length,
                          backgroundColor: Theme.of(context).dividerColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${_currentIndex + 1} / ${_activeQueue.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

            // Card Swiper Area
            Expanded(
              child: _isFinished
                  ? _buildFinishedState()
                  : _activeQueue.isEmpty
                      ? Center(child: Text(localizations.flashcardsEmptyState))
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          child: CardSwiper(
                            controller: _swiperController,
                            cardsCount: _activeQueue.length,
                            onSwipe: _onSwipe,
                            numberOfCardsDisplayed: 2,
                            padding: EdgeInsets.zero,
                            backCardOffset: const Offset(0, 15),
                            allowedSwipeDirection: const AllowedSwipeDirection.symmetric(horizontal: true),
                            cardBuilder: (
                              context,
                              index,
                              horizontalThresholdPercentage,
                              verticalThresholdPercentage,
                            ) {
                              return FlashcardWidget(
                                question: _activeQueue[index],
                                isFlipped: _currentCardFlipped,
                                onTap: () {
                                  setState(() {
                                    _currentCardFlipped = !_currentCardFlipped;
                                  });
                                },
                              );
                            },
                          ),
                        ),
            ),

            // Action Buttons
            if (!_isFinished && _activeQueue.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton.large(
                      heroTag: 'btn_wrong',
                      onPressed: () => _swiperController.swipe(CardSwiperDirection.left),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      elevation: 4,
                      child: Icon(
                        LucideIcons.x,
                        color: Theme.of(context).colorScheme.onError,
                        size: 40,
                      ),
                    ),
                    FloatingActionButton.large(
                      heroTag: 'btn_correct',
                      onPressed: () => _swiperController.swipe(CardSwiperDirection.right),
                      backgroundColor: customColors?.success ?? Colors.green,
                      elevation: 4,
                      child: const Icon(
                        LucideIcons.check,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
