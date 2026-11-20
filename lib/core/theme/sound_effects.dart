import 'package:flutter/services.dart';
import '../../data/services/storage_service.dart';

class SoundEffects {
  static bool get isEnabled => StorageService.isSoundEnabled();

  /// Subtle chime / tap feedback for UI buttons
  static void playTap() {
    if (!isEnabled) return;
    try {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Affirmative success chime (payment, save, resolve)
  static void playSuccess() {
    if (!isEnabled) return;
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Warning / Alert feedback (LOS detected, network down)
  static void playAlert() {
    if (!isEnabled) return;
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Blue Archive Entrance chime
  static void playEntrance() {
    if (!isEnabled) return;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }
}
