<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Danh sách Thực Tập Sinh" />
<c:set var="activePage" value="interns" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="container-fluid mt-4">
    <h2 class="h4 mb-4">Quản lý Thực Tập Sinh</h2>
    
    <!-- Form Tìm Kiếm (Dành cho BE2 xử lý logic) -->
    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/hr/interns/search" method="GET" class="row g-3 align-items-center">
                <div class="col-md-5">
                    <input type="text" class="form-control" name="keyword" placeholder="Nhập tên, email hoặc trường đại học...">
                </div>
                <div class="col-md-3">
                    <select class="form-select" name="status">
                        <option value="">-- Tất cả trạng thái --</option>
                        <option value="ACTIVE">Đang thực tập</option>
                        <option value="COMPLETED">Đã hoàn thành</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary w-100">Tìm kiếm</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Bảng Danh Sách -->
    <div class="card shadow-sm">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>Mã TTS</th>
                            <th>Họ Tên</th>
                            <th>Trường Đại Học</th>
                            <th>Trạng Thái</th>
                            <th class="text-center">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- BE2 sẽ dùng thẻ c:forEach để đổ dữ liệu thật vào khu vực này -->
                        <tr>
                            <td colspan="5" class="text-center text-muted py-4">
                                Dữ liệu trống. Đang chờ BE2 đổ dữ liệu từ Server...
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>