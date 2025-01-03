class AppConfig {
  final String title;
  final String ip;
  final String name;
  final String? fromVersion;

  const AppConfig({
    required this.title,
    required this.ip,
    required this.name,
    this.fromVersion,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final profileList = json['profileList'] as List;
    final firstProfile = profileList.first as Map<String, dynamic>;

    return AppConfig(
      title: json['title'] ?? 'Default Title',
      ip: firstProfile['ip'] ?? 'localhost:8080',
      name: firstProfile['name'] ?? 'server',
      fromVersion: null,
    );
  }

  AppConfig copyWith({
    String? title,
    String? ip,
    String? name,
    String? fromVersion,
  }) {
    return AppConfig(
      title: title ?? this.title,
      ip: ip ?? this.ip,
      name: name ?? this.name,
      fromVersion: fromVersion ?? this.fromVersion,
    );
  }
}
