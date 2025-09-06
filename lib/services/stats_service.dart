import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/daily_stats.dart';

class StatsService {
  static const String _statsKey = 'daily_stats';

  static Future<List<DailyStats>> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);
    
    if (statsJson == null) return [];
    
    final List<dynamic> statsList = json.decode(statsJson);
    return statsList.map((stats) => DailyStats(
      date: DateTime.parse(stats['date']),
      completedTasks: stats['completedTasks'] ?? 0,
      failedTasks: stats['failedTasks'] ?? 0,
    )).toList();
  }

  static Future<void> saveStats(List<DailyStats> stats) async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = json.encode(stats.map((stat) => {
      'date': stat.date.toIso8601String(),
      'completedTasks': stat.completedTasks,
      'failedTasks': stat.failedTasks,
    }).toList());
    
    await prefs.setString(_statsKey, statsJson);
  }

  static Future<void> recordTaskCompletion(bool completed) async {
    final stats = await loadStats();
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    
    // Find or create today's stats
    DailyStats? todayStats;
    int index = -1;
    
    for (int i = 0; i < stats.length; i++) {
      final statDate = DateTime(stats[i].date.year, stats[i].date.month, stats[i].date.day);
      if (statDate.isAtSameMomentAs(todayKey)) {
        todayStats = stats[i];
        index = i;
        break;
      }
    }
    
    if (todayStats == null) {
      todayStats = DailyStats(date: todayKey);
      stats.add(todayStats);
      index = stats.length - 1;
    }
    
    // Update stats
    if (completed) {
      stats[index] = todayStats.copyWith(completedTasks: todayStats.completedTasks + 1);
    } else {
      stats[index] = todayStats.copyWith(failedTasks: todayStats.failedTasks + 1);
    }
    
    await saveStats(stats);
  }

  static Future<DailyStats> getTodayStats() async {
    final stats = await loadStats();
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    
    for (final stat in stats) {
      final statDate = DateTime(stat.date.year, stat.date.month, stat.date.day);
      if (statDate.isAtSameMomentAs(todayKey)) {
        return stat;
      }
    }
    
    return DailyStats(date: todayKey);
  }
}