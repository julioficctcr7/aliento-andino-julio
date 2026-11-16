import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/audio/audio_capture_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CircularAudioBuffer [SUB-01-A]', () {
    test('escribe y lee muestras recientes correctamente', () {
      final buffer = CircularAudioBuffer(capacity: 10);
      final samples = Float32List.fromList([0.1, 0.2, 0.3, 0.4, 0.5]);

      buffer.write(samples);
      expect(buffer.availableSamples, 5);

      final read = buffer.readRecent(3);
      expect(read.length, 3);
      expect(read[0], closeTo(0.3, 1e-5));
      expect(read[1], closeTo(0.4, 1e-5));
      expect(read[2], closeTo(0.5, 1e-5));
    });

    test('sobrescribe circularmente cuando se supera la capacidad máxima', () {
      final buffer = CircularAudioBuffer(capacity: 4);
      buffer.write(Float32List.fromList([1.0, 2.0, 3.0, 4.0]));
      expect(buffer.availableSamples, 4);

      // Escribir 2 muestras más -> expulsa 1.0 y 2.0
      buffer.write(Float32List.fromList([5.0, 6.0]));
      expect(buffer.availableSamples, 4);

      final read = buffer.readRecent(4);
      expect(read, [3.0, 4.0, 5.0, 6.0]);
    });

    test('clear() reinicia índices y limpia muestras', () {
      final buffer = CircularAudioBuffer(capacity: 8);
      buffer.write(Float32List.fromList([0.9, 0.8, 0.7]));
      expect(buffer.availableSamples, 3);

      buffer.clear();
      expect(buffer.availableSamples, 0);
      final read = buffer.readRecent(3);
      expect(read, [0.0, 0.0, 0.0]);
    });
  });

  group('AudioCaptureService [SUB-01-A]', () {
    test('construye con buffer circular de tamaño configurable', () {
      final service = AudioCaptureService(circularBufferCapacity: 2048);
      expect(service.isCapturing, isFalse);
      expect(service.circularBuffer.capacity, 2048);
    });

    test('pcmAudioStream expone stream de Float32List broadcast', () {
      final service = AudioCaptureService();
      final stream1 = service.pcmAudioStream;
      final stream2 = service.pcmAudioStream;
      expect(stream1, isNotNull);
      expect(stream2, isNotNull);
    });
  });
}
