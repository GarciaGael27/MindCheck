-- =============================================================================
-- MindCheck — Row Level Security Policies
-- =============================================================================
-- Default deny: every table has RLS enabled.
-- Users see/write only their own data unless admin or active tutor.
-- =============================================================================

-- Enable RLS on all tables --------------------------------------------------
alter table public.profiles                    enable row level security;
alter table public.consents                    enable row level security;
alter table public.user_preferences            enable row level security;
alter table public.daily_checkins              enable row level security;
alter table public.instruments                 enable row level security;
alter table public.instrument_items            enable row level security;
alter table public.instrument_item_history     enable row level security;
alter table public.instrument_cutoffs          enable row level security;
alter table public.assessments                 enable row level security;
alter table public.assessment_responses        enable row level security;
alter table public.burnout_scores              enable row level security;
alter table public.crisis_events               enable row level security;
alter table public.resources                   enable row level security;
alter table public.resource_views              enable row level security;
alter table public.tutor_student_relationships enable row level security;
alter table public.notification_log            enable row level security;
alter table public.admin_audit_log             enable row level security;

-- =============================================================================
-- profiles
-- =============================================================================

create policy "profiles: users see own"
  on public.profiles for select
  using (
    id = auth.uid()
    or public.is_admin()
    or public.is_active_tutor_of(id)
  );

create policy "profiles: users update own"
  on public.profiles for update
  using (id = auth.uid())
  with check (id = auth.uid() and role = (select role from public.profiles where id = auth.uid()));

create policy "profiles: admin update any"
  on public.profiles for update
  using (public.is_admin())
  with check (public.is_admin());

-- INSERT happens via the on_auth_user_created trigger (security definer)
-- DELETE: never via API; soft delete only via update of deleted_at

-- =============================================================================
-- consents (immutable audit trail)
-- =============================================================================

create policy "consents: users see own"
  on public.consents for select
  using (user_id = auth.uid() or public.is_admin());

create policy "consents: users insert own"
  on public.consents for insert
  with check (user_id = auth.uid());

-- No UPDATE, no DELETE — consents are immutable

-- =============================================================================
-- user_preferences
-- =============================================================================

create policy "preferences: users see own"
  on public.user_preferences for select
  using (user_id = auth.uid() or public.is_admin());

create policy "preferences: users update own"
  on public.user_preferences for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- INSERT happens via the on_auth_user_created trigger

-- =============================================================================
-- daily_checkins
-- =============================================================================

create policy "checkins: users see own"
  on public.daily_checkins for select
  using (
    user_id = auth.uid()
    or public.is_admin()
    or public.is_active_tutor_of(user_id)
  );

create policy "checkins: users insert own"
  on public.daily_checkins for insert
  with check (user_id = auth.uid());

create policy "checkins: users update own same day"
  on public.daily_checkins for update
  using (user_id = auth.uid() and checkin_date = current_date)
  with check (user_id = auth.uid());

create policy "checkins: users delete own"
  on public.daily_checkins for delete
  using (user_id = auth.uid());

-- =============================================================================
-- instruments (catalog — readable by all auth users, admin manages)
-- =============================================================================

create policy "instruments: any auth user reads active"
  on public.instruments for select
  using (auth.role() = 'authenticated' and (active or public.is_admin()));

create policy "instruments: admin manages"
  on public.instruments for all
  using (public.is_admin())
  with check (public.is_admin());

-- =============================================================================
-- instrument_items
-- =============================================================================

create policy "items: any auth user reads"
  on public.instrument_items for select
  using (auth.role() = 'authenticated');

create policy "items: admin manages unlocked"
  on public.instrument_items for insert
  with check (public.is_admin());

create policy "items: admin updates"
  on public.instrument_items for update
  using (public.is_admin())
  with check (public.is_admin());

create policy "items: admin deletes unlocked"
  on public.instrument_items for delete
  using (public.is_admin() and locked = false);

-- =============================================================================
-- instrument_item_history (admin-only audit trail)
-- =============================================================================

create policy "item_history: admin reads"
  on public.instrument_item_history for select
  using (public.is_admin());

-- INSERT happens via the track_instrument_item_changes trigger

-- =============================================================================
-- instrument_cutoffs
-- =============================================================================

create policy "cutoffs: any auth user reads active"
  on public.instrument_cutoffs for select
  using (auth.role() = 'authenticated' and (active or public.is_admin()));

create policy "cutoffs: admin manages"
  on public.instrument_cutoffs for all
  using (public.is_admin())
  with check (public.is_admin());

-- =============================================================================
-- assessments
-- =============================================================================

create policy "assessments: users see own"
  on public.assessments for select
  using (
    user_id = auth.uid()
    or public.is_admin()
    or public.is_active_tutor_of(user_id)
  );

create policy "assessments: users insert own"
  on public.assessments for insert
  with check (user_id = auth.uid());

create policy "assessments: users update own"
  on public.assessments for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- =============================================================================
-- assessment_responses
-- =============================================================================

create policy "responses: users see own via assessment"
  on public.assessment_responses for select
  using (
    exists (
      select 1 from public.assessments a
      where a.id = assessment_responses.assessment_id
        and (
          a.user_id = auth.uid()
          or public.is_admin()
          or public.is_active_tutor_of(a.user_id)
        )
    )
  );

create policy "responses: users insert own via assessment"
  on public.assessment_responses for insert
  with check (
    exists (
      select 1 from public.assessments a
      where a.id = assessment_responses.assessment_id
        and a.user_id = auth.uid()
        and a.completed_at is null
        and a.abandoned_at is null
    )
  );

create policy "responses: users update own pending"
  on public.assessment_responses for update
  using (
    exists (
      select 1 from public.assessments a
      where a.id = assessment_responses.assessment_id
        and a.user_id = auth.uid()
        and a.completed_at is null
        and a.abandoned_at is null
    )
  );

-- =============================================================================
-- burnout_scores (server-computed, read-only for users)
-- =============================================================================

create policy "scores: users see own"
  on public.burnout_scores for select
  using (
    user_id = auth.uid()
    or public.is_admin()
    or public.is_active_tutor_of(user_id)
  );

-- INSERT/UPDATE/DELETE: only via security-definer functions or admin
create policy "scores: admin manages"
  on public.burnout_scores for all
  using (public.is_admin())
  with check (public.is_admin());

-- =============================================================================
-- crisis_events
-- =============================================================================

create policy "crisis: users see own"
  on public.crisis_events for select
  using (user_id = auth.uid() or public.is_admin());

create policy "crisis: users insert own"
  on public.crisis_events for insert
  with check (user_id = auth.uid());

create policy "crisis: users acknowledge own"
  on public.crisis_events for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- =============================================================================
-- resources (public catalog for auth users)
-- =============================================================================

create policy "resources: any auth user reads active"
  on public.resources for select
  using (auth.role() = 'authenticated' and (active or public.is_admin()));

create policy "resources: admin manages"
  on public.resources for all
  using (public.is_admin())
  with check (public.is_admin());

-- =============================================================================
-- resource_views
-- =============================================================================

create policy "resource_views: users see own"
  on public.resource_views for select
  using (user_id = auth.uid() or public.is_admin());

create policy "resource_views: users insert own"
  on public.resource_views for insert
  with check (user_id = auth.uid());

create policy "resource_views: users update own"
  on public.resource_views for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- =============================================================================
-- tutor_student_relationships (mutual consent)
-- =============================================================================

create policy "tutor_rel: parties see own"
  on public.tutor_student_relationships for select
  using (
    tutor_id = auth.uid()
    or student_id = auth.uid()
    or public.is_admin()
  );

create policy "tutor_rel: tutor invites"
  on public.tutor_student_relationships for insert
  with check (
    tutor_id = auth.uid()
    and exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'tutor'
    )
  );

create policy "tutor_rel: student accepts or revokes"
  on public.tutor_student_relationships for update
  using (student_id = auth.uid() or tutor_id = auth.uid())
  with check (student_id = auth.uid() or tutor_id = auth.uid());

create policy "tutor_rel: admin manages"
  on public.tutor_student_relationships for all
  using (public.is_admin())
  with check (public.is_admin());

-- =============================================================================
-- notification_log
-- =============================================================================

create policy "notifications: users see own"
  on public.notification_log for select
  using (user_id = auth.uid() or public.is_admin());

create policy "notifications: users mark opened"
  on public.notification_log for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- INSERT via server functions only

-- =============================================================================
-- admin_audit_log (admin-only)
-- =============================================================================

create policy "audit_log: admin reads"
  on public.admin_audit_log for select
  using (public.is_admin());

create policy "audit_log: admin inserts"
  on public.admin_audit_log for insert
  with check (public.is_admin() and admin_id = auth.uid());
