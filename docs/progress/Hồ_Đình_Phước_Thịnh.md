# Nhật ký tiến độ — 24521679 – Hồ Đình Phước Thịnh

- **Mã nhánh:** `hdp-thinh` (ví dụ: `feat/hdp-thinh/intake-30slots`, `feat/hdp-thinh/pause-appointments`, `feat/hdp-thinh/chat-notifications`)
- **Phạm vi phụ trách (v1.1):** `UC-PROF-04`, `UC-PROF-02`, `UC-PROF-03`, `UC-APPT-01`, `UC-COMM-01`, Notification Outbox (BE + FE)
- **Package Backend:** `com.nhom12.nutrition.intake` (dùng `PatientIntake` trong `patient/`), `.doctor`, `.communication`
- **Thư mục Frontend:** `frontend/src/features/{intake,assignments,tracking-pauses,appointments,chat,notifications}`
- **Màn hình UI:** `SCR-PAT-07`, `SCR-PAT-07A`, `SCR-PAT-08`, `SCR-DOC-05` (tạm dừng), `SCR-DOC-07`, `SCR-HD-01`, `SCR-HD-01B`, `SCR-HD-02`, `SCR-HD-03`
- **Tài liệu chi tiết:** [Hồ_Đình_Phước_Thịnh_tasks.docx](../tasks/Hồ_Đình_Phước_Thịnh_tasks.docx) | [AI_TASKS_OVERVIEW.md](../tasks/AI_TASKS_OVERVIEW.md)

> **Lưu ý phân công v1.1:** Nhận thêm `UC-PROF-04` (nộp `patient_intake` + tệp đính kèm minh chứng + hàng đợi Trưởng khoa `SCR-HD-01B`) để khép kín quy trình Trưởng khoa (`Tiếp nhận -> Phân công 30 ca -> Lịch khám`) và dùng chung upload `attachment` với Chat. Trong tuần đầu chưa có `frontend/`, bạn code Backend Phase A dùng `@WithMockUser` bình thường, rồi pull `main` sau PR #1 của Đặng Trần Thiện.

## Checklist giai đoạn

### Phase A — Tiếp nhận (`UC-PROF-04`) & Phân công 30 ca (`BR-01`)
- [ ] API + UI Bệnh nhân nộp `patient_intake` (tối đa 1 hồ sơ mở, bắt buộc đã xác minh SĐT), bổ sung/rút, upload/tải `attachment` kiểm tra quyền (`SCR-PAT-07A`)
- [ ] API + UI Hàng đợi Trưởng khoa duyệt `VERIFIED / NEEDS_INFORMATION / DECLINED` kèm `audit_event` (`SCR-HD-01B`)
- [ ] API xem tải `doctor_tracking_load` + phân công/điều chuyển khóa hàng `patient -> clinician` chống vượt 30 suất `TRACKING` (`SCR-HD-02`)
- [ ] Điều chuyển bác sĩ đóng ca cũ (`ENDED`), khóa quyền 403 BS cũ, bàn giao alert mở & tạo `conversation` mới

### Phase B — Tạm dừng theo dõi (`UC-PROF-03`) & Lịch khám (`UC-APPT-01`)
- [ ] API + UI `tracking_pause` (nộp, rút `PENDING`, duyệt `APPROVED/REJECTED`, tạo khẩn cấp) + phục hồi về `TRACKING` hoặc `WAITING_CAPACITY`
- [ ] API + UI Đặt lịch `UC-APPT-01` (`REQUESTED`, `CONFIRMED`, `NEEDS_INFORMATION`, `DECLINED`, `COMPLETED`) tại `SCR-PAT-07` & `SCR-HD-03`

### Phase C — Hội thoại tư vấn, Thông báo Outbox & Kiểm thử tích hợp
- [ ] `Conversation` + `Message` (văn bản, tệp `attachment.message_id`, thẻ `appointment_id`) + nút gọi `work_contact` / verified phone (`SCR-DOC-07`, `SCR-PAT-08`)
- [ ] Ghi `patient_interaction (CHAT_MESSAGE)` phục vụ `BR-06` + Service tạo `notification` (`IN_APP`/`EMAIL` chống trùng `event_key`) dùng chung toàn nhóm
- [ ] Pass test 2 request đồng thời ca thứ 31, upload/download IDOR & test điều chuyển khóa quyền 403 (`E2E-2`)

## Lịch sử Commit & Push

> Dùng `.\scripts\log-commit.ps1 -MemberFile "Hồ_Đình_Phước_Thịnh.md" -Tested "..."` sau mỗi lần commit để tự động thêm dòng mới vào bảng bên dưới.

| Ngày | Branch | Commit | Nội dung đã làm | Kết quả Test | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| _(mẫu)_ | `feat/hdp-thinh/intake-30slots` | `abcd123` | `feat(intake): implement patient intake review and 30-slot lock` | `mvn test PASS` | Xóa dòng mẫu khi bắt đầu |
