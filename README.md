# HỆ THỐNG QUẢN LÝ THỰC TẬP SINH (INTERNSHIP MANAGEMENT SYSTEM)

Dự án phát triển hệ thống Quản lý Thực tập sinh toàn diện trên nền tảng **Java Servlet, JSP, Jakarta EE 10, MySQL và Apache Tomcat 10.1**.

Hệ thống phục vụ toàn bộ vòng đời thực tập: Đăng ký, ứng tuyển, quản lý hồ sơ, duyệt tài liệu, ký hợp đồng, ghi danh bằng Gmail, phân công mentor, chấm công điểm danh, xin nghỉ phép, giao việc, báo cáo, họp trực tuyến, yêu cầu hỗ trợ và đánh giá hoàn thành thực tập.

---

## 1. Yêu cầu môi trường (Prerequisites)

- **Hệ điều hành**: Windows 10/11, macOS hoặc Linux.
- **Java Development Kit (JDK)**: JDK 17, JDK 21 hoặc JDK 24.
- **Apache Maven**: Phiên bản 3.8.x hoặc 3.9.x.
- **Apache Tomcat**: Phiên bản **10.1.x** (bắt buộc Jakarta EE 10 / `jakarta.servlet.*`).
- **Cơ sở dữ liệu**: MySQL 8.0+ hoặc MariaDB (khuyên dùng XAMPP).

---

## 2. Hướng dẫn cài đặt & Khởi chạy nhanh (Quick Start)

### Bước 1: Khởi động MySQL & Nạp Database

1. Mở **XAMPP Control Panel** và nhấn **Start** tại mục **MySQL** (hoặc đảm bảo dịch vụ MySQL đang chạy trên cổng `3306`).
2. Mở terminal / command prompt và import toàn bộ cơ sở dữ liệu mẫu bằng 1 lệnh:
   ```bash
   mysql -u root -p < database/full_database_dump.sql
   ```
   *(Nếu dùng XAMPP mặc định không có mật khẩu root, chỉ cần gõ: `mysql -u root < database/full_database_dump.sql` hoặc vào `http://localhost/phpmyadmin` bấm Import file `database/full_database_dump.sql`).*

> **Ghi chú**: File dump `database/full_database_dump.sql` đã bao gồm đầy đủ cấu trúc bảng, ràng buộc khóa ngoại, charset UTF-8 chuẩn xác tiếng Việt không lỗi font và đầy đủ dữ liệu người dùng mẫu.

### Bước 2: Kiểm tra cấu hình kết nối CSDL

File cấu hình kết nối CSDL nằm tại `src/main/resources/db.properties`. Mặc định đã được cấu hình chuẩn cho XAMPP:
```properties
db.url=jdbc:mysql://127.0.0.1:3306/internship_management?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh
db.username=root
db.password=
db.driver=com.mysql.cj.jdbc.Driver
```
*(Nếu MySQL của bạn dùng port hoặc mật khẩu khác, hãy chỉnh sửa lại file này tương ứng).*

### Bước 3: Khởi chạy dự án

#### Cách 1: Sử dụng Script tự động (Khuyên dùng trên Windows)
Dự án đã tích hợp sẵn script tự động:
1. Mở file `start_server.bat` (nhấp đúp hoặc chạy trong CMD/PowerShell).
2. Script sẽ tự động:
   - Kiểm tra trạng thái MySQL.
   - Build và đóng gói WAR bằng Maven (`mvn package -DskipTests`).
   - Copy file WAR sang thư mục `webapps/` của Tomcat 10.1.
   - Khởi động server Tomcat.

#### Cách 2: Build và Deploy thủ công
1. Build file WAR:
   ```bash
   mvn clean package -DskipTests
   ```
2. Copy file vừa tạo: `target/internship-management-system.war` vào thư mục `webapps/` của Apache Tomcat 10.1.
3. Khởi động Tomcat (`bin/catalina.bat run` hoặc `bin/catalina.sh run`).

### Bước 4: Truy cập ứng dụng

Mở trình duyệt web và truy cập đường dẫn:
```
http://localhost:8080/internship-management-system/
```

---

## 3. Danh sách tài khoản thử nghiệm theo vai trò

Tất cả các tài khoản mặc định có mật khẩu là: **`123456`**

| Vai trò (Role) | Tên đăng nhập (Username) | Mật khẩu | Họ và tên | Gmail / Chức vụ |
| :--- | :--- | :--- | :--- | :--- |
| **ADMIN** | `admin` | `123456` | Quản trị viên | admin@internship.local (Quản lý tài khoản, phân quyền, sao lưu) |
| **HR** | `hr_lan` | `123456` | Nguyễn Thị Lan | hr.lan@company.com (Tuyển dụng, duyệt hồ sơ, hợp đồng, chấm công, giải quyết hỗ trợ) |
| **MENTOR** | `mentor_hung` | `123456` | Phạm Quốc Hùng | mentor.hung@company.com (Phân công công việc, lịch họp, đánh giá TTS) |
| **INTERN** | `intern_nam` | `123456` | Nguyễn Văn Nam | nam.nv@university.edu.vn (Thực tập sinh Java Backend) |
| **INTERN** | `intern_hoa` | `123456` | Trần Thị Hoa | hoa.tt@university.edu.vn (Thực tập sinh) |
| **INTERN** | `intern_tuan` | `123456` | Lê Văn Tuấn | tuan.lv@university.edu.vn (Thực tập sinh) |
| **INTERN** | `khanh01` | `123456` | Nguyễn Quốc Khánh | nguyenqkhanh1626@gmail.com (Thực tập sinh An Toàn Thông Tin) |

---

## 4. Các tính năng & Phân hệ chính

1. **Phân hệ Quản trị (Admin)**:
   - Quản lý danh sách người dùng, kích hoạt/vô hiệu hóa tài khoản, gán phân quyền động (ADMIN, HR, MENTOR, INTERN).
   - Xem nhật ký hoạt động hệ thống (Audit Logs) và cơ chế sao lưu CSDL.

2. **Phân hệ Nhân sự (HR)**:
   - Quản lý chương trình thực tập theo phòng ban, tạo và quản lý kỳ thực tập.
   - Duyệt đơn ứng tuyển, quản lý hồ sơ và phê duyệt tài liệu.
   - Ghi danh thực tập sinh theo **Gmail** trực tiếp, tự động nhận diện và liên kết hồ sơ.
   - Quản lý hợp đồng: tạo mới, gửi hợp đồng, xác nhận và ký hợp đồng thực tập.
   - Theo dõi điểm danh, phê duyệt đơn xin nghỉ phép, tổng hợp báo cáo chuyên cần và phụ cấp.
   - Tiếp nhận và xử lý các yêu cầu hỗ trợ (Support Requests) từ thực tập sinh.

3. **Phân hệ Người hướng dẫn (Mentor)**:
   - Tiếp nhận danh sách thực tập sinh được phân công hướng dẫn.
   - Giao việc (Tasks), theo dõi tiến độ công việc theo từng tuần.
   - Lên lịch họp (Meetings) và nhận thông báo cuộc họp trực tiếp trên hệ thống.
   - Nhận xét, chấm điểm và đánh giá kết quả kết thúc kỳ thực tập.

4. **Phân hệ Thực tập sinh (Intern)**:
   - Quản lý hồ sơ cá nhân (thông tin trường học, ngành học, kỹ năng, CV).
   - Theo dõi trạng thái ứng tuyển và thông tin chương trình đã ghi danh.
   - Xem chi tiết và xác nhận hợp đồng thực tập trực tuyến.
   - Điểm danh trực tuyến hàng ngày, gửi đơn xin nghỉ phép có lý do.
   - Gửi yêu cầu hỗ trợ kỹ thuật/hành chính đến phòng Nhân sự.
   - Xem lịch họp, báo cáo kết quả và kết quả đánh giá thực tập.

---

## 5. Cấu trúc thư mục dự án

```text
TTS/
├── database/
│   ├── full_database_dump.sql     # Toàn bộ database hoàn chỉnh (Schema + Data mẫu chuẩn UTF-8)
│   └── schema.sql                 # Schema cơ bản
├── src/
│   ├── main/
│   │   ├── java/com/internship/
│   │   │   ├── controller/        # Servlets điều hướng và xử lý request
│   │   │   ├── dao/               # Tầng tương tác Cơ sở dữ liệu (JDBC)
│   │   │   ├── filter/            # Bộ lọc mã hóa UTF-8, xác thực phân quyền
│   │   │   ├── model/             # Entities và Data Models
│   │   │   ├── service/           # Tầng nghiệp vụ (Business Logic)
│   │   │   └── util/              # Tiện ích kết nối DB, bảo mật, mã hóa
│   │   ├── resources/
│   │   │   ├── db.properties      # Cấu hình kết nối MySQL
│   │   │   └── mail.properties    # Cấu hình máy chủ gửi Email SMTP
│   │   └── webapp/
│   │       ├── assets/            # CSS, JavaScript, Icons
│   │       ├── WEB-INF/views/     # Giao diện JSP theo phân quyền (admin, hr, mentor, intern)
│   │       └── login.jsp          # Trang đăng nhập và điều hướng
├── start_server.bat               # Script 1-click tự động build và chạy dự án trên Windows
├── stop_server.bat                # Script dừng server Tomcat
└── pom.xml                        # File cấu hình thư viện và build Maven
```
