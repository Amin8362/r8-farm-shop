import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class FarmSoundEngine {
  static const int _sampleRate = 22050;

  final List<AudioPlayer> _pool = List.generate(6, (_) => AudioPlayer());
  int _poolIndex = 0;

  bool _enabled = true;
  bool _ready = false;

  Source? _plantSrc;
  Source? _harvestSrc;
  Source? _sellSrc;
  Source? _upgradeSrc;
  Source? _stageSrc;
  Source? _failSrc;
  Source? _clickSrc;

  bool get enabled => _enabled;

  void setEnabled(bool value) {
    _enabled = value;
  }

  Future<void> init() async {
    if (_ready) return;
    try {
      for (final AudioPlayer p in _pool) {
        await p.setReleaseMode(ReleaseMode.stop);
      }

      _plantSrc = await _prepareSource('farm_plant', _buildPlantWav());
      _harvestSrc = await _prepareSource('farm_harvest', _buildHarvestWav());
      _sellSrc = await _prepareSource('farm_sell', _buildSellWav());
      _upgradeSrc = await _prepareSource('farm_upgrade', _buildUpgradeWav());
      _stageSrc = await _prepareSource('farm_stage', _buildStageClearWav());
      _failSrc = await _prepareSource('farm_fail', _buildFailWav());
      _clickSrc = await _prepareSource('farm_click', _buildClickWav());
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  Future<void> dispose() async {
    for (final AudioPlayer p in _pool) {
      try {
        await p.dispose();
      } catch (_) {}
    }
  }

  void playPlant() => _play(_plantSrc, volume: 0.65);
  void playHarvest() => _play(_harvestSrc, volume: 0.78);
  void playSell() => _play(_sellSrc, volume: 0.85);
  void playUpgrade() => _play(_upgradeSrc, volume: 0.85);
  void playStageClear() => _play(_stageSrc, volume: 0.92);
  void playFail() => _play(_failSrc, volume: 0.55);
  void playClick() => _play(_clickSrc, volume: 0.45);

  Future<void> _play(Source? source, {double volume = 0.75}) async {
    if (!_enabled || !_ready || source == null) return;
    try {
      final AudioPlayer player = _pool[_poolIndex];
      _poolIndex = (_poolIndex + 1) % _pool.length;
      final PlayerMode mode = source is DeviceFileSource
          ? PlayerMode.lowLatency
          : PlayerMode.mediaPlayer;
      await player.stop();
      await player.play(source, volume: volume, mode: mode);
    } catch (_) {}
  }

  Future<Source> _prepareSource(String name, Uint8List wavBytes) async {
    try {
      final File file = File('${Directory.systemTemp.path}/r8_$name.wav');
      await file.writeAsBytes(wavBytes, flush: true);
      return DeviceFileSource(file.path);
    } catch (_) {
      return BytesSource(wavBytes);
    }
  }

  Uint8List _buildPlantWav() {
    return _synthesize(0.085, (double t, double dur) {
      final double p = t / dur;
      final double freq = 190.0 + 210.0 * p;
      final double env = math.sin(math.pi * p) * math.exp(-3.5 * p);
      return math.sin(2.0 * math.pi * freq * t) * env * 0.65;
    });
  }

  Uint8List _buildHarvestWav() {
    return _synthesize(0.14, (double t, double dur) {
      final double p = t / dur;
      final double freq = p < 0.45 ? 587.33 : 880.0;
      final double env = (t / 0.008).clamp(0.0, 1.0) * math.exp(-7.5 * p);
      return math.sin(2.0 * math.pi * freq * t) * env * 0.65;
    });
  }

  // صدای صندوق پول (چاچینگ دو نت روشن)
  Uint8List _buildSellWav() {
    return _synthesize(0.24, (double t, double dur) {
      final double p = t / dur;
      final bool second = p >= 0.35;
      final double freq = second ? 1318.5 : 987.77;
      final double localP = second ? (p - 0.35) / 0.65 : p / 0.35;
      final double env =
          (localP / 0.06).clamp(0.0, 1.0) * math.exp(-5.5 * localP);
      final double tone = 0.72 * math.sin(2.0 * math.pi * freq * t) +
          0.28 * math.sin(2.0 * math.pi * freq * 2.0 * t);
      return tone * env * 0.6;
    });
  }

  Uint8List _buildUpgradeWav() {
    const List<double> notes = [523.25, 659.25, 783.99, 1046.5];
    return _synthesize(0.32, (double t, double dur) {
      final double p = t / dur;
      final int idx = (p * notes.length).floor().clamp(0, notes.length - 1);
      final double localP = (p * notes.length) - idx;
      final double env =
          (localP / 0.08).clamp(0.0, 1.0) * math.exp(-3.8 * localP);
      return math.sin(2.0 * math.pi * notes[idx] * t) * env * 0.6;
    });
  }

  Uint8List _buildStageClearWav() {
    const List<double> notes = [523.25, 659.25, 783.99, 1046.5, 1318.5];
    return _synthesize(0.55, (double t, double dur) {
      final double p = t / dur;
      final int idx = (p * notes.length).floor().clamp(0, notes.length - 1);
      final double localP = (p * notes.length) - idx;
      final double env =
          (localP / 0.08).clamp(0.0, 1.0) * math.exp(-2.8 * localP);
      final double f = notes[idx];
      final double wave = 0.75 * math.sin(2.0 * math.pi * f * t) +
          0.25 * math.sin(2.0 * math.pi * f * 1.5 * t);
      return wave * env * 0.65;
    });
  }

  Uint8List _buildFailWav() {
    return _synthesize(0.16, (double t, double dur) {
      final double p = t / dur;
      final double freq = 220.0 - 95.0 * p;
      final double env = math.exp(-7.5 * p);
      return math.sin(2.0 * math.pi * freq * t) * env * 0.55;
    });
  }

  Uint8List _buildClickWav() {
    return _synthesize(0.045, (double t, double dur) {
      final double p = t / dur;
      final double env = math.exp(-22.0 * p);
      return math.sin(2.0 * math.pi * 760.0 * t) * env * 0.4;
    });
  }

  Uint8List _synthesize(
    double durationSec,
    double Function(double t, double dur) sampleAt,
  ) {
    final int numSamples = (_sampleRate * durationSec).round();
    final int dataSize = numSamples * 2;
    final ByteData bytes = ByteData(44 + dataSize);

    bytes.setUint8(0, 0x52);
    bytes.setUint8(1, 0x49);
    bytes.setUint8(2, 0x46);
    bytes.setUint8(3, 0x46);
    bytes.setUint32(4, 36 + dataSize, Endian.little);
    bytes.setUint8(8, 0x57);
    bytes.setUint8(9, 0x41);
    bytes.setUint8(10, 0x56);
    bytes.setUint8(11, 0x45);

    bytes.setUint8(12, 0x66);
    bytes.setUint8(13, 0x6D);
    bytes.setUint8(14, 0x74);
    bytes.setUint8(15, 0x20);
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 1, Endian.little);
    bytes.setUint32(24, _sampleRate, Endian.little);
    bytes.setUint32(28, _sampleRate * 2, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);

    bytes.setUint8(36, 0x64);
    bytes.setUint8(37, 0x61);
    bytes.setUint8(38, 0x74);
    bytes.setUint8(39, 0x61);
    bytes.setUint32(40, dataSize, Endian.little);

    for (int i = 0; i < numSamples; i++) {
      final double t = i / _sampleRate;
      final double clamped = sampleAt(t, durationSec).clamp(-1.0, 1.0);
      bytes.setInt16(44 + i * 2, (clamped * 32767).round(), Endian.little);
    }

    return bytes.buffer.asUint8List();
  }
}
