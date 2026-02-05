import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz_app/domain/models/raffle/raffle_logo.dart';

/// Service for handling raffle-specific persistent storage
class RaffleStorageService {
  static const String _raffleLogo = 'raffle_logo';
  static const String _raffleLogoType = 'raffle_logo_type';
  static const String _raffleLogoFilename = 'raffle_logo_filename';
  // Maximum size for base64 encoded image (approximately 2MB in base64)
  static const int _maxBase64Size = 2 * 1024 * 1024; // 2MB in bytes

  static RaffleStorageService? _instance;
  static RaffleStorageService get instance =>
      _instance ??= RaffleStorageService._();

  RaffleStorageService._();

  /// Saves a RaffleLogo to persistent storage
  Future<bool> saveLogo(RaffleLogo logo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64String = base64Encode(logo.data);

      if (base64String.length > _maxBase64Size) {
        if (kDebugMode) {
          print(
            'Logo too large for storage: ${base64String.length} bytes. Max allowed: $_maxBase64Size bytes',
          );
        }
        return false; // Logo too large
      }

      await prefs.setString(_raffleLogo, base64String);
      await prefs.setString(_raffleLogoType, logo.type);
      if (logo.filename != null) {
        await prefs.setString(_raffleLogoFilename, logo.filename!);
      } else {
        await prefs.remove(_raffleLogoFilename);
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving raffle logo: $e');
      }
      return false;
    }
  }

  /// Retrieves a RaffleLogo from persistent storage
  Future<RaffleLogo?> getLogo() async {
    final prefs = await SharedPreferences.getInstance();
    final base64String = prefs.getString(_raffleLogo);
    final type = prefs.getString(_raffleLogoType);
    final filename = prefs.getString(_raffleLogoFilename);

    if (base64String == null || base64String.isEmpty) {
      return null;
    }

    try {
      final data = base64Decode(base64String);
      return RaffleLogo(
        data: data,
        type: type ?? 'unknown',
        filename: filename,
      );
    } catch (e) {
      // If decoding fails, remove the corrupted data
      await removeLogo();
      return null;
    }
  }

  /// Removes all raffle logo data from persistent storage
  Future<void> removeLogo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_raffleLogo);
    await prefs.remove(_raffleLogoType);
    await prefs.remove(_raffleLogoFilename);
  }

  /// Checks if a raffle logo is stored
  Future<bool> hasLogo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_raffleLogo);
  }
}
