class VersionInfo {
  final String version;
  final String buildDate;
  final String appName;

  const VersionInfo({
    required this.version,
    required this.buildDate,
    required this.appName,
  });

  // JSON에서 VersionInfo 객체 생성
  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      version: json['version'] as String,
      buildDate: json['buildDate'] as String,
      appName: json['appName'] as String,
    );
  }

  // VersionInfo를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'buildDate': buildDate,
      'appName': appName,
    };
  }

  // 버전 문자열 생성
  String get versionString => '${appName}_V$version($buildDate)';
}
