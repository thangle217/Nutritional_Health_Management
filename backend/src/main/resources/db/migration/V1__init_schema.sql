CREATE SCHEMA IF NOT EXISTS nutrition;
SET search_path = nutrition, public;

CREATE TABLE app_user (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    role text NOT NULL CHECK (role IN ('ADMIN','HEAD_DOCTOR','DOCTOR','PATIENT')),
    full_name text NOT NULL CHECK (btrim(full_name) <> ''),
    email text NOT NULL CHECK (position('@' in email) > 1),
    phone text NOT NULL CHECK (phone ~ '^\+[1-9][0-9]{7,14}$'),
    email_verified_at timestamptz,
    phone_verified_at timestamptz,
    password_hash text NOT NULL,
    status text NOT NULL DEFAULT 'PENDING_APPROVAL'
        CHECK (status IN ('PENDING_APPROVAL','ACTIVE','SUSPENDED','LOCKED','CLOSED')),
    failed_login_count integer NOT NULL DEFAULT 0 CHECK (failed_login_count >= 0),
    locked_until timestamptz,
    last_login_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (id, role),
    CHECK (role <> 'PATIENT' OR status <> 'ACTIVE' OR email_verified_at IS NOT NULL)
);
CREATE UNIQUE INDEX app_user_email_uq ON app_user (lower(email));
CREATE TABLE auth_session (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES app_user,
    refresh_token_digest text NOT NULL UNIQUE,
    issued_at timestamptz NOT NULL DEFAULT now(),
    expires_at timestamptz NOT NULL,
    revoked_at timestamptz,
    rotated_from uuid UNIQUE REFERENCES auth_session,
    CHECK (expires_at > issued_at),
    CHECK (revoked_at >= issued_at)
);
CREATE TABLE contact_verification (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES app_user,
    channel text NOT NULL CHECK (channel IN ('EMAIL','SMS')),
    destination text NOT NULL,
    token_digest text NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now(),
    expires_at timestamptz NOT NULL,
    consumed_at timestamptz,
    attempts integer NOT NULL DEFAULT 0 CHECK (attempts >= 0),
    CHECK (expires_at > created_at)
);
CREATE TABLE patient (
    id uuid PRIMARY KEY,
    role text GENERATED ALWAYS AS ('PATIENT'::text) STORED,
    patient_code bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
    joined_on date NOT NULL DEFAULT (now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date,
    date_of_birth date,
    sex text,
    address text,
    baseline_height_cm numeric(5,2) CHECK (baseline_height_cm > 0),
    baseline_weight_kg numeric(6,2) CHECK (baseline_weight_kg > 0),
    baseline_bmi numeric GENERATED ALWAYS AS
        (round(baseline_weight_kg / ((baseline_height_cm / 100) ^ 2), 2)) STORED,
    activity_level text,
    goals text,
    medical_history text,
    FOREIGN KEY (id, role) REFERENCES app_user (id, role)
);
CREATE TABLE clinician (
    id uuid PRIMARY KEY,
    role text NOT NULL CHECK (role IN ('DOCTOR','HEAD_DOCTOR')),
    specialty text,
    qualifications text,
    experience text,
    academic_title text,
    work_contact text,
    FOREIGN KEY (id, role) REFERENCES app_user (id, role) ON UPDATE CASCADE
);
CREATE TABLE patient_intake (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL REFERENCES patient,
    previously_examined_here boolean NOT NULL,
    requested_doctor_id uuid REFERENCES clinician,
    facility_visit_ref text,
    declaration_notes text,
    status text NOT NULL DEFAULT 'DRAFT' CHECK (status IN
        ('DRAFT','SUBMITTED','NEEDS_INFORMATION','VERIFIED','DECLINED','WITHDRAWN')),
    submitted_at timestamptz,
    reviewed_by uuid REFERENCES clinician,
    reviewed_at timestamptz,
    response text,
    UNIQUE (id, patient_id),
    CHECK ((reviewed_at IS NULL) = (reviewed_by IS NULL))
);
CREATE UNIQUE INDEX patient_intake_open_uq ON patient_intake (patient_id)
    WHERE status IN ('DRAFT','SUBMITTED','NEEDS_INFORMATION');

CREATE TABLE condition_catalog (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL UNIQUE
);
CREATE TABLE allergen (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL UNIQUE
);
CREATE TABLE health_declaration (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL REFERENCES patient,
    kind text NOT NULL CHECK (kind IN ('CONDITION','ALLERGY')),
    condition_id uuid REFERENCES condition_catalog,
    allergen_id uuid REFERENCES allergen,
    patient_description text,
    submitted_at timestamptz NOT NULL DEFAULT now(),
    status text NOT NULL DEFAULT 'PENDING' CHECK (status IN
        ('PENDING','NEEDS_INFORMATION','CONFIRMED','DECLINED','INACTIVE')),
    severity text CHECK (severity IN ('UNKNOWN','NON_CRITICAL','CRITICAL')),
    UNIQUE (id, patient_id),
    CHECK ((kind = 'CONDITION' AND allergen_id IS NULL AND severity IS NULL) OR
           (kind = 'ALLERGY' AND condition_id IS NULL)),
    CHECK (condition_id IS NOT NULL OR allergen_id IS NOT NULL OR
           NULLIF(btrim(patient_description), '') IS NOT NULL),
    CHECK (status <> 'CONFIRMED' OR (kind = 'CONDITION' AND condition_id IS NOT NULL)
           OR (kind = 'ALLERGY' AND allergen_id IS NOT NULL AND severity IS NOT NULL))
);
CREATE TABLE declaration_review (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    declaration_id uuid NOT NULL REFERENCES health_declaration,
    clinician_id uuid NOT NULL REFERENCES clinician,
    result text NOT NULL CHECK (result IN ('NEEDS_INFORMATION','CONFIRMED','DECLINED','INACTIVE')),
    severity text CHECK (severity IN ('UNKNOWN','NON_CRITICAL','CRITICAL')),
    patient_reply text,
    reviewed_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE attachment (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL REFERENCES patient,
    intake_id uuid,
    declaration_id uuid,
    message_id uuid,
    uploaded_by uuid NOT NULL REFERENCES app_user,
    object_key text NOT NULL UNIQUE,
    file_name text NOT NULL,
    mime_type text NOT NULL,
    size_bytes bigint NOT NULL CHECK (size_bytes > 0),
    uploaded_at timestamptz NOT NULL DEFAULT now(),
    FOREIGN KEY (intake_id, patient_id) REFERENCES patient_intake (id, patient_id),
    FOREIGN KEY (declaration_id, patient_id) REFERENCES health_declaration (id, patient_id),
    CHECK (num_nonnulls(intake_id, declaration_id, message_id) = 1)
);
CREATE TABLE assignment (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL REFERENCES patient,
    doctor_id uuid NOT NULL REFERENCES clinician,
    assigned_by uuid NOT NULL REFERENCES clinician,
    started_at timestamptz NOT NULL DEFAULT now(),
    ended_at timestamptz,
    status text NOT NULL CHECK (status IN
        ('TRACKING','PAUSED','AUTO_SUSPENDED','WAITING_CAPACITY','ENDED')),
    active_slot smallint CHECK (active_slot BETWEEN 1 AND 30),
    reason text,
    UNIQUE (id, patient_id),
    CHECK ((status = 'TRACKING') = (active_slot IS NOT NULL)),
    CHECK ((status = 'ENDED') = (ended_at IS NOT NULL)),
    CHECK (ended_at >= started_at)
);
CREATE UNIQUE INDEX assignment_current_patient_uq ON assignment (patient_id) WHERE ended_at IS NULL;
CREATE UNIQUE INDEX assignment_active_slot_uq ON assignment (doctor_id, active_slot)
    WHERE status = 'TRACKING';
CREATE INDEX assignment_doctor_current_idx ON assignment (doctor_id, patient_id) WHERE ended_at IS NULL;
CREATE TABLE tracking_pause (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL,
    assignment_id uuid NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    reason text NOT NULL,
    requested_by uuid NOT NULL REFERENCES app_user,
    requested_at timestamptz NOT NULL DEFAULT now(),
    status text NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','APPROVED','REJECTED','WITHDRAWN')),
    reviewed_by uuid REFERENCES clinician,
    reviewed_at timestamptz,
    review_note text,
    FOREIGN KEY (assignment_id, patient_id) REFERENCES assignment (id, patient_id),
    CHECK (end_date >= start_date),
    CHECK (status NOT IN ('APPROVED','REJECTED') OR (reviewed_at IS NOT NULL AND reviewed_by IS NOT NULL))
);
CREATE TABLE tracking_event (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id uuid NOT NULL REFERENCES assignment,
    event_type text NOT NULL CHECK (event_type IN
        ('ASSIGNED','TRANSFERRED','PAUSE_REQUESTED','PAUSE_APPROVED','PAUSE_DECLINED',
         'AUTO_SUSPENDED','WAITING_CAPACITY','RESUMED','ENDED')),
    actor_id uuid REFERENCES app_user,
    first_paused_date date,
    last_paused_date date,
    reason text,
    happened_at timestamptz NOT NULL DEFAULT now(),
    CHECK (last_paused_date >= first_paused_date)
);
CREATE TABLE patient_interaction (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id uuid NOT NULL REFERENCES patient,
    kind text NOT NULL CHECK (kind IN ('LOGIN','DATA_ENTRY','CHAT_MESSAGE')),
    occurred_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX patient_interaction_time_idx ON patient_interaction (patient_id, occurred_at);
CREATE TABLE appointment (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL REFERENCES patient,
    assignment_id uuid,
    requested_by uuid NOT NULL REFERENCES app_user,
    request_type text NOT NULL CHECK (request_type IN ('INITIAL_EXAM','FOLLOW_UP','CONSULTATION')),
    preferred_start timestamptz,
    preferred_end timestamptz,
    patient_reason text,
    confirmed_start timestamptz,
    confirmed_end timestamptz,
    confirmed_by uuid REFERENCES clinician,
    confirmed_doctor_id uuid REFERENCES clinician,
    status text NOT NULL DEFAULT 'REQUESTED' CHECK (status IN
        ('REQUESTED','NEEDS_INFORMATION','CONFIRMED','COMPLETED','DECLINED','CANCELLED','NO_SHOW')),
    response text,
    created_at timestamptz NOT NULL DEFAULT now(),
    FOREIGN KEY (assignment_id, patient_id) REFERENCES assignment (id, patient_id),
    CHECK (preferred_end IS NULL OR (preferred_start IS NOT NULL AND preferred_end > preferred_start)),
    CHECK ((confirmed_start IS NULL AND confirmed_end IS NULL) OR
           (confirmed_start IS NOT NULL AND confirmed_end IS NOT NULL AND confirmed_end > confirmed_start)),
    CHECK (status NOT IN ('CONFIRMED','COMPLETED','NO_SHOW') OR
           (confirmed_start IS NOT NULL AND confirmed_by IS NOT NULL))
);
CREATE INDEX appointment_queue_idx ON appointment (status, created_at);
CREATE TABLE conversation (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id uuid NOT NULL UNIQUE REFERENCES assignment,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE food_group (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL UNIQUE,
    active boolean NOT NULL DEFAULT true
);
CREATE TABLE food (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    status text NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','AVAILABLE','RESTRICTED','SUSPENDED','ARCHIVED'))
);
CREATE TABLE food_version (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    food_id uuid NOT NULL REFERENCES food,
    version_no integer NOT NULL CHECK (version_no > 0),
    food_group_id uuid NOT NULL REFERENCES food_group,
    name text NOT NULL,
    preparation text,
    image_object_key text,
    base_unit text NOT NULL CHECK (base_unit IN ('G','ML')),
    base_quantity numeric(10,3) NOT NULL CHECK (base_quantity > 0),
    kcal numeric(9,3) NOT NULL CHECK (kcal >= 0),
    protein_g numeric(9,3) NOT NULL CHECK (protein_g >= 0),
    carb_g numeric(9,3) NOT NULL CHECK (carb_g >= 0),
    fat_g numeric(9,3) NOT NULL CHECK (fat_g >= 0),
    fiber_g numeric(9,3) CHECK (fiber_g >= 0),
    sugar_g numeric(9,3) CHECK (sugar_g >= 0),
    sodium_mg numeric(9,3) NOT NULL CHECK (sodium_mg >= 0),
    cholesterol_mg numeric(9,3) CHECK (cholesterol_mg >= 0),
    glycemic_index numeric(7,2) CHECK (glycemic_index >= 0),
    proposed_by uuid NOT NULL REFERENCES clinician,
    reviewed_by uuid REFERENCES clinician,
    reviewed_at timestamptz,
    status text NOT NULL DEFAULT 'DRAFT' CHECK (status IN
        ('DRAFT','IN_REVIEW','PUBLISHED','SUPERSEDED','REJECTED')),
    review_note text,
    UNIQUE (food_id, version_no),
    CHECK (status NOT IN ('PUBLISHED','SUPERSEDED','REJECTED') OR
           (reviewed_by IS NOT NULL AND reviewed_at IS NOT NULL))
);
CREATE UNIQUE INDEX food_version_published_uq ON food_version (food_id) WHERE status = 'PUBLISHED';
CREATE TABLE food_unit_conversion (
    food_version_id uuid NOT NULL REFERENCES food_version,
    unit_name text NOT NULL,
    to_base_unit numeric(12,4) NOT NULL CHECK (to_base_unit > 0),
    PRIMARY KEY (food_version_id, unit_name)
);
CREATE TABLE food_allergen (
    food_version_id uuid NOT NULL REFERENCES food_version,
    allergen_id uuid NOT NULL REFERENCES allergen,
    PRIMARY KEY (food_version_id, allergen_id)
);
CREATE TABLE food_restriction (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    food_version_id uuid NOT NULL REFERENCES food_version,
    condition_id uuid REFERENCES condition_catalog,
    override_allowed boolean NOT NULL,
    reason text NOT NULL
);
CREATE UNIQUE INDEX food_restriction_scope_uq ON food_restriction
    (food_version_id, condition_id) WHERE condition_id IS NOT NULL;
CREATE UNIQUE INDEX food_restriction_general_uq ON food_restriction
    (food_version_id) WHERE condition_id IS NULL;

CREATE TYPE meal_slot AS ENUM ('BREAKFAST','AM_SNACK','LUNCH','PM_SNACK','DINNER','EVENING_SNACK');
CREATE TABLE meal_template (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid()
);
CREATE TABLE meal_template_version (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    template_id uuid NOT NULL REFERENCES meal_template,
    version_no integer NOT NULL CHECK (version_no > 0),
    name text NOT NULL,
    status text NOT NULL DEFAULT 'DRAFT' CHECK (status IN
        ('DRAFT','IN_REVIEW','PUBLISHED','SUPERSEDED','REJECTED')),
    proposed_by uuid NOT NULL REFERENCES clinician,
    reviewed_by uuid REFERENCES clinician,
    reviewed_at timestamptz,
    review_note text,
    UNIQUE (template_id, version_no),
    CHECK (status NOT IN ('PUBLISHED','SUPERSEDED','REJECTED') OR
           (reviewed_by IS NOT NULL AND reviewed_at IS NOT NULL))
);
CREATE UNIQUE INDEX meal_template_published_uq ON meal_template_version (template_id)
    WHERE status = 'PUBLISHED';
CREATE TABLE meal_template_item (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    template_version_id uuid NOT NULL REFERENCES meal_template_version,
    day_offset smallint NOT NULL CHECK (day_offset BETWEEN 0 AND 29),
    slot meal_slot NOT NULL,
    food_version_id uuid NOT NULL REFERENCES food_version,
    quantity numeric(10,3) NOT NULL CHECK (quantity > 0),
    unit text NOT NULL
);

CREATE TABLE prescription (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL REFERENCES patient,
    assignment_id uuid NOT NULL,
    created_by uuid NOT NULL REFERENCES clinician,
    created_at timestamptz NOT NULL DEFAULT now(),
    period_start date NOT NULL,
    period_end date NOT NULL,
    status text NOT NULL DEFAULT 'DRAFT' CHECK (status IN
        ('DRAFT','ISSUED','EXPIRED','CLOSED','CANCELLED','STOPPED_EARLY')),
    closed_by uuid REFERENCES clinician,
    closed_at timestamptz,
    close_notes text,
    actual_end_date date,
    close_reason text,
    FOREIGN KEY (assignment_id, patient_id) REFERENCES assignment (id, patient_id),
    UNIQUE (id, patient_id),
    CHECK (period_end - period_start + 1 BETWEEN 7 AND 30),
    CHECK (actual_end_date IS NULL OR actual_end_date >= period_start),
    CHECK (status NOT IN ('CLOSED','CANCELLED','STOPPED_EARLY') OR (closed_by IS NOT NULL AND closed_at IS NOT NULL)),
    CHECK (status NOT IN ('CANCELLED','STOPPED_EARLY') OR NULLIF(btrim(close_reason), '') IS NOT NULL),
    CHECK (status <> 'STOPPED_EARLY' OR actual_end_date IS NOT NULL)
);
CREATE TABLE prescription_version (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    prescription_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    version_no integer NOT NULL CHECK (version_no > 0),
    effective_on date NOT NULL,
    through_date date NOT NULL,
    target_kcal numeric(8,2) NOT NULL CHECK (target_kcal > 0),
    protein_percent numeric(5,2) NOT NULL CHECK (protein_percent BETWEEN 0 AND 100),
    carb_percent numeric(5,2) NOT NULL CHECK (carb_percent BETWEEN 0 AND 100),
    fat_percent numeric(5,2) NOT NULL CHECK (fat_percent BETWEEN 0 AND 100),
    water_ml integer NOT NULL CHECK (water_ml > 0),
    avoid_food_notes text,
    patient_instruction text,
    change_reason text,
    copied_from uuid REFERENCES prescription_version,
    status text NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','PUBLISHED','DISCARDED')),
    created_by uuid NOT NULL REFERENCES clinician,
    published_by uuid REFERENCES clinician,
    published_at timestamptz,
    FOREIGN KEY (prescription_id, patient_id) REFERENCES prescription (id, patient_id),
    UNIQUE (prescription_id, version_no),
    UNIQUE (id, patient_id),
    CHECK (through_date >= effective_on),
    CHECK (protein_percent + carb_percent + fat_percent = 100),
    CHECK (version_no = 1 OR NULLIF(btrim(change_reason), '') IS NOT NULL),
    CHECK (status <> 'PUBLISHED' OR (published_by IS NOT NULL AND published_at IS NOT NULL))
);
CREATE TABLE prescription_day (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    version_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    plan_date date NOT NULL,
    copied_from uuid REFERENCES prescription_day,
    note text,
    FOREIGN KEY (version_id, patient_id) REFERENCES prescription_version (id, patient_id),
    UNIQUE (version_id, plan_date),
    UNIQUE (id, patient_id, plan_date)
);
CREATE TABLE prescription_item (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    day_id uuid NOT NULL REFERENCES prescription_day,
    slot meal_slot NOT NULL,
    food_version_id uuid NOT NULL REFERENCES food_version,
    quantity numeric(10,3) NOT NULL CHECK (quantity > 0),
    unit text NOT NULL,
    warning_code text CHECK (warning_code IN ('RESTRICTED','ALLERGY_REVIEW')),
    warning_reason text,
    patient_instruction text,
    override_by uuid REFERENCES clinician,
    override_at timestamptz,
    CHECK (warning_code IS NULL OR
           (NULLIF(btrim(warning_reason), '') IS NOT NULL AND
            NULLIF(btrim(patient_instruction), '') IS NOT NULL AND
            override_by IS NOT NULL AND override_at IS NOT NULL))
);
CREATE TABLE applied_prescription_day (
    patient_id uuid NOT NULL,
    plan_date date NOT NULL,
    day_id uuid NOT NULL UNIQUE,
    PRIMARY KEY (patient_id, plan_date),
    FOREIGN KEY (day_id, patient_id, plan_date) REFERENCES prescription_day (id, patient_id, plan_date)
);
CREATE TABLE food_safety_review (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL REFERENCES patient,
    declaration_id uuid NOT NULL,
    day_id uuid NOT NULL,
    plan_date date NOT NULL,
    assignee_id uuid REFERENCES clinician,
    state text NOT NULL DEFAULT 'OPEN' CHECK (state IN ('OPEN','REVIEWING','CLOSED')),
    created_at timestamptz NOT NULL DEFAULT now(),
    resolved_at timestamptz,
    resolution text,
    FOREIGN KEY (declaration_id, patient_id) REFERENCES health_declaration (id, patient_id),
    FOREIGN KEY (day_id, patient_id, plan_date) REFERENCES prescription_day (id, patient_id, plan_date),
    UNIQUE (declaration_id, day_id),
    CHECK (state <> 'CLOSED' OR (resolved_at IS NOT NULL AND NULLIF(btrim(resolution), '') IS NOT NULL))
);
CREATE TABLE treatment_review (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    prescription_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    reviewed_by uuid NOT NULL REFERENCES clinician,
    outcome_summary text NOT NULL CHECK (btrim(outcome_summary) <> ''),
    next_step_guidance text,
    follow_up_recommended boolean NOT NULL DEFAULT false,
    reviewed_at timestamptz NOT NULL DEFAULT now(),
    FOREIGN KEY (prescription_id, patient_id) REFERENCES prescription (id, patient_id),
    UNIQUE (prescription_id)
);

CREATE TABLE daily_journal (
    patient_id uuid NOT NULL REFERENCES patient,
    journal_date date NOT NULL,
    applied_day_id uuid,
    state text NOT NULL DEFAULT 'DRAFT' CHECK (state IN ('DRAFT','SUBMITTED')),
    submitted_at timestamptz,
    PRIMARY KEY (patient_id, journal_date),
    FOREIGN KEY (applied_day_id, patient_id, journal_date)
        REFERENCES prescription_day (id, patient_id, plan_date),
    CHECK ((state = 'SUBMITTED') = (submitted_at IS NOT NULL))
);
CREATE TABLE journal_meal (
    patient_id uuid NOT NULL,
    journal_date date NOT NULL,
    slot meal_slot NOT NULL,
    outcome text NOT NULL CHECK (outcome IN ('AS_PLANNED','DIFFERENT','SKIPPED')),
    recorded_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (patient_id, journal_date, slot),
    FOREIGN KEY (patient_id, journal_date) REFERENCES daily_journal
);
CREATE TABLE journal_item (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL,
    journal_date date NOT NULL,
    slot meal_slot NOT NULL,
    food_version_id uuid REFERENCES food_version,
    food_name text NOT NULL,
    quantity numeric(10,3) NOT NULL CHECK (quantity > 0),
    unit text NOT NULL,
    kcal numeric(9,3) CHECK (kcal >= 0),
    protein_g numeric(9,3) CHECK (protein_g >= 0),
    carb_g numeric(9,3) CHECK (carb_g >= 0),
    fat_g numeric(9,3) CHECK (fat_g >= 0),
    sodium_mg numeric(9,3) CHECK (sodium_mg >= 0),
    FOREIGN KEY (patient_id, journal_date, slot) REFERENCES journal_meal,
    CHECK (food_version_id IS NULL OR num_nonnulls(kcal, protein_g, carb_g, fat_g, sodium_mg) = 5
          OR (sodium_mg IS NULL AND num_nonnulls(kcal, protein_g, carb_g, fat_g) = 4))
);
CREATE TABLE journal_water (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL,
    journal_date date NOT NULL,
    quantity_ml integer NOT NULL CHECK (quantity_ml > 0),
    recorded_at timestamptz NOT NULL DEFAULT now(),
    FOREIGN KEY (patient_id, journal_date) REFERENCES daily_journal
);
CREATE TABLE journal_revision (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL,
    journal_date date NOT NULL,
    editor_id uuid NOT NULL REFERENCES app_user,
    changed_at timestamptz NOT NULL DEFAULT now(),
    reason text,
    before_summary jsonb NOT NULL,
    after_summary jsonb NOT NULL,
    FOREIGN KEY (patient_id, journal_date) REFERENCES daily_journal
);
CREATE TABLE journal_correction_request (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL REFERENCES patient,
    journal_date date NOT NULL,
    patient_reason text NOT NULL,
    proposed_change jsonb NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    status text NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN','APPROVED','REJECTED','WITHDRAWN')),
    reviewed_by uuid REFERENCES clinician,
    reviewed_at timestamptz,
    response text,
    CHECK (status NOT IN ('APPROVED','REJECTED') OR (reviewed_by IS NOT NULL AND reviewed_at IS NOT NULL))
);

CREATE TYPE vital_kind AS ENUM ('WEIGHT','BP','GLUCOSE');
CREATE TABLE vital_measurement (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL REFERENCES patient,
    kind vital_kind NOT NULL,
    measured_at timestamptz NOT NULL,
    entered_at timestamptz NOT NULL DEFAULT now(),
    unit text NOT NULL,
    context_code text NOT NULL,
    value_1 numeric(9,3) NOT NULL CHECK (value_1 > 0),
    value_2 numeric(9,3) CHECK (value_2 > 0),
    recorded_height_cm numeric(5,2) CHECK (recorded_height_cm > 0),
    bmi numeric GENERATED ALWAYS AS (CASE WHEN kind = 'WEIGHT'
        THEN round(value_1 / ((recorded_height_cm / 100) ^ 2), 2) END) STORED,
    replaces_id uuid,
    UNIQUE (id, patient_id),
    FOREIGN KEY (replaces_id, patient_id) REFERENCES vital_measurement (id, patient_id),
    CHECK (
        (kind = 'BP' AND unit = 'MMHG' AND value_2 IS NOT NULL AND value_1 >= value_2) OR
        (kind = 'GLUCOSE' AND unit IN ('MG_DL','MMOL_L') AND value_2 IS NULL) OR
        (kind = 'WEIGHT' AND unit = 'KG' AND value_2 IS NULL)),
    CHECK (kind = 'WEIGHT' OR recorded_height_cm IS NULL),
    CHECK (replaces_id <> id)
);
CREATE UNIQUE INDEX vital_replacement_uq ON vital_measurement (replaces_id) WHERE replaces_id IS NOT NULL;
CREATE INDEX vital_patient_history_idx ON vital_measurement (patient_id, measured_at);
CREATE TABLE required_measurement_day (
    patient_id uuid NOT NULL,
    assignment_id uuid NOT NULL,
    required_date date NOT NULL,
    kind vital_kind NOT NULL,
    context_code text NOT NULL,
    specified_by uuid NOT NULL REFERENCES clinician,
    PRIMARY KEY (patient_id, required_date, kind, context_code),
    FOREIGN KEY (assignment_id, patient_id) REFERENCES assignment (id, patient_id)
);
CREATE TABLE threshold_rule (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    code text NOT NULL,
    version_no integer NOT NULL CHECK (version_no > 0),
    kind vital_kind NOT NULL CHECK (kind IN ('BP','GLUCOSE')),
    unit text NOT NULL,
    context_code text NOT NULL,
    patient_id uuid REFERENCES patient,
    condition_id uuid REFERENCES condition_catalog,
    condition_priority integer,
    status text NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','APPROVED','RETIRED')),
    effective_from timestamptz NOT NULL,
    effective_until timestamptz,
    approved_by uuid REFERENCES clinician,
    approved_at timestamptz,
    UNIQUE (code, version_no),
    CHECK (effective_until > effective_from),
    CHECK (num_nonnulls(patient_id, condition_id) <= 1),
    CHECK ((condition_id IS NOT NULL) = (condition_priority IS NOT NULL)),
    CHECK (condition_priority IS NULL OR condition_priority > 0),
    CHECK ((kind = 'BP' AND unit = 'MMHG') OR (kind = 'GLUCOSE' AND unit IN ('MG_DL','MMOL_L'))),
    CHECK (status = 'DRAFT' OR (approved_by IS NOT NULL AND approved_at IS NOT NULL))
);
CREATE TABLE threshold_clause (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_id uuid NOT NULL REFERENCES threshold_rule,
    operand text NOT NULL CHECK (operand IN ('SYSTOLIC','DIASTOLIC','GLUCOSE')),
    comparison text NOT NULL CHECK (comparison IN ('LT','LE','GT','GE')),
    limit_value numeric(9,3) NOT NULL CHECK (limit_value > 0),
    UNIQUE (rule_id, operand, comparison)
);
CREATE TABLE vital_assessment (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    measurement_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    rule_id uuid REFERENCES threshold_rule,
    state text NOT NULL CHECK (state IN ('RED','WITHIN_CONFIG','REVIEW_REQUIRED','NOT_APPLICABLE')),
    matched_values jsonb,
    assessed_at timestamptz NOT NULL DEFAULT now(),
    supersedes_id uuid,
    FOREIGN KEY (measurement_id, patient_id) REFERENCES vital_measurement (id, patient_id),
    UNIQUE (id, patient_id),
    FOREIGN KEY (supersedes_id, patient_id) REFERENCES vital_assessment (id, patient_id),
    CHECK (state NOT IN ('RED','WITHIN_CONFIG') OR rule_id IS NOT NULL),
    CHECK (supersedes_id <> id)
);
CREATE TABLE calorie_assessment (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL,
    journal_date date NOT NULL,
    assessed_at timestamptz NOT NULL DEFAULT now(),
    state text NOT NULL CHECK (state IN ('NOT_ASSESSED','WITHIN_TARGET','YELLOW')),
    actual_kcal numeric(10,3) CHECK (actual_kcal >= 0),
    target_kcal numeric(8,2) CHECK (target_kcal > 0),
    reason text,
    deviation_percent numeric GENERATED ALWAYS AS
        (round(abs(actual_kcal - target_kcal) * 100 / target_kcal, 4)) STORED,
    FOREIGN KEY (patient_id, journal_date) REFERENCES daily_journal,
    UNIQUE (id, patient_id, journal_date),
    CHECK (state = 'NOT_ASSESSED' OR (actual_kcal IS NOT NULL AND target_kcal IS NOT NULL)),
    CHECK (state = 'NOT_ASSESSED' OR (state = 'YELLOW') = (abs(actual_kcal - target_kcal) * 100 > target_kcal * 15))
);
CREATE TABLE alert (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL REFERENCES patient,
    assignment_id uuid,
    type text NOT NULL CHECK (type IN ('RED_VITAL','YELLOW_CALORIE')),
    vital_assessment_id uuid,
    calorie_assessment_id uuid,
    journal_date date,
    occurred_at timestamptz NOT NULL,
    acknowledged_at timestamptz,
    acknowledged_by uuid REFERENCES clinician,
    resolved_at timestamptz,
    resolved_by uuid REFERENCES clinician,
    resolution text,
    status text NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN','ACKNOWLEDGED','RESOLVED')),
    acknowledge_due_at timestamptz,
    resolve_due_at timestamptz,
    FOREIGN KEY (assignment_id, patient_id) REFERENCES assignment (id, patient_id),
    FOREIGN KEY (vital_assessment_id, patient_id) REFERENCES vital_assessment (id, patient_id),
    FOREIGN KEY (calorie_assessment_id, patient_id, journal_date)
        REFERENCES calorie_assessment (id, patient_id, journal_date),
    UNIQUE (vital_assessment_id),
    CHECK ((type = 'RED_VITAL' AND vital_assessment_id IS NOT NULL AND calorie_assessment_id IS NULL
            AND journal_date IS NULL AND acknowledge_due_at IS NOT NULL AND resolve_due_at IS NOT NULL
            AND acknowledge_due_at = occurred_at + interval '60 minutes'
            AND resolve_due_at = occurred_at + interval '2 hours') OR
           (type = 'YELLOW_CALORIE' AND vital_assessment_id IS NULL AND calorie_assessment_id IS NOT NULL
            AND journal_date IS NOT NULL AND acknowledge_due_at IS NULL AND resolve_due_at IS NULL)),
    CHECK (status = 'OPEN' OR (acknowledged_at IS NOT NULL AND acknowledged_by IS NOT NULL)),
    CHECK (status <> 'RESOLVED' OR (resolved_at IS NOT NULL AND resolved_by IS NOT NULL
           AND NULLIF(btrim(resolution), '') IS NOT NULL)),
    CHECK (acknowledged_at >= occurred_at),
    CHECK (resolved_at >= acknowledged_at)
);
CREATE UNIQUE INDEX alert_yellow_day_uq ON alert (patient_id, journal_date) WHERE type = 'YELLOW_CALORIE';
CREATE INDEX alert_queue_idx ON alert (status, type, occurred_at);
CREATE TABLE alert_event (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_id uuid NOT NULL REFERENCES alert,
    actor_id uuid REFERENCES app_user,
    kind text NOT NULL CHECK (kind IN ('CREATED','ACKNOWLEDGED','RESOLVED','REASSESSED','TRANSFERRED','SLA_BREACH')),
    payload jsonb NOT NULL DEFAULT '{}',
    occurred_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE follow_up_event (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL REFERENCES patient,
    assignment_id uuid,
    prescription_id uuid,
    event_date date NOT NULL,
    event_type text NOT NULL CHECK (event_type IN
        ('JOURNAL_SUBMITTED','JOURNAL_NOT_SUBMITTED','MISSED_DATA_REMINDER','AUTO_SUSPENDED','PRESCRIPTION_DUE')),
    dedupe_key text NOT NULL UNIQUE,
    state text CHECK (state IN ('NOT_STARTED','INCOMPLETE','RECORDED_BUT_NOT_SENT')),
    raised_at timestamptz NOT NULL DEFAULT now(),
    FOREIGN KEY (assignment_id, patient_id) REFERENCES assignment (id, patient_id),
    FOREIGN KEY (prescription_id, patient_id) REFERENCES prescription (id, patient_id),
    CHECK (event_type <> 'PRESCRIPTION_DUE' OR prescription_id IS NOT NULL),
    CHECK ((event_type = 'JOURNAL_NOT_SUBMITTED') = (state IS NOT NULL))
);
CREATE TABLE message (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id uuid NOT NULL REFERENCES conversation,
    sender_id uuid REFERENCES app_user,
    body text,
    follow_up_event_id uuid UNIQUE REFERENCES follow_up_event,
    appointment_id uuid REFERENCES appointment,
    created_at timestamptz NOT NULL DEFAULT now(),
    CHECK (
        (sender_id IS NOT NULL AND follow_up_event_id IS NULL
         AND (NULLIF(btrim(body), '') IS NOT NULL OR appointment_id IS NOT NULL))
        OR (sender_id IS NULL AND follow_up_event_id IS NOT NULL AND appointment_id IS NULL)
    )
);
CREATE INDEX message_history_idx ON message (conversation_id, created_at, id);
ALTER TABLE attachment
    ADD CONSTRAINT attachment_message_fk FOREIGN KEY (message_id) REFERENCES message (id);
CREATE INDEX attachment_message_idx ON attachment (message_id) WHERE message_id IS NOT NULL;
CREATE TABLE notification (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_id uuid NOT NULL REFERENCES app_user,
    channel text NOT NULL CHECK (channel IN ('IN_APP','EMAIL')),
    event_key text NOT NULL,
    alert_id uuid REFERENCES alert,
    follow_up_event_id uuid REFERENCES follow_up_event,
    appointment_id uuid REFERENCES appointment,
    safety_review_id uuid REFERENCES food_safety_review,
    status text NOT NULL DEFAULT 'QUEUED' CHECK (status IN ('QUEUED','SENT','FAILED')),
    attempts integer NOT NULL DEFAULT 0 CHECK (attempts >= 0),
    created_at timestamptz NOT NULL DEFAULT now(),
    last_attempt_at timestamptz,
    next_attempt_at timestamptz,
    sent_at timestamptz,
    read_at timestamptz,
    UNIQUE (recipient_id, channel, event_key),
    CHECK (status <> 'SENT' OR sent_at IS NOT NULL),
    CHECK (read_at IS NULL OR channel = 'IN_APP'),
    CHECK (num_nonnulls(alert_id, follow_up_event_id, appointment_id, safety_review_id) <= 1)
);
CREATE INDEX notification_outbox_idx ON notification (status, next_attempt_at, created_at) WHERE status <> 'SENT';
CREATE INDEX notification_inbox_idx ON notification (recipient_id, created_at DESC) WHERE channel = 'IN_APP';

CREATE TABLE audit_event (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    actor_id uuid REFERENCES app_user,
    action text NOT NULL,
    object_type text NOT NULL,
    object_id uuid,
    patient_id uuid REFERENCES patient,
    reason text,
    source_ip inet,
    metadata jsonb NOT NULL DEFAULT '{}',
    occurred_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX audit_event_actor_idx ON audit_event (actor_id, occurred_at DESC);
CREATE INDEX audit_event_occurred_idx ON audit_event (occurred_at DESC);
CREATE INDEX audit_event_patient_idx ON audit_event (patient_id, occurred_at DESC) WHERE patient_id IS NOT NULL;
CREATE INDEX audit_event_object_idx ON audit_event (object_type, object_id, occurred_at DESC);
CREATE TABLE operation_run (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_code text NOT NULL,
    status text NOT NULL CHECK (status IN ('RUNNING','SUCCEEDED','FAILED')),
    started_at timestamptz NOT NULL DEFAULT now(),
    finished_at timestamptz,
    metadata jsonb NOT NULL DEFAULT '{}',
    CHECK (finished_at >= started_at),
    CHECK ((status = 'RUNNING') = (finished_at IS NULL))
);
CREATE INDEX operation_run_task_idx ON operation_run (task_code, started_at DESC);
CREATE INDEX follow_up_event_patient_date_idx ON follow_up_event (patient_id, event_date DESC);

CREATE TABLE system_setting (
    setting_key text PRIMARY KEY CHECK (btrim(setting_key) <> ''),
    value_json jsonb NOT NULL,
    description text,
    version_no integer NOT NULL DEFAULT 1 CHECK (version_no > 0),
    updated_by uuid REFERENCES app_user,
    updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE system_setting_history (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    setting_key text NOT NULL REFERENCES system_setting (setting_key),
    version_no integer NOT NULL CHECK (version_no > 0),
    old_value_json jsonb,
    new_value_json jsonb NOT NULL,
    change_reason text NOT NULL CHECK (btrim(change_reason) <> ''),
    changed_by uuid NOT NULL REFERENCES app_user,
    changed_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (setting_key, version_no)
);

CREATE VIEW daily_nutrition_summary AS
SELECT j.patient_id, j.journal_date, j.applied_day_id, j.state,
       count(i.id) AS food_count,
       CASE WHEN count(i.id) > 0 AND count(i.id) = count(i.kcal) THEN sum(i.kcal)
            WHEN count(i.id) = 0 AND j.state = 'SUBMITTED' AND EXISTS (
                SELECT 1 FROM journal_meal m WHERE m.patient_id = j.patient_id
                  AND m.journal_date = j.journal_date AND m.outcome = 'SKIPPED'
            ) AND NOT EXISTS (
                SELECT 1 FROM journal_meal m WHERE m.patient_id = j.patient_id
                  AND m.journal_date = j.journal_date AND m.outcome <> 'SKIPPED'
            ) THEN 0 END AS total_kcal,
       CASE WHEN count(i.id) = count(i.protein_g) THEN sum(i.protein_g) END AS protein_g,
       CASE WHEN count(i.id) = count(i.carb_g) THEN sum(i.carb_g) END AS carb_g,
       CASE WHEN count(i.id) = count(i.fat_g) THEN sum(i.fat_g) END AS fat_g,
       CASE WHEN count(i.id) = count(i.sodium_mg) THEN sum(i.sodium_mg) END AS sodium_mg,
       (SELECT sum(w.quantity_ml) FROM journal_water w
        WHERE w.patient_id = j.patient_id AND w.journal_date = j.journal_date) AS water_ml
FROM daily_journal j
LEFT JOIN journal_item i USING (patient_id, journal_date)
GROUP BY j.patient_id, j.journal_date;

CREATE VIEW doctor_tracking_load AS
SELECT c.id AS doctor_id,
       count(a.id) FILTER (WHERE a.status = 'TRACKING') AS tracking_count,
       count(a.id) FILTER (WHERE a.status IN ('PAUSED','AUTO_SUSPENDED','WAITING_CAPACITY')) AS other_assigned_count
FROM clinician c
LEFT JOIN assignment a ON c.id = a.doctor_id AND a.ended_at IS NULL
GROUP BY c.id;
