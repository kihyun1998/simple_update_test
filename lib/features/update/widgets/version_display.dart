import 'package:flutter/material.dart';

class VersionDisplay extends StatelessWidget {
  final String? currentVersion;
  final String targetVersion;

  const VersionDisplay({
    super.key,
    required this.currentVersion,
    required this.targetVersion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        currentVersion != null
            ? "version: $currentVersion to $targetVersion"
            : "version: $targetVersion",
      ),
    );
  }
}
