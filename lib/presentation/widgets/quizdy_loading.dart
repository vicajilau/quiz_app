// Copyright (C) 2026 Victor Carreras
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
import 'package:lottie/lottie.dart';

class QuizdyLoading extends StatelessWidget {
  const QuizdyLoading({super.key, this.height = 80, this.width = 80});

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) =>
      Lottie.asset('images/quizdy_loading.json', height: height, width: width);
}
