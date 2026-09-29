<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Tổng Quan Hệ Thống HR" />
<c:set var="activePage" value="dashboard" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<!-- Thêm Bootstrap Icons nếu chưa có trong header -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

<div class="container-fluid py-4 bg-light min-vh-100">
    <!-- Tiêu đề trang -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="h4 fw-bold text-dark mb-1">Tổng Quan Hệ Thống (HR Dashboard)</h2>
            <p class="text-muted small mb-0">Chào mừng trở lại, quản trị viên nhân sự.</p>
        </div>
        <div>
            <button class="btn btn-primary btn-sm px-3 shadow-sm">
                <i class="bi bi-plus-lg me-1"></i> Tạo Báo Cáo
            </button>
        </div>
    </div>
    
    <!-- Hàng chứa các thẻ thống kê (KPI Cards) -->
    <div class="row g-3 mb-4">
        <!-- Hồ sơ chờ duyệt -->
        <div class="col-xl-3 col-md-6">
            <div class="card border-0 shadow-sm rounded-4 h-100 border-start border-primary border-4">
                <div class="card-body">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-semibold text-uppercase">Hồ Sơ Chờ Duyệt</span>
                            <h2 class="fs-2 fw-bold text-dark mt-2 mb-0">15</h2>
                        </div>
                        <div class="rounded-circle bg-primary bg-opacity-10 p-3 text-primary">
                            <i class="bi bi-file-earmark-person fs-3"></i>
                        </div>
                    </div>
                    <div class="mt-3 pt-2 border-top d-flex justify-content-between align-items-center">
                        <a href="${pageContext.request.contextPath}/hr/applications" class="text-primary text-decoration-none small fw-semibold">
                            Xem chi tiết <i class="bi bi-arrow-right ms-1"></i>
                        </a>
                        <span class="badge bg-primary bg-opacity-10 text-primary small">+3 hôm nay</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- TTS Đang Thực Tập -->
        <div class="col-xl-3 col-md-6">
            <div class="card border-0 shadow-sm rounded-4 h-100 border-start border-success border-4">
                <div class="card-body">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-semibold text-uppercase">TTS Đang Thực Tập</span>
                            <h2 class="fs-2 fw-bold text-dark mt-2 mb-0">42</h2>
                        </div>
                        <div class="rounded-circle bg-success bg-opacity-10 p-3 text-success">
                            <i class="bi bi-people fs-3"></i>
                        </div>
                    </div>
                    <div class="mt-3 pt-2 border-top d-flex justify-content-between align-items-center">
                        <a href="${pageContext.request.contextPath}/hr/interns" class="text-success text-decoration-none small fw-semibold">
                            Xem chi tiết <i class="bi bi-arrow-right ms-1"></i>
                        </a>
                        <span class="badge bg-success bg-opacity-10 text-success small">Ổn định</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Chương Trình Active -->
        <div class="col-xl-3 col-md-6">
            <div class="card border-0 shadow-sm rounded-4 h-100 border-start border-warning border-4">
                <div class="card-body">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-semibold text-uppercase">Chương Trình Active</span>
                            <h2 class="fs-2 fw-bold text-dark mt-2 mb-0">3</h2>
                        </div>
                        <div class="rounded-circle bg-warning bg-opacity-10 p-3 text-warning">
                            <i class="bi bi-kanban fs-3"></i>
                        </div>
                    </div>
                    <div class="mt-3 pt-2 border-top d-flex justify-content-between align-items-center">
                        <a href="${pageContext.request.contextPath}/hr/programs" class="text-warning text-dark text-decoration-none small fw-semibold">
                            Xem chi tiết <i class="bi bi-arrow-right ms-1"></i>
                        </a>
                        <span class="badge bg-warning bg-opacity-10 text-dark small">Đang chạy</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Mentor Đang Hướng Dẫn -->
        <div class="col-xl-3 col-md-6">
            <div class="card border-0 shadow-sm rounded-4 h-100 border-start border-info border-4">
                <div class="card-body">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-semibold text-uppercase">Mentor Hướng Dẫn</span>
                            <h2 class="fs-2 fw-bold text-dark mt-2 mb-0">12</h2>
                        </div>
                        <div class="rounded-circle bg-info bg-opacity-10 p-3 text-info">
                            <i class="bi bi-person-badge fs-3"></i>
                        </div>
                    </div>
                    <div class="mt-3 pt-2 border-top d-flex justify-content-between align-items-center">
                        <a href="${pageContext.request.contextPath}/hr/mentors" class="text-info text-decoration-none small fw-semibold">
                            Xem chi tiết <i class="bi bi-arrow-right ms-1"></i>
                        </a>
                        <span class="badge bg-info bg-opacity-10 text-info small">Đầy đủ</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Phần nội dung phụ trợ bên dưới (Biểu đồ / Hoạt động gần đây) -->
    <div class="row g-3">
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm rounded-4 p-3 h-100">
                <div class="card-body">
                    <h5 class="card-title fw-bold mb-3">Thống Kê Tuyển Dụng Thực Tập Sinh</h5>
                    <div class="text-center py-5 text-muted bg-light rounded-3">
                        <i class="bi bi-bar-chart-line fs-1 text-secondary opacity-50"></i>
                        <p class="mt-2 mb-0">Khu vực hiển thị biểu đồ thống kê (Có thể tích hợp Chart.js)</p>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm rounded-4 p-3 h-100">
                <div class="card-body">
                    <h5 class="card-title fw-bold mb-3">Hoạt Động Gần Đây</h5>
                    <ul class="list-unstyled mb-0">
                        <li class="d-flex align-items-start mb-3 pb-2 border-bottom">
                            <div class="rounded-circle bg-primary bg-opacity-10 p-2 text-primary me-3">
                                <i class="bi bi-person-plus-fill"></i>
                            </div>
                            <div>
                                <p class="mb-0 small fw-semibold">Nguyễn Văn A nộp hồ sơ TTS Java</p>
                                <small class="text-muted">10 phút trước</small>
                            </div>
                        </li>
                        <li class="d-flex align-items-start mb-3 pb-2 border-bottom">
                            <div class="rounded-circle bg-success bg-opacity-10 p-2 text-success me-3">
                                <i class="bi bi-check-circle-fill"></i>
                            </div>
                            <div>
                                <p class="mb-0 small fw-semibold">Đã duyệt thực tập cho Trần Thị B</p>
                                <small class="text-muted">1 giờ trước</small>
                            </div>
                        </li>
                        <li class="d-flex align-items-start">
                            <div class="rounded-circle bg-warning bg-opacity-10 p-2 text-warning me-3">
                                <i class="bi bi-calendar-event"></i>
                            </div>
                            <div>
                                <p class="mb-0 small fw-semibold">Tạo chương trình Spring Boot 2026</p>
                                <small class="text-muted">Hôm qua</small>
                            </div>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>