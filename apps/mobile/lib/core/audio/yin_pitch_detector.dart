import 'dart:math' as math;
import 'dart:typed_data';

/// Resultado de afinación acústica en tiempo real.
class TuningResult {
  final double detectedHz;
  final double targetHz;
  final double centsDeviation;
  final bool isTuned;
  final bool isSilent;
  final bool isOutOfRange;

  const TuningResult({
    required this.detectedHz,
    required this.targetHz,
    required this.centsDeviation,
    required this.isTuned,
    this.isSilent = false,
    this.isOutOfRange = false,
  });

  @override
  String toString() =>
      'TuningResult(detected: ${detectedHz.toStringAsFixed(2)} Hz, '
      'target: ${targetHz.toStringAsFixed(2)} Hz, '
      'cents: ${centsDeviation.toStringAsFixed(1)}, '
      'tuned: $isTuned, silent: $isSilent, outOfRange: $isOutOfRange)';
}

/// Implementación optimizada del algoritmo YIN para detección de frecuencia
/// fundamental (f0) en instrumentos de viento andinos (Quena, Zampoña y Tarka).
///
/// Optimizado para ventanas de 1024 a 2048 muestras a 44.1 kHz con latencia <35ms.
class YinPitchDetector {
  final int sampleRate;
  final double threshold;
  final double minFrequency;
  final double maxFrequency;
  final double silenceRmsThreshold;
  final double tunedToleranceCents;

  const YinPitchDetector({
    this.sampleRate = 44100,
    this.threshold = 0.15,
    this.minFrequency = 150.0,
    this.maxFrequency = 3000.0,
    this.silenceRmsThreshold = 0.01,
    this.tunedToleranceCents = 15.0,
  });

  /// Calcula la energía Root Mean Square (RMS) del buffer.
  double calculateRms(Float32List buffer) {
    if (buffer.isEmpty) return 0.0;
    double sum = 0.0;
    for (int i = 0; i < buffer.length; i++) {
      final s = buffer[i];
      sum += s * s;
    }
    return math.sqrt(sum / buffer.length);
  }

  /// Detecta la frecuencia fundamental (f0) en Hertz del buffer PCM dado.
  ///
  /// Si el buffer es silencioso (RMS < silenceRmsThreshold), retorna 0.0.
  /// Si la frecuencia está fuera del rango andino [minFrequency, maxFrequency], retorna 0.0.
  double detectFundamentalFrequency(Float32List pcmBuffer, [int? customRate]) {
    final rate = customRate ?? sampleRate;
    if (pcmBuffer.isEmpty) return 0.0;

    final rms = calculateRms(pcmBuffer);
    if (rms < silenceRmsThreshold) {
      return 0.0;
    }

    final minPeriod = (rate / maxFrequency).floor();
    final maxPeriod = (rate / minFrequency).ceil();

    final bufferSize = pcmBuffer.length;
    final windowSize = bufferSize ~/ 2;

    if (maxPeriod >= windowSize) {
      return 0.0;
    }

    // Paso 1: Función de Diferencia d_t(tau)
    final diff = Float64List(maxPeriod + 1);
    for (int tau = 1; tau <= maxPeriod; tau++) {
      double sum = 0.0;
      for (int i = 0; i < windowSize; i++) {
        final delta = pcmBuffer[i] - pcmBuffer[i + tau];
        sum += delta * delta;
      }
      diff[tau] = sum;
    }

    // Paso 2: Cumulative Mean Normalized Difference Function (CMND)
    final cmnd = Float64List(maxPeriod + 1);
    cmnd[0] = 1.0;
    double runningSum = 0.0;

    for (int tau = 1; tau <= maxPeriod; tau++) {
      runningSum += diff[tau];
      if (runningSum > 0.0) {
        cmnd[tau] = diff[tau] * tau / runningSum;
      } else {
        cmnd[tau] = 1.0;
      }
    }

    // Paso 3: Búsqueda del primer valle bajo el umbral absoluto
    int tauEstimate = -1;
    for (int tau = minPeriod; tau <= maxPeriod; tau++) {
      if (cmnd[tau] < threshold) {
        while (tau + 1 <= maxPeriod && cmnd[tau + 1] < cmnd[tau]) {
          tau++;
        }
        tauEstimate = tau;
        break;
      }
    }

    // Si no cruzó el umbral, buscar el mínimo global
    if (tauEstimate == -1) {
      double minVal = double.infinity;
      for (int tau = minPeriod; tau <= maxPeriod; tau++) {
        if (cmnd[tau] < minVal) {
          minVal = cmnd[tau];
          tauEstimate = tau;
        }
      }
      if (minVal > 0.4) {
        return 0.0;
      }
    }

    // Paso 4: Interpolación Parabólica para resolución sub-sample
    double betterTau = tauEstimate.toDouble();
    if (tauEstimate > 1 && tauEstimate < maxPeriod) {
      final s0 = cmnd[tauEstimate - 1];
      final s1 = cmnd[tauEstimate];
      final s2 = cmnd[tauEstimate + 1];
      final denom = 2.0 * (2.0 * s1 - s0 - s2);
      if (denom.abs() > 1e-9) {
        final delta = (s2 - s0) / denom;
        betterTau = tauEstimate + delta;
      }
    }

    if (betterTau <= 0.0) return 0.0;

    final frequency = rate / betterTau;
    if (frequency < minFrequency || frequency > maxFrequency) {
      return 0.0;
    }

    return frequency;
  }

  /// Calcula la desviación en Cents entre la frecuencia detectada y la objetivo.
  ///
  /// Fórmula: 1200 * log2(detectedHz / targetHz)
  double calculateCentsDeviation(double detectedHz, double targetHz) {
    if (detectedHz <= 0.0 || targetHz <= 0.0) return 0.0;
    return 1200.0 * (math.log(detectedHz / targetHz) / math.ln2);
  }

  /// Evalúa la afinación completa de una muestra.
  TuningResult evaluateTuning({
    required double detectedHz,
    required double targetHz,
    double? toleranceCents,
  }) {
    final tolerance = toleranceCents ?? tunedToleranceCents;

    if (detectedHz <= 0.0) {
      return TuningResult(
        detectedHz: 0.0,
        targetHz: targetHz,
        centsDeviation: 0.0,
        isTuned: false,
        isSilent: true,
      );
    }

    if (detectedHz < minFrequency || detectedHz > maxFrequency) {
      final cents = calculateCentsDeviation(detectedHz, targetHz);
      return TuningResult(
        detectedHz: detectedHz,
        targetHz: targetHz,
        centsDeviation: cents,
        isTuned: false,
        isOutOfRange: true,
      );
    }

    final cents = calculateCentsDeviation(detectedHz, targetHz);
    final isTuned = cents.abs() <= tolerance;

    return TuningResult(
      detectedHz: detectedHz,
      targetHz: targetHz,
      centsDeviation: cents,
      isTuned: isTuned,
    );
  }
}
