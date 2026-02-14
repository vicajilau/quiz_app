import 'package:flutter/material.dart';

abstract class LocaleEvent {
  const LocaleEvent();
}

class ChangeLocale extends LocaleEvent {
  final Locale locale;

  const ChangeLocale(this.locale);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChangeLocale && other.locale == locale;
  }

  @override
  int get hashCode => locale.hashCode;
}
