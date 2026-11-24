SET search_path = nutrition, public;

-- Seed dữ liệu phát triển / demo giả lập (idempotent: chạy lại nhiều lần không lỗi, không trùng).
-- Mật khẩu chung cho toàn bộ tài khoản demo trong file này: Demo@123456
-- (Password hash BCrypt $2a$10$ thực tế sẽ được sinh & xác thực bởi BCryptPasswordEncoder).

INSERT INTO app_user (id, role, full_name, email, phone, email_verified_at, phone_verified_at, password_hash, status)
VALUES
    ('10000000-0000-4000-8000-000000000001', 'ADMIN', 'Quản trị hệ thống', 'admin@nhom12.local', '+84901000001', now(), now(), '$2a$10$A9gvPpq2npaG7x7tko835e0gNL1qx7I4Yi//NvXfW6sMf2KSFrKLK', 'ACTIVE'),
    ('10000000-0000-4000-8000-000000000002', 'HEAD_DOCTOR', 'BS.CKII Trần Minh Khôi', 'truongkhoa@nhom12.local', '+84901000002', now(), now(), '$2a$10$A9gvPpq2npaG7x7tko835e0gNL1qx7I4Yi//NvXfW6sMf2KSFrKLK', 'ACTIVE'),
    ('10000000-0000-4000-8000-000000000003', 'DOCTOR', 'BS. Nguyễn Lan Anh', 'bacsi1@nhom12.local', '+84901000003', now(), now(), '$2a$10$A9gvPpq2npaG7x7tko835e0gNL1qx7I4Yi//NvXfW6sMf2KSFrKLK', 'ACTIVE'),
    ('10000000-0000-4000-8000-000000000004', 'DOCTOR', 'BS. Phạm Quốc Huy', 'bacsi2@nhom12.local', '+84901000004', now(), now(), '$2a$10$A9gvPpq2npaG7x7tko835e0gNL1qx7I4Yi//NvXfW6sMf2KSFrKLK', 'ACTIVE'),
    ('10000000-0000-4000-8000-000000000005', 'PATIENT', 'Lê Văn An', 'benhnhan1@nhom12.local', '+84901000005', now(), now(), '$2a$10$A9gvPpq2npaG7x7tko835e0gNL1qx7I4Yi//NvXfW6sMf2KSFrKLK', 'ACTIVE'),
    ('10000000-0000-4000-8000-000000000006', 'PATIENT', 'Nguyễn Thị Bình', 'benhnhan2@nhom12.local', '+84901000006', now(), now(), '$2a$10$A9gvPpq2npaG7x7tko835e0gNL1qx7I4Yi//NvXfW6sMf2KSFrKLK', 'ACTIVE'),
    ('10000000-0000-4000-8000-000000000007', 'PATIENT', 'Trần Hoàng Cường', 'benhnhan3@nhom12.local', '+84901000007', now(), now(), '$2a$10$A9gvPpq2npaG7x7tko835e0gNL1qx7I4Yi//NvXfW6sMf2KSFrKLK', 'ACTIVE')
ON CONFLICT (id) DO NOTHING;

INSERT INTO clinician (id, role, specialty, qualifications, experience, academic_title, work_contact)
VALUES
    ('10000000-0000-4000-8000-000000000002', 'HEAD_DOCTOR', 'Dinh dưỡng lâm sàng', 'Bác sĩ Chuyên khoa II', '14 năm', 'Trưởng khoa', '028-3800-1001'),
    ('10000000-0000-4000-8000-000000000003', 'DOCTOR', 'Nội tiết - Chuyển hóa', 'Thạc sĩ Y khoa', '8 năm', 'Bác sĩ điều trị', '028-3800-1002'),
    ('10000000-0000-4000-8000-000000000004', 'DOCTOR', 'Tim mạch - Huyết áp', 'Bác sĩ Chuyên khoa I', '6 năm', 'Bác sĩ điều trị', '028-3800-1003')
ON CONFLICT (id) DO NOTHING;

INSERT INTO patient (id, date_of_birth, sex, address, baseline_height_cm, baseline_weight_kg, activity_level, goals, medical_history)
VALUES
    ('10000000-0000-4000-8000-000000000005', DATE '1988-05-14', 'MALE', 'Quận 3, TP.HCM', 170.00, 74.50, 'MODERATE', 'Kiểm soát đường huyết lúc đói và giảm 4 kg trong 2 tháng', 'Tiền đái tháo đường type 2'),
    ('10000000-0000-4000-8000-000000000006', DATE '1994-11-02', 'FEMALE', 'Quận Bình Thạnh, TP.HCM', 158.00, 56.00, 'LIGHT', 'Cân bằng dinh dưỡng hậu phẫu nhẹ', 'Đã khám ngoại trú tháng 11/2026'),
    ('10000000-0000-4000-8000-000000000007', DATE '1979-03-21', 'MALE', 'TP. Thủ Đức, TP.HCM', 168.00, 78.00, 'SEDENTARY', 'Ổn định huyết áp tâm thu dưới 130 mmHg', 'Tăng huyết áp độ I')
ON CONFLICT (id) DO NOTHING;

INSERT INTO patient_intake (id, patient_id, previously_examined_here, requested_doctor_id, facility_visit_ref, declaration_notes, status, submitted_at, reviewed_by, reviewed_at, response)
VALUES
    ('20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000005', true, '10000000-0000-4000-8000-000000000003', 'PK-2026-1012', 'Đã khám nội tiết tuần trước', 'VERIFIED', now() - interval '7 days', '10000000-0000-4000-8000-000000000002', now() - interval '6 days', 'Đủ điều kiện theo dõi dinh dưỡng'),
    ('20000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000006', true, '10000000-0000-4000-8000-000000000003', 'PK-2026-1145', 'Gửi mã lượt khám chờ Trưởng khoa xác minh', 'SUBMITTED', now() - interval '1 day', NULL, NULL, NULL),
    ('20000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000007', true, '10000000-0000-4000-8000-000000000004', 'PK-2026-0988', 'Đã khám tim mạch định kỳ', 'VERIFIED', now() - interval '12 days', '10000000-0000-4000-8000-000000000002', now() - interval '11 days', 'Đã đối chiếu hồ sơ khám')
ON CONFLICT (id) DO NOTHING;

INSERT INTO assignment (id, patient_id, doctor_id, assigned_by, started_at, ended_at, status, active_slot, reason)
VALUES
    ('30000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000005', '10000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000002', now() - interval '6 days', NULL, 'TRACKING', 1, 'Phân công bác sĩ nội tiết theo dõi chính'),
    ('30000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000007', '10000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000002', now() - interval '10 days', NULL, 'PAUSED', NULL, 'Đang tạm dừng theo dõi do công tác')
ON CONFLICT (id) DO NOTHING;

INSERT INTO conversation (id, assignment_id)
VALUES
    ('31000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000001'),
    ('31000000-0000-4000-8000-000000000002', '30000000-0000-4000-8000-000000000002')
ON CONFLICT (assignment_id) DO NOTHING;

INSERT INTO tracking_pause (id, patient_id, assignment_id, start_date, end_date, reason, requested_by, status, reviewed_by, reviewed_at, review_note)
VALUES
    ('32000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000007', '30000000-0000-4000-8000-000000000002',
     (now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date, (now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date + 3,
     'Đi công tác 4 ngày', '10000000-0000-4000-8000-000000000007', 'APPROVED', '10000000-0000-4000-8000-000000000004', now() - interval '1 hour', 'Duyệt tạm dừng hợp lệ')
ON CONFLICT (id) DO NOTHING;

INSERT INTO condition_catalog (id, name)
VALUES
    ('40000000-0000-4000-8000-000000000001', 'Đái tháo đường type 2'),
    ('40000000-0000-4000-8000-000000000002', 'Tăng huyết áp'),
    ('40000000-0000-4000-8000-000000000003', 'Rối loạn lipid máu'),
    ('40000000-0000-4000-8000-000000000004', 'Bệnh thận mạn giai đoạn nhẹ')
ON CONFLICT (name) DO NOTHING;

INSERT INTO allergen (id, name)
VALUES
    ('41000000-0000-4000-8000-000000000001', 'Hải sản có vỏ (tôm, cua)'),
    ('41000000-0000-4000-8000-000000000002', 'Đậu phộng'),
    ('41000000-0000-4000-8000-000000000003', 'Lactose / Sữa bò'),
    ('41000000-0000-4000-8000-000000000004', 'Gluten')
ON CONFLICT (name) DO NOTHING;

INSERT INTO health_declaration (id, patient_id, kind, condition_id, allergen_id, patient_description, status, severity)
VALUES
    ('42000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000005', 'CONDITION', '40000000-0000-4000-8000-000000000001', NULL, 'Đang theo dõi đường huyết sáng', 'CONFIRMED', NULL),
    ('42000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000005', 'ALLERGY', NULL, '41000000-0000-4000-8000-000000000003', 'Đầy bụng nhẹ khi uống sữa tươi nguyên kem', 'CONFIRMED', 'NON_CRITICAL')
ON CONFLICT (id) DO NOTHING;

INSERT INTO food_group (id, name, active)
VALUES
    ('50000000-0000-4000-8000-000000000001', 'Ngũ cốc và tinh bột', true),
    ('50000000-0000-4000-8000-000000000002', 'Thịt, cá, trứng và đậu', true),
    ('50000000-0000-4000-8000-000000000003', 'Rau củ và trái cây', true),
    ('50000000-0000-4000-8000-000000000004', 'Sữa và chế phẩm', true),
    ('50000000-0000-4000-8000-000000000005', 'Món chế biến sẵn / Đồ uống', true)
ON CONFLICT (name) DO NOTHING;

INSERT INTO food (id, status)
VALUES
    ('51000000-0000-4000-8000-000000000001', 'AVAILABLE'),
    ('51000000-0000-4000-8000-000000000002', 'AVAILABLE'),
    ('51000000-0000-4000-8000-000000000003', 'AVAILABLE'),
    ('51000000-0000-4000-8000-000000000004', 'AVAILABLE'),
    ('51000000-0000-4000-8000-000000000005', 'RESTRICTED'),
    ('51000000-0000-4000-8000-000000000006', 'SUSPENDED')
ON CONFLICT (id) DO NOTHING;

INSERT INTO food_version (id, food_id, version_no, food_group_id, name, preparation, base_unit, base_quantity,
                          kcal, protein_g, carb_g, fat_g, fiber_g, sugar_g, sodium_mg, cholesterol_mg, glycemic_index,
                          proposed_by, reviewed_by, reviewed_at, status, review_note)
VALUES
    ('52000000-0000-4000-8000-000000000001', '51000000-0000-4000-8000-000000000001', 1, '50000000-0000-4000-8000-000000000001',
     'Cơm gạo lứt hấp', 'Vo sạch, nấu chín mềm', 'G', 100, 111.000, 2.600, 23.000, 0.900, 1.800, 0.400, 5.000, 0.000, 50.00,
     '10000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000002', now(), 'PUBLISHED', 'Đạt chuẩn thực đơn đái tháo đường'),
    ('52000000-0000-4000-8000-000000000002', '51000000-0000-4000-8000-000000000002', 1, '50000000-0000-4000-8000-000000000002',
     'Ức gà áp chảo ít dầu', 'Ướp thảo mộc, áp chảo không da', 'G', 100, 165.000, 31.000, 0.000, 3.600, 0.000, 0.000, 74.000, 85.000, 0.00,
     '10000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000002', now(), 'PUBLISHED', 'Giàu đạm, ít béo'),
    ('52000000-0000-4000-8000-000000000003', '51000000-0000-4000-8000-000000000003', 1, '50000000-0000-4000-8000-000000000003',
     'Bông cải xanh luộc', 'Luộc vừa chín, không thêm muối', 'G', 100, 35.000, 2.400, 7.200, 0.400, 3.300, 1.400, 41.000, 0.000, 15.00,
     '10000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000002', now(), 'PUBLISHED', 'Khuyến nghị mỗi bữa chính'),
    ('52000000-0000-4000-8000-000000000004', '51000000-0000-4000-8000-000000000004', 1, '50000000-0000-4000-8000-000000000004',
     'Sữa hạt hạnh nhân không đường', 'Uống trực tiếp hoặc làm ấm nhẹ', 'ML', 200, 30.000, 1.000, 1.000, 2.500, 0.500, 0.000, 130.000, 0.000, 25.00,
     '10000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000002', now(), 'PUBLISHED', 'Thay thế cho người bất dung nạp lactose'),
    ('52000000-0000-4000-8000-000000000005', '51000000-0000-4000-8000-000000000005', 1, '50000000-0000-4000-8000-000000000005',
     'Nước mắm pha nhạt', 'Pha loãng giảm natri', 'ML', 15, 9.000, 1.200, 1.000, 0.000, 0.000, 0.800, 780.000, 0.000, 0.00,
     '10000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000002', now(), 'PUBLISHED', 'Hạn chế dùng cho bệnh nhân tăng huyết áp'),
    ('52000000-0000-4000-8000-000000000006', '51000000-0000-4000-8000-000000000006', 1, '50000000-0000-4000-8000-000000000005',
     'Trà sữa trân châu đường đen', 'Đồ uống mẫu kiểm thử trạng thái đình chỉ', 'ML', 350, 390.000, 3.000, 72.000, 10.000, 0.500, 48.000, 95.000, 12.000, 78.00,
     '10000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000002', now(), 'PUBLISHED', 'Tạm đình chỉ đưa vào phiếu mới')
ON CONFLICT (food_id, version_no) DO NOTHING;

INSERT INTO food_unit_conversion (food_version_id, unit_name, to_base_unit)
VALUES
    ('52000000-0000-4000-8000-000000000001', 'CHÉN_VỪA', 150.0000),
    ('52000000-0000-4000-8000-000000000004', 'LY_200ML', 200.0000),
    ('52000000-0000-4000-8000-000000000005', 'MUỖNG_CANH', 15.0000)
ON CONFLICT (food_version_id, unit_name) DO NOTHING;

INSERT INTO food_restriction (id, food_version_id, condition_id, override_allowed, reason)
VALUES
    ('53000000-0000-4000-8000-000000000001', '52000000-0000-4000-8000-000000000005', '40000000-0000-4000-8000-000000000002',
     true, 'Hàm lượng natri cao; chỉ dùng khi bác sĩ ghi rõ hướng dẫn pha loãng')
ON CONFLICT (food_version_id, condition_id) WHERE condition_id IS NOT NULL DO NOTHING;

INSERT INTO threshold_rule (id, code, version_no, kind, unit, context_code, patient_id, condition_id, condition_priority,
                            status, effective_from, approved_by, approved_at)
VALUES
    ('60000000-0000-4000-8000-000000000001', 'BP_GLOBAL_RESTING', 1, 'BP', 'MMHG', 'RESTING', NULL, NULL, NULL,
     'APPROVED', now() - interval '30 days', '10000000-0000-4000-8000-000000000002', now() - interval '30 days'),
    ('60000000-0000-4000-8000-000000000002', 'GLUCOSE_GLOBAL_FASTING', 1, 'GLUCOSE', 'MMOL_L', 'FASTING', NULL, NULL, NULL,
     'APPROVED', now() - interval '30 days', '10000000-0000-4000-8000-000000000002', now() - interval '30 days')
ON CONFLICT (code, version_no) DO NOTHING;

INSERT INTO threshold_clause (id, rule_id, operand, comparison, limit_value)
VALUES
    ('61000000-0000-4000-8000-000000000001', '60000000-0000-4000-8000-000000000001', 'SYSTOLIC', 'GE', 140.000),
    ('61000000-0000-4000-8000-000000000002', '60000000-0000-4000-8000-000000000001', 'DIASTOLIC', 'GE', 90.000),
    ('61000000-0000-4000-8000-000000000003', '60000000-0000-4000-8000-000000000002', 'GLUCOSE', 'GE', 7.000),
    ('61000000-0000-4000-8000-000000000004', '60000000-0000-4000-8000-000000000002', 'GLUCOSE', 'LT', 3.900)
ON CONFLICT (rule_id, operand, comparison) DO NOTHING;

INSERT INTO system_setting (setting_key, value_json, description, version_no, updated_by)
VALUES
    ('clinic.working_hours', '{"timezone":"Asia/Ho_Chi_Minh","start":"07:30","end":"17:00","days":["MON","TUE","WED","THU","FRI","SAT"]}'::jsonb, 'Khung giờ có nhân sự xử lý cảnh báo của cơ sở', 1, '10000000-0000-4000-8000-000000000001'),
    ('journal.edit_window_hours', '48'::jsonb, 'Số giờ cho phép bệnh nhân tự sửa nhật ký kể từ cuối ngày (giờ VN)', 1, '10000000-0000-4000-8000-000000000001'),
    ('alert.red_ack_sla_minutes', '60'::jsonb, 'Chỉ tiêu tiếp nhận cảnh báo đỏ (phút)', 1, '10000000-0000-4000-8000-000000000001'),
    ('alert.red_resolve_sla_minutes', '120'::jsonb, 'Chỉ tiêu giải quyết cảnh báo đỏ (phút)', 1, '10000000-0000-4000-8000-000000000001'),
    ('assignment.max_active_patients', '30'::jsonb, 'Số ca TRACKING tối đa của một bác sĩ (BR-01)', 1, '10000000-0000-4000-8000-000000000001')
ON CONFLICT (setting_key) DO NOTHING;

INSERT INTO system_setting_history (setting_key, version_no, old_value_json, new_value_json, change_reason, changed_by)
SELECT setting_key, 1, NULL, value_json, 'Khởi tạo tham số vận hành mặc định cho môi trường phát triển', updated_by
FROM system_setting
ON CONFLICT (setting_key, version_no) DO NOTHING;
