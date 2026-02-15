import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service to manage weekly bonus challenge data synchronization
/// between home screen and earnings screen
class WeeklyChallengeService {
  static const String _keyCompletedJobs = 'weekly_challenge_completed';
  static const String _keyTargetJobs = 'weekly_challenge_target';
  static const String _keyRewardAmount = 'weekly_challenge_reward';
  static const String _keyTitle = 'weekly_challenge_title';
  static const String _keySubtitle = 'weekly_challenge_subtitle';
  static const String _keyEndsIn = 'weekly_challenge_ends_in';
  static const String _keyIsCompleted = 'weekly_challenge_is_completed';
  static const String _keyLastUpdated = 'weekly_challenge_last_updated';

  /// Save weekly challenge data to SharedPreferences
  static Future<void> saveWeeklyChallengeData({
    required int completedJobs,
    required int targetJobs,
    required double rewardAmount,
    String title = 'Weekly Challenge',
    String subtitle = 'Complete jobs to earn bonus',
    String endsIn = '',
    bool isCompleted = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt(_keyCompletedJobs, completedJobs);
      await prefs.setInt(_keyTargetJobs, targetJobs);
      await prefs.setDouble(_keyRewardAmount, rewardAmount);
      await prefs.setString(_keyTitle, title);
      await prefs.setString(_keySubtitle, subtitle);
      await prefs.setString(_keyEndsIn, endsIn);
      await prefs.setBool(_keyIsCompleted, isCompleted);
      await prefs.setString(_keyLastUpdated, DateTime.now().toIso8601String());

      print(
        '✅ WeeklyChallengeService: Saved $completedJobs/$targetJobs, reward: ₹$rewardAmount',
      );
    } catch (e) {
      print('❌ WeeklyChallengeService: Error saving: $e');
    }
  }

  /// Get weekly challenge data from SharedPreferences
  static Future<Map<String, dynamic>?> getWeeklyChallengeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final completedJobs = prefs.getInt(_keyCompletedJobs);
      final targetJobs = prefs.getInt(_keyTargetJobs);
      final rewardAmount = prefs.getDouble(_keyRewardAmount);

      if (completedJobs == null || targetJobs == null || rewardAmount == null) {
        return null;
      }

      return {
        'completedJobs': completedJobs,
        'targetJobs': targetJobs,
        'rewardAmount': rewardAmount,
        'title': prefs.getString(_keyTitle) ?? 'Weekly Challenge',
        'subtitle':
            prefs.getString(_keySubtitle) ?? 'Complete jobs to earn bonus',
        'endsIn': prefs.getString(_keyEndsIn) ?? '',
        'isCompleted': prefs.getBool(_keyIsCompleted) ?? false,
        'lastUpdated': prefs.getString(_keyLastUpdated) ?? '',
      };
    } catch (e) {
      print('Error getting weekly challenge data: $e');
      return null;
    }
  }

  /// Clear weekly challenge data
  static Future<void> clearWeeklyChallengeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_keyCompletedJobs);
      await prefs.remove(_keyTargetJobs);
      await prefs.remove(_keyRewardAmount);
      await prefs.remove(_keyTitle);
      await prefs.remove(_keySubtitle);
      await prefs.remove(_keyEndsIn);
      await prefs.remove(_keyIsCompleted);
      await prefs.remove(_keyLastUpdated);
    } catch (e) {
      print('Error clearing weekly challenge data: $e');
    }
  }

  /// Update only the completed jobs count (for quick updates)
  static Future<void> updateCompletedJobs(int completedJobs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyCompletedJobs, completedJobs);
      await prefs.setString(_keyLastUpdated, DateTime.now().toIso8601String());

      // Check if completed
      final targetJobs = prefs.getInt(_keyTargetJobs) ?? 0;
      if (completedJobs >= targetJobs && targetJobs > 0) {
        await prefs.setBool(_keyIsCompleted, true);
      }
    } catch (e) {
      print('Error updating completed jobs: $e');
    }
  }
}
