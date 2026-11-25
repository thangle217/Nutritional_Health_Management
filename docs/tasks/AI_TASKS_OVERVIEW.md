# Tóm tắt Phân công & Đặc tả Kỹ thuật cho AI Agents (Phiên bản v1.1 — Kèm React Frontend)

Tài liệu này chuyển thể đầy đủ nội dung từ 4 file Word giao việc (`docs/tasks/*_tasks.docx`, bản cập nhật **v1.1 ngày 25/11/2026**) sang định dạng Markdown thuần để mọi AI coding agent đọc trực tiếp không sai lệch.
Khi cần xem sơ đồ luồng màn hình (`06_ui_flows/*.png`), wireframe (`07_ui_wireframes/*.png`) hoặc mô tả chi tiết từng nút bấm trên UI, đối chiếu [`docs/specs/Nhom12_Dac_Ta_UI_va_Luong_Man_Hinh.docx`](../specs/Nhom12_Dac_Ta_UI_va_Luong_Man_Hinh.docx).

---

## 0. Tóm tắt tái cân bằng công việc khi thêm React Frontend (v1.1)

Để giữ cân bằng khối lượng khi triển khai đầy đủ **React Frontend** trong cùng monorepo:
- **24521657 – Đặng Trần Thiện** phụ trách **Sprint 0 React Frontend Foundation** (khởi tạo `frontend/`, 5 layout vai trò, `RoleGuard`, `apiClient`, token màu, form/chart kit) + **Auth/JWT**, **Onboarding BMI** và **Quản trị tài khoản Admin**. Hai Use Case `UC-PROF-04` và `UC-PROF-05` được chuyển cho 2 bạn phù hợp nhất về nghiệp vụ.
- **24521679 – Hồ Đình Phước Thịnh** nhận thêm **`UC-PROF-04` (Tiếp nhận bệnh nhân & tệp minh chứng)** để khép kín toàn bộ quy trình Trưởng khoa (`Duyệt tiếp nhận -> Phân công 30 ca -> Đặt lịch khám`) và dùng chung hạ tầng upload `attachment` với Chat.
- **24521702 – Phạm Đình Thịnh** nhận thêm **`UC-PROF-05` (Khai báo bệnh lý/dị ứng & `FoodSafetyReview`)** vì logic xác nhận dị ứng trùng đơn gắn trực tiếp với `applied_prescription_day` và `prescription_item` do bạn xây dựng, giảm phụ thuộc chéo giữa hai người.
- **24521666 – Phan Viết Thiện** giữ nguyên nghiệp vụ Theo dõi hằng ngày (`Nhật ký 48h`, `Chỉ số`, `Cảnh báo Đỏ/Vàng`, `Job BR-06/07`, `7 Báo cáo CSV`, `Cài đặt & Audit`), đồng thời giảm tải phần khung `SCR-ADM-00` và layout chung (do Đặng Trần Thiện dựng sẵn ở Sprint 0).

---

## 1. Giao diện tích hợp liên module (Cross-Module Contracts)

| Interface / Dịch vụ dùng chung | Người cung cấp | Người sử dụng | Quy ước tích hợp |
| --- | --- | --- | --- |
| **`CurrentUser` / `SecurityContextHelper`** | Đặng Trần Thiện (`auth`) | Cả 3 thành viên còn lại | Cung cấp `userId`, `role`, `patientId` (nếu là `PATIENT`), `clinicianId` (nếu là `DOCTOR`/`HEAD_DOCTOR`) từ JWT Bearer token |
| **`NotificationOutboxService` + `ChatEventCardService`** | Hồ Đình Phước Thịnh (`communication`) | Phạm Đình Thịnh, Phan Viết Thiện | Service nội bộ tạo `notification` (`IN_APP`/`EMAIL` chống trùng `event_key`) và chèn thẻ sự kiện vào `conversation` (thẻ Nhật ký ngày, Cảnh báo Đỏ/Vàng, Sắp hết hạn `BR-07`, Ngừng tuân thủ `BR-06`) |
| **`FoodSafetyReview` hook** | Phạm Đình Thịnh (`clinical`/`mealplan`) | Hệ thống đơn & dị ứng | Tự sinh `food_safety_review` khi dị ứng mới `CONFIRMED` trùng món trong `applied_prescription_day` |
| **Dashboard Widget Slots (`SCR-PAT-01`, `SCR-DOC-01`, `SCR-ADM-00`)** | Khung layout do `dt-thien` dựng | `pv-thien`, `hdp-thinh`, `pd-thinh` | Layout cha cung cấp vùng grid widget; mỗi bạn đăng ký component widget của mình (KPI Calo/Nước/Nhật ký/Cảnh báo của `pv-thien`, số tải BS/Lịch hẹn của `hdp-thinh`) |

---

## 2. 24521657 – Đặng Trần Thiện (`dt-thien`)
**Vai trò:** Sprint 0 React Frontend Foundation + Auth, Tài khoản, Onboarding & Hồ sơ cơ bản

- **Use Cases:** `UC-AUTH-01`, `UC-AUTH-02`, `UC-AUTH-03`, `UC-AUTH-04`, `UC-USER-01`, `UC-PROF-01`
- **Backend Packages:** `com.nhom12.nutrition.auth`, `.user`, `.patient` (hồ sơ cơ bản & onboarding; **không sửa** `PatientIntake.java`)
- **Frontend Folders:** `frontend/src/{app,components,layouts,routes,services,types,utils}`, `.nvmrc`, `.github/workflows/frontend-ci.yml`, `frontend/src/features/{auth,onboarding,profile,admin-users}`
- **Nhật ký & Nhánh:** `docs/progress/Đặng_Trần_Thiện.md` | `feat/dt-thien/sprint0-fe-core-auth`, `feat/dt-thien/onboarding-profile`, `feat/dt-thien/admin-users`
- **Database (Schema `nutrition`):**
  - *Đọc/Ghi chính:* `app_user`, `auth_session`, `contact_verification`, `patient` (`lower(email)` duy nhất; `patient_code` & `baseline_bmi` là `GENERATED ALWAYS`; cascade `app_user.role <-> clinician`).
  - *Đọc tham chiếu:* `clinician`, `assignment` (để trả trạng thái Cổng hạn chế hay Đầy đủ sau đăng nhập), `condition_catalog`, `allergen` (để hiển thị chọn nhanh hoặc `"Chưa rõ"` trong bảng hỏi onboarding).
- **REST API (`/api/v1`):**
  - `POST /api/v1/auth/register`, `login`, `refresh`, `logout` — `PATIENT` mới tự sinh `patient_code` & `joined_on`, BCrypt hash, rotation `auth_session`, rate-limit & khóa tạm khi đăng nhập sai.
  - `POST /api/v1/auth/verify-email`, `resend-email-otp`, `verify-phone` — Verify Email mở Cổng hạn chế; Verify SĐT mở quyền gửi tiếp nhận/đặt lịch.
  - `POST /api/v1/auth/change-password`, `forgot-password` — Thu hồi refresh token cũ.
  - `GET/PUT /api/v1/patients/me`, `GET/PUT /api/v1/patients/me/onboarding` — Lưu nháp, cho phép `"Chưa rõ"`, trả `baseline_bmi`.
  - `GET/POST/PATCH /api/v1/admin/users/**` (`ADMIN`) — Tạo nhân sự (tự tạo `clinician` khi là BS/Trưởng khoa), khóa/mở, đổi role cascade kèm ghi `audit_event`.
- **Màn hình UI (`SCR-*`):**
  - **5 Layouts dùng chung** (`Public`, `Patient` với banner Cổng hạn chế vs Đầy đủ, `Doctor`, `HeadDoctor`, `Admin`) + `SCR-ADM-00` (khung dashboard tổng quan).
  - `SCR-PUB-01..04` (`/`, `/register`, `/login`, `/verify-email`), `SCR-PUB-05` & `05B` (`/onboarding`, `/verify-phone`), `SCR-PAT-06` (tab Hồ sơ cá nhân cơ bản), `SCR-ADM-01` (`/admin/users`).
- **Thứ tự & Checklist:**
  - *Phase A (Sprint 0 — Ưu tiên PR #1):* Dựng `frontend/` + `frontend-ci.yml` + JWT Auth + `CurrentUser` helper + test 4 vai trò đăng nhập `Demo@123456`.
  - *Phase B:* Onboarding BMI (`Lưu nháp`, `"Chưa rõ"`), Verify Email/SĐT OTP (`SCR-PUB-01..05B`).
  - *Phase C:* `SCR-PAT-06` cơ bản, `SCR-ADM-01` quản trị tài khoản, test IDOR + khóa sai mật khẩu.

---

## 3. 24521679 – Hồ Đình Phước Thịnh (`hdp-thinh`)
**Vai trò:** Tiếp nhận (`UC-PROF-04`), Phân công 30 ca (`BR-01`), Tạm dừng, Lịch khám & Hội thoại

- **Use Cases:** `UC-PROF-04`, `UC-PROF-02`, `UC-PROF-03`, `UC-APPT-01`, `UC-COMM-01`, Notification Outbox
- **Backend Packages:** `com.nhom12.nutrition.intake` (dùng lại `PatientIntake`, `IntakeStatus` trong `patient/`), `.doctor`, `.communication`
- **Frontend Folders:** `frontend/src/features/{intake,assignments,tracking-pauses,appointments,chat,notifications}`
- **Nhật ký & Nhánh:** `docs/progress/Hồ_Đình_Phước_Thịnh.md` | `feat/hdp-thinh/intake-30slots`, `feat/hdp-thinh/pause-appointments`, `feat/hdp-thinh/chat-notifications`
- **Database (Schema `nutrition`):**
  - *Đọc/Ghi chính:* `patient_intake` (tối đa 1 hồ sơ mở `DRAFT/SUBMITTED/NEEDS_INFORMATION`), `attachment` (minh chứng tiếp nhận & tệp chat `message_id`), `clinician`, `assignment` (tối đa 30 suất `TRACKING` với `active_slot 1..30`; khóa hàng `patient` rồi `clinician` trong 1 transaction; `PAUSED` giữ phân công với `active_slot = NULL`), `tracking_pause`, `tracking_event`, `doctor_tracking_load` (view), `appointment`, `conversation`, `message`, `notification`, `patient_interaction`.
  - *Đọc tham chiếu:* `patient` (kiểm tra `phone_verified_at`), `alert` (chuyển alert chưa xử lý sang BS mới khi điều chuyển).
- **REST API (`/api/v1`):**
  - `GET/POST /api/v1/intake-requests`, `DELETE/POST .../withdraw`, `GET /api/v1/head-doctor/intakes`, `POST /api/v1/head-doctor/intakes/{id}/review` — Kiểm tra `phone_verified_at`, upload/tải `attachment` an toàn, Trưởng khoa duyệt `VERIFIED / NEEDS_INFORMATION / DECLINED` + ghi `audit_event`.
  - `GET /api/v1/head-doctor/doctors-load`, `POST /api/v1/head-doctor/assignments` — Phân công mới (bắt buộc `patient_intake` `VERIFIED`), điều chuyển (đóng ca cũ `ENDED`, mở `conversation` mới, chuyển alert mở sang BS mới), phục hồi từ `PAUSED`/`AUTO_SUSPENDED` (đủ 30/30 -> `WAITING_CAPACITY`).
  - `GET /api/v1/doctors/me/patients`, `GET /api/v1/doctors/me/dashboard` — Danh sách ca & tải `x/30`.
  - `POST /api/v1/tracking-pauses`, `POST /api/v1/tracking-pauses/{id}/decision` — Xin, rút `PENDING`, duyệt `APPROVED/REJECTED` hoặc BS tạo khẩn.
  - `GET/POST /api/v1/appointments`, `POST /api/v1/head-doctor/appointments/{id}/manage` — Đặt lịch, `CONFIRMED / NEEDS_INFORMATION / DECLINED / COMPLETED`.
  - `GET /api/v1/conversations`, `GET/POST /api/v1/conversations/{id}/messages` — Văn bản/tệp/thẻ sự kiện/tái khám, ghi `patient_interaction (CHAT_MESSAGE)`, chặn `403` BS cũ sau `ENDED`.
  - `GET /api/v1/notifications`, `PATCH /api/v1/notifications/{id}/read` — Đánh dấu đã đọc thông báo (`read_at` tách biệt khỏi acknowledge alert).
- **Màn hình UI (`SCR-*`):** `SCR-PAT-07` (Tạm dừng & Lịch khám), `SCR-PAT-07A` (Yêu cầu Tiếp nhận), `SCR-PAT-08` (Hội thoại BN), `SCR-DOC-05` (tab Tạm dừng), `SCR-DOC-07` (Hội thoại BS), `SCR-HD-01`, `SCR-HD-01B` (Hàng đợi Tiếp nhận), `SCR-HD-02` (Phân công 30 ca), `SCR-HD-03` (Quản lý Lịch khám).
- **Checklist bắt buộc:** Không thể phân công ca thứ 31 `TRACKING` (test 2 thread đồng thời); không nộp được `patient_intake` khi chưa xác minh SĐT; điều chuyển xong BS cũ nhận `403` ở chat/hồ sơ cũ; nút gọi chỉ lộ SĐT đã xác minh / `work_contact`.

---

## 4. 24521702 – Phạm Đình Thịnh (`pd-thinh`)
**Vai trò:** Bệnh lý/Dị ứng (`UC-PROF-05`), Món ăn, Thực đơn mẫu & Phiếu chỉ định (`BR-02`, `BR-08`)

- **Use Cases:** `UC-PROF-05`, `UC-FOOD-01`, `UC-PLAN-01`, `UC-PRES-01`, `UC-PRES-02`
- **Backend Packages:** `com.nhom12.nutrition.clinical`, `.food`, `.mealplan` (dùng `PrescriptionProcedureService` đã có sẵn)
- **Frontend Folders:** `frontend/src/features/{declarations,foods,templates,prescriptions}`
- **Nhật ký & Nhánh:** `docs/progress/Phạm_Đình_Thịnh.md` | `feat/pd-thinh/foods-templates`, `feat/pd-thinh/prescriptions-publish`, `feat/pd-thinh/clinical-declarations`
- **Database (Schema `nutrition`):**
  - *Đọc/Ghi chính:* `condition_catalog`, `allergen`, `health_declaration`, `declaration_review`, `food_safety_review`, `food_group`, `food`, `food_version`, `food_unit_conversion`, `food_allergen`, `food_restriction`, `meal_template`, `meal_template_version`, `meal_template_item`, `prescription`, `prescription_version`, `prescription_day`, `prescription_item`, `applied_prescription_day`, `treatment_review`, `patient_prescription_calendar` (view), `publish_prescription()`, `close_or_stop_prescription()`.
  - *Đọc tham chiếu:* `assignment` (kiểm tra quyền BS phụ trách đang `TRACKING`), `patient`.
- **REST API (`/api/v1`):**
  - `GET/POST /api/v1/patients/me/declarations`, `POST /api/v1/declarations/{id}/reviews`, `GET/POST /api/v1/food-safety-reviews/**` — BN khai báo bệnh lý/dị ứng (không tự đổi `CONFIRMED`); BS phụ trách/`HEAD_DOCTOR` duyệt; khi `CONFIRMED` dị ứng mới phải quét `applied_prescription_day` sinh `food_safety_review`.
  - `GET/POST/PATCH /api/v1/admin/food-groups` — Quản trị nhóm thực phẩm (`ADMIN`).
  - `GET/POST /api/v1/foods`, `POST /api/v1/foods/{id}/versions`, `POST /api/v1/head-doctor/food-versions/{verId}/review`, `PATCH /api/v1/head-doctor/foods/{id}/status` — Đề xuất sửa tạo bản `IN_REVIEW`; Trưởng khoa duyệt (`SUPERSEDED` -> `PUBLISHED`) và đổi `AVAILABLE / RESTRICTED / SUSPENDED`.
  - `GET/POST /api/v1/meal-plan-templates/**`, `POST .../review` — Thực đơn mẫu 0..29 ngày, 6 khung bữa `meal_slot`.
  - `POST /api/v1/prescriptions`, `POST .../days/copy`, `POST .../versions`, `POST .../versions/{verId}/publish`, `POST .../close` — Kỳ `7..30` ngày, `target_kcal > 0`, `P+C+L=100%`, gọi `PrescriptionProcedureService`, lưu `treatment_review` khi `CLOSED`.
  - `GET /api/v1/prescriptions/my-calendar` — Lịch ăn cho `PATIENT` từ `patient_prescription_calendar` (tuyệt đối ẩn `DRAFT`).
- **Màn hình UI (`SCR-*`):** `SCR-PAT-02` (`/patient/prescription`), `SCR-PAT-06` (tab Bệnh lý & Dị ứng), `SCR-DOC-02` (tab Duyệt dị ứng & `FoodSafetyReview`), `SCR-DOC-03` (`/doctor/foods`), `SCR-DOC-04` (`/doctor/prescriptions`), `SCR-HD-04` (`/head-doctor/catalog-reviews`), `SCR-ADM-02` (`/admin/food-groups`).
- **Checklist bắt buộc:** Kỳ `<7` hoặc `>30` ngày, `target_kcal <= 0`, `P+C+L != 100%` bị chặn ở cả BE lẫn FE; chặn món `SUSPENDED` & dị ứng `CRITICAL/UNKNOWN`; `RESTRICTED` bắt buộc lý do + hướng dẫn + xác nhận; `Sao chép ngày` tạo bản sao độc lập; `STOPPED_EARLY` giải phóng ngày tương lai; xác nhận dị ứng trùng đơn hiện hành sinh đúng `food_safety_review`.

---

## 5. 24521666 – Phan Viết Thiện (`pv-thien`)
**Vai trò:** Nhật ký 48h, Chỉ số sức khỏe, Cảnh báo Đỏ/Vàng (`SLA`), Job `BR-06/07`, 7 Báo cáo CSV & Audit

- **Use Cases:** `UC-JOUR-01..03`, `UC-METR-01`, `UC-ALRT-01..02`, `UC-REPO-01..02`, `UC-AUDT-01`, Spring Scheduler `BR-06` & `BR-07`
- **Backend Packages:** `com.nhom12.nutrition.journal`, `.healthmetric`, `.alert`, `.report`, `.audit`
- **Frontend Folders:** `frontend/src/features/{journals,metrics,alerts,reports,admin-ops}`
- **Nhật ký & Nhánh:** `docs/progress/Phan_Viết_Thiện.md` | `feat/pv-thien/journal-yellow-alert`, `feat/pv-thien/metrics-alerts-jobs`, `feat/pv-thien/reports-admin-ops`
- **Database (Schema `nutrition`):**
  - *Đọc/Ghi chính:* `daily_journal`, `journal_meal`, `journal_item`, `journal_water`, `journal_revision`, `journal_correction_request`, `calorie_assessment`, `vital_measurement`, `required_measurement_day`, `threshold_rule`, `threshold_clause`, `vital_assessment`, `alert`, `alert_event`, `patient_interaction` (khi ghi nhật ký/sinh hiệu), `follow_up_event`, `operation_run`, `audit_event`, `system_setting`, `system_setting_history`.
  - *Đọc tham chiếu:* `applied_prescription_day`, `food_version`, `assignment`, `tracking_pause` (để loại trừ ngày `PAUSED APPROVED` khỏi `BR-06`), `patient`, `clinician`.
- **REST API (`/api/v1`):**
  - `GET/PUT /api/v1/food-journals/{date}`, `POST .../submit`, `POST .../correction-requests`, `POST /api/v1/journal-correction-requests/{id}/review` — Snapshot dinh dưỡng lúc ghi, kiểm soát 48h (`Asia/Ho_Chi_Minh`), đánh giá lệch Calo (`>15%` hai chiều -> 1 cảnh báo Vàng/ngày, đúng `15.0%` KHÔNG cảnh báo), tạo thẻ Chat ngày qua service của `hdp-thinh`.
  - `GET/POST /api/v1/health-metrics`, `GET /api/v1/patients/me/progress` — Cân nặng/BMI/HA (bắt buộc cặp & `Systolic >= Diastolic`)/Đường huyết kèm bối cảnh (`replaces_id` giữ nguyên bản ghi cũ), dữ liệu biểu đồ tiến độ.
  - `GET/POST /api/v1/head-doctor/thresholds`, `GET /api/v1/alerts`, `POST /api/v1/alerts/{id}/acknowledge`, `POST /api/v1/alerts/{id}/resolve` — Ưu tiên ngưỡng Cá nhân -> Bệnh lý xác nhận (`condition_priority`) -> Chung; Cảnh báo Đỏ SLA 60p tiếp nhận / 2h giải quyết; tách biệt Đã đọc thông báo != Tiếp nhận != Giải quyết.
  - `GET /api/v1/reports/{1..7}`, `GET /api/v1/reports/{1..7}/export.csv` — 6 báo cáo chuyên môn + báo cáo quản trị thứ 7, lọc theo quyền, giữ đúng bác sĩ tại thời điểm phát sinh.
  - `GET/PUT /api/v1/admin/settings/{key}` (+ bắt buộc lý do vào `system_setting_history`), `GET/POST /api/v1/admin/operations`, `GET /api/v1/admin/audit-logs` (che dữ liệu lâm sàng mặc định).
- **Màn hình UI (`SCR-*`):** `SCR-PAT-01` (widget Hôm nay), `SCR-PAT-03`, `SCR-PAT-03B`, `SCR-PAT-04`, `SCR-PAT-05` (4 biểu đồ Recharts), `SCR-DOC-01` (widget theo dõi/cảnh báo), `SCR-DOC-05` (tab Hiệu chỉnh sau 48h), `SCR-DOC-06` (Cảnh báo SLA), `SCR-DOC-08` (Báo cáo BS), `SCR-HD-05` (Cấu hình ngưỡng), `SCR-HD-06` (Báo cáo tổng hợp & CSV), `SCR-ADM-03` (`system_setting` & backup/job), `SCR-ADM-04` (Audit Log).
- **Checklist bắt buộc:** Lệch `15.0%` không cảnh báo vàng, `15.1%` tạo đúng 1 cảnh báo vàng/ngày; sửa `food_version` không đổi kcal lịch sử; job `BR-06` bỏ qua ngày `PAUSED APPROVED` & chạy lại job không tạo thông báo trùng (`dedupe_key`); lỗi gửi email không làm mất `vital_measurement`; xuất CSV không rò rỉ dữ liệu ngoài quyền.
