enum AlarmSoundType { defaultSound, system, custom }

class AlarmSoundModel {
  final AlarmSoundType type;
  final String uri;      // The raw path or system content URI
  final String? fileName; // Saved filename for iOS Library/Sounds or Android FileProvider
  final String title;

  AlarmSoundModel({
    required this.type,
    required this.uri,
    this.fileName,
    required this.title,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'uri': uri,
    'fileName': fileName,
    'title': title,
  };

  factory AlarmSoundModel.fromJson(Map<String, dynamic> json) {
    return AlarmSoundModel(
      type: AlarmSoundType.values.byName(json['type'] as String),
      uri: json['uri'] as String,
      fileName: json['fileName'] as String?,
      title: json['title'] as String,
    );
  }

  // Serialize to string key format: type|uri|fileName|title
  String toKey() => '${type.name}|$uri|${fileName ?? ''}|$title';

  factory AlarmSoundModel.fromKey(String key) {
    if (key == 'default') {
      return AlarmSoundModel(type: AlarmSoundType.defaultSound, uri: 'default', title: 'Default');
    }
    final parts = key.split('|');
    if (parts.length >= 4) {
      return AlarmSoundModel(
        type: AlarmSoundType.values.byName(parts[0]),
        uri: parts[1],
        fileName: parts[2].isEmpty ? null : parts[2],
        title: parts[3],
      );
    }
    // Backward compatibility fallback for old "uri|name" format
    if (key.contains('|')) {
      final oldPath = parts[0];
      final oldName = parts[1];
      return AlarmSoundModel(
        type: AlarmSoundType.custom,
        uri: oldPath,
        fileName: oldName,
        title: oldName.split('.').first,
      );
    }
    return AlarmSoundModel(
      type: AlarmSoundType.defaultSound,
      uri: key,
      title: 'Default',
    );
  }
}
