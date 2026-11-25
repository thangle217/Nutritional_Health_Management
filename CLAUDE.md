# CLAUDE.md

Dự án **Nhóm 12 — Hệ thống quản lý dinh dưỡng và thực đơn cá nhân** (Spring Boot 3.5.16 + PostgreSQL 17 + Flyway + React TypeScript Vite).

## Bắt buộc đọc trước khi thực hiện bất kỳ thay đổi nào

1. Đọc toàn bộ [`AGENTS.md`](./AGENTS.md) để nắm **Ma trận sở hữu thư mục theo thành viên**, danh sách file bảo vệ và luật kỹ thuật bắt buộc.
2. Đọc [`CONTRIBUTING.md`](./CONTRIBUTING.md) để làm việc đúng nhánh `feat/<mã-tên>/<phạm-vi>` (KHÔNG sửa trực tiếp trên `main`) và cập nhật nhật ký bằng `scripts/log-commit.ps1`.
3. Đọc [`docs/tasks/AI_TASKS_OVERVIEW.md`](./docs/tasks/AI_TASKS_OVERVIEW.md) và file tiến độ của người dùng tại `docs/progress/<Họ_Tên>.md` để biết đúng Use Case, màn hình `SCR-*`, bảng DB và REST endpoint được giao.
4. Trước khi chạm vào DB/Flyway, đọc [`docs/database/README.md`](./docs/database/README.md) — **tuyệt đối không sửa** `V1__init_schema.sql`, `V2__publish_prescription_and_views.sql`, `V3__dev_seed.sql`.
5. Trước khi kết thúc mỗi task, chạy `mvn -B test` trong `backend/` (và `npm run lint && npm test && npm run build` trong `frontend/` nếu có thay đổi React) và báo rõ file đã đổi, lệnh đã chạy và kết quả thực tế.
