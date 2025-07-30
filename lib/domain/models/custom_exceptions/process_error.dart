import 'package:flutter/material.dart';

abstract class ProcessError {
  bool get success;
  String getDescriptionForInputError(BuildContext context);
  String getDescriptionForFileError(BuildContext context);
}
