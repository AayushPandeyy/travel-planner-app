import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Status of a trip from the API.
enum TripStatus { upcoming, ongoing, completed }

class TripEntity extends Equatable {
  final String id;
  final String name;
  final String destination;
  final String emoji;
  final String colorHex;
  final DateTime startDate;
  final DateTime endDate;
  final double totalBudget;
  final double spentBudget;
  final int activitiesCount;
  final int pendingDocuments;
  final int pendingReminders;
  final TripStatus status;

  const TripEntity({
    required this.id,
    required this.name,
    required this.destination,
    this.emoji = '✈️',
    this.colorHex = '#6C63FF',
    required this.startDate,
    required this.endDate,
    required this.totalBudget,
    this.spentBudget = 0,
    this.activitiesCount = 0,
    this.pendingDocuments = 0,
    this.pendingReminders = 0,
    this.status = TripStatus.upcoming,
  });

  // ── Computed ──

  int get daysLeft => startDate.difference(DateTime.now()).inDays;
  int get totalDays => endDate.difference(startDate).inDays;
  double get budgetPercent =>
      totalBudget > 0 ? (spentBudget / totalBudget).clamp(0.0, 1.0) : 0.0;
  bool get isOverBudget => spentBudget > totalBudget;

  Color get displayColor {
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF6C63FF);
    }
  }

  TripEntity copyWith({
    String? id,
    String? name,
    String? destination,
    String? emoji,
    String? colorHex,
    DateTime? startDate,
    DateTime? endDate,
    double? totalBudget,
    double? spentBudget,
    int? activitiesCount,
    int? pendingDocuments,
    int? pendingReminders,
    TripStatus? status,
  }) {
    return TripEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      destination: destination ?? this.destination,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalBudget: totalBudget ?? this.totalBudget,
      spentBudget: spentBudget ?? this.spentBudget,
      activitiesCount: activitiesCount ?? this.activitiesCount,
      pendingDocuments: pendingDocuments ?? this.pendingDocuments,
      pendingReminders: pendingReminders ?? this.pendingReminders,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    destination,
    emoji,
    colorHex,
    startDate,
    endDate,
    totalBudget,
    spentBudget,
    activitiesCount,
    pendingDocuments,
    pendingReminders,
    status,
  ];
}
