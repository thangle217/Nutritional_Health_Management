# Bảng theo dõi tiến độ & lịch sử Commit — Nhóm 12

> **Quy tắc chống xung đột Git (Zero Merge Conflict):** Mỗi thành viên **CHỈ cập nhật file `.md` mang tên mình** trong thư mục này mỗi khi hoàn thành chức năng hoặc trước khi push Pull Request. Không sửa chéo file của bạn khác.

## Tổng quan phân công nhóm

| Thành viên | MSSV | Vai trò / Phạm vi chính | File tiến độ riêng | Tài liệu giao việc |
| --- | --- | --- | --- | --- |
| Lê Trần Quang Thắng | `24521605` | Thiết kế hệ thống, DB PostgreSQL 17, UML, UI Spec & Khung Backend | [Lê_Trần_Quang_Thắng.md](./Lê_Trần_Quang_Thắng.md) | Kiến trúc & Review PR |
| Đặng Trần Thiện | `24521657` | Auth, Tài khoản, Onboarding BMI, Tiếp nhận (`UC-PROF-04`), Bệnh lý/Dị ứng (`UC-PROF-05`) | [Đặng_Trần_Thiện.md](./Đặng_Trần_Thiện.md) | [Đặng_Trần_Thiện_tasks.docx](../tasks/Đặng_Trần_Thiện_tasks.docx) |
| Hồ Đình Phước Thịnh | `24521679` | Phân công 30 ca (`BR-01`), Tạm dừng (`UC-PROF-03`), Lịch khám (`UC-APPT-01`), Chat & Thông báo | [Hồ_Đình_Phước_Thịnh.md](./Hồ_Đình_Phước_Thịnh.md) | [Hồ_Đình_Phước_Thịnh_tasks.docx](../tasks/Hồ_Đình_Phước_Thịnh_tasks.docx) |
| Phạm Đình Thịnh | `24521702` | Món ăn (`UC-FOOD-01`), Thực đơn mẫu (`UC-PLAN-01`), Phiếu chỉ định (`UC-PRES-01..02`, `BR-02/08`) | [Phạm_Đình_Thịnh.md](./Phạm_Đình_Thịnh.md) | [Phạm_Đình_Thịnh_tasks.docx](../tasks/Phạm_Đình_Thịnh_tasks.docx) |
| Phan Viết Thiện | `24521666` | Nhật ký 48h, Chỉ số, Cảnh báo Đỏ/Vàng (`SLA 60p/2h`), Job `BR-06/07`, 7 Báo cáo & Audit | [Phan_Viết_Thiện.md](./Phan_Viết_Thiện.md) | [Phan_Viết_Thiện_tasks.docx](../tasks/Phan_Viết_Thiện_tasks.docx) |

## Quy trình 3 bước khi code & push lên GitHub

1. **Cài mẫu commit chuẩn (chạy 1 lần sau khi clone):**
   ```powershell
   git config commit.template .gitmessage
   ```
   Quy ước tiêu đề commit: `<type>(<scope>): <mô tả ngắn gọn>` (ví dụ: `feat(auth): implement email OTP verification for UC-AUTH-04`).
2. **Ghi nhận commit vào nhật ký cá nhân (tự động hoặc ghi tay):**
   Sau khi `git commit` tính năng vừa xong, chạy script ngay tại gốc repo:
   ```powershell
   .\scripts\log-commit.ps1 -MemberFile "Đặng_Trần_Thiện.md" -Tested "mvn test PASS; Swagger OK" -Notes "Hoàn tất verify-email"
   ```
   Sau đó `git add docs/progress/<Tên_của_bạn>.md` và `git commit --amend --no-edit` (hoặc tạo commit cập nhật progress) rồi `git push`.
3. **Tạo Pull Request vào `main`:**
   GitHub sẽ tự điền sẵn mẫu kiểm tra trong `.github/PULL_REQUEST_TEMPLATE.md` và tự động chạy kiểm thử bằng GitHub Actions (`.github/workflows/backend-ci.yml`).
