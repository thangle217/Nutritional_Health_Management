# Bảng theo dõi tiến độ & lịch sử Commit — Nhóm 12 (v1.1 Kèm React Frontend)

> **Quy tắc chống xung đột Git (Zero Merge Conflict):** Mỗi thành viên **CHỈ cập nhật file `.md` mang tên mình** trong thư mục này mỗi khi hoàn thành chức năng hoặc trước khi push Pull Request. Không sửa chéo file của bạn khác.

## Tổng quan phân công nhóm (v1.1)

| Thành viên | MSSV | Mã nhánh | Vai trò / Phạm vi chính (BE + FE) | File tiến độ riêng | Tài liệu giao việc |
| --- | --- | --- | --- | --- | --- |
| Lê Trần Quang Thắng | `24521605` | `main` (Review) | Thiết kế hệ thống, DB PostgreSQL 17, UML, UI Spec, Khung Backend, Quy chuẩn AI (`AGENTS.md`) & Review PR | [Lê_Trần_Quang_Thắng.md](./Lê_Trần_Quang_Thắng.md) | Kiến trúc & Review PR |
| Đặng Trần Thiện | `24521657` | `dt-thien` | **Sprint 0 Khung React FE + CI FE**, Auth/JWT (`UC-AUTH-01..04`), Onboarding BMI (`UC-PROF-01`), Quản trị tài khoản (`UC-USER-01`, `SCR-ADM-00..01`) | [Đặng_Trần_Thiện.md](./Đặng_Trần_Thiện.md) | [Đặng_Trần_Thiện_tasks.docx](../tasks/Đặng_Trần_Thiện_tasks.docx) |
| Hồ Đình Phước Thịnh | `24521679` | `hdp-thinh` | Tiếp nhận (`UC-PROF-04`), Phân công 30 ca (`BR-01`), Tạm dừng (`UC-PROF-03`), Lịch khám (`UC-APPT-01`), Chat & Notification Outbox | [Hồ_Đình_Phước_Thịnh.md](./Hồ_Đình_Phước_Thịnh.md) | [Hồ_Đình_Phước_Thịnh_tasks.docx](../tasks/Hồ_Đình_Phước_Thịnh_tasks.docx) |
| Phạm Đình Thịnh | `24521702` | `pd-thinh` | Bệnh lý/Dị ứng & `FoodSafetyReview` (`UC-PROF-05`), Món ăn (`UC-FOOD-01`), Thực đơn mẫu (`UC-PLAN-01`), Phiếu chỉ định (`UC-PRES-01..02`, `BR-02/08`) | [Phạm_Đình_Thịnh.md](./Phạm_Đình_Thịnh.md) | [Phạm_Đình_Thịnh_tasks.docx](../tasks/Phạm_Đình_Thịnh_tasks.docx) |
| Phan Viết Thiện | `24521666` | `pv-thien` | Nhật ký 48h, Chỉ số, Cảnh báo Đỏ/Vàng (`SLA 60p/2h`), Job `BR-06/07`, 7 Báo cáo CSV & Audit | [Phan_Viết_Thiện.md](./Phan_Viết_Thiện.md) | [Phan_Viết_Thiện_tasks.docx](../tasks/Phan_Viết_Thiện_tasks.docx) |

> Chi tiết kỹ thuật dạng Markdown cho AI agent xem tại [docs/tasks/AI_TASKS_OVERVIEW.md](../tasks/AI_TASKS_OVERVIEW.md); hướng dẫn chia nhánh & prompt mẫu xem tại [CONTRIBUTING.md](../../CONTRIBUTING.md).

## Quy trình 3 bước khi code & push lên GitHub

1. **Cài mẫu commit chuẩn (chạy 1 lần sau khi clone) và tạo nhánh ngắn:**
   ```powershell
   git config commit.template .gitmessage
   git config core.quotepath false
   git checkout -b feat/dt-thien/sprint0-fe-core-auth
   ```
2. **Ghi nhận commit vào nhật ký cá nhân:**
   Sau khi `git commit` tính năng vừa xong, chạy script ngay tại gốc repo:
   ```powershell
   .\scripts\log-commit.ps1 -MemberFile "Đặng_Trần_Thiện.md" -Tested "mvn -B test PASS; npm run build PASS" -Notes "Hoàn tất Sprint 0 FE + Auth"
   ```
   Sau đó `git add docs/progress/<Tên_của_bạn>.md` và `git commit --amend --no-edit` rồi `git push -u origin <tên-nhánh>`.
3. **Tạo Pull Request vào `main`:**
   GitHub sẽ tự điền sẵn mẫu kiểm tra trong `.github/PULL_REQUEST_TEMPLATE.md` và tự động chạy kiểm thử bằng GitHub Actions (`.github/workflows/backend-ci.yml`).
