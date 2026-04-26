# MindCheck

Plataforma de monitoreo de bienestar estudiantil basada en el **Maslach Burnout Inventory — Student Survey (MBI-SS)**. Detecta niveles de burnout, registra check-ins diarios y conecta estudiantes con tutores y recursos de apoyo.

---

## Stack tecnológico

| Capa | Tecnología |
|------|-----------|
| Web dashboard | Next.js 16 (App Router) + React 19 |
| App móvil | Expo 54 + React Native 0.81 + NativeWind |
| Backend / API | FastAPI 0.115 (Python 3.12) |
| Base de datos | PostgreSQL 17 vía Supabase |
| Autenticación | Supabase Auth (JWT) |
| Monorepo | Turborepo + pnpm workspaces |

---

## Arquitectura

```
┌─────────────────────────────────────────┐
│               CLIENTES                  │
│  ┌──────────────┐  ┌─────────────────┐  │
│  │  Dashboard   │  │  Mobile (Expo)  │  │
│  │  Next.js 16  │  │  React Native   │  │
│  └──────┬───────┘  └────────┬────────┘  │
└─────────┼────────────────────┼──────────┘
          │                    │
          ▼                    ▼
┌─────────────────────────────────────────┐
│                BACKEND                  │
│  ┌──────────────┐  ┌─────────────────┐  │
│  │   FastAPI    │  │    Supabase     │  │
│  │   :8000      │  │  Auth / Realtime│  │
│  │  Scoring MBI │  │  Storage / RLS  │  │
│  │  Alertas     │  │                 │  │
│  └──────┬───────┘  └────────┬────────┘  │
└─────────┼────────────────────┼──────────┘
          └──────────┬─────────┘
                     ▼
          ┌──────────────────┐
          │  PostgreSQL 17   │
          │   (Supabase)     │
          └──────────────────┘
```

**Responsabilidades por capa:**

- **Supabase** — autenticación, base de datos, RLS (Row Level Security), storage y realtime
- **FastAPI** — lógica de negocio: scoring MBI-SS, detección de crisis, procesamiento de alertas
- **Dashboard** — panel web para estudiantes, tutores y administradores
- **Mobile** — app para estudiantes: check-ins diarios y cuestionarios

---

## Estructura del monorepo

```
mindcheck/
├── apps/
│   ├── dashboard/          # Next.js — panel web
│   ├── mobile/             # Expo — app móvil
│   └── api/                # FastAPI — backend de lógica
├── packages/
│   ├── types/              # Tipos TypeScript compartidos
│   ├── constants/          # Lógica MBI-SS + escala Likert
│   ├── supabase/           # Cliente Supabase tipado + Database types
│   ├── ui/                 # Componentes React compartidos
│   ├── eslint-config/      # Configuración ESLint
│   └── typescript-config/  # Configuraciones TypeScript base
├── supabase/
│   ├── config.toml         # Configuración Supabase local
│   └── migrations/         # Migraciones SQL
├── turbo.json
├── pnpm-workspace.yaml
└── package.json
```

---

## Apps

### `apps/dashboard` — Panel web

Next.js 16 con App Router. Dirigido a estudiantes, tutores y administradores.

```
apps/dashboard/
├── app/
│   ├── layout.tsx          # Root layout
│   ├── globals.css
│   └── page.tsx
├── lib/
│   └── supabase/
│       ├── browser.ts      # Cliente para Client Components
│       └── server.ts       # Cliente para Server Components (cookies)
├── .env.local
├── next.config.js
└── tsconfig.json
```

**Dependencias clave:**
- `@supabase/ssr` — autenticación SSR con cookies
- `react-hook-form` + `zod` — formularios con validación
- `recharts` — gráficos de burnout
- `zustand` — manejo de estado global
- `lucide-react` — iconos

---

### `apps/mobile` — App móvil

Expo 54 con Expo Router (file-based routing) y NativeWind (Tailwind para React Native).

```
apps/mobile/
├── app/
│   ├── _layout.tsx         # Root layout con SafeAreaProvider
│   └── index.tsx           # Pantalla inicial
├── lib/
│   └── supabase.ts         # Cliente Supabase con AsyncStorage
├── assets/                 # Íconos y splash screen
├── app.json                # Configuración Expo (bundle IDs, plugins)
├── tailwind.config.js
├── metro.config.js
└── .env
```

**Bundle IDs:**
- iOS: `com.mindcheck.app`
- Android: `com.mindcheck.app`

**Dependencias clave:**
- `nativewind` — Tailwind para React Native
- `@react-native-async-storage/async-storage` — persistencia de sesión
- `expo-router` — navegación file-based
- `expo-notifications` — notificaciones push
- `expo-secure-store` — almacenamiento seguro de tokens
- `react-hook-form` + `zod` — formularios con validación
- `victory-native` — gráficos

---

### `apps/api` — Backend FastAPI

Servicio Python que maneja la lógica de scoring MBI-SS y alertas de crisis.

```
apps/api/
├── app/
│   ├── main.py             # FastAPI app + middleware CORS
│   ├── core/
│   │   ├── config.py       # Variables de entorno (pydantic-settings)
│   │   └── auth.py         # Verificación JWT de Supabase
│   ├── routers/
│   │   ├── assessments.py  # Inicio y envío de cuestionarios
│   │   ├── checkins.py     # Check-ins diarios
│   │   └── scores.py       # Historial de scores
│   ├── schemas/
│   │   ├── assessment.py   # Pydantic models para assessments
│   │   └── checkin.py      # Pydantic models para check-ins
│   └── services/
│       ├── supabase.py     # Clientes admin y user
│       └── scoring.py      # Algoritmo de scoring MBI-SS
├── requirements.txt
├── pyproject.toml
├── .env
└── .env.example
```

**Endpoints disponibles:**

| Método | Ruta | Descripción |
|--------|------|-------------|
| `GET` | `/health` | Health check |
| `POST` | `/api/v1/assessments/start` | Inicia un assessment MBI-SS |
| `POST` | `/api/v1/assessments/{id}/submit` | Envía respuestas y calcula burnout |
| `POST` | `/api/v1/checkins/` | Registra check-in diario |
| `GET` | `/api/v1/checkins/` | Lista check-ins del usuario autenticado |
| `GET` | `/api/v1/scores/latest` | Último score de burnout |
| `GET` | `/api/v1/scores/history` | Historial de scores |

Documentación interactiva disponible en `http://localhost:8000/docs` cuando el servidor está corriendo.

---

## Packages compartidos

### `@mindcheck/types`

Tipos TypeScript usados en todas las apps y packages.

```typescript
type UserRole        = 'student' | 'tutor' | 'admin'
type BurnoutRiskLevel = 'low' | 'medium' | 'high'
type MBIDimension    = 'exhaustion' | 'cynicism' | 'efficacy'

interface DailyCheckin { mood, sleep_hours, stress_level, study_hours, notes }
interface BurnoutScore  { exhaustion_mean, cynicism_mean, efficacy_mean, risk_level }
```

### `@mindcheck/constants`

Lógica del algoritmo MBI-SS en TypeScript.

- `MBI_SS_SCALE` — escala Likert 0–6 en español (Nunca → Todos los días)
- `classifyDimension()` — clasifica una dimensión contra los cutoffs de población
- `overallRisk()` — combina las 3 dimensiones en un nivel de riesgo general
- `computeDimensionMeans()` — calcula promedios por dimensión desde respuestas crudas

### `@mindcheck/supabase`

Cliente Supabase totalmente tipado con los tipos auto-generados de la base de datos.

```typescript
import { createSupabaseClient, type Database } from '@mindcheck/supabase'
```

### `@mindcheck/ui`

Componentes React compartidos entre el dashboard y futuras apps web.

---

## Base de datos

El esquema completo vive en `supabase/migrations/`. Contiene 17 tablas con RLS habilitado en todas.

| Tabla | Descripción |
|-------|-------------|
| `profiles` | Extiende `auth.users` con rol y contexto académico |
| `consents` | Audit trail de consentimientos (solo INSERT, inmutable) |
| `user_preferences` | Idioma, tema y configuración de notificaciones |
| `daily_checkins` | Pulso diario (mood 1–5, sueño, estrés, horas de estudio) |
| `instruments` | Catálogo de instrumentos psicométricos (MBI-SS, PSS-10, PHQ-9, GAD-7) |
| `instrument_items` | 15 ítems del MBI-SS bloqueados en español |
| `instrument_cutoffs` | Umbrales de riesgo por dimensión (Schaufeli et al., 2002) |
| `assessments` | Sesiones de cuestionario (started / completed / abandoned) |
| `assessment_responses` | Respuestas individuales a cada ítem |
| `burnout_scores` | Resultados calculados por sesión |
| `crisis_events` | Eventos de crisis detectados (watch / warning / urgent) |
| `resources` | Biblioteca de contenido y recursos de apoyo |
| `resource_views` | Tracking de vistas y feedback (helpful) |
| `tutor_student_relationships` | Relaciones tutor-estudiante (pending / active / revoked) |
| `notification_log` | Registro de notificaciones enviadas |
| `admin_audit_log` | Audit trail de acciones administrativas |

**Triggers automáticos:**
- Al crear un usuario → se crea su `profile` y `user_preferences` automáticamente
- Todas las tablas actualizan `updated_at` automáticamente

**Política de acceso (RLS):**
- Cada usuario solo ve sus propios datos
- Un tutor activo puede ver los datos de sus estudiantes
- Un admin tiene acceso completo

---

## Configuración inicial

### Requisitos previos

- Node.js >= 18
- pnpm >= 9
- Python >= 3.12
- Supabase CLI

### 1. Clonar e instalar dependencias JS

```bash
git clone <repo-url>
cd mindcheck
pnpm install
```

### 2. Variables de entorno

**Dashboard** (`apps/dashboard/.env.local`):
```env
NEXT_PUBLIC_SUPABASE_URL=https://<project>.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=<anon-key>
SUPABASE_SERVICE_ROLE_KEY=<service-role-key>
```

**Mobile** (`apps/mobile/.env`):
```env
EXPO_PUBLIC_SUPABASE_URL=https://<project>.supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=<anon-key>
EXPO_PUBLIC_API_URL=http://localhost:8000
```

**API** (`apps/api/.env`):
```env
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_ANON_KEY=<anon-key>
SUPABASE_SERVICE_ROLE_KEY=<service-role-key>
SUPABASE_JWT_SECRET=<jwt-secret>
```

> El `SUPABASE_JWT_SECRET` se encuentra en: **Supabase Dashboard → Project Settings → API → JWT Secret**

### 3. Entorno Python (API)

```bash
cd apps/api
python -m venv .venv
source .venv/bin/activate      # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### 4. Aplicar migraciones de base de datos

```bash
# Con Supabase local
supabase start
supabase db reset

# Con Supabase Cloud (proyecto ya creado)
supabase link --project-ref <project-ref>
supabase db push
```

---

## Levantar el proyecto en desarrollo

### Todo junto (recomendado)

```bash
pnpm dev
```

Esto levanta el dashboard (`:3000`) y la app móvil en paralelo usando Turborepo.

La API FastAPI se levanta por separado:
```bash
cd apps/api
source .venv/bin/activate
uvicorn app.main:app --reload --port 8000
```

### Por separado

```bash
# Dashboard
cd apps/dashboard && pnpm dev
# → http://localhost:3000

# Mobile
cd apps/mobile && pnpm dev
# → Expo DevTools, escanea el QR con Expo Go

# API
cd apps/api && uvicorn app.main:app --reload --port 8000
# → http://localhost:8000
# → Docs: http://localhost:8000/docs
```

---

## Comandos útiles

```bash
# Instalar todas las dependencias
pnpm install

# Build de producción
pnpm build

# Lint de todo el monorepo
pnpm lint

# Type checking
pnpm check-types

# Formatear código
pnpm format

# Regenerar tipos de Supabase (después de cambios en la BD)
supabase gen types typescript --linked > packages/supabase/src/database.types.ts

# Ejecutar solo una app con Turborepo
pnpm dev --filter=@mindcheck/dashboard
pnpm dev --filter=@mindcheck/mobile
```

---

## Flujo de autenticación

```
Usuario           Dashboard / Mobile          Supabase Auth       FastAPI
  │                       │                        │                 │
  ├── signup / login ────►│                        │                 │
  │                       ├── signUp/signIn() ────►│                 │
  │                       │◄── JWT access_token ───┤                 │
  │                       │                        │                 │
  │◄── redirige al home ──┤                        │                 │
  │                       │                        │                 │
  ├── acción protegida ──►│                        │                 │
  │            POST /api/v1/... + Bearer <token>  ─────────────────►│
  │                       │                        │   verifica JWT  │
  │                       │                        │◄────────────────┤
  │                       │◄────────── respuesta ──────────────────  │
  │◄── resultado ─────────┤
```

---

## Variables de entorno — resumen completo

| Variable | App | Descripción |
|----------|-----|-------------|
| `NEXT_PUBLIC_SUPABASE_URL` | Dashboard | URL del proyecto Supabase |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Dashboard | Clave anon (pública, segura en cliente) |
| `SUPABASE_SERVICE_ROLE_KEY` | Dashboard | Clave service role (solo servidor) |
| `EXPO_PUBLIC_SUPABASE_URL` | Mobile | URL del proyecto Supabase |
| `EXPO_PUBLIC_SUPABASE_ANON_KEY` | Mobile | Clave anon (pública) |
| `EXPO_PUBLIC_API_URL` | Mobile | URL del backend FastAPI |
| `SUPABASE_URL` | API | URL del proyecto Supabase |
| `SUPABASE_ANON_KEY` | API | Clave anon |
| `SUPABASE_SERVICE_ROLE_KEY` | API | Clave service role (bypasa RLS) |
| `SUPABASE_JWT_SECRET` | API | Secreto para verificar tokens JWT |

---

## Contribuir

1. Crea una rama desde `main`:
   ```bash
   git checkout -b feature/nombre-del-feature
   ```
2. Haz tus cambios
3. Verifica que pasan los checks:
   ```bash
   pnpm lint && pnpm check-types
   ```
4. Abre un Pull Request describiendo los cambios
