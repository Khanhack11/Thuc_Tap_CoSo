# BE2 – Intern Profiles, Documents & Contract Management

## Tổng quan phạm vi BE2 (Sprint 1 & Sprint 2)

BE2 chịu trách nhiệm:
- **Intern Profile (Hồ sơ TTS)**: Tạo lập hồ sơ (Sprint 1), HR chỉnh sửa hồ sơ TTS theo whitelist an toàn (US02 - Sprint 2), HR tìm kiếm và lọc danh sách TTS theo trường/ngành/tên (US03 - Sprint 2).
- **Document Management (Quản lý tài liệu)**: TTS tải lên tài liệu (CV, bảng điểm, bằng cấp, CMND) định dạng PDF/DOC/DOCX tối đa 5MB (Sprint 1/US04), HR duyệt (`APPROVED`) và từ chối (`REJECTED` kèm lý do bắt buộc) tài liệu của TTS (US05 - Sprint 2), ghi nhận người duyệt và thời gian duyệt.
- **Contract Management (Quản lý hợp đồng)**: HR upload hợp đồng đính kèm đơn ứng tuyển `APPROVED` (US09 - Sprint 2, PDF/DOC/DOCX tối đa 5MB, cho phép thay thế khi chưa xác nhận, chặn ghi đè khi đã `CONFIRMED`), TTS xem và xác nhận hợp đồng (US10 - Sprint 2, chỉ INTERN sở hữu mới được xác nhận, ghi nhận `confirmed_at`).

---

## Schema SQL & Migration

### Thứ tự chạy khởi tạo DB mới:
1. `database/schema.sql` (BE1 – users, roles)
2. `sql/schema_be2.sql` (BE2 – intern_profiles, applications, documents, contracts)
3. `sql/schema_be3.sql` (BE3 – departments, internship_programs, mentors, program_enrollments, mentor_assignments)

### Migration cho Database hiện có (Baseline develop `b207e52` / `8af20bc`):
Chạy script:
```sql
sql/migrate_be2_documents.sql
```
Script này bổ sung an toàn 3 cột vào bảng `documents`:
- `reviewed_by` BIGINT (FK -> `users(user_id)`)
- `reviewed_at` DATETIME
- `reject_reason` TEXT
*(Bảng `contracts` đã có sẵn `confirmed_at` và ràng buộc cần thiết từ Sprint 1).*

---

## API Contract chi tiết (Dành cho FE1, FE2, BE3, BE4, QA)

### 1. US02: HR Chỉnh sửa hồ sơ TTS

| Thuộc tính | Giá trị |
|---|---|
| **URL** | `/hr/interns/edit` |
| **Method** | `POST` |
| **Quyền** | HR hoặc ADMIN (qua session `currentUser`) |
| **Request Parameters** | `profileId` (bắt buộc, int), `fullName` (bắt buộc, string), `dob` (bắt buộc, yyyy-MM-dd), `gender` (bắt buộc: Male/Female/Other), `phone` (bắt buộc, format VN), `email` (bắt buộc, email format), `university` (bắt buộc, string), `major` (bắt buộc, string), `gpa` (tùy chọn, float [0.0 - 4.0]), `skills` (tùy chọn, string) |
| **Bảo mật & Whitelist** | Server chỉ cập nhật các trường thông tin học vấn/cá nhân. Tuyệt đối KHÔNG nhận `userId`, `role`, hay trạng thái của `Application` từ request của form. `profileId` phải tồn tại. |
| **Response** | Redirect → `/hr/intern-detail?id=<profileId>` kèm `successMessage` hoặc `errorMessage` trong session |
| **Mã lỗi** | 403 nếu không phải HR/Admin; Redirect kèm `errorMessage` nếu vi phạm validation format |

---

### 2. US03: HR Tìm kiếm và Lọc danh sách TTS

| Thuộc tính | Giá trị |
|---|---|
| **URL** | `/hr/interns` hoặc `/hr/interns/search` |
| **Method** | `GET` |
| **Quyền** | HR hoặc ADMIN |
| **Query Parameters** | `keyword` (tìm chung), `name` (tìm theo tên), `university` (lọc theo trường đại học), `major` (lọc theo chuyên ngành) |
| **Request Attributes (JSP)** | `profiles` (List\<InternProfile\>), `searchName` (String), `searchUniversity` (String), `searchMajor` (String), `keyword` (String) |
| **Response** | Forward → `/hr/intern-list.jsp` |

---

### 3. HR Xem chi tiết hồ sơ & Hợp đồng của TTS

| Thuộc tính | Giá trị |
|---|---|
| **URL** | `/hr/intern-detail` |
| **Method** | `GET` |
| **Quyền** | HR hoặc ADMIN |
| **Query Parameters** | `id=<profileId>` (bắt buộc, int) |
| **Request Attributes (JSP)** | `profile` (InternProfile), `documents` (List\<Document\>), `application` (Application - đơn ứng tuyển mới nhất), `contract` (Contract - nếu đã upload hợp đồng) |
| **Response** | Forward → `/hr/intern-detail.jsp` |

---

### 4. US05: HR Duyệt / Từ chối tài liệu của TTS

| Thuộc tính | Giá trị |
|---|---|
| **URL** | `/document/review` (hoặc `/hr/document/review`, `/hr/documents/review`) |
| **Method** | `POST` |
| **Quyền** | HR hoặc ADMIN |
| **Request Parameters** | `action` (`approve` hoặc `reject`), `documentId` (int, bắt buộc), `rejectReason` (bắt buộc khi action là `reject`), `profileId` (tùy chọn, phục vụ redirect) |
| **Hỗ trợ định dạng** | - **HTML Form**: Redirect về `/hr/intern-detail?id=<profileId>` với session message.<br>- **AJAX / JSON** (gửi `Accept: application/json` hoặc header `X-Requested-With: XMLHttpRequest`): Trả JSON `{"success": true, "message": "..."}` hoặc `{"success": false, "message": "..."}` với HTTP 200/400/403. |
| **Validation** | - Trạng thái chuyển: `PENDING` → `APPROVED` hoặc `REJECTED`.<br>- Từ chối bắt buộc phải có `rejectReason`.<br>- Ghi nhận `reviewed_by = currentUser.userId` và `reviewed_at = NOW()`.<br>- Duyệt/từ chối tài liệu KHÔNG tự ý thay đổi trạng thái của `Application`. |

---

### 5. US04: TTS Upload tài liệu

| Thuộc tính | Giá trị |
|---|---|
| **URL** | `/document/upload` |
| **Method** | `POST` (enctype: `multipart/form-data`) |
| **Quyền** | INTERN (tải cho hồ sơ chính mình) |
| **Parameters** | `file` (Part), `docType` (`CV`, `TRANSCRIPT`, `CERTIFICATE`, `IDENTITY_CARD`) |
| **Ràng buộc** | File định dạng `.pdf`, `.doc`, `.docx`. Dung lượng tối đa: **5 MB**. Tài liệu mới tải lên luôn có trạng thái `PENDING`. Khi tải lại, giữ nguyên lịch sử tài liệu cũ bị từ chối. |
| **Response** | Redirect → `/intern/documents` kèm thông báo |

---

### 6. Xem và Tải tài liệu (Download an toàn)

| Thuộc tính | Giá trị |
|---|---|
| **URL** | `/document/download` |
| **Method** | `GET` |
| **Query Parameters** | `id=<documentId>` (bắt buộc, int) |
| **Kiểm tra quyền** | - HR và Admin được tải/xem mọi tài liệu.<br>- INTERN chỉ được tải tài liệu thuộc hồ sơ của chính mình (kiểm tra qua `profileId` gắn với `currentUser.userId`). |
| **Mã lỗi** | 401 nếu chưa đăng nhập; 403 nếu truy cập trái phép; 404 nếu file không tồn tại |

---

### 7. US09: HR Tải lên và Quản lý Hợp đồng

| Thuộc tính | Giá trị |
|---|---|
| **URL** | `/contract/upload` |
| **Method** | `POST` (enctype: `multipart/form-data`) |
| **Quyền** | HR hoặc ADMIN |
| **Request Parameters** | `file` (Part hợp đồng: `.pdf`, `.doc`, `.docx`, tối đa 5MB), `applicationId` (bắt buộc, int), `profileId` (tùy chọn, để redirect) |
| **Quy ước & Ràng buộc nghiệp vụ Sprint 2** | 1. Đơn ứng tuyển (`Application`) phải có trạng thái **`APPROVED`** mới được tải hợp đồng.<br>2. Trạng thái ban đầu: **`PENDING_CONFIRMATION`**.<br>3. Cho phép HR tải file mới để thay thế khi hợp đồng đang ở `PENDING_CONFIRMATION`.<br>4. **Không cho phép ghi đè**: Nếu hợp đồng đã được TTS xác nhận (**`CONFIRMED`**), hệ thống chặn ghi đè và ném lỗi/thông báo lỗi. |
| **Response** | Redirect → `/hr/intern-detail?id=<profileId>` (hoặc `/contract/view?id=<contractId>`) với thông báo |

---

### 8. US10: TTS Xem và Xác nhận Hợp đồng

| Thuộc tính | Giá trị |
|---|---|
| **Xem hợp đồng** | `GET /contract/view` (TTS xem hợp đồng của mình, HR xem theo `id=<contractId>`) |
| **Xác nhận hợp đồng** | `POST /contract/confirm` |
| **Query/Body Params** | `contractId=<contractId>` (hoặc `id=<contractId>`) |
| **Quyền** | **Chỉ INTERN sở hữu hợp đồng** mới có quyền xác nhận (kiểm tra `currentUser.role == INTERN` và hợp đồng thuộc về `profileId` của user) |
| **Behavior** | Chuyển trạng thái `status`: `PENDING_CONFIRMATION` → **`CONFIRMED`**. Ghi nhận thời điểm xác nhận vào cột **`confirmed_at`** (CURRENT_TIMESTAMP). Idempotent nếu đã xác nhận trước đó. |
| **Response** | Redirect → `/contract/view` với `successMessage = "Hợp đồng đã được xác nhận thành công!"` |
| **Lỗi** | 403 nếu không phải TTS sở hữu; 404 nếu hợp đồng không tồn tại |

---

### 9. Tải xuống Hợp đồng (Download an toàn)

| Thuộc tính | Giá trị |
|---|---|
| **URL** | `/contract/download` |
| **Method** | `GET` |
| **Query Parameters** | `id=<contractId>` |
| **Kiểm tra quyền** | HR/Admin hoặc INTERN sở hữu hợp đồng. Người dùng khác nhận HTTP 403. |
| **Header Response** | `Content-Type: application/pdf` (hoặc mime-type tương ứng), `Content-Disposition: inline/attachment` |

---

## Tóm tắt trạng thái và Vòng đời dữ liệu

```
[Document Lifecycle]
                 ┌───> APPROVED (by HR/Admin)
 PENDING (Upload)┤
                 └───> REJECTED (by HR/Admin, bắt buộc reject_reason)
 (Re-upload tạo bản ghi PENDING mới, lưu lại lịch sử bản REJECTED)

[Contract Lifecycle]
 Application: APPROVED
         │
         ▼
 PENDING_CONFIRMATION (HR Upload) ──(TTS Confirms)──> CONFIRMED (Lưu confirmed_at, Khóa sửa/ghi đè)
         ▲                │
         └──(HR Re-upload)┘
```
