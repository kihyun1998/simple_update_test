class VersionInfo {
  final String version;
  final String buildDate;
  final String versionString;

  const VersionInfo({
    required this.version,
    required this.buildDate,
    required this.versionString,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      version: json['version'] as String,
      buildDate: json['buildDate'] as String,
      versionString: json['versionString'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'buildDate': buildDate,
      'versionString': versionString,
    };
  }
}
