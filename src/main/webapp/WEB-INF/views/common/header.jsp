<%--
    header.jsp - Khung đầu trang dùng chung cho mọi role.
    Owner: FE1

    Cách dùng trong một trang JSP:
        <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <c:set var="pageTitle"  value="Hồ sơ cá nhân" />
        <c:set var="activePage" value="profile" />
        <%@ include file="/WEB-INF/views/common/header.jsp" %>
        ... nội dung trang ...
        <%@ include file="/WEB-INF/views/common/footer.jsp" %>

    Trang KHÔNG cần lặp lại <html>, <head>, sidebar hay topbar.

    ============================================================================
    HỢP ĐỒNG SESSION VỚI BE1 - KHÔNG ĐƯỢC ĐỔI TÊN
    ----------------------------------------------------------------------------
    LoginServlet đặt vào session:
        currentUser : com.internship.model.User
        currentRole : String - "ADMIN" | "HR" | "MENTOR" | "INTERN"

    User của BE1 KHÔNG có isAdmin()/isHR()/isIntern().
    Nên TUYỆT ĐỐI không viết ${sessionScope.currentUser.admin} -> ném
    PropertyNotFoundException -> HTTP 500.

    Lấy role: dùng currentRole (đã chốt với BE1 ngày 28/09/2026). KHÔNG dùng
    ${sessionScope.currentUser.role.roleName} - hiện cho cùng kết quả
    (currentRole = user.getRole().getRoleName()) nhưng không phải key đã chốt,
    và sẽ lệch nếu cách tính currentRole ở LoginServlet thay đổi.
        ${sessionScope.currentRole eq 'ADMIN'}

    Trước 28/09/2026 khối dưới đây đọc sessionScope.user nên không bao giờ
    render: không có tên người dùng, không có nhãn vai trò, và không có nút
    Đăng xuất nào trong toàn bộ giao diện.
    ============================================================================
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:if test="${empty pageTitle}">
    <c:set var="pageTitle" value="Hệ thống quản lý thực tập" />
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${pageTitle} - Internship Management System</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${ctx}/assets/css/app.css" rel="stylesheet">
    <c:if test="${not empty pageStylesheet}">
        <link href="${ctx}/assets/css/${pageStylesheet}" rel="stylesheet">
    </c:if>
</head>
<body>

<div class="app-shell">

    <%@ include file="/WEB-INF/views/common/sidebar.jsp" %>

    <div class="app-backdrop" id="appBackdrop" hidden></div>

    <div class="app-main">

        <header class="app-topbar">
            <button type="button" class="app-menu-toggle" aria-label="Mở menu" aria-expanded="false">
                <i class="bi bi-list"></i>
            </button>

            <h1 class="app-topbar__title">${pageTitle}</h1>

            <div class="app-topbar__spacer"></div>

            <c:if test="${not empty sessionScope.currentUser}">
                <div class="app-user">
                    <span class="app-user__avatar" aria-hidden="true">
                        <c:choose>
                            <c:when test="${not empty sessionScope.currentUser.username}">
                                <c:out value="${fn:toUpperCase(fn:substring(sessionScope.currentUser.username, 0, 1))}" />
                            </c:when>
                            <c:otherwise><i class="bi bi-person"></i></c:otherwise>
                        </c:choose>
                    </span>
                    <span class="app-user__meta">
                        <%-- User của BE1 có getFullName(); ưu tiên họ tên, chưa có thì lấy username --%>
                        <span class="app-user__name"><c:out value="${empty sessionScope.currentUser.fullName ? sessionScope.currentUser.username : sessionScope.currentUser.fullName}" /></span>
                        <span class="app-user__role">
                            <c:choose>
                                <c:when test="${sessionScope.currentRole eq 'ADMIN'}">Quản trị viên</c:when>
                                <c:when test="${sessionScope.currentRole eq 'HR'}">Nhân sự (HR)</c:when>
                                <c:when test="${sessionScope.currentRole eq 'MENTOR'}">Mentor</c:when>
                                <c:when test="${sessionScope.currentRole eq 'INTERN'}">Thực tập sinh</c:when>
                                <c:otherwise><c:out value="${sessionScope.currentRole}" /></c:otherwise>
                            </c:choose>
                        </span>
                    </span>
                    <%--
                        LogoutServlet CHỈ override doPost, KHÔNG có doGet. Nên
                        <a href="${ctx}/auth/logout"> (GET) sẽ trả 405 Method Not
                        Allowed. Bắt buộc phải là form POST như dưới đây.
                        Không thêm doGet vào LogoutServlet (file của BE1).
                    --%>
                    <form action="${ctx}/auth/logout" method="post" class="m-0">
                        <button type="submit" class="btn btn-outline-brand btn-sm">
                            <i class="bi bi-box-arrow-right"></i>
                            <span class="d-none d-sm-inline ms-1">Đăng xuất</span>
                        </button>
                    </form>
                </div>
            </c:if>
        </header>

        <main class="app-content">

            <c:if test="${not empty sessionScope.flashSuccess}">
                <div class="alert alert-success d-flex align-items-start gap-2" role="alert">
                    <i class="bi bi-check-circle-fill mt-1"></i>
                    <div class="flex-grow-1">${sessionScope.flashSuccess}</div>
                    <button type="button" class="btn-close" data-dismiss="alert" aria-label="Đóng"></button>
                </div>
                <c:remove var="flashSuccess" scope="session" />
            </c:if>

            <c:if test="${not empty sessionScope.flashError}">
                <div class="alert alert-danger d-flex align-items-start gap-2" role="alert">
                    <i class="bi bi-exclamation-triangle-fill mt-1"></i>
                    <div class="flex-grow-1">${sessionScope.flashError}</div>
                    <button type="button" class="btn-close" data-dismiss="alert" aria-label="Đóng"></button>
                </div>
                <c:remove var="flashError" scope="session" />
            </c:if>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger d-flex align-items-start gap-2" role="alert">
                    <i class="bi bi-exclamation-octagon-fill mt-1"></i>
                    <div class="flex-grow-1">${errorMessage}</div>
                    <button type="button" class="btn-close" data-dismiss="alert" aria-label="Đóng"></button>
                </div>
            </c:if>
