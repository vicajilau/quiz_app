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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/presentation/blocs/onboarding_cubit/onboarding_cubit.dart';
import 'package:quizdy/presentation/blocs/onboarding_cubit/onboarding_state.dart';
import 'package:quizdy/presentation/screens/onboarding/widgets/onboarding_desktop_layout.dart';
import 'package:quizdy/presentation/screens/onboarding/widgets/onboarding_mobile_layout.dart';
import 'package:quizdy/presentation/screens/onboarding/widgets/onboarding_widgets.dart';
import 'package:quizdy/routes/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  final bool fromSettings;

  const OnboardingScreen({super.key, this.fromSettings = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  bool? _wasWideLayout;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    if (!_pageController.hasClients) {
      return;
    }

    final currentPage =
        _pageController.page?.round() ?? _pageController.initialPage;
    if (currentPage == page) {
      return;
    }

    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.linear,
    );
  }

  void _recreatePageController(int initialPage) {
    final previousController = _pageController;
    _pageController = PageController(initialPage: initialPage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      previousController.dispose();
    });
  }

  Future<void> _finish(BuildContext context) async {
    final configurationService = ServiceLocator.getIt<ConfigurationService>();
    await context.read<OnboardingCubit>().completeOnboarding();
    final hasAcceptedPrivacyPolicy = await configurationService
        .getPrivacyPolicyAccepted();

    if (context.mounted) {
      if (widget.fromSettings) {
        context.pop();
        return;
      }

      if (!hasAcceptedPrivacyPolicy) {
        context.go('${AppRoutes.privacyPolicy}?required=true');
        return;
      }

      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = buildOnboardingPages(context);

    return BlocProvider(
      create: (_) => OnboardingCubit(totalPages: pages.length),
      child: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          _animateToPage(state.currentPage);
        },
        builder: (context, state) {
          final cubit = context.read<OnboardingCubit>();

          return Scaffold(
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 720;
                  if (_wasWideLayout != isWide) {
                    final targetPage = state.currentPage;
                    _wasWideLayout = isWide;
                    _recreatePageController(targetPage);
                  }

                  if (isWide) {
                    return OnboardingDesktopLayout(
                      state: state,
                      pages: pages,
                      pageController: _pageController,
                      cubit: cubit,
                      onFinish: () => _finish(context),
                    );
                  }
                  return OnboardingMobileLayout(
                    state: state,
                    pages: pages,
                    pageController: _pageController,
                    cubit: cubit,
                    onFinish: () => _finish(context),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
