-- =============================================================================
-- MindCheck — Initial Schema
-- =============================================================================
-- Burnout detection app for university students
-- Privacy-first, consent-driven, validated psychometric instruments
-- =============================================================================

-- Extensions ------------------------------------------------------------------
create extension if not exists pgcrypto;
create extension if not exists citext;

-- =============================================================================
-- Enums
-- =============================================================================

create type public.user_role            as enum ('student', 'tutor', 'admin');
create type public.burnout_risk_level   as enum ('low', 'medium', 'high');
create type public.mbi_dimension        as enum ('exhaustion', 'cynicism', 'efficacy');
create type public.instrument_code      as enum ('mbi_ss', 'pss_10', 'phq_9', 'gad_7');
create type public.consent_type         as enum (
  'data_processing',
  'research_use',
  'tutor_sharing',
  'anonymous_aggregation'
);
create type public.crisis_severity      as enum ('watch', 'warning', 'urgent');
create type public.notification_channel as enum ('push', 'email', 'in_app');
create type public.tutor_relationship_status as enum ('pending', 'active', 'revoked');

-- =============================================================================
-- Helper functions
-- =============================================================================

create or replace function public.handle_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- =============================================================================
-- 1. Profiles (extends auth.users)
-- =============================================================================

create table public.profiles (
  id              uuid primary key references auth.users(id) on delete cascade,
  display_name    text not null,
  email           citext not null,
  role            public.user_role not null default 'student',

  -- Academic context (optional)
  university      text,
  career          text,
  semester        smallint check (semester between 1 and 20),
  birth_year      smallint check (birth_year between 1950 and 2030),
  gender          text,
  pronouns        text,

  -- Onboarding state
  onboarding_step smallint not null default 0,
  onboarded_at    timestamptz,

  -- Privacy preferences
  pseudonym       text unique,
  show_real_name  boolean not null default true,

  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  deleted_at      timestamptz
);

create index profiles_role_idx on public.profiles(role) where deleted_at is null;
create index profiles_email_idx on public.profiles(email) where deleted_at is null;

create trigger profiles_updated_at
  before update on public.profiles
  for each row execute function public.handle_updated_at();

-- =============================================================================
-- 2. Consents (legal compliance)
-- =============================================================================

create table public.consents (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references auth.users(id) on delete cascade,
  consent_type   public.consent_type not null,
  policy_version text not null,
  granted        boolean not null,
  granted_at     timestamptz not null default now(),
  ip_address     inet,
  user_agent     text
);

create index consents_user_type_idx on public.consents(user_id, consent_type, granted_at desc);

-- =============================================================================
-- 3. User preferences
-- =============================================================================

create table public.user_preferences (
  user_id               uuid primary key references auth.users(id) on delete cascade,
  preferred_language    text not null default 'es',
  theme                 text not null default 'system' check (theme in ('light','dark','system')),
  daily_reminder_at     time,
  weekly_assessment_day smallint check (weekly_assessment_day between 0 and 6),
  notifications_enabled boolean not null default true,
  notification_channels public.notification_channel[] not null default array['push']::public.notification_channel[],
  data_export_format    text not null default 'json',
  updated_at            timestamptz not null default now()
);

create trigger user_preferences_updated_at
  before update on public.user_preferences
  for each row execute function public.handle_updated_at();

-- =============================================================================
-- 4. Auto-create profile + preferences on signup
-- =============================================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name, email)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data ->> 'display_name',
      split_part(new.email, '@', 1)
    ),
    new.email
  );

  insert into public.user_preferences (user_id)
  values (new.id);

  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =============================================================================
-- 5. Daily check-ins (lightweight wellness pulse)
-- =============================================================================

create table public.daily_checkins (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users(id) on delete cascade,
  mood          smallint not null check (mood between 1 and 5),
  sleep_hours   numeric(4,1) check (sleep_hours between 0 and 24),
  stress_level  smallint check (stress_level between 1 and 10),
  study_hours   numeric(4,1) check (study_hours between 0 and 24),
  notes         text,
  checkin_date  date not null default current_date,
  created_at    timestamptz not null default now(),
  unique (user_id, checkin_date)
);

create index daily_checkins_user_date_idx
  on public.daily_checkins(user_id, checkin_date desc);

-- =============================================================================
-- 6. Instruments catalog
-- =============================================================================

create table public.instruments (
  code             public.instrument_code primary key,
  name             text not null,
  description      text,
  language         text not null default 'es',
  total_items      smallint not null,
  scale_min        smallint not null default 0,
  scale_max        smallint not null default 6,
  validated_source text,
  active           boolean not null default true,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create trigger instruments_updated_at
  before update on public.instruments
  for each row execute function public.handle_updated_at();

create table public.instrument_items (
  id              uuid primary key default gen_random_uuid(),
  instrument      public.instrument_code not null references public.instruments(code) on delete cascade,
  item_number     smallint not null,
  text            text not null,
  dimension       text,
  reverse_scored  boolean not null default false,
  locked          boolean not null default false,
  version         smallint not null default 1,
  source_citation text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (instrument, item_number)
);

create trigger instrument_items_updated_at
  before update on public.instrument_items
  for each row execute function public.handle_updated_at();

create index instrument_items_instrument_idx
  on public.instrument_items(instrument, item_number);

-- Audit history of item edits
create table public.instrument_item_history (
  id            uuid primary key default gen_random_uuid(),
  item_id       uuid not null references public.instrument_items(id) on delete cascade,
  previous_text text not null,
  new_text      text not null,
  changed_by    uuid not null references auth.users(id),
  reason        text not null,
  changed_at    timestamptz not null default now()
);

create index instrument_item_history_item_idx
  on public.instrument_item_history(item_id, changed_at desc);

-- Cutoffs per instrument + dimension + population
create table public.instrument_cutoffs (
  id             uuid primary key default gen_random_uuid(),
  instrument     public.instrument_code not null references public.instruments(code) on delete cascade,
  dimension      text not null,
  low_threshold  numeric(5,2) not null,
  high_threshold numeric(5,2) not null,
  population     text not null default 'default',
  active         boolean not null default true,
  notes          text,
  created_at     timestamptz not null default now(),
  unique (instrument, dimension, population)
);

-- =============================================================================
-- 7. Assessments (instrument sessions)
-- =============================================================================

create table public.assessments (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references auth.users(id) on delete cascade,
  instrument       public.instrument_code not null references public.instruments(code),
  started_at       timestamptz not null default now(),
  completed_at     timestamptz,
  abandoned_at     timestamptz,
  duration_seconds integer,
  check (
    (completed_at is null and abandoned_at is null) or
    (completed_at is not null and abandoned_at is null) or
    (completed_at is null and abandoned_at is not null)
  )
);

create index assessments_user_completed_idx
  on public.assessments(user_id, completed_at desc nulls last);

create table public.assessment_responses (
  id            uuid primary key default gen_random_uuid(),
  assessment_id uuid not null references public.assessments(id) on delete cascade,
  item_number   smallint not null,
  value         smallint not null,
  answered_at   timestamptz not null default now(),
  unique (assessment_id, item_number)
);

create index assessment_responses_assessment_idx
  on public.assessment_responses(assessment_id);

-- =============================================================================
-- 8. Burnout scores (computed results)
-- =============================================================================

create table public.burnout_scores (
  id                uuid primary key default gen_random_uuid(),
  assessment_id     uuid not null unique references public.assessments(id) on delete cascade,
  user_id           uuid not null references auth.users(id) on delete cascade,
  exhaustion        numeric(5,2) not null,
  cynicism          numeric(5,2) not null,
  efficacy          numeric(5,2) not null,
  risk_level        public.burnout_risk_level not null,
  probability       numeric(5,2),
  algorithm_version text not null default 'mbi-cutoffs-v1',
  created_at        timestamptz not null default now()
);

create index burnout_scores_user_created_idx
  on public.burnout_scores(user_id, created_at desc);

-- =============================================================================
-- 9. Crisis events (mental health safety)
-- =============================================================================

create table public.crisis_events (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users(id) on delete cascade,
  severity        public.crisis_severity not null,
  triggered_by    text not null,
  source_id       uuid,
  resources_shown text[],
  acknowledged_at timestamptz,
  created_at      timestamptz not null default now()
);

create index crisis_events_user_created_idx
  on public.crisis_events(user_id, created_at desc);

create index crisis_events_unack_idx
  on public.crisis_events(user_id, severity)
  where acknowledged_at is null;

-- =============================================================================
-- 10. Resources (curated content library)
-- =============================================================================

create table public.resources (
  id         uuid primary key default gen_random_uuid(),
  category   text not null,
  title      text not null,
  body       text,
  url        text,
  language   text not null default 'es',
  emergency  boolean not null default false,
  active     boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index resources_category_active_idx
  on public.resources(category, active);
create index resources_emergency_idx
  on public.resources(emergency, active) where emergency = true;

create trigger resources_updated_at
  before update on public.resources
  for each row execute function public.handle_updated_at();

create table public.resource_views (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  resource_id uuid not null references public.resources(id) on delete cascade,
  viewed_at   timestamptz not null default now(),
  helpful     boolean
);

create index resource_views_user_idx
  on public.resource_views(user_id, viewed_at desc);

-- =============================================================================
-- 11. Tutor-student relationships (future-ready, opt-in)
-- =============================================================================

create table public.tutor_student_relationships (
  id          uuid primary key default gen_random_uuid(),
  tutor_id    uuid not null references public.profiles(id) on delete cascade,
  student_id  uuid not null references public.profiles(id) on delete cascade,
  status      public.tutor_relationship_status not null default 'pending',
  invited_at  timestamptz not null default now(),
  accepted_at timestamptz,
  revoked_at  timestamptz,
  unique (tutor_id, student_id),
  check (tutor_id <> student_id)
);

create index tutor_student_tutor_idx
  on public.tutor_student_relationships(tutor_id, status);
create index tutor_student_student_idx
  on public.tutor_student_relationships(student_id, status);

-- =============================================================================
-- 12. Notification log (anti-spam, observability)
-- =============================================================================

create table public.notification_log (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users(id) on delete cascade,
  channel       public.notification_channel not null,
  template_code text not null,
  sent_at       timestamptz not null default now(),
  opened_at     timestamptz
);

create index notification_log_user_sent_idx
  on public.notification_log(user_id, sent_at desc);

-- =============================================================================
-- 13. Admin audit log
-- =============================================================================

create table public.admin_audit_log (
  id          uuid primary key default gen_random_uuid(),
  admin_id    uuid not null references auth.users(id),
  action      text not null,
  entity_type text not null,
  entity_id   uuid,
  payload     jsonb,
  ip_address  inet,
  created_at  timestamptz not null default now()
);

create index admin_audit_log_admin_idx
  on public.admin_audit_log(admin_id, created_at desc);
create index admin_audit_log_entity_idx
  on public.admin_audit_log(entity_type, entity_id, created_at desc);

-- =============================================================================
-- Helper: is_admin() — used by RLS policies
-- =============================================================================

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid()
      and role = 'admin'
      and deleted_at is null
  );
$$;

-- Helper: is_active_tutor_of(student_id)
create or replace function public.is_active_tutor_of(student uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.tutor_student_relationships
    where tutor_id = auth.uid()
      and student_id = student
      and status = 'active'
  );
$$;

-- =============================================================================
-- Track instrument item edits automatically
-- =============================================================================

create or replace function public.track_instrument_item_changes()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'UPDATE' and old.text is distinct from new.text then
    insert into public.instrument_item_history (item_id, previous_text, new_text, changed_by, reason)
    values (
      new.id,
      old.text,
      new.text,
      auth.uid(),
      coalesce(current_setting('app.change_reason', true), 'unspecified')
    );
    new.version = old.version + 1;
  end if;
  return new;
end;
$$;

create trigger instrument_items_track_changes
  before update on public.instrument_items
  for each row execute function public.track_instrument_item_changes();
