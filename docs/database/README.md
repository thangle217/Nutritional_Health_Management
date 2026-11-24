# PostgreSQL cho hệ thống quản lý dinh dưỡng Nhóm 12

Lược đồ chuẩn **PostgreSQL 17+** dùng cho một cơ sở y tế tư nhân và một khoa. Các quy tắc nghiệp vụ tham chiếu [Nhóm12_Mô_Hình_Usecase.doc](../Nhóm12_Mô_Hình_Usecase.doc) (mục 5) và [Nhom12_Analysis.doc](../Nhom12_Analysis.doc) (mục 4) trong cùng thư mục đặc tả.

## Danh sách file SQL

| File | Mục đích | Ghi chú chạy |
| --- | --- | --- |
| `001_schema.sql` | Tạo schema `nutrition`, 54 bảng nghiệp vụ (bao gồm `treatment_review`, `system_setting`, `system_setting_history`), các ràng buộc `CHECK`/`UNIQUE`, index kiểm toán và 2 view tổng hợp | Chạy 1 lần khi khởi tạo DB mới |
| `002_publish_prescription.sql` | Tạo hàm `publish_prescription(p_version_id, p_actor_id)`, `close_or_stop_prescription(...)`, các trigger chống sửa lịch sử phiếu đã công bố và view `patient_prescription_calendar` | Chạy ngay sau `001_schema.sql` |
| `003_seed_dev.sql` | Dữ liệu mẫu giả lập phục vụ lập trình & demo (Admin, Trưởng khoa, 2 Bác sĩ, 3 Bệnh nhân, danh mục món ăn, ngưỡng mặc định, `system_setting`). Mật khẩu demo: `Demo@123456` | Idempotent — chạy lại nhiều lần không trùng |
| `090_verify.sql` | Kiểm thử ràng buộc `BR-01..BR-08`, quyền `DOCTOR`/`HEAD_DOCTOR`, dừng sớm phiếu (`STOPPED_EARLY`), `treatment_review`, chat/attachment và `system_setting` trong một transaction `ROLLBACK` | Chạy bất kỳ lúc nào trên DB thử nghiệm |

## Cài đặt PostgreSQL 17 trên Windows & chạy thủ công với `psql`

1. Cài đặt **PostgreSQL 17** từ trang chính thức https://www.postgresql.org/download/windows/ (hoặc `winget install --id PostgreSQL.PostgreSQL.17 -e`), ghi nhớ mật khẩu user `postgres` (cổng mặc định `5432`).
2. Thêm `C:\Program Files\PostgreSQL\17\bin` vào `PATH` (hoặc mở **SQL Shell (psql)**).
3. Tạo database và chạy các script theo thứ tự từ thư mục này:

```powershell
createdb -U postgres -h localhost -E UTF8 nhom12_dev
psql -X -v ON_ERROR_STOP=1 -U postgres -h localhost -d nhom12_dev -f 001_schema.sql
psql -X -v ON_ERROR_STOP=1 -U postgres -h localhost -d nhom12_dev -f 002_publish_prescription.sql
psql -X -v ON_ERROR_STOP=1 -U postgres -h localhost -d nhom12_dev -f 003_seed_dev.sql
psql -X -v ON_ERROR_STOP=1 -U postgres -h localhost -d nhom12_dev -f 090_verify.sql
```

## Tích hợp với App Spring Boot 3 + Flyway

Bộ migration trong `D:\Usecase OOP\nutrition-management\backend\src\main\resources\db\` sử dụng trực tiếp nội dung của `001_schema.sql`, `002_publish_prescription.sql` và `003_seed_dev.sql` (đã tách `BEGIN/COMMIT` để Flyway quản lý transaction tự động):

- `db/migration/V1__init_schema.sql`
- `db/migration/V2__publish_prescription_and_views.sql`
- `db/seed/V3__dev_seed.sql` (chỉ bật trong profile `dev`)

Nếu bạn dùng **Spring Boot + Flyway** để tự khởi tạo DB mới, chỉ cần tạo database rỗng `nhom12_dev` rồi chạy ứng dụng Spring Boot (xem chi tiết tại `D:\Usecase OOP\nutrition-management\README.md`).

## Quy tắc và bảng dữ liệu chính

| Luồng | Dữ liệu chính | Quy tắc triển khai |
| --- | --- | --- |
| Đăng ký và tiếp nhận | `app_user`, `contact_verification`, `auth_session`, `patient`, `patient_intake`, `attachment` | Sau khi xác minh email, bệnh nhân vào cổng hoàn tất hồ sơ. Kiểm tra SĐT trước khi gửi `patient_intake`. Mỗi bệnh nhân có tối đa 1 hồ sơ mở (`DRAFT`/`SUBMITTED`/`NEEDS_INFORMATION`). `attachment` hỗ trợ đính kèm cho tiếp nhận, khai báo y tế hoặc tin nhắn (`message_id`). |
| Bệnh lý và dị ứng | `health_declaration`, `declaration_review`, `food_safety_review` | Giữ lịch sử đánh giá riêng và rà soát xung đột với các ngày phiếu đang áp dụng. |
| Phân công, tạm dừng | `assignment`, `tracking_pause`, `tracking_event`, `doctor_tracking_load` | Mỗi bệnh nhân tối đa 1 phân công hiện hành; mỗi bác sĩ tối đa 30 suất `TRACKING`. `PAUSED`, `AUTO_SUSPENDED`, `WAITING_CAPACITY` không chiếm tải. Cập nhật `app_user.role` cascade sang `clinician`. |
| Đặt lịch và trao đổi | `appointment`, `conversation`, `message` | `message` hỗ trợ gắn `appointment_id` (đề nghị tái khám từ chat) và tệp qua `attachment.message_id`. |
| Danh mục và mẫu | `food_group`, `food`, `food_version`, `food_unit_conversion`, `food_restriction`, `food_allergen`, `meal_template_version` | Duyệt bản công bố mới thay bản cũ nhưng bảo toàn snapshot trong phiếu và nhật ký lịch sử. |
| Phiếu, ban hành & đóng sớm | `prescription`, `prescription_version`, `prescription_day`, `prescription_item`, `applied_prescription_day`, `treatment_review` | `publish_prescription` cho phép `DOCTOR` hoặc `HEAD_DOCTOR` đang phụ trách `TRACKING` ban hành cả đợt. `close_or_stop_prescription` xử lý `CLOSED` / `CANCELLED` / `STOPPED_EARLY`, giải phóng ngày tương lai trong `applied_prescription_day` và lưu vết `audit_event`. `treatment_review` lưu tổng kết đợt điều trị. |
| Nhật ký, chỉ số và sửa dữ liệu | `daily_journal`, `journal_meal`, `journal_item`, `journal_water`, `journal_revision`, `journal_correction_request`, `vital_measurement`, `required_measurement_day` | Sửa trong hạn 48 giờ theo giờ `Asia/Ho_Chi_Minh`, lưu diff trước/sau và đánh giá lại tự động. |
| Cảnh báo & tác vụ nền | `calorie_assessment`, `threshold_rule`, `threshold_clause`, `vital_assessment`, `alert`, `alert_event`, `follow_up_event`, `notification` | Cảnh báo vàng khi lệch Calo > 15%. Cảnh báo đỏ áp mốc SLA `60` phút tiếp nhận và `2` giờ giải quyết. |
| Vận hành & kiểm toán | `audit_event`, `operation_run`, `system_setting`, `system_setting_history`, `daily_nutrition_summary`, `patient_prescription_calendar` | `system_setting` và `system_setting_history` quản lý tham số hệ thống theo phiên bản kèm lý do thay đổi (`UC-REPO-02`). |
