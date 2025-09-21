import 'package:flutter/material.dart';
import 'dart:math' as math;

class RaffleAnimationWidget extends StatefulWidget {
  const RaffleAnimationWidget({super.key});

  @override
  State<RaffleAnimationWidget> createState() => _RaffleAnimationWidgetState();
}

class _RaffleAnimationWidgetState extends State<RaffleAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _startAnimation();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    // Start rotation animation (continuous)
    _rotationController.repeat();

    // Start scale animation with bounce effect
    _scaleController.forward();

    // Start fade animation
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated dice/casino icon
            AnimatedBuilder(
              animation: Listenable.merge([
                _rotationController,
                _scaleController,
                _fadeController,
              ]),
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: Transform.scale(
                    scale: 0.8 + (_scaleController.value * 0.4),
                    child: FadeTransition(
                      opacity: _fadeController,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: const Icon(
                          Icons.casino,
                          size: 32,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Pulsing text
            AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeController,
                  child: Text(
                    'Sorteando...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 6),

            // Loading indicator dots
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final delay = index * 0.3;
                    final animationValue =
                        (_rotationController.value + delay) % 1.0;
                    final opacity =
                        (math.sin(animationValue * 2 * math.pi) + 1) / 2;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(
                          alpha: opacity * 0.8 + 0.2,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
