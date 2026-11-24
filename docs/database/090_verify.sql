BEGIN;
SET search_path = nutrition, public;

DO $$
DECLARE
    v_head uuid;
    v_doctor uuid;
    v_patient uuid;
    v_assignment uuid;
    v_group uuid;
    v_food uuid;
    v_food_version uuid;
    v_allergen uuid;
    v_declaration uuid;
    v_prescription uuid;
    v_version uuid;
    v_second uuid;
    v_day date := (now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date + 1;
    v_event_at timestamptz := now();
    v_counter integer;
    v_id uuid;
    v_index integer;
    v_journal_date date := (now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date;
    v_measurement uuid;
    v_rule uuid;
    v_assessment uuid;
    v_head2 uuid;
    v_patient_head uuid;
    v_conv uuid;
    v_appt uuid;
    v_msg uuid;
BEGIN
    INSERT INTO app_user (role, full_name, email, phone, password_hash, status)
    VALUES ('HEAD_DOCTOR', 'Test Head', 'head@example.invalid', '+84900000001', 'test', 'ACTIVE')
    RETURNING id INTO v_head;
    INSERT INTO app_user (role, full_name, email, phone, password_hash, status)
    VALUES ('DOCTOR', 'Test Doctor', 'doctor@example.invalid', '+84900000002', 'test', 'ACTIVE')
    RETURNING id INTO v_doctor;
    INSERT INTO clinician (id, role) VALUES (v_head, 'HEAD_DOCTOR'), (v_doctor, 'DOCTOR');

    FOR v_index IN 1..31 LOOP
        INSERT INTO app_user (role, full_name, email, phone, password_hash, status, email_verified_at)
        VALUES ('PATIENT', 'Test Patient', format('patient%s@example.invalid', v_index), '+84900000003',
                'test', 'ACTIVE', now())
        RETURNING id INTO v_id;
        INSERT INTO patient (id) VALUES (v_id);
        IF v_index <= 30 THEN
            INSERT INTO assignment (patient_id, doctor_id, assigned_by, status, active_slot)
            VALUES (v_id, v_doctor, v_head, 'TRACKING', v_index);
        END IF;
        IF v_index = 1 THEN v_patient := v_id; END IF;
    END LOOP;
    BEGIN
        INSERT INTO assignment (patient_id, doctor_id, assigned_by, status, active_slot)
        VALUES (v_id, v_doctor, v_head, 'TRACKING', 30);
        RAISE EXCEPTION 'Test failed: an active slot was duplicated';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;
    UPDATE assignment SET status = 'PAUSED', active_slot = NULL WHERE doctor_id = v_doctor AND active_slot = 30;
    INSERT INTO assignment (patient_id, doctor_id, assigned_by, status, active_slot)
    VALUES (v_id, v_doctor, v_head, 'TRACKING', 30);
    IF (SELECT tracking_count FROM doctor_tracking_load WHERE doctor_id = v_doctor) <> 30
       OR (SELECT other_assigned_count FROM doctor_tracking_load WHERE doctor_id = v_doctor) <> 1 THEN
        RAISE EXCEPTION 'Test failed: paused tracking capacity';
    END IF;
    BEGIN
        INSERT INTO assignment (patient_id, doctor_id, assigned_by, status)
        VALUES (v_patient, v_doctor, v_head, 'PAUSED');
        RAISE EXCEPTION 'Test failed: duplicate current assignment accepted';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;
    SELECT id INTO STRICT v_assignment FROM assignment WHERE patient_id = v_patient AND ended_at IS NULL;

    BEGIN
        INSERT INTO appointment (patient_id, requested_by, request_type, status)
        VALUES (v_patient, v_patient, 'INITIAL_EXAM', 'CONFIRMED');
        RAISE EXCEPTION 'Test failed: confirmation accepted without schedule';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    INSERT INTO appointment (patient_id, requested_by, request_type, preferred_start)
    VALUES (v_patient, v_patient, 'INITIAL_EXAM', v_event_at + interval '7 days');

    INSERT INTO food_group (name) VALUES ('Test group') RETURNING id INTO v_group;
    INSERT INTO food (status) VALUES ('SUSPENDED') RETURNING id INTO v_food;
    INSERT INTO food_version (food_id, food_group_id, version_no, name, base_unit, base_quantity,
           kcal, protein_g, carb_g, fat_g, sodium_mg, proposed_by, reviewed_by, reviewed_at, status)
    VALUES (v_food, v_group, 1, 'Test food', 'G', 100, 200, 10, 30, 5, 80, v_doctor, v_head, now(), 'PUBLISHED')
    RETURNING id INTO v_food_version;
    INSERT INTO prescription (patient_id, assignment_id, created_by, period_start, period_end)
    VALUES (v_patient, v_assignment, v_doctor, v_day, v_day + 6) RETURNING id INTO v_prescription;
    INSERT INTO prescription_version (prescription_id, patient_id, version_no, effective_on, through_date,
           target_kcal, protein_percent, carb_percent, fat_percent, water_ml, created_by)
    VALUES (v_prescription, v_patient, 1, v_day, v_day + 6, 1800, 20, 50, 30, 1200, v_doctor)
    RETURNING id INTO v_version;
    INSERT INTO prescription_day (version_id, patient_id, plan_date)
    SELECT v_version, v_patient, v_day + d FROM generate_series(0, 6) AS day_offsets(d);
    INSERT INTO prescription_item (day_id, slot, food_version_id, quantity, unit)
    SELECT id, 'BREAKFAST', v_food_version, 100, 'G' FROM prescription_day WHERE version_id = v_version;
    BEGIN
        PERFORM publish_prescription(v_version, v_head);
        RAISE EXCEPTION 'Test failed: publishing by wrong actor';
    EXCEPTION WHEN insufficient_privilege THEN NULL;
    END;
    BEGIN
        PERFORM publish_prescription(v_version, v_doctor);
        RAISE EXCEPTION 'Test failed: suspended food published';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    UPDATE food SET status = 'AVAILABLE' WHERE id = v_food;
    INSERT INTO allergen (name) VALUES ('Test allergen') RETURNING id INTO v_allergen;
    INSERT INTO food_allergen VALUES (v_food_version, v_allergen);
    INSERT INTO health_declaration (patient_id, kind, allergen_id, status, severity)
    VALUES (v_patient, 'ALLERGY', v_allergen, 'CONFIRMED', 'CRITICAL') RETURNING id INTO v_declaration;
    BEGIN
        PERFORM publish_prescription(v_version, v_doctor);
        RAISE EXCEPTION 'Test failed: critical allergy published';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    UPDATE health_declaration SET status = 'INACTIVE' WHERE id = v_declaration;
    INSERT INTO food_restriction (food_version_id, override_allowed, reason)
    VALUES (v_food_version, true, 'Test restriction');
    BEGIN
        PERFORM publish_prescription(v_version, v_doctor);
        RAISE EXCEPTION 'Test failed: mandatory note missing';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    UPDATE prescription_item SET warning_code = 'RESTRICTED', warning_reason = 'Test restriction',
           patient_instruction = 'Test note', override_by = v_doctor, override_at = now();
    PERFORM publish_prescription(v_version, v_doctor);
    SELECT count(*) INTO v_counter FROM patient_prescription_calendar WHERE patient_id = v_patient;
    IF v_counter <> 7 THEN RAISE EXCEPTION 'Test failed: expected seven published days'; END IF;
    BEGIN
        UPDATE prescription_item SET quantity = 125 WHERE warning_code = 'RESTRICTED';
        RAISE EXCEPTION 'Test failed: published history changed';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    INSERT INTO prescription (patient_id, assignment_id, created_by, period_start, period_end)
    VALUES (v_patient, v_assignment, v_doctor, v_day, v_day + 6) RETURNING id INTO v_prescription;
    INSERT INTO prescription_version (prescription_id, patient_id, version_no, effective_on, through_date,
           target_kcal, protein_percent, carb_percent, fat_percent, water_ml, created_by)
    VALUES (v_prescription, v_patient, 1, v_day, v_day + 6, 1800, 20, 50, 30, 1200, v_doctor)
    RETURNING id INTO v_second;
    INSERT INTO prescription_day (version_id, patient_id, plan_date)
    SELECT v_second, v_patient, v_day + d FROM generate_series(0, 6) AS day_offsets(d);
    INSERT INTO prescription_item (day_id, slot, food_version_id, quantity, unit, warning_code,
           warning_reason, patient_instruction, override_by, override_at)
    SELECT id, 'BREAKFAST', v_food_version, 100, 'G', 'RESTRICTED', 'Test restriction', 'Test note', v_doctor, now()
    FROM prescription_day WHERE version_id = v_second;
    BEGIN
        PERFORM publish_prescription(v_second, v_doctor);
        RAISE EXCEPTION 'Test failed: clinical plans overlap';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    INSERT INTO daily_journal (patient_id, journal_date) VALUES (v_patient, v_journal_date);
    INSERT INTO calorie_assessment (patient_id, journal_date, state, actual_kcal, target_kcal)
    VALUES (v_patient, v_journal_date, 'WITHIN_TARGET', 1150, 1000),
           (v_patient, v_journal_date, 'YELLOW', 849, 1000),
           (v_patient, v_journal_date, 'YELLOW', 1151, 1000);
    BEGIN
        INSERT INTO calorie_assessment (patient_id, journal_date, state, actual_kcal, target_kcal)
        VALUES (v_patient, v_journal_date, 'YELLOW', 1150, 1000);
        RAISE EXCEPTION 'Test failed: exactly 15 percent must not trigger an alert';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    INSERT INTO vital_measurement (patient_id, kind, measured_at, unit, context_code, value_1, value_2)
    VALUES (v_patient, 'BP', v_event_at, 'MMHG', 'TEST', 140, 90) RETURNING id INTO v_measurement;
    INSERT INTO threshold_rule (code, version_no, kind, unit, context_code, status, effective_from,
           approved_by, approved_at)
    VALUES ('TEST', 1, 'BP', 'MMHG', 'TEST', 'APPROVED', v_event_at, v_head, v_event_at)
    RETURNING id INTO v_rule;
    INSERT INTO vital_assessment (measurement_id, patient_id, rule_id, state)
    VALUES (v_measurement, v_patient, v_rule, 'RED') RETURNING id INTO v_assessment;
    BEGIN
        INSERT INTO alert (patient_id, type, vital_assessment_id, occurred_at, acknowledge_due_at, resolve_due_at)
        VALUES (v_patient, 'RED_VITAL', v_assessment, v_event_at, v_event_at + interval '2 hours',
                v_event_at + interval '2 hours');
        RAISE EXCEPTION 'Test failed: acknowledgment deadline is not one hour';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    INSERT INTO alert (patient_id, type, vital_assessment_id, occurred_at, acknowledge_due_at, resolve_due_at)
    VALUES (v_patient, 'RED_VITAL', v_assessment, v_event_at, v_event_at + interval '1 hour',
            v_event_at + interval '2 hours');

    INSERT INTO notification (recipient_id, channel, event_key)
    VALUES (v_patient, 'IN_APP', 'test.event'), (v_patient, 'EMAIL', 'test.event');
    BEGIN
        INSERT INTO notification (recipient_id, channel, event_key) VALUES (v_patient, 'EMAIL', 'test.event');
        RAISE EXCEPTION 'Test failed: duplicated notification accepted';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    -- 1. HEAD_DOCTOR assigned directly as active tracking doctor CAN publish prescription; unassigned HEAD_DOCTOR cannot.
    INSERT INTO app_user (role, full_name, email, phone, password_hash, status, email_verified_at)
    VALUES ('PATIENT', 'Head Patient', 'headpatient@example.invalid', '+84900000004', 'test', 'ACTIVE', now())
    RETURNING id INTO v_patient_head;
    INSERT INTO patient (id) VALUES (v_patient_head);
    INSERT INTO assignment (patient_id, doctor_id, assigned_by, status, active_slot)
    VALUES (v_patient_head, v_head, v_head, 'TRACKING', 1);
    INSERT INTO prescription (patient_id, assignment_id, created_by, period_start, period_end)
    SELECT v_patient_head, id, v_head, v_day, v_day + 6 FROM assignment WHERE patient_id = v_patient_head AND ended_at IS NULL
    RETURNING id INTO v_prescription;
    INSERT INTO prescription_version (prescription_id, patient_id, version_no, effective_on, through_date,
           target_kcal, protein_percent, carb_percent, fat_percent, water_ml, created_by)
    VALUES (v_prescription, v_patient_head, 1, v_day, v_day + 6, 1700, 25, 45, 30, 1200, v_head)
    RETURNING id INTO v_version;
    INSERT INTO prescription_day (version_id, patient_id, plan_date)
    SELECT v_version, v_patient_head, v_day + d FROM generate_series(0, 6) AS day_offsets(d);
    INSERT INTO prescription_item (day_id, slot, food_version_id, quantity, unit, warning_code,
           warning_reason, patient_instruction, override_by, override_at)
    SELECT id, 'BREAKFAST', v_food_version, 100, 'G', 'RESTRICTED', 'Test restriction', 'Test note', v_head, now()
    FROM prescription_day WHERE version_id = v_version;
    PERFORM publish_prescription(v_version, v_head);

    INSERT INTO app_user (role, full_name, email, phone, password_hash, status)
    VALUES ('HEAD_DOCTOR', 'Second Head', 'head2@example.invalid', '+84900000005', 'test', 'ACTIVE')
    RETURNING id INTO v_head2;
    INSERT INTO clinician (id, role) VALUES (v_head2, 'HEAD_DOCTOR');
    BEGIN
        PERFORM publish_prescription(v_version, v_head2);
        RAISE EXCEPTION 'Test failed: unassigned head doctor must not publish';
    EXCEPTION WHEN insufficient_privilege THEN NULL;
    END;

    -- 2. STOPPED_EARLY constraints, close_or_stop_prescription releasing future dates, and treatment_review
    BEGIN
        INSERT INTO prescription (patient_id, assignment_id, created_by, period_start, period_end, status, closed_by, closed_at)
        VALUES (v_patient_head, (SELECT id FROM assignment WHERE patient_id = v_patient_head AND ended_at IS NULL),
                v_head, v_day + 7, v_day + 13, 'STOPPED_EARLY', v_head, now());
        RAISE EXCEPTION 'Test failed: STOPPED_EARLY allowed without close_reason/actual_end_date';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    PERFORM close_or_stop_prescription(v_prescription, v_head, 'STOPPED_EARLY', 'Benh nhan chuyen phac do', v_day + 2);
    IF (SELECT status FROM prescription WHERE id = v_prescription) <> 'STOPPED_EARLY'
       OR (SELECT count(*) FROM applied_prescription_day WHERE patient_id = v_patient_head) <> 3
       OR NOT EXISTS (SELECT 1 FROM audit_event WHERE object_id = v_prescription AND action = 'PRESCRIPTION_STOPPED_EARLY') THEN
        RAISE EXCEPTION 'Test failed: close_or_stop_prescription did not stop early cleanly';
    END IF;

    -- Freed dates (v_day + 3 .. v_day + 9) can now host a newly published prescription
    INSERT INTO prescription (patient_id, assignment_id, created_by, period_start, period_end)
    VALUES (v_patient_head, (SELECT id FROM assignment WHERE patient_id = v_patient_head AND ended_at IS NULL),
            v_head, v_day + 3, v_day + 9)
    RETURNING id INTO v_second;
    INSERT INTO prescription_version (prescription_id, patient_id, version_no, effective_on, through_date,
           target_kcal, protein_percent, carb_percent, fat_percent, water_ml, created_by)
    VALUES (v_second, v_patient_head, 1, v_day + 3, v_day + 9, 1750, 25, 45, 30, 1200, v_head)
    RETURNING id INTO v_version;
    INSERT INTO prescription_day (version_id, patient_id, plan_date)
    SELECT v_version, v_patient_head, (v_day + 3) + d FROM generate_series(0, 6) AS day_offsets(d);
    INSERT INTO prescription_item (day_id, slot, food_version_id, quantity, unit, warning_code,
           warning_reason, patient_instruction, override_by, override_at)
    SELECT id, 'LUNCH', v_food_version, 100, 'G', 'RESTRICTED', 'Test restriction', 'Test note', v_head, now()
    FROM prescription_day WHERE version_id = v_version;
    PERFORM publish_prescription(v_version, v_head);

    INSERT INTO treatment_review (prescription_id, patient_id, reviewed_by, outcome_summary, next_step_guidance, follow_up_recommended)
    VALUES (v_prescription, v_patient_head, v_head, 'On dinh chi so duong huyet sau 3 ngay dau', 'Chuyen sang thuc don moi', true);
    BEGIN
        INSERT INTO treatment_review (prescription_id, patient_id, reviewed_by, outcome_summary)
        VALUES (v_second, v_patient_head, v_head, '   ');
        RAISE EXCEPTION 'Test failed: blank outcome_summary accepted';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 3. Message linked to appointment_id + attachment linked to message_id
    INSERT INTO conversation (assignment_id) VALUES (v_assignment) RETURNING id INTO v_conv;
    INSERT INTO appointment (patient_id, assignment_id, requested_by, request_type, preferred_start)
    VALUES (v_patient, v_assignment, v_doctor, 'FOLLOW_UP', v_event_at + interval '5 days')
    RETURNING id INTO v_appt;
    INSERT INTO message (conversation_id, sender_id, body, appointment_id)
    VALUES (v_conv, v_doctor, 'De nghi tai kham sau 5 ngay', v_appt)
    RETURNING id INTO v_msg;
    INSERT INTO attachment (patient_id, message_id, uploaded_by, object_key, file_name, mime_type, size_bytes)
    VALUES (v_patient, v_msg, v_doctor, 'chat/sample-plan.pdf', 'sample-plan.pdf', 'application/pdf', 1024);

    -- 4. system_setting & system_setting_history
    INSERT INTO system_setting (setting_key, value_json, description, version_no, updated_by)
    VALUES ('test.retention_days', '{"days": 365}'::jsonb, 'Retention policy', 1, v_head);
    INSERT INTO system_setting_history (setting_key, version_no, old_value_json, new_value_json, change_reason, changed_by)
    VALUES ('test.retention_days', 1, NULL, '{"days": 365}'::jsonb, 'Initial test setting', v_head);
    BEGIN
        INSERT INTO system_setting_history (setting_key, version_no, new_value_json, change_reason, changed_by)
        VALUES ('test.retention_days', 2, '{"days": 730}'::jsonb, '  ', v_head);
        RAISE EXCEPTION 'Test failed: blank change_reason accepted';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 5. Role update cascade from app_user to clinician (DOCTOR -> HEAD_DOCTOR)
    UPDATE app_user SET role = 'HEAD_DOCTOR' WHERE id = v_doctor;
    IF (SELECT role FROM clinician WHERE id = v_doctor) <> 'HEAD_DOCTOR' THEN
        RAISE EXCEPTION 'Test failed: role update did not cascade to clinician';
    END IF;
END;
$$;
ROLLBACK;
