class RecentFile {
  final String path;
  final DateTime lastAccessed;

  RecentFile({
    required this.path,
    required this.lastAccessed,
  });

  // Create from JSON
  factory RecentFile.fromJson(Map<String, dynamic> json) {
    return RecentFile(
      path: json['path'] as String,
      lastAccessed: DateTime.parse(json['lastAccessed'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'lastAccessed': lastAccessed.toIso8601String(),
    };
  }

  // Create a copy with updated values
  RecentFile copyWith({
    String? path,
    DateTime? lastAccessed,
  }) {
    return RecentFile(
      path: path ?? this.path,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecentFile && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
} 