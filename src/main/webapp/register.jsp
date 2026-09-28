<%--
    register.jsp - Trang đăng ký tài khoản Thực tập sinh. Owner: FE1 (US06 / 4.3)

    ============================================================================
    QUY TẮC BẮT BUỘC TỪ BẢN CHỐT (không được vi phạm):
    "Public registration luôn tạo role Intern ở phía server.
     Client không được tự gửi role tùy ý."
    => Trang này CỐ Ý KHÔNG có ô chọn role và KHÔNG có input ẩn tên "role".
       Nếu sau này có ai thêm vào, đó là lỗ hổng leo thang quyền.
    ============================================================================
    HỢP ĐỒNG ĐÃ CHỐT VỚI BE1 (US39/4.1) - đối chiếu RegisterServlet
    ----------------------------------------------------------------------------
    [1] Servlet nhận POST tại  ${ctx}/auth/register   (đã có trên develop)
    [2] Tham số servlet THỰC SỰ đọc:
            username, email, fullName, password, confirmPassword
        => phone / university / major / gpa KHÔNG được đọc và KHÔNG được lưu.
           Phần hồ sơ này chờ BE2 (bảng intern_profiles). Vì vậy 3 field
           phone / university / major đã BỎ thuộc tính required: bắt người dùng
           nhập bắt buộc rồi vứt đi là sai. Họ điền nốt ở trang Hồ sơ cá nhân.
           Khi BE2 nối xong thì kiểm tra lại, có thể bật required trở lại.
    [3] Đăng ký lỗi:   forward về /register.jsp kèm request attribute
                       "errorMessage" (đã xác nhận trong RegisterServlet)
    [4] Đăng ký đúng:  set session flashSuccess rồi redirect về ${ctx}/auth/login
                       => KHÔNG set sessionScope.user ở bước này; người dùng
                          phải đăng nhập lại. Đó là lý do trang này không đọc
                          session.
    ----------------------------------------------------------------------------
    BƯỚC "NỘP HỒ SƠ" (Application) KHÔNG nằm ở đây.
    Việc tạo và nộp đơn ứng tuyển đã có endpoint riêng (/intern/applications).
    Nút nộp hồ sơ nằm ở trang hồ sơ, không thêm vào đây, vì lúc đó thí sinh
    đã có tài khoản và đã đăng nhập.
    ============================================================================
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đăng ký thực tập sinh - Internship Management System</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${ctx}/assets/css/app.css" rel="stylesheet">
</head>
<body>

<div class="auth-page">
    <div class="auth-card auth-card--wide">

        <div class="auth-card__brand">
            <i class="bi bi-mortarboard-fill"></i>
            <span>Internship Manager</span>
        </div>
        <p class="auth-card__sub">
            Tạo tài khoản thực tập sinh và khai báo hồ sơ ban đầu
        </p>

        <%-- Lỗi đăng ký do RegisterServlet trả về: request attribute "errorMessage" --%>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger" role="alert">
                <i class="bi bi-exclamation-octagon-fill me-1"></i><c:out value="${errorMessage}" />
            </div>
        </c:if>

        <form action="${ctx}/auth/register" method="post" data-check-password>

            <h2 class="h6 fw-bold mb-3">
                <i class="bi bi-person-badge me-1"></i>Thông tin tài khoản
            </h2>

            <div class="row g-3 mb-4">
                <div class="col-md-6">
                    <label class="form-label" for="username">Tên đăng nhập <span class="req">*</span></label>
                    <input type="text" id="username" name="username" class="form-control"
                           value="<c:out value='${param.username}' />"
                           required autofocus autocomplete="username"
                           minlength="4" maxlength="50"
                           pattern="[A-Za-z0-9._\-]{4,50}" placeholder="intern_nam">
                    <span class="form-text">4 đến 50 ký tự, chỉ dùng chữ, số, dấu chấm, gạch dưới.</span>
                </div>

                <div class="col-md-6">
                    <label class="form-label" for="email">Email <span class="req">*</span></label>
                    <input type="email" id="email" name="email" class="form-control"
                           value="<c:out value='${param.email}' />"
                           required autocomplete="email" maxlength="120"
                           placeholder="nam@student.edu.vn">
                    <span class="form-text">Dùng để nhận thông báo từ hệ thống.</span>
                </div>

                <div class="col-md-6">
                    <label class="form-label" for="password">Mật khẩu <span class="req">*</span></label>
                    <input type="password" id="password" name="password" class="form-control"
                           required autocomplete="new-password"
                           minlength="8" maxlength="100" placeholder="Tối thiểu 8 ký tự">
                </div>

                <div class="col-md-6">
                    <label class="form-label" for="confirmPassword">Nhập lại mật khẩu <span class="req">*</span></label>
                    <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                           required autocomplete="new-password"
                           minlength="8" maxlength="100" placeholder="Nhập lại mật khẩu">
                </div>
            </div>

            <h2 class="h6 fw-bold mb-3">
                <i class="bi bi-person-vcard me-1"></i>Hồ sơ ban đầu
            </h2>

            <p class="form-text mb-3">
                Chỉ <strong>Họ và tên</strong> là bắt buộc. Các thông tin còn lại
                có thể bổ sung sau khi đăng nhập, ở trang <strong>Hồ sơ cá nhân</strong>.
            </p>

            <div class="row g-3 mb-3">
                <div class="col-md-8">
                    <label class="form-label" for="fullName">Họ và tên <span class="req">*</span></label>
                    <input type="text" id="fullName" name="fullName" class="form-control"
                           value="<c:out value='${param.fullName}' />"
                           required maxlength="100" placeholder="Nguyễn Văn Nam">
                </div>
                <div class="col-md-4">
                    <%-- Không required: RegisterServlet chưa đọc field này, xem ghi chú đầu file --%>
                    <label class="form-label" for="phone">Số điện thoại</label>
                    <input type="tel" id="phone" name="phone" class="form-control"
                           value="<c:out value='${param.phone}' />"
                           pattern="[0-9+ .()\-]{9,15}" placeholder="0912345678">
                </div>
            </div>

            <div class="row g-3 mb-4">
                <div class="col-md-7">
                    <%-- Không required: RegisterServlet chưa đọc field này --%>
                    <label class="form-label" for="university">Trường đại học / cao đẳng</label>
                    <input type="text" id="university" name="university" class="form-control"
                           value="<c:out value='${param.university}' />"
                           maxlength="150" placeholder="Đại học Bách Khoa Hà Nội">
                </div>
                <div class="col-md-5">
                    <%-- Không required: RegisterServlet chưa đọc field này --%>
                    <label class="form-label" for="major">Chuyên ngành</label>
                    <input type="text" id="major" name="major" class="form-control"
                           value="<c:out value='${param.major}' />"
                           maxlength="100" placeholder="Công nghệ thông tin">
                </div>
                <div class="col-md-3">
                    <label class="form-label" for="gpa">GPA (hệ 4)</label>
                    <input type="number" id="gpa" name="gpa" class="form-control"
                           value="<c:out value='${param.gpa}' />"
                           step="0.01" min="0" max="4" placeholder="3.50">
                </div>
            </div>

            <%-- KHÔNG thêm ô chọn role ở đây. Server luôn gán role = INTERN. --%>

            <div class="d-flex flex-wrap gap-2 align-items-center">
                <button type="submit" class="btn btn-brand">
                    <i class="bi bi-person-plus me-1"></i>Đăng ký
                </button>
                <a href="${ctx}/auth/login" class="btn btn-outline-brand">Đã có tài khoản</a>
            </div>

        </form>

        <p class="auth-foot">
            Sau khi đăng ký thành công, bạn đăng nhập và vào
            <strong>Hồ sơ cá nhân</strong> để hoàn thiện thông tin, tải lên CV
            và nộp hồ sơ ứng tuyển.
        </p>

        <div class="auth-note">
            <i class="bi bi-info-circle me-1"></i>
            Tài khoản đăng ký tại đây luôn có quyền <strong>Thực tập sinh</strong>.
            Tài khoản HR, Mentor và Quản trị viên do quản trị viên cấp riêng.
        </div>

    </div>
</div>

<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
