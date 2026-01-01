/// Audio Item Model
/// 
/// Represents a single audio recording
class AudioItem {
  final String id;
  final String title;
  final Duration duration;
  final DateTime date;
  final String type; // 'cleaned', 'original', 'all'

  AudioItem({
    required this.id,
    required this.title,
    required this.duration,
    required this.date,
    required this.type,
  });

  factory AudioItem.fromJson(Map<String, dynamic> json) {
    return AudioItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled',
      duration: Duration(seconds: json['duration'] is int ? json['duration'] : 0),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      type: json['type'] ?? 'original',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'duration': duration.inSeconds,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  /// Format duration as MM:SS
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format date as "Month Day, Year"
  String get formattedDate {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

