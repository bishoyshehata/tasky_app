/// Result of parsing a voice input string for date/time information.
class ParsedReminder {
  /// The resolved [DateTime], or null if no date/time found.
  final DateTime? dateTime;

  /// A human-readable description of what was detected, e.g.:
  ///   "Tomorrow • 8:00 PM"
  ///   "غدًا • 9:00 ص"
  final String? description;

  /// The repeat rule, e.g., "daily" or null.
  final String? repeatRule;

  /// The cleaned text with date/time and repeat rule phrases removed.
  final String cleanedTitle;

  /// The parsed task description if any "description" keyword was used.
  final String? cleanedDescription;

  const ParsedReminder({
    this.dateTime,
    this.description,
    this.repeatRule,
    this.cleanedTitle = '',
    this.cleanedDescription,
  });

  bool get hasReminder => dateTime != null;
}

/// Pure-Dart, zero-dependency parser that extracts date/time hints from
/// free-form Arabic and English task title text.
///
/// Does NOT use AI — only regex patterns + simple arithmetic.
///
/// Supported expressions (Arabic):
///   بكرة / غدًا / غداً / اليوم / الساعة X / X صباحًا / X مساءً /
///   بعد ساعة / بعد ساعتين / يوم الجمعة / الجمعة القادمة / بعد أسبوع / كل يوم
///
/// Supported expressions (English):
///   today / tomorrow / next <weekday> / in an hour / in X hours /
///   at X am|pm / X:XX am|pm / next week / every day
class ReminderDateParser {
  ReminderDateParser._();

  static const _arabicWeekdays = {
    'الأحد': DateTime.sunday,
    'الاثنين': DateTime.monday,
    'الثلاثاء': DateTime.tuesday,
    'الأربعاء': DateTime.wednesday,
    'الخميس': DateTime.thursday,
    'الجمعة': DateTime.friday,
    'السبت': DateTime.saturday,
  };

  static const _englishWeekdays = {
    'sunday': DateTime.sunday,
    'monday': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'friday': DateTime.friday,
    'saturday': DateTime.saturday,
  };

  // ── Public API ───────────────────────────────────────────────

  /// Attempts to parse [input] for date/time information.
  /// Returns a [ParsedReminder] with `hasReminder == false` if nothing found.
  static ParsedReminder parse(String input) {
    final now = DateTime.now();
    final text = input.trim();

    // Check for description split
    final descRegex = RegExp(r'(?:الوصف|description|desc)\s+(.*)', caseSensitive: false);
    final descMatch = descRegex.firstMatch(text);
    String titlePart = text;
    String? descriptionPart;
    if (descMatch != null) {
      titlePart = text.substring(0, descMatch.start).trim();
      descriptionPart = descMatch.group(1)?.trim();
    }

    final lowercaseTitle = titlePart.toLowerCase();

    // Try parsers in priority order
    final baseReminder = _tryEveryDay(lowercaseTitle, now) ??
        _tryRelativeDays(lowercaseTitle, now) ??
        _tryTimeOfDay(lowercaseTitle, now) ??
        _tryRelativeHours(lowercaseTitle, now) ??
        _tryWeekday(lowercaseTitle, now) ??
        _tryNextWeek(lowercaseTitle, now);

    final cleanedTitle = _cleanTitle(titlePart);

    if (baseReminder != null) {
      return ParsedReminder(
        dateTime: baseReminder.dateTime,
        description: baseReminder.description,
        repeatRule: baseReminder.repeatRule,
        cleanedTitle: cleanedTitle,
        cleanedDescription: descriptionPart,
      );
    }

    return ParsedReminder(
      cleanedTitle: cleanedTitle,
      cleanedDescription: descriptionPart,
    );
  }

  static String _cleanTitle(String originalInput) {
    var cleaned = originalInput;

    // 1. Remove repeat patterns
    cleaned = cleaned.replaceAll(RegExp(r'\b(every day|daily|كل يوم)\b', caseSensitive: false), '');

    // 2. Remove next week/relative days
    cleaned = cleaned.replaceAll(
      RegExp(r'\b(tomorrow|today|بكرة|غداً|غدًا|غدا|اليوم|next week|بعد أسبوع|الأسبوع القادم)\b', caseSensitive: false),
      '',
    );

    // 3. Remove relative hours
    cleaned = cleaned.replaceAll(RegExp(r'\b(بعد\s+(ساعة|ساعتين|\d+\s*ساع))\b', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\b(in\s+(an?\s+hour|\d+\s+hours?))\b', caseSensitive: false), '');

    // 4. Remove time of day patterns
    cleaned = cleaned.replaceAll(
      RegExp(r'(الساعة\s+)?\d{1,2}(?::\d{2})?\s*(صباحًا|صباحا|مساءً|مساء|ص|م)', caseSensitive: false),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'\b(at\s+)?\d{1,2}(?::\d{2})?\s*(am|pm|am\.|pm\.)\b', caseSensitive: false),
      '',
    );

    // 5. Remove weekdays and their modifiers
    final weekdays = [
      'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت',
      'sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday',
      'next', 'يوم', 'القادم', 'القادمة'
    ];
    for (final day in weekdays) {
      cleaned = cleaned.replaceAll(RegExp('\\b$day\\b', caseSensitive: false), '');
      cleaned = cleaned.replaceAll(day, '');
    }

    // 6. Clean up prepositions and extra spaces
    cleaned = cleaned.replaceAll(RegExp(r'\b(في|بـ|at|on|in|for|from|to)\b', caseSensitive: false), '');
    
    // Replace multiple spaces with a single space
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    return cleaned.trim();
  }

  // ── Parsers ──────────────────────────────────────────────────

  /// "كل يوم" / every day
  static ParsedReminder? _tryEveryDay(String text, DateTime now) {
    final isEveryDay = text.contains('كل يوم') || text.contains('every day') || text.contains('daily');
    if (!isEveryDay) return null;

    final timeResult = _extractTime(text);
    final resolved = timeResult != null
        ? DateTime(now.year, now.month, now.day, timeResult.$1, timeResult.$2)
        : DateTime(now.year, now.month, now.day, 8, 0);

    final timeLabel = _formatTime(resolved.hour, resolved.minute);
    return ParsedReminder(
      dateTime: resolved,
      description: 'يومياً • $timeLabel',
      repeatRule: 'daily',
    );
  }

  /// "اليوم" / today
  static ParsedReminder? _tryRelativeDays(String text, DateTime now) {
    final isToday =
        text.contains('اليوم') || text.contains('today');
    final isTomorrow =
        text.contains('بكرة') ||
        text.contains('غداً') ||
        text.contains('غدًا') ||
        text.contains('غدا') ||
        text.contains('tomorrow');

    if (!isToday && !isTomorrow) return null;

    final base = isTomorrow
        ? DateTime(now.year, now.month, now.day + 1)
        : DateTime(now.year, now.month, now.day);

    // Try to also pick up a time from the same text
    final timeResult = _extractTime(text);
    final resolved = timeResult != null
        ? DateTime(base.year, base.month, base.day, timeResult.$1, timeResult.$2)
        : DateTime(base.year, base.month, base.day, 8, 0); // default 8:00 AM

    final label = isTomorrow ? 'غدًا' : 'اليوم';
    final timeLabel = _formatTime(resolved.hour, resolved.minute);
    return ParsedReminder(
      dateTime: resolved,
      description: '$label • $timeLabel',
    );
  }

  /// "الساعة 8 مساءً" / "at 8 PM" / "9:30 am"
  static ParsedReminder? _tryTimeOfDay(String text, DateTime now) {
    final time = _extractTime(text);
    if (time == null) return null;

    // Apply to today (or tomorrow if the time is already past)
    var resolved = DateTime(
      now.year, now.month, now.day, time.$1, time.$2,
    );
    if (resolved.isBefore(now)) {
      resolved = resolved.add(const Duration(days: 1));
    }

    final day = resolved.day == now.day ? 'اليوم' : 'غدًا';
    return ParsedReminder(
      dateTime: resolved,
      description: '$day • ${_formatTime(time.$1, time.$2)}',
    );
  }

  /// "بعد ساعة" / "بعد ساعتين" / "in an hour" / "in X hours"
  static ParsedReminder? _tryRelativeHours(String text, DateTime now) {
    // Arabic: بعد ساعة / بعد ساعتين / بعد X ساعات
    final arMatch = RegExp(
      r'بعد\s+(ساعة|ساعتين|(\d+)\s*ساع)',
    ).firstMatch(text);
    if (arMatch != null) {
      final hours = arMatch.group(1) == 'ساعة'
          ? 1
          : arMatch.group(1) == 'ساعتين'
              ? 2
              : int.tryParse(arMatch.group(2) ?? '1') ?? 1;
      final resolved = now.add(Duration(hours: hours));
      return ParsedReminder(
        dateTime: resolved,
        description: 'بعد $hours ساعة • ${_formatTime(resolved.hour, resolved.minute)}',
      );
    }

    // English: in an hour / in X hours
    final enMatch = RegExp(
      r'in\s+(an?\s+hour|(\d+)\s+hours?)',
    ).firstMatch(text);
    if (enMatch != null) {
      final raw = enMatch.group(1)!;
      final hours = raw.contains('an ') || raw.contains('a ') ? 1 : int.tryParse(enMatch.group(2) ?? '1') ?? 1;
      final resolved = now.add(Duration(hours: hours));
      return ParsedReminder(
        dateTime: resolved,
        description: 'In $hours hour${hours > 1 ? 's' : ''} • ${_formatTime(resolved.hour, resolved.minute)}',
      );
    }

    return null;
  }

  /// "يوم الجمعة" / "الجمعة" / "next Friday"
  static ParsedReminder? _tryWeekday(String text, DateTime now) {
    int? targetWeekday;
    bool isArabic = false;

    for (final entry in _arabicWeekdays.entries) {
      if (text.contains(entry.key)) {
        targetWeekday = entry.value;
        isArabic = true;
        break;
      }
    }

    if (targetWeekday == null) {
      for (final entry in _englishWeekdays.entries) {
        if (text.contains(entry.key)) {
          targetWeekday = entry.value;
          break;
        }
      }
    }

    if (targetWeekday == null) return null;

    var daysAhead = targetWeekday - now.weekday;
    if (daysAhead <= 0) daysAhead += 7;
    
    // Check if "next" is explicitly mentioned for English or "القادم"/"القادمة" for Arabic
    final hasNext = text.contains('next') || text.contains('القادم') || text.contains('القادمة');
    if (hasNext && daysAhead < 7) {
      daysAhead += 7;
    }

    final base = now.add(Duration(days: daysAhead));

    final timeResult = _extractTime(text);
    final resolved = timeResult != null
        ? DateTime(base.year, base.month, base.day, timeResult.$1, timeResult.$2)
        : DateTime(base.year, base.month, base.day, 8, 0);

    // Get day name back for the label
    final dayName = isArabic
        ? _arabicWeekdays.entries.firstWhere((e) => e.value == targetWeekday).key
        : _englishWeekdays.entries.firstWhere((e) => e.value == targetWeekday).key;
    final timeLabel = _formatTime(resolved.hour, resolved.minute);

    return ParsedReminder(
      dateTime: resolved,
      description: '$dayName • $timeLabel',
    );
  }

  /// "بعد أسبوع" / "next week"
  static ParsedReminder? _tryNextWeek(String text, DateTime now) {
    final matches =
        text.contains('بعد أسبوع') || text.contains('الأسبوع القادم') || text.contains('next week');
    if (!matches) return null;

    final resolved = now.add(const Duration(days: 7));
    return ParsedReminder(
      dateTime: DateTime(resolved.year, resolved.month, resolved.day, 8, 0),
      description: 'الأسبوع القادم • 8:00 ص',
    );
  }

  // ── Time extraction helper ────────────────────────────────────

  /// Extracts (hour24, minute) from text, or null if not found.
  static (int, int)? _extractTime(String text) {
    // Arabic: الساعة X مساءً/صباحًا or X مساءً/صباحًا
    final arFull = RegExp(
      r'(?:الساعة\s+)?(\d{1,2})(?::(\d{2}))?\s*(صباحًا|صباحا|مساءً|مساء|ص|م)',
    ).firstMatch(text);
    if (arFull != null) {
      var h = int.parse(arFull.group(1)!);
      final m = int.tryParse(arFull.group(2) ?? '0') ?? 0;
      final period = arFull.group(3)!;
      if (period.contains('م') || period.contains('مساء')) {
        if (h != 12) h += 12;
      } else {
        if (h == 12) h = 0;
      }
      return (h.clamp(0, 23), m.clamp(0, 59));
    }

    // English: at X pm / X:XX am
    final enFull = RegExp(
      r'(?:at\s+)?(\d{1,2})(?::(\d{2}))?\s*(am|pm)',
    ).firstMatch(text);
    if (enFull != null) {
      var h = int.parse(enFull.group(1)!);
      final m = int.tryParse(enFull.group(2) ?? '0') ?? 0;
      final period = enFull.group(3)!;
      if (period == 'pm' && h != 12) h += 12;
      if (period == 'am' && h == 12) h = 0;
      return (h.clamp(0, 23), m.clamp(0, 59));
    }

    return null;
  }

  /// Formats hour/minute as "8:00 ص" or "8:00 PM" based on value.
  static String _formatTime(int h, int m) {
    final minute = m.toString().padLeft(2, '0');
    if (h < 12) {
      final display = h == 0 ? 12 : h;
      return '$display:$minute ص';
    } else {
      final display = h == 12 ? 12 : h - 12;
      return '$display:$minute م';
    }
  }
}
