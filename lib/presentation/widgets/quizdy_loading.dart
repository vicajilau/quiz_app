import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class QuizdyLoading extends StatelessWidget {
  const QuizdyLoading({super.key, this.height = 80, this.width = 80});

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'images/quizdy_loading.json',
      height: height,
      width: width,
    );
  }
}
