# DESIGN.md — Especificación de Diseño Web Admin (Angular 21)

> **Ámbito**: Panel de administración y gestión pedagógica para docentes y administradores de **Aliento Andino**.
> **Tokens compartidos de color y tipografía base**: Consultar el sistema global en [`../../DESIGN.md`](../../DESIGN.md).

---

## 1. Arquitectura de Layout de Escritorio

El panel administrativo web está diseñado prioritariamente para pantallas de escritorio ($\ge 1280\text{px}$) y tablets en orientación horizontal ($\ge 960\text{px}$), estructurado a través de `AdminLayoutComponent`:

```
┌────────────────────────────────────────────────────────────────────────┐
│ Navbar Superior (64px altura fija, sticky)                            │
├───────────────┬────────────────────────────────────────────────────────┤
│ Sidebar       │ Área de Contenido Principal (Router Outlet)            │
│ (240px exp. / │ - Breadcrumbs y Título de Pantalla                     │
│  64px col.)   │ - Tarjetas KPI / Métricas                              │
│               │ - Tablas de Datos con Scroll Elástico                  │
│               │ - Gráficos Analíticos (ngx-charts)                     │
└───────────────┴────────────────────────────────────────────────────────┘
```

### Breakpoints Responsivos (Grid 12 Columnas)

| Breakpoint | Ancho Mínimo    | Comportamiento del Layout                                    |
| :--------- | :-------------- | :----------------------------------------------------------- |
| **`xs`**   | $0\text{px}$    | Sidebar oculto tras menú hamburguesa (off-canvas drawer).    |
| **`sm`**   | $600\text{px}$  | Formularios en 1 columna, tarjetas colapsadas verticalmente. |
| **`md`**   | $960\text{px}$  | Sidebar en modo icono ($64\text{px}$), grid en 2 columnas.   |
| **`lg`**   | $1280\text{px}$ | Sidebar completo ($240\text{px}$), grid en 3 o 4 columnas.   |
| **`xl`**   | $1920\text{px}$ | Contenedor centrado con `max-width: 1600px`.                 |

---

## 2. Sistema de Espaciado y Ritmo Vertical Web

Variables CSS implementadas en `apps/web/src/styles.css`:

| Token CSS                  | Valor  | Aplicación en Interfaz Web                                  |
| :------------------------- | :----- | :---------------------------------------------------------- |
| `--space-1` (`space-xs`)   | `4px`  | Micro-separación, espaciado de tags e iconos inline.        |
| `--space-2` (`space-sm`)   | `8px`  | Gap entre botones agrupados, padding interno de badges.     |
| `--space-3` (`space-md`)   | `12px` | Padding vertical en celdas de tabla compactas.              |
| `--space-4` (`space-lg`)   | `16px` | Padding estándar de inputs, separación entre filtros.       |
| `--space-6` (`space-xl`)   | `20px` | Padding interior de tarjetas (`.card`), headers de sección. |
| `--space-8` (`space-2xl`)  | `24px` | Separación entre bloques de widgets y diálogos modales.     |
| `--space-12` (`space-3xl`) | `32px` | Márgenes perimetrales de la vista principal.                |

---

## 3. Componentes de Datos y Gestión

### A. Tablas de Datos (`.table-container`)

- **Contenedor Elástico**: `min-width: 850px` con `overflow-x: auto` para prevenir desbordes.
- **Densidad de Fila**:
  - _Normal_: `48px` de altura, padding `12px 16px`.
  - _Compacta_: `36px` de altura, para visualización densa de registros de auditoría y telemetría.
- **Cabeceras (`th`)**: Fondo `--bg-surface-alt`, tipografía `12px` mayúsculas, peso `600`, color `--text-muted`.
- **Estados Hover**: Transición suave a `--bg-hover` (`#1A2235` en dark, `#E2E8F0` en light).

### B. Tarjetas Analíticas y Métricas (KPI Cards)

- Radio de borde: `16px` (`--radius-xl`).
- Fondo `--bg-surface`, borde de `1px solid var(--bg-border)`.
- Icono temático en caja redondeada con fondo alpha (`rgba(6, 182, 212, 0.1)`).
- Valor de la métrica en `Headline Medium` (`24px bold`) con indicador de tendencia (verde $\uparrow$, rojo $\downarrow$).

### C. Visualización de Gráficos (`ngx-charts`)

- Paleta adaptada al tema andino: Cyan (`#06B6D4`), Violeta (`#8B5CF6`), Esmeralda (`#10B981`), Ámbar (`#F59E0B`).
- Ejes y guías en color `--bg-border`.
- Tooltips flotantes con superficie `--bg-elevated` y bordes redondeados `8px`.

---

## 4. Formularios y Diálogos Modales

### A. Controles de Formulario (`.form-input`, `.form-select`, `.form-textarea`)

- Borde estándar: `1px solid var(--bg-border)` con radio de `8px`.
- Estado foco (`:focus`): Anillo accesible `2px solid var(--color-primary)` con outline compensado.
- Textos de ayuda y errores: Tipografía `12px` debajo del control; mensajes de error en `--color-error` (`#EF4444`).

### B. Modales y Diálogos (`MatDialog` / `.modal-surface`)

- Anchos máximos predefinidos:
  - Pequeño (`sm`): `400px` (confirmaciones destructivas, bans).
  - Mediano (`md`): `600px` (creación de categorías, asignación de tareas).
  - Grande (`lg`): `840px` (editor de notas musicales, reportes detallados).
- Radio de esquina: `16px`.
- Telón de fondo (_Backdrop_): `rgba(0, 0, 0, 0.6)` con efecto `backdrop-filter: blur(4px)`.

---

## 5. Editor de Notas y Tablatura Andina (`NotesEditor`)

Componente especializado para profesores:

- Rejilla secuencial de notas con representación de compás musical.
- Controles de nota: selector de afinación base (ej: G4, A4, B4), octava, duración (negra, corchea, semicorchea) y tolerancia de afinación en cents ($\pm 10$ a $\pm 30$).
- Previsualización gráfica de la digitación requerida según el instrumento andino seleccionado (Quena, Zampoña o Tarka).
