# Estándares de Codificación — Aliento Andino

> Convenciones por tecnología. El formato lo imponen las herramientas automáticas (`ruff format`, `dart format`, Prettier) y el análisis estático lo verifican los linters (`ruff check`, `flutter analyze`, `eslint`). Ante cualquier duda, prevalece la convención ya establecida en el código adyacente.

---

## 1. Resumen por Tecnología

| Ámbito                                          | Indentación | Longitud Máxima | Estilo Base y Herramienta                                 |
| :---------------------------------------------- | :---------: | :-------------: | :-------------------------------------------------------- |
| **Python** (`apps/backend/`, `apps/ml/`)        | 4 espacios  | 100 caracteres  | PEP 8, Ruff (`pyproject.toml`)                            |
| **Dart / Flutter** (`apps/mobile/`)             | 2 espacios  |  80 caracteres  | Effective Dart, `flutter_lints` (`analysis_options.yaml`) |
| **TypeScript** (`apps/web/`, `apps/docs/`)      | 2 espacios  | 100 caracteres  | Angular Style Guide, ESLint (`eslint.config.js`)          |
| **SQL / Migraciones** (`apps/backend/alembic/`) | 4 espacios  | 100 caracteres  | PostgreSQL estándar, `snake_case`                         |
| **Markdown, JSON, YAML**                        | 2 espacios  | 100 caracteres  | Prettier (`.prettierrc`)                                  |

---

## 2. Python (Backend — FastAPI)

**Herramienta:** [Ruff](https://docs.astral.sh/ruff/) (linter + formateador).  
**Configuración:** [`apps/backend/pyproject.toml`](../apps/backend/pyproject.toml)

### Nombres y Convenciones

| Elemento              | Convención         | Ejemplo                                          |
| :-------------------- | :----------------- | :----------------------------------------------- |
| Módulos y paquetes    | `snake_case`       | `auth_service.py`, `practice_service.py`         |
| Funciones y variables | `snake_case`       | `get_feed()`, `practice_session_id`              |
| Funciones privadas    | `_snake_case`      | `_build_post_response()`, `_notify_mentions()`   |
| Clases y modelos ORM  | `PascalCase`       | `User`, `Lesson`, `PracticeSession`              |
| Esquemas Pydantic     | `PascalCase`       | `UserResponse`, `LessonCreate`, `PracticeResult` |
| Constantes            | `UPPER_SNAKE_CASE` | `ACCESS_TOKEN_EXPIRE_MINUTES`                    |

### Reglas de Arquitectura y Buenas Prácticas

- **Arquitectura en Capas:**
  - `routers/`: Solo valida entradas HTTP, autoriza permisos y delega a servicios. **Prohibido ejecutar consultas SQL directas en routers.**
  - `services/`: Contiene la lógica de negocio, cálculos musicales y transacciones.
  - `models/`: Declaración de tablas y relaciones ORM (SQLAlchemy 2).
  - `schemas/`: Validación y serialización Pydantic v2 estricta.
- **Tipado Explícito Obligatorio:** Todos los parámetros y valores de retorno deben declarar _type hints_ (`async def evaluate_lesson(db: AsyncSession, user_id: uuid.UUID) -> LessonResponse`).
- **Validación Estricta:** Las entradas de API deben validarse mediante esquemas Pydantic v2, nunca parseando `request.json()` manualmente.
- **Manejo Honesto de Excepciones:** Lanzar `HTTPException` con código de estado HTTP estándar (400, 401, 403, 404, 422, 500) y mensaje descriptivo en español para el usuario.
- **Docstrings:** Estilo Google en funciones y clases de servicio.

---

## 3. Dart (Mobile — Flutter)

**Herramienta:** [flutter_lints](https://pub.dev/packages/flutter_lints) + `dart format`.  
**Configuración:** [`apps/mobile/analysis_options.yaml`](../apps/mobile/analysis_options.yaml)

### Nombres y Convenciones

| Elemento               | Convención                                | Ejemplo                                        |
| :--------------------- | :---------------------------------------- | :--------------------------------------------- |
| Clases, widgets, tipos | `PascalCase`                              | `LessonPlayerScreen`, `TunerBloc`              |
| Archivos y carpetas    | `snake_case`                              | `lesson_player_screen.dart`, `tuner_bloc.dart` |
| Métodos y variables    | `camelCase`                               | `calculateCents()`, `isNoteCorrect`            |
| Constantes             | `lowerCamelCase` / `SCREAMING_SNAKE_CASE` | `kMinTargetSize`, `DEFAULT_BUFFER_SIZE`        |

### Reglas de Arquitectura y Buenas Prácticas

- **Arquitectura Clean + BLoC:**

  ```text
  features/<modulo>/
    data/          → models/ (DTOs), repositories/ (acceso a backend/local)
    presentation/
      bloc/        → eventos, estados y BLoC (lógica reactiva de UI)
      screens/     → pantallas completas
      widgets/     → componentes de UI y digitación reutilizables
  core/            → router, theme, network (Dio), constants
  ```

- **Inmutabilidad y Optimización:**
  - Constructores `const` obligatorios en widgets sin estado o con propiedades finales (`prefer_const_constructors`).
  - Separación estricta entre estados y eventos en BLoC.
- **Liberación de Recursos:** Sobrecarga obligatoria de `dispose()` en todos los controladores de audio, cámaras, animaciones y streams para evitar fugas de memoria.
- **Tokens de Diseño:** Prohibido el uso de colores hexadecimales arbitrarios. Reutilizar `Theme.of(context).colorScheme.*` y `AppTheme.*` ([`../DESIGN.md`](../DESIGN.md)).
- **Ergonomía Motriz:** Controles táctiles con área mínima de $\ge 48\text{px} \times 48\text{px}$ según la Ley de Fitts.

---

## 4. TypeScript (Web Admin — Angular 21)

**Herramienta:** [ESLint](https://eslint.org/) con `@angular-eslint` + Prettier.  
**Configuración:** [`apps/web/eslint.config.js`](../apps/web/eslint.config.js) y [`.prettierrc`](../.prettierrc)

### Nombres y Convenciones

| Elemento                | Convención                | Ejemplo                                |
| :---------------------- | :------------------------ | :------------------------------------- |
| Componentes (archivos)  | `kebab-case.component.ts` | `lesson-list.component.ts`             |
| Selector de Componentes | `app-kebab-case`          | `app-lesson-list`                      |
| Clases e interfaces     | `PascalCase`              | `LessonService`, `UserAdminModel`      |
| Variables y métodos     | `camelCase`               | `fetchAnalytics()`, `activeCategoryId` |
| Constantes              | `UPPER_SNAKE_CASE`        | `API_BASE_URL`                         |

### Reglas de Arquitectura y Buenas Prácticas

- **Componentes Standalone Exclusivos:** Todos los componentes se definen con `standalone: true`.
- **Reactividad con Angular Signals:** Estado local y compartido gestionado con `signal()`, `computed()` y `effect()`.
- **Inyección de Dependencias Moderna:** Uso prioritario de la función `inject()` sobre constructores sobrecargados.
- **Tipado Estricto:** Prohibido el uso indiscriminado de `any`. Definir modelos e interfaces para todo DTO de API.
- **Cero Llamadas de Red en Vistas:** Las solicitudes HTTP se concentran en `core/services/` y se inyectan en componentes de presentación.

---

## 5. Datos y Persistencia (PostgreSQL & Alembic)

| Aspecto              | Convención                                    | Ejemplo                                                    |
| :------------------- | :-------------------------------------------- | :--------------------------------------------------------- |
| Nombres de Tablas    | Plural en `snake_case`                        | `users`, `lessons`, `practice_sessions`                    |
| Clave Primaria (PK)  | Siempre `id` (UUID o Integer autoincremental) | `id: Mapped[uuid.UUID]`                                    |
| Claves Foráneas (FK) | `<entidad_singular>_id`                       | `user_id`, `lesson_id`                                     |
| Índices              | `ix_<tabla>_<campo>`                          | `ix_practice_sessions_user_id`                             |
| Migraciones Alembic  | Descriptivas con identificador de revisión    | `alembic/versions/a1b2c3d4e5f6_add_performance_indexes.py` |

---

## 6. Comandos de Verificación Local

| Control                  | Comando                                                               | Criterio de Aprobación                                    |
| :----------------------- | :-------------------------------------------------------------------- | :-------------------------------------------------------- |
| **Formato Global**       | `pnpm format:check`                                                   | Sin diferencias de formateo en todo el monorepo           |
| **Formato Automático**   | `pnpm format`                                                         | Aplica Prettier a Markdown, JSON, YAML y TypeScript       |
| **Lint Backend**         | `cd apps/backend && ruff check .`                                     | 0 errores y 0 warnings                                    |
| **Formato Backend**      | `cd apps/backend && ruff format --check .`                            | Formato conforme a PEP 8                                  |
| **Lint Web**             | `cd apps/web && pnpm lint`                                            | 0 errores en TypeScript y plantillas HTML                 |
| **Lint Mobile**          | `cd apps/mobile && flutter analyze`                                   | 0 advertencias o errores estáticos                        |
| **Formato Mobile**       | `cd apps/mobile && dart format --output=none --set-exit-if-changed .` | Formato conforme a Dart                                   |
| **Tests Backend**        | `cd apps/backend && pytest tests/ -v`                                 | 100% de pruebas en verde                                  |
| **Tests Web**            | `cd apps/web && pnpm test --run`                                      | 100% de pruebas en verde                                  |
| **Tests Mobile**         | `cd apps/mobile && flutter test`                                      | 100% de pruebas en verde                                  |
| **Verificación Commits** | `pnpm exec commitlint --from origin/main`                             | Mensajes en formato Conventional Commits                  |
| **Cero Atribución AI**   | `node scripts/ai-attribution.mjs --range origin/main..HEAD`           | Sin menciones de herramientas de IA en commits ni autores |
