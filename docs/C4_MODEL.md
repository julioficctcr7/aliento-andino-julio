# Modelo C4 de Arquitectura de Software — Aliento Andino

> **Sistema**: Plataforma de Tutoría Virtual y Red Social para Instrumentos de Viento Andinos (Quena, Zampoña y Tarka).  
> **Estándar**: C4 Model (Context, Containers, Components, Code) por Simon Brown.  
> **Trazabilidad**: Enlazado con [`ARCHITECTURE.md`](ARCHITECTURE.md), [`SPRINTS_AND_USER_STORIES.md`](SPRINTS_AND_USER_STORIES.md), [`QUALITY_STANDARDS.md`](QUALITY_STANDARDS.md), [`CODING_STANDARDS.md`](CODING_STANDARDS.md) y tokens en [`../DESIGN.md`](../DESIGN.md).

---

## 1. Nivel 1: Diagrama de Contexto del Sistema (System Context)

El diagrama de contexto ubica a **Aliento Andino** dentro de su ecosistema operativo, delimitando a los usuarios y los sistemas externos con los que se relaciona.

```mermaid
flowchart TD
    subgraph Actores ["Usuarios del Sistema"]
        Estudiante["👤 Estudiante de Viento Andino<br/>[Persona]<br/>Aprende Quena, Zampoña o Tarka con práctica en vivo"]
        Docente["👤 Docente / Administrador<br/>[Persona]<br/>Gestiona lecciones, curricula, digitaciones y audita reportes"]
    end

    subgraph FronteraSistema ["Frontera del Sistema Aliento Andino"]
        SistemaCore["🏔️ Plataforma Aliento Andino<br/>[Sistema de Software]<br/>Tutoría interactiva on-device, inferencia de audio/postura, red social y gestión curricular"]
    end

    subgraph SistemasExternos ["Sistemas Externos"]
        FCM["🔔 Firebase Cloud Messaging (FCM)<br/>[Sistema Externo]<br/>Envío de notificaciones push de racha y retos"]
        GHPages["📚 GitHub Pages CDN<br/>[Sistema Externo]<br/>Alojamiento estático de manual de usuario (Docusaurus)"]
        ObjectStorage["💾 Cloud Object Storage / S3<br/>[Sistema Externo]<br/>Backups cifrados diarios de PostgreSQL"]
    end

    Estudiante -->|"1. Practica afinación, postura y recibe feedback on-device [HTTPS/Audio]"| SistemaCore
    Docente -->|"2. Crea lecciones, administra usuarios y modera contenido [HTTPS/Web]"| SistemaCore
    SistemaCore -->|"3. Despacha alertas de racha diaria y recordatorios"| FCM
    FCM -->|"4. Notificaciones push al móvil"| Estudiante
    Docente -.->|"5. Consulta manuales y documentación de arquitectura"| GHPages
    Estudiante -.->|"6. Consulta guías de digitación y calibración"| GHPages
    SistemaCore -->|"7. Descarga periódica de backups automatizados"| ObjectStorage
```

### Descripción de Elementos de Contexto

| Elemento                        | Tipo                | Descripción                                                                                                                 |
| :------------------------------ | :------------------ | :-------------------------------------------------------------------------------------------------------------------------- |
| **Estudiante de Viento Andino** | Persona             | Usuario móvil que interpreta Quena, Zampoña o Tarka frente al micrófono y cámara.                                           |
| **Docente / Administrador**     | Persona             | Usuario del panel web encargado de la curaduría pedagógica y moderación comunitaria.                                        |
| **Plataforma Aliento Andino**   | Sistema de Software | Núcleo integral que procesa la telemetría, autentica usuarios, almacena progreso y brinda tutoría interactiva.              |
| **Firebase Cloud Messaging**    | Sistema Externo     | Servicio de mensajería para alertas de inactividad, preservación de racha (_Streak Flame_) y retos semanales.               |
| **GitHub Pages CDN**            | Sistema Externo     | Red de distribución de contenido que aloja el portal Docusaurus con manuales y especificaciones técnicas.                   |
| **Cloud Object Storage**        | Sistema Externo     | Repositorio de almacenamiento de objetos donde se depositan los backups comprimidos (`pg_dump`) generados por scripts cron. |

---

## 2. Nivel 2: Diagrama de Contenedores (Containers)

El diagrama de contenedores describe las aplicaciones, almacenes de datos y microservicios que componen **Aliento Andino**, indicando protocolos de comunicación y límites tecnológicos.

```mermaid
flowchart TB
    subgraph DispositivoMovil ["📱 Dispositivo Móvil del Estudiante (Android 8+ / iOS 14+)"]
        MobileApp["📱 Aplicación Móvil<br/>[Flutter 3.x / Dart]<br/>BLoC, GoRouter, Dio, SharedPreferences, Drift SQLite"]

        subgraph MotorLocal ["⚡ Motor de Inferencia On-Device (Edge AI)"]
            YIN["🎙️ YIN / SPICE Engine<br/>[C++ / FFI Dart]<br/>Pitch fundamental f0 y cents (<50ms)"]
            MediaPipe["👁️ MediaPipe Pose & Hands<br/>[TFLite / GPU]<br/>Postura y digitación a 30 FPS"]
            SLM["🤖 SLM Tutor Local<br/>[Gemma 2 2B / Llama 3.2 1B]<br/>Consejos pedagógicos offline"]
        end

        MobileApp <-->|"Buffer PCM / Isolates"| YIN
        MobileApp <-->|"RGB Frames / GPU Pipeline"| MediaPipe
        MobileApp <-->|"Telemetría JSON / Prompt"| SLM
    end

    subgraph NavegadorAdmin ["💻 Estación de Trabajo Docente"]
        WebAdmin["💻 Panel Web Admin<br/>[Angular 21 Standalone]<br/>Signals, Angular Material, Lucide Icons"]
    end

    subgraph ServidorProduccion ["🖥️ Servidor de Producción (VPS / Cloud Host)"]
        ReverseProxy["🔀 Reverse Proxy & API Gateway<br/>[Nginx Alpine]<br/>Terminación SSL, rate limiting, routing /api/* y /"]
        BackendAPI["⚙️ Backend Core API REST<br/>[FastAPI / Python 3.12]<br/>Uvicorn async, Pydantic v2, SQLAlchemy 2 Async"]
        MicroML["🧠 Microservicio ML Auxiliar<br/>[FastAPI / PyTorch / Puerto 8001]<br/>FAQ semántico, validación armónica pesada"]
        Database[("🗄️ Base de Datos Relacional<br/>[PostgreSQL 16 Alpine]<br/>Tablas normalizadas, JSONB telemetría, Alembic")]
    end

    subgraph Documentacion ["📚 Portal de Documentación"]
        DocsSite["📖 Manual de Usuario y Wiki<br/>[Docusaurus 3.x]<br/>GitHub Pages estático"]
    end

    WebAdmin -->|"HTTPS / JSON [REST API]"| ReverseProxy
    MobileApp -->|"HTTPS / JSON [REST API Sync]"| ReverseProxy
    ReverseProxy -->|"Proxy pass :8000"| BackendAPI
    ReverseProxy -->|"Proxy pass :8001"| MicroML
    BackendAPI -->|"TCP / SQL asíncrono (asyncpg :5432)"| Database
    BackendAPI -.->|"Llamada interna RPC/HTTP"| MicroML
```

### Especificación de Contenedores

| Contenedor           | Tecnología                     | Responsabilidad                                                                                             | Protocolos                      |
| :------------------- | :----------------------------- | :---------------------------------------------------------------------------------------------------------- | :------------------------------ |
| **Mobile App**       | Flutter 3.x (Dart)             | Interfaz de práctica, captura de audio/video, orquestación de feedback, sincronización offline.             | HTTPS (REST), FFI a C++         |
| **Motor On-Device**  | C++, TFLite, MediaPipe, WebLLM | Detección de pitch $<50\text{ms}$, visión a 30 FPS y generación de consejos con 0 bytes enviados a la nube. | En memoria (Pointers / JSON)    |
| **Web Admin**        | Angular 21 Standalone          | Panel administrativo para gestión curricular de notas/digitaciones, estadísticas de uso y moderación.       | HTTPS (REST/JSON)               |
| **Reverse Proxy**    | Nginx Alpine                   | Gateway perimetral, balanceador de carga local, terminación SSL, rate limiting contra abusos (DDoS).        | HTTP/1.1, HTTPS (TLS 1.3)       |
| **Backend API**      | FastAPI / Python 3.12          | Autenticación JWT rotativa, lógica de negocio de lecciones, evaluación de rachas, rankings y muro social.   | HTTPS / REST / asyncpg          |
| **Microservicio ML** | FastAPI / Python 3.12 (8001)   | Motor complementario de embeddings semánticos para FAQ musical y validaciones armónicas complejas.          | HTTP / REST                     |
| **Base de Datos**    | PostgreSQL 16 Alpine           | Persistencia de usuarios, secuencias de notas, intentos de práctica, auditoría y relaciones sociales.       | PostgreSQL Wire Protocol (5432) |
| **Docs Site**        | Docusaurus 3 (pnpm)            | Wiki técnica y manual de usuario desplegado en GitHub Pages.                                                | HTTPS estático CDN              |

---

## 3. Nivel 3: Diagramas de Componentes (Components)

### 3.1 Componentes de Backend Core API (`apps/backend`)

El backend sigue una arquitectura en capas estrictamente desacoplada: **Routers $\rightarrow$ Services $\rightarrow$ Models / Database**.

```mermaid
flowchart TD
    subgraph RoutersLayer ["Capa de Routers (HTTP / Endpoints)"]
        AuthR["AuthRouter<br/>/api/v1/auth"]
        LessonR["LessonsRouter<br/>/api/v1/lessons"]
        PracticeR["PracticeRouter<br/>/api/v1/practice"]
        SocialR["SocialRouter<br/>/api/v1/social"]
        RankingR["RankingsRouter<br/>/api/v1/rankings"]
        TutorR["TutorRouter<br/>/api/v1/tutor"]
        AuditR["AuditRouter<br/>/api/v1/admin/audit"]
    end

    subgraph SecurityLayer ["Capa de Seguridad & Dependencias"]
        AuthDep["AuthDependency<br/>(get_current_user, get_current_admin)"]
        RateLimit["RateLimiter<br/>(Slowapi / TokenBucket)"]
        DBSession["DatabaseSession<br/>(get_db asyncpg)"]
    end

    subgraph SchemasLayer ["Capa de Contratos (Pydantic v2)"]
        AuthSchemas["AuthSchemas<br/>(UserRegister, UserLogin, TokenResponse)"]
        LessonSchemas["LessonSchemas<br/>(LessonCreate, LessonResponse, NoteSequenceCreate)"]
        PracticeSchemas["PracticeSchemas<br/>(PracticeSubmitRequest, PracticeSessionResponse)"]
        SocialSchemas["SocialSchemas<br/>(PostCreate, PostResponse, CommentCreate)"]
        RankingSchemas["RankingSchemas<br/>(LeaderboardResponse, StreakResponse)"]
    end

    subgraph ServicesLayer ["Capa de Servicios de Negocio"]
        AuthSvc["AuthService<br/>(login, register, rotate_refresh_token)"]
        LessonSvc["LessonService<br/>(get_lessons, create_lesson, get_by_id)"]
        PracticeSvc["PracticeService<br/>(submit_session, get_history, calculate_xp)"]
        SocialSvc["SocialService<br/>(create_post, get_feed, toggle_reaction)"]
        RankingSvc["RankingService<br/>(get_leaderboard, update_streaks)"]
        TutorSvc["TutorService<br/>(generate_fallback_advice, log_ai_usage)"]
        AuditSvc["AuditService<br/>(log_admin_action, query_audit_logs)"]
    end

    subgraph ModelsLayer ["Capa de Persistencia (SQLAlchemy 2 Async)"]
        UserModel["UserModel (users)"]
        LessonModel["LessonModel & NoteSequenceModel (lessons, note_sequences)"]
        PracticeModel["PracticeSessionModel (practice_sessions)"]
        SocialModel["PostModel, CommentModel, ReactionModel"]
        RankingModel["UserRankingModel, WeeklyChallengeModel"]
        AuditModel["AuditLogModel (audit_logs)"]
    end

    RoutersLayer --> SecurityLayer
    RoutersLayer --> SchemasLayer
    RoutersLayer --> ServicesLayer
    ServicesLayer --> ModelsLayer
    ModelsLayer --> DBSession
```

### 3.2 Componentes de la Aplicación Web Admin (`apps/web`)

Desarrollada en Angular 21 con arquitectura Standalone, Signals y control de acceso RBAC.

```mermaid
flowchart TD
    subgraph WebCore ["Capa Core & Infraestructura"]
        AuthGuard["AdminGuard & AuthGuard<br/>(Control de rutas por rol)"]
        AuthInterceptor["AuthInterceptor<br/>(Inyección Bearer + refresh de token)"]
        HttpService["HttpClient Engine"]
    end

    subgraph WebServices ["Servicios de Dominio con Signals"]
        AuthAdminSvc["AuthAdminService<br/>(currentUser, isAuthenticated signal)"]
        LessonAdminSvc["LessonAdminService<br/>(lessonsList, categories, activeLesson)"]
        AuditAdminSvc["AuditAdminService<br/>(auditLogs signal, filters)"]
        ModerationSvc["SocialModerationService<br/>(reportedPosts, banUser)"]
        AnalyticsSvc["AnalyticsService<br/>(overviewMetrics, chartsData)"]
    end

    subgraph WebViews ["Vistas y Componentes Standalone"]
        LayoutComp["AdminLayoutComponent<br/>(Navbar, Sidebar, ToastContainer)"]
        LessonListComp["LessonListComponent<br/>(Tabla reactiva, filtros por instrumento)"]
        LessonEditorComp["LessonEditorComponent<br/>(Editor de secuencias de notas y digitación)"]
        ModerationComp["ModerationDashboardComponent<br/>(Gestión de reportes comunitarios)"]
        AuditLogsComp["AuditLogsComponent<br/>(Visor de eventos de seguridad)"]
    end

    WebViews --> WebServices
    WebServices --> WebCore
    WebCore -->|"HTTP /api/v1/*"| HttpService
```

### 3.3 Componentes de la Aplicación Móvil (`apps/mobile`)

Estructurada en Flutter 3.x con Clean Architecture, BLoC reactivo e inferencia local desacoplada.

```mermaid
flowchart TD
    subgraph UIViews ["Capa de Presentación (UI)"]
        TunerScreen["AfinadorScreen<br/>(Aguja reactiva, cents, nombre de nota)"]
        PracticeScreen["PracticeScreen<br/>(Reproductor de melodía, digitación interactiva)"]
        FingeringWidget["FingeringWidget<br/>(Quena 7 orificios, Zampoña 2 filas, Tarka 6 orif.)"]
        PostureCameraView["PostureCameraView<br/>(Overlay de hombros y codos con MediaPipe)"]
        SocialFeedView["SocialFeedView<br/>(Muro comunitario, audio player, reacciones)"]
    end

    subgraph BlocsLayer ["Gestión de Estado (BLoC / Cubit)"]
        TunerBloc["TunerBloc (AudioStreamEvent -> NoteDetectedState)"]
        PracticeBloc["PracticeBloc (Start, NoteHit, CompleteSession)"]
        PostureBloc["PostureBloc (CameraFrame -> AlignmentEvaluated)"]
        SocialBloc["SocialBloc (FetchFeed, LikePost, SubmitComment)"]
        AuthBloc["AuthBloc (LoginRequested, TokenRefreshed, Logout)"]
    end

    subgraph DomainEngines ["Motores de Procesamiento On-Device"]
        YinEngine["YinPitchDetector<br/>(FFI C++ Isolate, Buffer circular 1024)"]
        BreathCalibrator["BreathCalibrator<br/>(Cálculo RMS de 3s para 'Soplo Suave')"]
        MediaPipePipeline["MediaPipePipeline<br/>(Pose 33 landmarks + Hands 21 landmarks)"]
        SlmOrchestrator["LocalSlmOrchestrator<br/>(Inferencia pedagógica offline con Gemma/Llama)"]
    end

    subgraph DataRepositories ["Capa de Datos y Repositorios"]
        LessonRepo["LessonRepository (API REST + Local Cache)"]
        PracticeRepo["PracticeRepository (Idempotencia offline + Sync)"]
        AuthRepo["AuthRepository (FlutterSecureStorage JWT)"]
        DioClient["DioApiClient (Interceptors, Retry Policy)"]
        LocalDb["Drift / SQLite Database (Almacenamiento offline)"]
    end

    UIViews --> BlocsLayer
    BlocsLayer --> DomainEngines
    BlocsLayer --> DataRepositories
    DataRepositories --> DioClient
    DataRepositories --> LocalDb
```

---

## 4. Nivel 4: Diagrama de Código y Clases Clave (Code Level)

Para asegurar la **continuidad arquitectónica estricta** y erradicar cualquier discrepancia de nombres (como `gastosPago()` vs `gastosTotalPagar()`), se formalizan los contratos de clases y modelos del dominio:

```mermaid
classDiagram
    class InstrumentType {
        <<enumeration>>
        QUENA
        ZAMPONA
        TARKA
    }

    class DifficultyLevel {
        <<enumeration>>
        PRINCIPIANTE
        INTERMEDIO
        AVANZADO
    }

    class Category {
        +UUID id
        +string name
        +string description
        +int order
        +bool is_active
        +datetime created_at
    }

    class Lesson {
        +UUID id
        +UUID category_id
        +string title
        +string description
        +DifficultyLevel difficulty
        +int tempo_bpm
        +string time_signature
        +string key_signature
        +InstrumentType instrument
        +bool is_premium
        +int total_plays
        +float average_score
        +List~NoteSequence~ notes
        +validate_notes_sequence() bool
    }

    class NoteSequence {
        +UUID id
        +UUID lesson_id
        +int position
        +string note
        +float duration
        +bool is_rest
        +int velocity
        +int finger
        +string hand
        +Map fingering_data
    }

    class PracticeSession {
        +UUID id
        +UUID user_id
        +UUID lesson_id
        +UUID client_id
        +float score
        +int correct_notes
        +int wrong_notes
        +int missed_notes
        +int total_notes
        +float average_tempo
        +float total_time_seconds
        +float pitch_accuracy_percentage
        +float posture_score_percentage
        +List~dict~ errors_detail
        +bool completed
        +datetime created_at
        +calculate_final_xp() int
    }

    class TelemetryRecord {
        +float cents_deviation
        +float detected_hz
        +string detected_note
        +float shoulder_angle_degrees
        +float elbow_angle_degrees
        +bool holes_properly_covered
        +float breath_rms_energy
        +datetime timestamp
    }

    class User {
        +UUID id
        +string email
        +string username
        +string hashed_password
        +string role
        +int current_streak
        +int max_streak
        +int streak_freezes
        +int total_xp
        +datetime last_practice_date
        +bool is_active
    }

    Category "1" --o "*" Lesson : contiene
    Lesson "1" --* "*" NoteSequence : compone
    User "1" --* "*" PracticeSession : realiza
    Lesson "1" --* "*" PracticeSession : evalúa
    PracticeSession ..> TelemetryRecord : genera
```

---

## 5. Matriz de Continuidad de Nomenclatura y Contratos Unificados

Para cumplir con la directriz de **tolerancia cero a discrepancias de nombres**, la siguiente tabla define el estándar canónico en todas las capas tecnológicas:

| Concepto de Negocio       | Campo en Base de Datos (SQL) | Schema Backend (Pydantic)                     | DTO Web Admin (TypeScript)                    | Modelo Mobile (Dart)                                |
| :------------------------ | :--------------------------- | :-------------------------------------------- | :-------------------------------------------- | :-------------------------------------------------- |
| **Identificador Lección** | `id` (UUID)                  | `id: UUID`                                    | `id: string`                                  | `String id`                                         |
| **Categoría Asignada**    | `category_id` (UUID)         | `category_id: UUID`                           | `category_id: string`                         | `String categoryId` (con `@JsonKey('category_id')`) |
| **Tempo en BPM**          | `tempo_bpm` (INTEGER)        | `tempo_bpm: int`                              | `tempo_bpm: number`                           | `int tempoBpm`                                      |
| **Instrumento Andino**    | `instrument` (VARCHAR)       | `instrument: str` (`quena`/`zampona`/`tarka`) | `instrument: 'quena' \| 'zampona' \| 'tarka'` | `InstrumentType instrument`                         |
| **Desviación en Cents**   | N/A (Telemetría JSONB)       | `cents_deviation: float`                      | `cents_deviation: number`                     | `double centsDeviation`                             |
| **Energía de Soplo**      | N/A (Config Local)           | `breath_rms_energy: float`                    | N/A                                           | `double breathRmsEnergy`                            |
| **Secuencia de Notas**    | `note_sequences` (Tabla)     | `notes: list[NoteSequenceResponse]`           | `notes: NoteSequence[]`                       | `List<NoteSequenceModel> notes`                     |
| **Idempotencia Cliente**  | `client_id` (UUID único)     | `client_id: UUID \| None`                     | N/A                                           | `String clientId`                                   |
| **Racha de Días**         | `current_streak` (INTEGER)   | `current_streak: int`                         | `current_streak: number`                      | `int currentStreak`                                 |
| **Congeladores Racha**    | `streak_freezes` (INTEGER)   | `streak_freezes: int`                         | `streak_freezes: number`                      | `int streakFreezes`                                 |

### Regla Canónica de Métodos por Capa

- **Obtener lista de lecciones**:
  - Backend Endpoint: `GET /api/v1/lessons` $\rightarrow$ Service: `LessonService.get_lessons()`
  - Web Service: `LessonAdminService.getLessons()`
  - Mobile Repository: `LessonRepository.getLessons()`
- **Registrar sesión de práctica**:
  - Backend Endpoint: `POST /api/v1/practice/session` $\rightarrow$ Service: `PracticeService.submit_practice_session()`
  - Mobile Repository: `PracticeRepository.submitPracticeSession()`
- **Calibrar soplo suave**:
  - Mobile Engine: `BreathCalibrator.calibrateSoftBreath()`
- **Detectar frecuencia fundamental**:
  - Mobile C++ Engine: `YinDetector_DetectPitch()` $\rightarrow$ Dart Wrapper: `YinPitchDetector.detectFundamentalFrequency()`

---

## 6. Estrategia de Manejo de Errores y Fallos en la Arquitectura

La arquitectura implementa patrones explícitos de resiliencia y manejo de excepciones en cada componente:

```mermaid
flowchart TD
    ErrorOrigin["Origen del Fallo"] --> CatA["A. Falla de Entrada / Validación"]
    ErrorOrigin --> CatB["B. Falla de Sensores / Audio / Cámara"]
    ErrorOrigin --> CatC["C. Falla de Red / Modo Offline"]
    ErrorOrigin --> CatD["D. Falla de Servidor / Transacción"]

    CatA --> ResA["HTTP 422 Unprocessable Entity<br/>Error descriptivo Pydantic / Angular Form validation"]
    CatB --> ResB["Degradación Agraciada On-Device<br/>Reintento de buffer, aviso ergonómico sin interrumpir sonido"]
    CatC --> ResC["Almacenamiento Local Drift SQLite<br/>Queue offline con reintento exponencial idempotente"]
    CatD --> ResD["Rollback de Transacción SQLAlchemy<br/>Log estructurado en AuditLog + HTTP 500 canónico"]
```

1. **Errores de Validación (422 / 400)**: Respuestas estándar con clave `detail` conteniendo el campo exacto y el mensaje en español neutro.
2. **Caída de Red / Modo Avión**: La app móvil detecta pérdida de enlace mediante `ConnectivityService`. La práctica no se interrumpe porque YIN y MediaPipe operan localmente. El resultado se encola en SQLite local con `client_id` autogenerado y se sincroniza al recuperar conexión.
3. **Ruido Acústico o Desconexión de Micrófono**: Si el umbral de energía RMS es inferior a la calibración de "Soplo Suave", el motor ignora el frame en lugar de emitir falsas desafinaciones.
4. **Pérdida de Landmark Postural**: Si la confianza de MediaPipe cae por debajo de 0.5 (iluminación baja o usuario fuera de cuadro), la evaluación postural se suspende temporalmente sin degradar la evaluación de afinación de audio.
