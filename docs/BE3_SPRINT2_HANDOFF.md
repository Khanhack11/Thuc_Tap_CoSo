# BE3 Sprint 2 — Bàn giao backend

Ngày triển khai: 30/09/2026. Base ban đầu: `develop` tại `8af20bc`.
Nhánh: `feature/be3-sprint2-program-mentor`.

## Phạm vi

| US | Backend | FE phối hợp |
|---|---|---|
| US11 + US13 | Tạo/sửa/kích hoạt chương trình; quản lý khoảng ngày | FE2 |
| US12 | Ghi danh thủ công đơn APPROVED, chọn mentor ban đầu hoặc phân sau | FE2 |
| US29 | Tạo hồ sơ mentor từ User MENTOR ACTIVE, danh sách theo phòng ban | FE3 |
| US30 | Phân/đổi mentor, lưu lịch sử | FE3 |
| US31 | Tải hiện tại, sức chứa, chỗ còn lại của mentor | FE3 |
| US14 | Thông tin chương trình và khoảng thời gian của TTS đang đăng nhập | FE1 |

Tái sử dụng nền tảng Sprint 1. Không thay đổi User, auth/session, kết nối DB,
schema BE1/BE2 hoặc các module BE4. Không thêm thư viện hoặc migration DB.
BE3 dùng session `currentUser`, `long userId`, kiểm tra role bằng `UserRoleChecks`.

## Quy tắc đã triển khai

1. Tên chương trình được bỏ khoảng trắng đầu/cuối và gộp khoảng trắng liên tiếp.
   Trùng khi cùng tên đã chuẩn hóa (không phân biệt hoa/thường, có phân biệt dấu),
   phòng ban và cặp ngày bắt đầu/kết thúc. Chỉ khóa trong cùng phòng ban khi
   tạo/sửa; kiểm tra và lưu trong một transaction READ_COMMITTED.
   Quy tắc này áp dụng qua CatalogService; không có unique index mới để chặn SQL
   viết trực tiếp bên ngoài service. Dữ liệu cũ không bị tự động gộp/xóa.
2. Ngày bắt đầu/kết thúc bắt buộc, `startDate <= endDate`; cho phép một ngày.
   HTTP nhận đúng `yyyy-MM-dd`, chặn ngày không tồn tại, giới hạn năm 1000–9999.
3. Chương trình chưa có ghi danh được sửa phòng ban/ngày/sức chứa.
   Sau khi đã có bất kỳ ghi danh nào (kể cả COMPLETED/CANCELLED), chỉ được sửa
   tên/mô tả. Server kiểm tra lại trong transaction và khóa cùng bản ghi program
   mà thao tác ghi danh sử dụng, không dựa vào việc FE khóa input.
   Sửa không được thay trạng thái; kích hoạt là thao tác riêng PLANNED → ACTIVE.
4. Mentor phải từ User MENTOR ACTIVE, có phòng ban, `maxMentees > 0`.
   Chặn User đã có Mentor (kể cả Mentor INACTIVE); unique `mentors.user_id` sẵn có
   vẫn bảo vệ khi tạo đồng thời. Danh sách tài khoản có thể thêm loại bỏ User đã có Mentor.
5. HR/Admin tự ghi danh Application APPROVED vào chương trình ACTIVE còn chỗ.
   Không tự ghi danh sau duyệt; không yêu cầu hợp đồng CONFIRMED.
   Một Application tối đa một enrollment, một TTS tối đa một ACTIVE enrollment.
6. Ghi danh và phân mentor ban đầu là hai bước lưu riêng. Nếu bước ghi danh đã
   thành công mà mentor không hợp lệ/hết chỗ/lỗi DB, enrollment vẫn giữ lại.
   Redirect tới chi tiết enrollment đã tạo và báo rõ chưa phân mentor.
   Retry bằng `assign-mentor` với enrollmentId hiện có; KHÔNG gửi lại `enroll`.
7. Phân/đổi mentor chỉ cho enrollment ACTIVE; mentor và User của mentor ACTIVE,
   cùng phòng ban với chương trình và chưa đầy. Form chỉ đưa ra mentor hợp lệ;
   service kiểm tra lại khi POST. Một enrollment tối đa một phân công hiện hành.
8. Đổi mentor bắt buộc lý do (1–200 ký tự sau trim), mentor mới khác người cũ.
   Kết thúc phân công cũ và thêm mới trong một transaction, giữ nguyên enrollmentId,
   lịch sử và người thực hiện Task/Feedback/Evaluation trước đó.
9. Tải mentor = COUNT DISTINCT enrollment có `ended_at IS NULL` và enrollment ACTIVE.
   `remainingCapacity = max(0, maxMentees - currentMenteeCount)`;
   `atCapacity = currentMenteeCount >= maxMentees`. Không lưu/cache riêng nên đọc
   lại sau phân/đổi/kết thúc enrollment sẽ có số liệu mới.
10. US14 lấy User từ session → profile → enrollment ACTIVE, không nhận User/profile/
    enrollment ID từ client. Có chương trình, phòng ban, start/end, trạng thái và
    mentor hiện tại; tách trạng thái chưa ghi danh/chưa mentor/lỗi tải.
    Không phải lịch ca, chấm công hay deadline nhiệm vụ.

## Route và dữ liệu cho FE

Các URL bên dưới cần thêm contextPath khi tạo link. Endpoint trả JSP/request attrs,
không phải JSON. POST luôn có `csrfToken` lấy từ GET; sai token hoặc sai quyền trả 403.
Sau POST dùng redirect và flash `successMessage`/`errorMessage` trong session;
GET chuyển flash sang request và xóa khỏi session.

### Danh mục — FE2 và FE3

`GET /hr/catalog`, `/hr/programs`, `/hr/mentors` dùng cùng controller/view QA.
`departmentId` không bắt buộc, bỏ trống là tất cả. ID không tồn tại báo lỗi, không
được hiểu thành danh sách tất cả.

Request attrs:

- `departments`: List<Department> (`departmentId`, `departmentName`).
- `programs`: List<InternshipProgram> (`programId`, `programName`, `departmentId`,
  `departmentName`, `description`, `startDate`, `endDate`, `maxInterns`, `status`).
- `mentors`: List<Mentor> (`mentorId`, `userId`, `fullName`, `email`, `departmentId`,
  `departmentName`, `specialization`, `status`, `currentMenteeCount`, `maxMentees`,
  `remainingCapacity`, `atCapacity`).
- `mentorUsers`: List<User> có thể tạo Mentor; tuyệt đối không render passwordHash.
- `selectedDepartmentId`, `csrfToken`, `successMessage`, `errorMessage`.
- Khi `action=edit-program&programId=<id>`: thêm `editingProgram` và
  `programStructureLocked` (boolean). Luôn gửi lại đầy đủ thông tin chương trình;
  FE có thể dùng hidden input cho các giá trị đã khóa nhưng server vẫn kiểm tra.

`POST /hr/catalog` (hoặc alias tương ứng):

| action | Tham số ngoài csrfToken/action |
|---|---|
| create-department | name, description (tùy chọn) |
| create-program | name, departmentId, description (tùy chọn), startDate, endDate, maxInterns |
| update-program | programId + toàn bộ các trường create-program |
| activate-program | programId |
| create-mentor | userId, departmentId, specialization (tùy chọn), maxMentees |

Giữ tên tham số camelCase. Không dùng `/hr/programs/create`, `department_id`,
`start_date` hay `end_date` từ form FE giả định cũ; không có route tương ứng.
Frontend chuẩn do FE2/FE3 tích hợp trên contract này; JSP `WEB-INF/views/hr/catalog.jsp`
là màn hình tối thiểu để QA thao tác backend, không thay thế thiết kế FE Sprint 2.

### Ghi danh/phân mentor — FE2/FE3

`/hr/enrollments` giữ contract Sprint 1:

- GET mặc định: `enrollments`, `viewMode=list`.
- GET `action=detail&id=<enrollmentId>`: `enrollment`, `mentorHistory`, `viewMode=detail`.
- GET `action=enroll-form&applicationId=<optional id>`: `applicationId`,
  `programs` ACTIVE, `mentors` ACTIVE còn chỗ (FE lọc tiếp theo program.departmentId),
  `viewMode=enroll-form`. Server luôn kiểm tra lại phòng ban khi POST.
- GET `action=assign-form&enrollmentId=<id>` hoặc `change-form`: `enrollment`,
  `mentors` cùng phòng ban, còn chỗ, không phải mentor hiện tại; `viewMode` tương ứng.
- POST `action=enroll`: `applicationId`, `programId`, `mentorId` tùy chọn.
  Thành công redirect `/hr/enrollments?action=detail&id=<id>`; nếu phân mentor
  thất bại có cả successMessage xác nhận ghi danh và errorMessage giải thích bước còn thiếu.
- POST `action=assign-mentor`: `enrollmentId`, `mentorId`.
- POST `action=change-mentor`: `enrollmentId`, `newMentorId`, `endReason`.

FE2/FE3 dùng chung thao tác assign-mentor, không tạo nghiệp vụ phân mentor thứ hai.

### Thông tin thực tập — FE1

`GET /intern/enrollment` (INTERN):

- `enrollment`: ProgramEnrollment hoặc null. Dùng `programName`, `departmentName`,
  `startDate`, `endDate`, `status`, `enrolledAt`, `currentMentorId`, `currentMentorName`.
- `currentMentor`: MentorAssignment hoặc null (`mentorName`, `assignedAt`).
- `errorMessage`: có giá trị nếu tải thất bại; không hiển thị như chưa ghi danh.
- `Cache-Control: no-store`; không dùng User ID hoặc enrollment ID do client gửi.

## Kiểm chứng và điều kiện nghiệm thu

Chạy `mvn clean package` cho build/unit/controller checks.
Kiểm tra MySQL thật là opt-in: `mvn -Dbe3.mysql=true test`.
Test cần db.properties local và tài khoản có quyền tạo/xóa database thử nghiệm.
Test tạo DB tên ngẫu nhiên `be3_sprint2_test_<uuid>`, chuyển JDBC URL CHỈ trong JVM test,
nạp schema BE1–BE4 vào DB đó, sau cùng khôi phục URL và xóa đúng DB vừa tạo.
Không ghi vào internship_management, không đưa mật khẩu vào source/log/commit.

Kiểm thử MySQL gồm chương trình trùng (kể cả tên legacy có khoảng trắng), tạo đồng
thời, sửa trước/sau ghi danh, tạo mentor trùng, ghi danh không cần hợp đồng,
mentor hết chỗ/assign lại trên enrollment hiện có, đổi mentor/lịch sử/tải,
ngày/phòng ban US14 và giữ bản ghi Task/Report/Evaluation của BE4.

Kết quả tại bản bàn giao ngày 30/09/2026:

- `mvn -Dbe3.mysql=true clean package`: 69 tests, 0 failures/errors/skipped; WAR build thành công.
- Precompile bằng Jasper của Tomcat 10.1: cả 3 JSP BE3 đã sửa (`hr/catalog`,
  `hr/enrollments`, `intern/enrollment`) biên dịch thành công, 0 lỗi.
- Không triển khai đè bản Tomcat đang có hoặc tự merge vào develop/main.
- Chưa nghiệm thu thao tác giao diện FE Sprint 2 trên trình duyệt thật.

QA2 còn phải nghiệm thu luồng web với giao diện FE Sprint 2: thao tác thực, quyền,
CSRF, input sai, empty/error states, refresh sau phân/đổi mentor và regression.
Chỉ đánh dấu Done khi PR tích hợp + QA nghiệm thu; build đạt không đồng nghĩa
đã hoàn thành 100% toàn bộ Sprint 2.
