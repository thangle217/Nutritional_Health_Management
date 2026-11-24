BEGIN;
SET search_path = nutrition, public;

-- The application supplies the authenticated actor and shares the patient/food
-- lock order below for transfers, declarations and publishing catalog changes.
CREATE FUNCTION publish_prescription(p_version_id uuid, p_actor_id uuid)
RETURNS void
LANGUAGE plpgsql
SET search_path = nutrition, pg_temp
AS $$
DECLARE
    v_version prescription_version%ROWTYPE;
    v_plan prescription%ROWTYPE;
    v_today date := (clock_timestamp() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date;
BEGIN
    SELECT * INTO STRICT v_version FROM prescription_version WHERE id = p_version_id;
    PERFORM 1 FROM patient WHERE id = v_version.patient_id FOR UPDATE;
    SELECT * INTO STRICT v_version FROM prescription_version WHERE id = p_version_id FOR UPDATE;
    SELECT * INTO STRICT v_plan FROM prescription WHERE id = v_version.prescription_id FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM assignment a JOIN app_user u ON u.id = a.doctor_id
        WHERE a.patient_id = v_plan.patient_id AND a.status = 'TRACKING'
          AND a.doctor_id = p_actor_id AND u.role IN ('DOCTOR', 'HEAD_DOCTOR') AND u.status = 'ACTIVE'
    ) THEN
        RAISE EXCEPTION USING ERRCODE = '42501', MESSAGE = 'Current tracking doctor required';
    END IF;

    IF v_plan.status NOT IN ('DRAFT','ISSUED') OR v_version.status <> 'DRAFT'
       OR v_version.effective_on < v_today OR v_version.effective_on < v_plan.period_start
       OR v_version.through_date > v_plan.period_end
       OR (v_version.version_no = 1 AND (v_version.effective_on <> v_plan.period_start
           OR v_version.through_date <> v_plan.period_end))
       OR (v_version.version_no > 1 AND (v_plan.status <> 'ISSUED' OR v_version.effective_on <= v_today))
       OR EXISTS (
           SELECT 1 FROM prescription_version
           WHERE prescription_id = v_plan.id AND status = 'PUBLISHED'
             AND version_no >= v_version.version_no
       ) THEN
        RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'Invalid effective range or version state';
    END IF;

    IF EXISTS (
        SELECT 1 FROM prescription_day d
        WHERE d.version_id = p_version_id
          AND (d.plan_date NOT BETWEEN v_version.effective_on AND v_version.through_date
               OR NOT EXISTS (SELECT 1 FROM prescription_item i WHERE i.day_id = d.id))
    ) OR (
        SELECT count(*) FROM prescription_day WHERE version_id = p_version_id
    ) <> (v_version.through_date - v_version.effective_on + 1) THEN
        RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'Each day of the selected period must contain meal items';
    END IF;

    IF EXISTS (
        SELECT 1 FROM daily_journal j JOIN prescription_day d
          ON d.patient_id = j.patient_id AND d.plan_date = j.journal_date
        WHERE d.version_id = p_version_id
    ) THEN
        RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'Cannot change a day that already has a journal';
    END IF;

    PERFORM f.id
    FROM food f
    WHERE EXISTS (
        SELECT 1 FROM food_version fv JOIN prescription_item i ON fv.id = i.food_version_id
        JOIN prescription_day d ON d.id = i.day_id
        WHERE fv.food_id = f.id AND d.version_id = p_version_id
    )
    ORDER BY f.id FOR UPDATE OF f;

    IF EXISTS (
        SELECT 1 FROM prescription_day d JOIN prescription_item i ON i.day_id = d.id
        JOIN food_version fv ON fv.id = i.food_version_id JOIN food f ON f.id = fv.food_id
        WHERE d.version_id = p_version_id
          AND (f.status NOT IN ('AVAILABLE','RESTRICTED') OR fv.status <> 'PUBLISHED'
               OR (i.unit <> fv.base_unit AND NOT EXISTS (
                   SELECT 1 FROM food_unit_conversion c
                   WHERE c.food_version_id = fv.id AND c.unit_name = i.unit)))
    ) THEN
        RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'Unavailable food, obsolete catalog version or invalid unit';
    END IF;

    IF EXISTS (
        SELECT 1 FROM prescription_day d JOIN prescription_item i ON i.day_id = d.id
        JOIN food_allergen fa ON fa.food_version_id = i.food_version_id
        JOIN health_declaration h ON h.allergen_id = fa.allergen_id
        WHERE d.version_id = p_version_id AND h.patient_id = v_plan.patient_id
          AND (h.status IN ('PENDING','NEEDS_INFORMATION') OR
               (h.status = 'CONFIRMED' AND h.severity IN ('CRITICAL','UNKNOWN')) OR
               (h.status = 'CONFIRMED' AND h.severity = 'NON_CRITICAL'
                AND (i.warning_code IS DISTINCT FROM 'ALLERGY_REVIEW' OR i.override_by IS DISTINCT FROM p_actor_id)))
    ) THEN
        RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'Allergy conflict requires review or blocks publication';
    END IF;

    IF EXISTS (
        SELECT 1 FROM prescription_day d JOIN prescription_item i ON i.day_id = d.id
        JOIN food_version fv ON fv.id = i.food_version_id JOIN food f ON f.id = fv.food_id
        WHERE d.version_id = p_version_id AND
          (
            (f.status = 'RESTRICTED' AND NOT EXISTS (
                SELECT 1 FROM food_restriction r WHERE r.food_version_id = fv.id
            ))
            OR EXISTS (
                SELECT 1 FROM food_restriction r
                WHERE r.food_version_id = fv.id
                  AND (r.condition_id IS NULL OR EXISTS (
                      SELECT 1 FROM health_declaration h
                      WHERE h.patient_id = v_plan.patient_id AND h.condition_id = r.condition_id
                        AND h.status = 'CONFIRMED'
                  ))
                  AND (NOT r.override_allowed OR i.warning_code IS NULL
                       OR i.override_by IS DISTINCT FROM p_actor_id)
            )
          )
    ) THEN
        RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'Food restriction prohibits publication or requires a signed note';
    END IF;

    IF EXISTS (
        SELECT 1 FROM applied_prescription_day ap
        JOIN prescription_day old_day ON old_day.id = ap.day_id
        JOIN prescription_version old_version ON old_version.id = old_day.version_id
        JOIN prescription_day new_day ON new_day.patient_id = ap.patient_id AND new_day.plan_date = ap.plan_date
        WHERE new_day.version_id = p_version_id AND old_version.prescription_id <> v_plan.id
    ) THEN
        RAISE EXCEPTION USING ERRCODE = '23505', MESSAGE = 'A different prescription already applies on this day';
    END IF;

    UPDATE prescription_version
    SET status = 'PUBLISHED', published_by = p_actor_id, published_at = clock_timestamp()
    WHERE id = p_version_id;
    INSERT INTO applied_prescription_day (patient_id, plan_date, day_id)
    SELECT patient_id, plan_date, id FROM prescription_day WHERE version_id = p_version_id
    ON CONFLICT (patient_id, plan_date) DO UPDATE SET day_id = EXCLUDED.day_id;
    UPDATE prescription SET status = 'ISSUED' WHERE id = v_plan.id;
    INSERT INTO audit_event (actor_id, action, object_type, object_id, patient_id)
    VALUES (p_actor_id, 'PRESCRIPTION_VERSION_PUBLISHED', 'PRESCRIPTION_VERSION', p_version_id, v_plan.patient_id);
END;
$$;
REVOKE EXECUTE ON FUNCTION publish_prescription(uuid, uuid) FROM PUBLIC;

CREATE FUNCTION close_or_stop_prescription(
    p_prescription_id uuid,
    p_actor_id uuid,
    p_target_status text,
    p_reason text,
    p_actual_end_date date DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SET search_path = nutrition, pg_temp
AS $$
DECLARE
    v_plan prescription%ROWTYPE;
    v_today date := (clock_timestamp() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date;
    v_end date;
BEGIN
    SELECT * INTO STRICT v_plan FROM prescription WHERE id = p_prescription_id;
    PERFORM 1 FROM patient WHERE id = v_plan.patient_id FOR UPDATE;
    SELECT * INTO STRICT v_plan FROM prescription WHERE id = p_prescription_id FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM app_user u
        WHERE u.id = p_actor_id AND u.status = 'ACTIVE'
          AND (
              u.role = 'HEAD_DOCTOR'
              OR (u.role = 'DOCTOR' AND EXISTS (
                  SELECT 1 FROM assignment a
                  WHERE a.patient_id = v_plan.patient_id AND a.doctor_id = p_actor_id AND a.ended_at IS NULL
              ))
          )
    ) THEN
        RAISE EXCEPTION USING ERRCODE = '42501', MESSAGE = 'Assigned doctor or HEAD_DOCTOR required';
    END IF;

    IF p_target_status NOT IN ('CLOSED','CANCELLED','STOPPED_EARLY')
       OR v_plan.status IN ('CLOSED','CANCELLED','STOPPED_EARLY') THEN
        RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'Invalid target status or prescription already terminated';
    END IF;

    IF p_target_status IN ('CANCELLED','STOPPED_EARLY') AND NULLIF(btrim(p_reason), '') IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'Reason required when cancelling or stopping early';
    END IF;

    IF p_target_status = 'CANCELLED' THEN
        IF v_plan.status <> 'DRAFT' AND v_today >= v_plan.period_start THEN
            RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'Cannot cancel prescription on or after period_start; use STOPPED_EARLY';
        END IF;
        DELETE FROM applied_prescription_day ap
        USING prescription_day d, prescription_version v
        WHERE ap.day_id = d.id AND d.version_id = v.id AND v.prescription_id = v_plan.id;
        v_end := NULL;
    ELSIF p_target_status = 'STOPPED_EARLY' THEN
        IF v_plan.status NOT IN ('ISSUED','EXPIRED') THEN
            RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'Only ISSUED or EXPIRED prescriptions can be stopped early';
        END IF;
        v_end := COALESCE(p_actual_end_date, GREATEST(v_today, v_plan.period_start));
        IF v_end < v_plan.period_start OR v_end > v_plan.period_end THEN
            RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'actual_end_date must fall within prescription period';
        END IF;
        DELETE FROM applied_prescription_day ap
        USING prescription_day d, prescription_version v
        WHERE ap.day_id = d.id AND d.version_id = v.id
          AND v.prescription_id = v_plan.id AND ap.plan_date > v_end;
    ELSE
        IF v_plan.status NOT IN ('ISSUED','EXPIRED') THEN
            RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'Only ISSUED or EXPIRED prescriptions can be closed';
        END IF;
        v_end := COALESCE(p_actual_end_date, v_plan.period_end);
        IF v_end < v_plan.period_start THEN
            RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'actual_end_date must be >= period_start';
        END IF;
    END IF;

    UPDATE prescription
    SET status = p_target_status,
        closed_by = p_actor_id,
        closed_at = clock_timestamp(),
        close_reason = NULLIF(btrim(p_reason), ''),
        actual_end_date = v_end
    WHERE id = v_plan.id;

    INSERT INTO audit_event (actor_id, action, object_type, object_id, patient_id, reason)
    VALUES (p_actor_id, 'PRESCRIPTION_' || p_target_status, 'PRESCRIPTION', v_plan.id, v_plan.patient_id, NULLIF(btrim(p_reason), ''));
END;
$$;
REVOKE EXECUTE ON FUNCTION close_or_stop_prescription(uuid, uuid, text, text, date) FROM PUBLIC;

CREATE FUNCTION protect_published_prescription_version() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF OLD.status = 'PUBLISHED' THEN
        RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'Published prescription version is immutable';
    END IF;
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER protect_prescription_version
BEFORE UPDATE OR DELETE ON prescription_version
FOR EACH ROW EXECUTE FUNCTION protect_published_prescription_version();

CREATE FUNCTION protect_published_prescription_content() RETURNS trigger
LANGUAGE plpgsql
SET search_path = nutrition, pg_temp
AS $$
DECLARE
    v_old_version_id uuid;
    v_new_version_id uuid;
    v_row record;
BEGIN
    IF TG_TABLE_NAME = 'prescription_day' THEN
        IF TG_OP <> 'INSERT' THEN v_old_version_id := OLD.version_id; END IF;
        IF TG_OP <> 'DELETE' THEN v_new_version_id := NEW.version_id; END IF;
    ELSE
        IF TG_OP <> 'INSERT' THEN
            SELECT version_id INTO v_old_version_id FROM prescription_day WHERE id = OLD.day_id;
        END IF;
        IF TG_OP <> 'DELETE' THEN
            SELECT version_id INTO v_new_version_id FROM prescription_day WHERE id = NEW.day_id;
        END IF;
    END IF;
    FOR v_row IN
        SELECT status FROM prescription_version
        WHERE id IN (v_old_version_id, v_new_version_id) ORDER BY id FOR KEY SHARE
    LOOP
        IF v_row.status = 'PUBLISHED' THEN
            RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'Published menu content is immutable';
        END IF;
    END LOOP;
    IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER protect_prescription_day
BEFORE INSERT OR UPDATE OR DELETE ON prescription_day
FOR EACH ROW EXECUTE FUNCTION protect_published_prescription_content();
CREATE TRIGGER protect_prescription_item
BEFORE INSERT OR UPDATE OR DELETE ON prescription_item
FOR EACH ROW EXECUTE FUNCTION protect_published_prescription_content();

CREATE VIEW patient_prescription_calendar AS
SELECT ad.patient_id, ad.plan_date, d.id AS day_id, v.id AS version_id, p.id AS prescription_id,
       v.target_kcal, v.protein_percent, v.carb_percent, v.fat_percent, v.water_ml,
       CASE
           WHEN p.status IN ('CLOSED','CANCELLED','STOPPED_EARLY','EXPIRED') THEN p.status
           WHEN p.period_start > (now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date THEN 'PENDING_START'
           WHEN p.period_end < (now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date THEN 'EXPIRED'
           ELSE 'ACTIVE'
       END AS display_state
FROM applied_prescription_day ad
JOIN prescription_day d ON d.id = ad.day_id
JOIN prescription_version v ON v.id = d.version_id
JOIN prescription p ON p.id = v.prescription_id;

COMMIT;
