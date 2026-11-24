# Nhật ký tiến độ — 24521605 – Lê Trần Quang Thắng (System Design & Core Setup)

- **Phạm vi phụ trách:** Đặc tả Use Case (v1.2), Phân tích UML (v1.4), PostgreSQL 17 Schema / Stored Procedures / Dev Seed, Đặc tả UI & Wireframe, Phân công 4 thành viên, Khung Backend Spring Boot 3 + Flyway.

## Checklist mốc hoàn thành

- [x] Chuẩn hóa `Nhóm12_Mô_Hình_Usecase.doc` (v1.2) + 8 sơ đồ Use Case draw.io
- [x] Chuẩn hóa `Nhom12_Analysis.doc` (v1.4) + 47 sơ đồ lớp, trạng thái, tuần tự, hoạt động draw.io
- [x] Hoàn thiện & kiểm thử PGlite PostgreSQL 17.5 bộ SQL (`001_schema.sql`, `002_publish_prescription.sql`, `003_seed_dev.sql`, `090_verify.sql` — 54 bảng, 3 view)
- [x] Hoàn thiện `Nhom12_Dac_Ta_UI_va_Luong_Man_Hinh.docx` + 5 sơ đồ luồng UI + 8 wireframe
- [x] Tách 4 tài liệu phân công `<Họ_Tên>_tasks.docx` cho 4 thành viên
- [x] Dựng khung Spring Boot 3.5.16 + Flyway + JPA + Security + `mvn test` (9/9 PASS) + chạy thật PostgreSQL 17 cổng `5432`
- [ ] Review Pull Request tích hợp module của 4 thành viên & chạy E2E tổng hợp

## Lịch sử Commit & Push

| Ngày | Branch | Commit | Nội dung đã làm | Kết quả Test | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| 2026-11-24 | `main` | `init` | `chore: initialize Nhom 12 nutrition management backend, DB, specs, diagrams, tasks, and progress tracking` | `mvn test 9/9 PASS`; PGlite 17.5 PASS | Khung chuẩn cho cả nhóm |
