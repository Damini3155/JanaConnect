import 'dart:async';
import 'dart:typed_data';
import 'package:record_platform_interface/record_platform_interface.dart';

/// Stub Linux implementation of the record plugin.
/// Implements all abstract members of record_platform_interface 1.6.0.
/// Throws UnsupportedError at runtime since Linux is not a target for this app.
class RecordLinux extends RecordPlatform {
  static void registerWith() {
    RecordPlatform.instance = RecordLinux();
  }

  @override
  Future<void> create(String recorderId) async {}

  @override
  Future<void> dispose(String recorderId) async {}

  @override
  Future<bool> hasPermission(String recorderId, {bool request = true}) async {
    return false;
  }

  @override
  Future<bool> isPaused(String recorderId) async => false;

  @override
  Future<bool> isRecording(String recorderId) async => false;

  @override
  Future<void> pause(String recorderId) async {}

  @override
  Future<void> resume(String recorderId) async {}

  @override
  Future<void> cancel(String recorderId) async {}

  @override
  Future<bool> isEncoderSupported(
    String recorderId,
    AudioEncoder encoder,
  ) async {
    return false;
  }

  @override
  Stream<RecordState> onStateChanged(String recorderId) {
    return const Stream.empty();
  }

  @override
  Future<void> start(
    String recorderId,
    RecordConfig config, {
    required String path,
  }) async {
    throw UnsupportedError('record is not supported on Linux');
  }

  @override
  Future<Stream<Uint8List>> startStream(
    String recorderId,
    RecordConfig config,
  ) async {
    throw UnsupportedError('record streaming is not supported on Linux');
  }

  @override
  Future<String?> stop(String recorderId) async => null;

  @override
  Future<List<InputDevice>> listInputDevices(String recorderId) async => [];

  @override
  Future<Amplitude> getAmplitude(String recorderId) async {
    return Amplitude(current: 0, max: 0);
  }
}
