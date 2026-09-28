<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Chi tiết Thực Tập Sinh" />
<c:set var="activePage" value="interns" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="container-fluid mt-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4">Hồ Sơ Thực Tập Sinh</h2>
        <a href="${pageContext.request.contextPath}/hr/interns" class="btn btn-outline-secondary">Quay lại danh sách</a>
    </div>

    <div class="row">
        <!-- Thông tin tóm tắt bên trái -->
        <div class="col-md-4 mb-4">
            <div class="card shadow-sm">
                <div class="card-body text-center">
                    <div class="bg-secondary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 100px; height: 100px; font-size: 2rem;">
                        TTS
                    </div>
                    <h5 class="card-title fw-bold">[Tên TTS sẽ hiển thị ở đây]</h5>
                    <p class="text-muted">[Email hiển thị ở đây]</p>
                    <span class="badge bg-success">Đang thực tập</span>
                </div>
            </div>
        </div>

        <!-- Chi tiết hồ sơ bên phải -->
        <div class="col-md-8">
            <div class="card shadow-sm">
                <div class="card-header bg-white fw-bold py-3">Thông tin chi tiết</div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-sm-3 text-muted">Trường Đại học:</div>
                        <div class="col-sm-9 fw-semibold">[Tên Trường]</div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-sm-3 text-muted">Chuyên ngành:</div>
                        <div class="col-sm-9 fw-semibold">[Chuyên Ngành]</div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-sm-3 text-muted">Mentor Hướng dẫn:</div>
                        <div class="col-sm-9 fw-semibold">[Tên Mentor]</div>
                    </div>
                    <div class="row mt-4 pt-3 border-top">
                        <div class="col-12">
                            <a href="#" class="btn btn-primary me-2">Tải CV (PDF)</a>
                            <a href="#" class="btn btn-outline-danger">Chấm dứt thực tập</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>