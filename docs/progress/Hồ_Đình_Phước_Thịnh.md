# Nhật ký tiến độ — 24521679 – Hồ Đình Phước Thịnh

- **Phạm vi phụ trách:** `UC-PROF-02`, `UC-PROF-03`, `UC-APPT-01`, `UC-COMM-01`, Notification Outbox
- **Package Backend:** `com.nhom12.nutrition.doctor`, `com.nhom12.nutrition.communication`
- **Màn hình UI:** `SCR-HD-01..03`, `SCR-DOC-05` (tạm dừng), `SCR-DOC-07`, `SCR-PAT-07`, `SCR-PAT-08`
- **Tài liệu chi tiết:** [Hồ_Đình_Phước_Thịnh_tasks.docx](../tasks/Hồ_Đình_Phước_Thịnh_tasks.docx)

## Checklist giai đoạn

### Phase A — Phân công 30 ca & Tạm dừng (`BR-01`)
- [ ] API xem tải `doctor_tracking_load` + phân công / điều chuyển khóa thứ tự Patient -> Clinician chống vượt 30 suất `TRACKING`
- [ ] Điều chuyển bác sĩ đóng ca cũ (`ENDED`), thu hồi quyền BS cũ, bàn giao việc mở & tạo `conversation` mới
- [ ] Quản lý `tracking_pause` (nộp, rút `PENDING`, duyệt `APPROVED/REJECTED`, tạo khẩn cấp) + phục hồi về `TRACKING` hoặc `WAITING_CAPACITY`

### Phase B — Lịch khám & Hội thoại tư vấn
- [ ] API & UI Đặt lịch `UC-APPT-01` (`REQUESTED`, `CONFIRMED`, `NEEDS_INFORMATION`, `DECLINED`, `COMPLETED`)
- [ ] `Conversation` + `Message` (văn bản, tệp `attachment.message_id`, thẻ `appointment_id`) + nút gọi `work_contact` / verified phone
- [ ] Ghi `patient_interaction (CHAT_MESSAGE)` phục vụ `BR-06`

### Phase C — Thông báo & Kiểm thử tích hợp
- [ ] Service tạo `notification` (`IN_APP` / `EMAIL` với `event_key` chống trùng) dùng chung cho toàn nhóm
- [ ] Màn hình UI `SCR-HD-02`, `SCR-HD-03`, `SCR-DOC-07`, `SCR-PAT-08`
- [ ] Pass test 2 request đồng thời ca thứ 31 & test điều chuyển khóa quyền 403 (`E2E-2`)

## Lịch sử Commit & Push

> Dùng `.\scripts\log-commit.ps1 -MemberFile "Hồ_Đình_Phước_Thịnh.md" -Tested "..."` sau mỗi lần commit để tự động thêm dòng mới vào bảng bên dưới.

| Ngày | Branch | Commit | Nội dung đã làm | Kết quả Test | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| _(mẫu)_ | `feature/assignment-chat` | `abcd123` | `feat(doctor): enforce 30 tracking slots with row locking` | `mvn test PASS` | Xóa dòng mẫu khi bắt đầu |
