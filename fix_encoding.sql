USE internship_management;
SET NAMES utf8mb4;

UPDATE roles SET description = _utf8mb4'Quản trị hệ thống' WHERE role_id = 1;
UPDATE roles SET description = _utf8mb4'Nhân sự' WHERE role_id = 2;
UPDATE roles SET description = _utf8mb4'Người hướng dẫn thực tập sinh' WHERE role_id = 3;
UPDATE roles SET description = _utf8mb4'Thực tập sinh' WHERE role_id = 4;

UPDATE users SET full_name = _utf8mb4'Nguyễn Thị Lan' WHERE user_id = 1;
UPDATE users SET full_name = _utf8mb4'Nguyễn Văn Nam' WHERE user_id = 2;
UPDATE users SET full_name = _utf8mb4'Trần Thị Hoa' WHERE user_id = 3;
UPDATE users SET full_name = _utf8mb4'Lê Văn Tuấn' WHERE user_id = 4;
UPDATE users SET full_name = _utf8mb4'Phạm Quốc Hùng' WHERE user_id = 5;
UPDATE users SET full_name = _utf8mb4'Quản trị viên' WHERE user_id = 6;
UPDATE users SET full_name = _utf8mb4'Nguyễn Quốc Khánh' WHERE user_id = 7;

UPDATE intern_profiles SET full_name = _utf8mb4'Nguyễn Văn Nam', university = _utf8mb4'Đại học Bách Khoa Hà Nội', major = _utf8mb4'Công nghệ thông tin' WHERE profile_id = 1;
UPDATE intern_profiles SET full_name = _utf8mb4'Trần Thị Hoa', university = _utf8mb4'Đại học Kinh tế Quốc dân', major = _utf8mb4'Hệ thống thông tin quản lý' WHERE profile_id = 2;
UPDATE intern_profiles SET full_name = _utf8mb4'Lê Văn Tuấn', university = _utf8mb4'Đại học Công nghệ - ĐHQGHN', major = _utf8mb4'Khoa học máy tính' WHERE profile_id = 3;
UPDATE intern_profiles SET full_name = _utf8mb4'Nguyễn Quốc Khánh', university = _utf8mb4'Đại học CNTT & TT Thái Nguyên', major = _utf8mb4'An Toàn Thông Tin' WHERE profile_id = 4;

UPDATE departments SET department_name = _utf8mb4'Phòng Phát triển Phần mềm', description = _utf8mb4'Bộ phận kỹ thuật và phát triển phần mềm' WHERE department_id = 1;

UPDATE internship_programs SET program_name = _utf8mb4'Chương trình Thực tập Java Backend 2026', description = _utf8mb4'Đào tạo thực tập sinh backend công nghệ Java Servlet, JSP, MySQL' WHERE program_id = 1;
