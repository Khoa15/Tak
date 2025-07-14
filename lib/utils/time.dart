import 'package:flutter/material.dart';

class Time {
  static Future<DateTime?> pickDeadline({
    context,
    DateTime? initialDate,
  }) async {
    final now = DateTime.now().add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );
    return picked;
  }
}
