# Feature: HU-01 Afinador Cromático de Aguja y Detección de Frecuencia Fundamental en Tiempo Real

Parent Issue: #8 | Milestone: Sprint 1 | Story Points: 8 SP
Architecture: Mobile (Flutter 3.x) & Backend (FastAPI Python 3.12)

## Specs

S1: "Capturar audio del micrófono del dispositivo móvil mediante buffer circular de 1024 muestras a 44100 Hz, enviándolo a un worker isolate para no congelar la UI."
S2: "Clase: AudioCaptureService, Método: Stream<Float32List> get pcmAudioStream, Método: Future<void> startCapture({int sampleRate = 44100, int bufferSize = 1024}), Método: Future<void> stopCapture()"
S3: "Manejo de Errores: PermissionDeniedException: Si el usuario deniega permiso de micrófono, emitir estado AudioPermissionDenied para mostrar diálogo explicativo. AudioHardwareException: Fallo al inicializar stream de audio, emitir reintento con backoff."
S4: "Renderizar la aguja de afinación reactiva con física suavizada (interpolación lerp), rango de ±50 cents, display de frecuencia en Hz y cambio de color dinámico según tolerancia, consumiendo tokens de apps/mobile/DESIGN.md."
S5: "Clase: TunerBloc, Evento: TunerPitchSampleReceived(double detectedHz, String targetNote, double targetHz), Estado: TunerActiveState(double centsDeviation, String noteName, bool isTuned, double frequencyHz)"
S6: "Tokens de color: Afinado #10B981 (<= ±15 cents), Desviación leve #F97316, Desafinado #EF4444."
S7: "Ausencia de audio o silencio prolongado: Retornar aguja al centro en reposo gradualmente (cents = 0, opacidad reducida)."
S8: "Proveer configuración de afinación y rangos de cents por instrumento andino (Quena: ±15 cents, Zampoña: ±20 cents, Tarka: ±25 cents) con persistencia en backend."
S9: "Endpoint: GET /api/v1/tuning/tolerances, Schema de respuesta: InstrumentTuningResponse(instrument: str, base_hz: float, allowed_cents_tolerance: float)"
S10: "Manejo de Errores: Instrumento no soportado: HTTP 400 Bad Request con mensaje 'Instrumento no admitido. Valores válidos: quena, zampona, tarka'."

## Tasks

- T1 (Specs: S1, S2, S3) [inline]: Implementar AudioCaptureService con buffer circular de 1024 muestras y tests unitarios. (Issue #9 - SUB-01-A)
- T2 (Specs: S4, S5, S6, S7) [inline]: Implementar TunerBloc, TunerGaugeWidget y TunerScreen consumiendo tokens y tests de widget/bloc. (Issue #10 - SUB-01-B)
- T3 (Specs: S8, S9, S10) [inline]: Implementar schemas, servicio, router y tests en backend para tolerancias de afinación andina. (Issue #11 - SUB-01-C)

## Log

L1: "Implementa las subissues de la issue #8 perteneciente a la HU-01, utiliza ODD. @[AGENTS.md]"
