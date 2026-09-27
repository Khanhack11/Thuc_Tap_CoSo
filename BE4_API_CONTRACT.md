# BE4 API contract (FE2 / FE3)

BE4 cung cấp JSON API trên cùng ứng dụng Tomcat. Không cần server/API riêng. Prefix thực tế là `/{contextPath}` (ví dụ `/internship-management-system`). User phải đăng nhập theo cơ chế BE1; BE4 lấy user ID từ session `currentUser`, không nhận `userId` do client gửi.

## Cách gọi

- GET và POST trả `application/json;charset=UTF-8`; ngày là `YYYY-MM-DD`, thời điểm là ISO local datetime hoặc `null`.
- POST dùng `Content-Type: application/x-www-form-urlencoded;charset=UTF-8`.
- Trước POST, FE gọi `GET /{role}/be4/csrf` trên cùng session, nhận `{ "csrfToken": "..." }`; gửi token qua header `X-CSRF-Token` hoặc trường `_csrf` trong form.
- `role` trong URL là `intern`, `mentor`, hoặc `hr`. User phải có đúng role tương ứng; riêng `ADMIN` có thể gọi phần `hr`.
- Lỗi trả `{ "error": "..." }` với mã 400 (tham số sai), 403 (không có quyền / CSRF), 404 (route sai), 409 (xung đột trạng thái/trùng), 415 (POST sai content type), 500 (lỗi DB). Nếu chưa đăng nhập, filter BE1 có thể chuyển về trang login.
- Tất cả ID dạng số nguyên dương. Không đưa dữ liệu HTML thô vào trang; FE phải escape khi render nội dung do người dùng nhập.

## FE3: Mentor

| Method | Path sau `/mentor/be4` | Tham số | Kết quả |
|---|---|---|---|
| GET | `/dashboard` | — | `MentorDashboard` |
| GET | `/enrollments` | — | `EnrollmentSummary[]` được phân cho mentor |
| GET | `/tasks` | `enrollmentId` | `Task[]` của đợt thực tập được phân |
| POST | `/tasks` | `title`, `description` (tùy chọn), `dueDate` (tùy chọn) | `Task` mới |
| GET | `/assignments` | `enrollmentId` | `TaskAssignment[]` |
| POST | `/assignments` | `taskId`, `enrollmentId` | `TaskAssignment` mới |
| GET | `/progress` | `assignmentId` | `TaskProgress[]` (lịch sử) |
| GET | `/reports` | `enrollmentId` | `WeeklyReport[]` |
| GET | `/feedback` | `reportId` | `ReportFeedback[]` |
| POST | `/feedback` | `reportId`, `comment` và/hoặc `rating` 1–5 | `ReportFeedback` mới; báo cáo thành `REVIEWED` |
| GET | `/evaluation` | `enrollmentId` | `Evaluation` hoặc `null` |
| POST | `/evaluation` | `enrollmentId`, `score` 0–100, `comment` (tùy chọn) | `Evaluation` mới |

## FE3: Intern

| Method | Path sau `/intern/be4` | Tham số | Kết quả |
|---|---|---|---|
| GET | `/enrollments` | — | `EnrollmentSummary[]` của TTS |
| GET | `/tasks` | `enrollmentId` | `Task[]` |
| GET | `/assignments` | `enrollmentId` | `TaskAssignment[]` |
| GET | `/progress` | `assignmentId` | `TaskProgress[]` |
| POST | `/progress` | `assignmentId`, `completionPercentage` 0–100, `note` (tùy chọn) | `TaskProgress` mới |
| GET | `/reports` | `enrollmentId` | `WeeklyReport[]` |
| POST | `/reports` | `enrollmentId`, `weekNumber` (bắt đầu từ 1), `content` (có thể trống khi nháp) | `WeeklyReport` nháp |
| POST | `/reports/update` | `reportId`, `content` | `WeeklyReport` đã sửa (chỉ nháp) |
| POST | `/reports/submit` | `reportId` | `WeeklyReport` đã nộp |
| GET | `/feedback` | `reportId` | `ReportFeedback[]` |
| GET | `/evaluation` | `enrollmentId` | `Evaluation` hoặc `null` |

## FE2: HR

| Method | Path sau `/hr/be4` | Tham số | Kết quả |
|---|---|---|---|
| GET | `/dashboard` | — | `HrDashboard` |
| GET | `/evaluation` | `enrollmentId` | `Evaluation` hoặc `null` |

`HrDashboard` gồm `totalInterns`, `activeEnrollments`, `completedEnrollments`, `completionRatePercent`, `internsByUniversity`, `internsByMajor`, `activeInternsByMentor`. Ba mảng cuối gồm `{ "label": "...", "count": 1 }`. Tỷ lệ = completed / (active + completed) × 100; không tính enrollment cancelled. `MentorDashboard` gồm `activeInterns`, `tasksTodo`, `tasksInProgress`, `tasksDone`, `reportsSubmitted`, `reportsReviewed`, `evaluationsCompleted`.

## Quy tắc nghiệp vụ

- Mentor hiện tại mới tạo/giao task, phản hồi báo cáo, đánh giá tổng kết; enrollment cần `ACTIVE` cho thao tác ghi.
- Intern chỉ sửa task/report của chính mình trong enrollment `ACTIVE`. Tiến độ tăng dần, 0–100; 100 là `DONE`, không sửa nữa. Mỗi lần cập nhật có một dòng lịch sử.
- Mỗi enrollment chỉ có một báo cáo cho mỗi `weekNumber`; báo cáo `DRAFT` mới sửa/nộp được; `SUBMITTED` mới được mentor phản hồi một lần.
- Một enrollment có tối đa một evaluation; score tối đa hai số thập phân. Mentor đánh giá trước khi HR kết thúc enrollment.
- GET vẫn xem được lịch sử của enrollment đã hoàn thành (khi intern còn sở hữu hoặc mentor vẫn được phân công); POST không cho sửa. Mentor đã bị gỡ/đổi khỏi enrollment không còn quyền xem lịch sử của enrollment đó.

## Tích hợp DB và kiểm thử

Chạy `database/schema.sql`, `sql/schema_be2.sql`, `sql/schema_be3.sql`, rồi `sql/schema_be4.sql` theo thứ tự trên database test. BE4 chưa chỉnh file chung BE1/BE2/BE3. Khi BE2/BE3 merge vào `develop`, BE4 phải cập nhật nhánh, chạy schema và smoke test toàn luồng trên MySQL/Tomcat. `mvn clean package` trên foundation hiện tại mới xác nhận compile, chưa chạy SQL thật.
