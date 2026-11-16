# DESIGN.md — Sistema de Diseño Central y Tokens Compartidos

> **Ámbito**: Sistema de diseño unificado de **Aliento Andino**. Define los tokens nucleares de color, tipografía base, accesibilidad y semántica pedagógica compartida entre la aplicación Web (Angular) y Móvil (Flutter).  
> **Especificaciones por plataforma**:
>
> - 💻 **Panel Web Admin (Desktop & Data)**: [`apps/web/DESIGN.md`](apps/web/DESIGN.md)
> - 📱 **App Móvil (Ergonomía Táctil & HUD)**: [`apps/mobile/DESIGN.md`](apps/mobile/DESIGN.md)

---

## 1. Filosofía Visual e Identidad Andina

El lenguaje visual de Aliento Andino fusiona la **riqueza cultural de los aerófonos andinos** (Quena, Zampoña, Tarka) con la precisión analítica de una plataforma EdTech moderna:

- **Enfoque Dark-First**: Diseñado principalmente para sesiones de práctica en entornos con baja iluminación y confort visual durante horas continuas de estudio musical.
- **Soporte Light Mode Completo**: Mapeo simétrico de contrastes para aulas iluminadas y oficinas docentes.
- **Semántica Pedagógica Clara**: El color nunca es decorativo; comunica afinación, estabilidad rítmica y alineación postural.

---

## 2. Paleta de Colores y Tokens Nucleares

Los tokens se encuentran sincronizados entre las variables CSS (`apps/web/src/styles.css`) y el tema declarativo en Flutter (`apps/mobile/lib/core/theme/app_theme.dart`).

### A. Colores Semánticos Principales

| Token Semántico           | Dark Mode | Light Mode | Variable CSS (`:root`) | Flutter (`AppTheme`) | Significado Pedagógico / Uso                                                         |
| :------------------------ | :-------- | :--------- | :--------------------- | :------------------- | :----------------------------------------------------------------------------------- |
| **Primary (Cyan Andino)** | `#06B6D4` | `#0891B2`  | `--color-primary`      | `AppTheme.cyan`      | Identidad central, nota esperada, foco activo y acciones principales.                |
| **Secondary (Violeta)**   | `#8B5CF6` | `#7C3AED`  | `--color-violet`       | `AppTheme.purple`    | Niveles avanzados, teoría musical y gamificación.                                    |
| **Success (Esmeralda)**   | `#10B981` | `#059669`  | `--color-success`      | `AppTheme.success`   | **Nota perfectamente afinada** ($\pm 15$ cents), lección aprobada, postura correcta. |
| **Warning (Ámbar)**       | `#F59E0B` | `#D97706`  | `--color-warning`      | `AppTheme.warning`   | **Afinación inestable** (desviación de cents), postura relajada a corregir.          |
| **Error (Carmesí)**       | `#EF4444` | `#DC2626`  | `--color-error`        | `AppTheme.error`     | **Nota errónea**, digitación incorrecta, acción destructiva.                         |
| **Streak (Naranja Inti)** | `#F97316` | `#EA580C`  | `--color-orange`       | `AppTheme.orange`    | Racha de práctica diaria ("Streak Flame"), fuego de constancia.                      |
| **Info (Azul Titiqaqa)**  | `#3B82F6` | `#2563EB`  | `--color-blue`         | `AppTheme.info`      | Calibración de micrófono, avisos del sistema y estados de conexión.                  |

---

### B. Superficies, Fondos y Contornos

| Token                        | Dark Mode | Light Mode | Variable CSS    | Flutter Theme             |
| :--------------------------- | :-------- | :--------- | :-------------- | :------------------------ |
| **Fondo Base (Body)**        | `#0A0E17` | `#F8FAFC`  | `--bg-body`     | `scaffoldBackgroundColor` |
| **Superficie de Tarjeta**    | `#111827` | `#FFFFFF`  | `--bg-surface`  | `colorScheme.surface`     |
| **Superficie Elevada**       | `#1F2937` | `#F1F5F9`  | `--bg-elevated` | `surfaceContainerHigh`    |
| **Superficie Hover**         | `#1A2235` | `#E2E8F0`  | `--bg-hover`    | `surfaceContainerHighest` |
| **Bordes Estándar**          | `#1E293B` | `#CBD5E1`  | `--bg-border`   | `outline`                 |
| **Bordes Muted / Divisores** | `#374151` | `#E2E8F0`  | `--bg-muted`    | `dividerColor`            |

---

## 3. Tipografía Base y Jerarquía

La tipografía base del ecosistema es **Inter** (con fallback a `system-ui, -apple-system, Roboto, sans-serif`):

| Escala                 | Tamaño | Peso (Weight)   | Altura de Línea | Uso                                                       |
| :--------------------- | :----- | :-------------- | :-------------- | :-------------------------------------------------------- |
| **Headline Large**     | `32px` | 700 (Bold)      | `1.2`           | Títulos principales de sección y felicitaciones de nivel. |
| **Headline Medium**    | `24px` | 600 (Semi-bold) | `1.3`           | Títulos de tarjetas de lección, cabeceras de diálogo.     |
| **Headline Small**     | `18px` | 600 (Semi-bold) | `1.4`           | Subtítulos de módulos y nombres de canciones.             |
| **Body Large**         | `16px` | 500 (Medium)    | `1.5`           | Botones principales y texto de lectura destacado.         |
| **Body Medium (Base)** | `14px` | 400 (Regular)   | `1.5`           | Párrafos generales, métricas y celdas tabulares.          |
| **Caption / Subtitle** | `12px` | 500 (Medium)    | `1.4`           | Etiquetas de digigramas, notas al pie y timestamps.       |

---

## 4. Accesibilidad Universal (WCAG 2.1 AA)

1. **Contraste de Color**: Todo texto sobre cualquier fondo cumple un ratio mínimo de contraste de $4.5:1$ ($3:1$ para gráficos y controles táctiles).
2. **Resiliencia al Daltonismo**: La retroalimentación de afinación musical nunca depende exclusivamente del color:
   - Verde (Afinado) va acompañado del valor numérico de cents y la aguja en centro.
   - Naranja/Rojo (Desafinado) incluye indicadores direccionales $\uparrow$ (subir tono) o $\downarrow$ (bajar tono).
3. **Mapeo por Plataforma**:
   - Para las especificaciones de pantalla ancha, tablas y gráficos web, consultar [`apps/web/DESIGN.md`](apps/web/DESIGN.md).
   - Para la ergonomía táctil, Ley de Fitts y el HUD interactivo móvil, consultar [`apps/mobile/DESIGN.md`](apps/mobile/DESIGN.md).
