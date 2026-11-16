# DESIGN.md — Especificación de Diseño Móvil (Flutter 3.x)

> **Ámbito**: Aplicación móvil interactiva para estudiantes de **Aliento Andino** (Android / iOS).  
> **Tokens compartidos de color y tipografía base**: Consultar el sistema global en [`../../DESIGN.md`](../../DESIGN.md).

---

## 1. Ergonomía Móvil y Ley de Fitts

La práctica de instrumentos de viento andinos impone restricciones físicas singulares: el estudiante sostiene la flauta o zampoña con ambas manos, teniendo acceso limitado a la pantalla táctil durante la ejecución.

### Reglas Ergonómicas Obligatorias

1. **Área Efectiva de Toque Mínima**: Todo botón o elemento accionable posee una dimensión efectiva $\ge 48\text{px} \times 48\text{px}$.
2. **Controles de Alto Impacto**: Botones críticos (Iniciar Práctica, Pausa, Recalibrar Soplo, Siguiente Ejercicio) tienen un área $\ge 52\text{px} \times 52\text{px}$ con padding táctil ampliado (`minTargetSize: MaterialTapTargetSize.padded`).
3. **Arquitectura "Thumb Zone"**: Las acciones principales de control se concentran en el tercio inferior de la pantalla, accesibles con el pulgar sin forzar la muñeca.
4. **Respuesta Háptica**: Vibración corta (`HapticFeedback.selectionClick`) al cambiar de nota afinada, y vibración prolongada (`HapticFeedback.mediumImpact`) al completar un compás perfecto.

---

## 2. Escala de Espaciado y Geometría Móvil

Tokens implementados en `apps/mobile/lib/core/theme/app_theme.dart`:

| Token          | Dimensión | Uso Habitual en Flutter                                                 |
| :------------- | :-------- | :---------------------------------------------------------------------- |
| **`spaceXs`**  | `4.0`     | Espacio entre iconos pequeños y etiquetas numéricas de digitación.      |
| **`spaceSm`**  | `8.0`     | Separación entre tubos de zampoña en digigramas, gaps de chips.         |
| **`spaceMd`**  | `12.0`    | Padding de listas compactas, márgenes de badges.                        |
| **`spaceLg`**  | `16.0`    | Margen perimetral estándar (`EdgeInsets.all(16)`), padding de tarjetas. |
| **`spaceXl`**  | `20.0`    | Separación entre bloques de ejercicios y secciones del perfil.          |
| **`space2Xl`** | `24.0`    | Padding superior de Bottom Sheets y cabeceras de lección.               |
| **`space3Xl`** | `32.0`    | Separación mayor en pantallas de bienvenida y felicitación de nivel.    |

### Radios de Borde Móvil

- **`radiusMd` (`8.0`)**: Indicadores de cents y micro-chips.
- **`radiusLg` (`12.0`)**: Botones estándar (`ElevatedButton`, `OutlinedButton`).
- **`radiusXl` (`16.0`)**: Tarjetas de canciones (`Card`), cuadros de diálogo.
- **`radiusSheet` (`24.0`)**: Esquinas superiores de `ModalBottomSheet`.
- **`radiusPill` (`999.0`)**: Botón de racha ("Streak Flame"), cápsulas de nivel y FABs.

---

## 3. HUD de Práctica en Tiempo Real (Heads-Up Display)

La pantalla de práctica activa combina telemetría multimodal simultánea sin sobrecargar la atención del alumno:

```
┌──────────────────────────────────────────────────────────────┐
│ [← Atrás]       El Cóndor Pasa (Compás 3/16)       [⚙ Ajustes]│
├──────────────────────────────────────────────────────────────┤
│                                                              │
│              [ AGUJA DEL AFINADOR EN CENTS ]                 │
│              -50 ─── [-15  0  +15] ─── +50                   │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                PENTAGRAMA / TABLATURA ANDINA                 │
│          ♪─── Sol4 ─── La4 ─── Si4 ─── Re5                   │
│               [  Cursor de Seguimiento  ]                    │
├──────────────────────────────┬───────────────────────────────┤
│ DIGIGRAMA INTERACTIVO        │ MONITOR POSTURAL (PiP)        │
│ ● (Orificio 1 obturado)      │ [ Cámara Frontal MediaPipe ]  │
│ ● (Orificio 2 obturado)      │ Ángulo codos: 52° (OK)        │
│ ○ (Orificio 3 abierto)       │ Columna erguida (OK)          │
├──────────────────────────────┴───────────────────────────────┤
│ [ ⏸ Pausar ]            [ ↺ Reintentar ]         [ ▶ Continuar]│
└──────────────────────────────────────────────────────────────┘
```

### Componentes Clave del HUD

1. **Afinador de Aguja en Cents (`PitchGaugeWidget`)**:
   - Escala semicircular o lineal continua de $-50$ a $+50$ cents.
   - Zona verde de tolerancia pedagógica: $[-15, +15]$ cents.
   - Indicador visual redundante: Iconos $\uparrow$ (subir tono) o $\downarrow$ (bajar tono) para estudiantes daltónicos.
2. **Digigramas de Viento Andino (`WindGuideWidget`)**:
   - **Quena**: Representación de 6 orificios frontales y 1 posterior (pulgar), con coloreado dinámico según la nota requerida.
   - **Zampoña (Siku)**: Representación de hileras **Ira** (6 tubos) y **Arka** (7 tubos), iluminando el tubo activo con el flujo de aire sugerido.
   - **Tarka**: Diagrama de 6 orificios y marcador de presión de aire ("soplo con carácter").
3. **Cámara Postural PiP (`PostureOverlayWidget`)**:
   - Recuadro flotante de $120\text{px} \times 90\text{px}$ en esquina inferior.
   - Esqueleto MediaPipe sintetizado: verde para postura adecuada, naranja cuando los codos caen o el cuello se flexiona excesivamente.

---

## 4. Componentes Sociales y Gamificación

- **`StreakFlameWidget`**: Indicador animado de racha de estudio diaria con gradientes naranja (`#F97316`) y amarillo Inti (`#F59E0B`).
- **Insignias Andinas (`AndeanBadgeCard`)**: Representaciones vectoriales de la Chacana, Inti y Killa con acabado metálico (Oro, Plata, Bronce).
- **Muro Comunitario**: Feed de publicaciones con reproducción de grabaciones de audio, sistema de ánimos (_"kallpa"_) y desafíos musicales asíncronos.
