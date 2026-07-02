import 'package:flutter_test/flutter_test.dart';
import 'package:engez/data/models/alarm_sound_model.dart';

void main() {
  group('AlarmSoundModel Tests', () {
    test('Default sound model parsing from key', () {
      final model = AlarmSoundModel.fromKey('default');
      expect(model.type, AlarmSoundType.defaultSound);
      expect(model.uri, 'default');
      expect(model.title, 'Default');
    });

    test('Custom sound model serialization and parsing', () {
      final original = AlarmSoundModel(
        type: AlarmSoundType.custom,
        uri: 'some/path/to/file.mp3',
        fileName: 'file.mp3',
        title: 'Custom Melody',
      );
      final key = original.toKey();
      expect(key, 'custom|some/path/to/file.mp3|file.mp3|Custom Melody');

      final parsed = AlarmSoundModel.fromKey(key);
      expect(parsed.type, AlarmSoundType.custom);
      expect(parsed.uri, 'some/path/to/file.mp3');
      expect(parsed.fileName, 'file.mp3');
      expect(parsed.title, 'Custom Melody');
    });
  });
}
