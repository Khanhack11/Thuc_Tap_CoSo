<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Quản lý phụ cấp" />
</jsp:include>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-cash-coin me-2"></i> Quản lý phụ cấp (US25)</h2>
</div>

<c:if test="">
    <div class="alert alert-danger"><c:out value=""/></div>
</c:if>
<c:if test="">
    <div class="alert alert-success">Thao tác thành công.</div>
</c:if>

<div class="card mb-4">
    <div class="card-header bg-white"><h5 class="mb-0">Tạo mới phụ cấp</h5></div>
    <div class="card-body">
        <form action="/hr/allowances" method="post" class="row g-3">
            <input type="hidden" name="csrfToken" value="<%= com.internship.util.CsrfToken.expose(request) %>">
            <input type="hidden" name="action" value="create">
            <div class="col-md-3">
                <label class="form-label">Mã Ghi Danh (Enrollment ID)</label>
                <input type="number" name="enrollmentId" class="form-control" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">Loại phụ cấp</label>
                <select name="allowanceType" class="form-select" required>
                    <option value="MEAL">Ăn trưa</option>
                    <option value="TRAVEL">Đi lại</option>
                    <option value="SALARY">Lương TTS</option>
                    <option value="OTHER">Khác</option>
                </select>
            </div>
            <div class="col-md-2">
                <label class="form-label">Kỳ (VD: 2026-10)</label>
                <input type="text" name="period" class="form-control" required>
            </div>
            <div class="col-md-2">
                <label class="form-label">Số tiền (VNĐ)</label>
                <input type="number" name="amount" class="form-control" required min="0" step="1000">
            </div>
            <div class="col-md-2 d-flex align-items-end">
                <button type="submit" class="btn btn-primary w-100"><i class="bi bi-plus-circle"></i> Tạo mới</button>
            </div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <form action="/hr/allowances" method="get" class="mb-3">
            <div class="input-group" style="max-width: 400px;">
                <input type="number" name="enrollmentId" class="form-control" placeholder="Lọc theo Enrollment ID" value="<c:out value=''/>">
                <button class="btn btn-outline-secondary" type="submit">Lọc</button>
            </div>
        </form>
        
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>TTS</th>
                    <th>Kỳ áp dụng</th>
                    <th>Loại</th>
                    <th>Số tiền</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="">
                        <tr><td colspan="6" class="text-center">Không có dữ liệu phụ cấp.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="a" items="">
                            <tr>
                                <td><c:out value="" /> (#<c:out value="" />)</td>
                                <td><c:out value="" /></td>
                                <td><c:out value="" /></td>
                                <td><fmt:formatNumber value="" type="currency" currencySymbol="" /> Đ</td>
                                <td>
                                    <c:choose>
                                        <c:when test="">
                                            <span class="badge bg-success">Đã thanh toán</span><br>
                                            <small class="text-muted"><c:out value="" /></small>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-warning">Chờ thanh toán</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:if test="">
                                        <form action="/hr/allowances" method="post" style="display:inline;">
                                            <input type="hidden" name="csrfToken" value="<%= com.internship.util.CsrfToken.expose(request) %>">
                                            <input type="hidden" name="action" value="update_status">
                                            <input type="hidden" name="allowanceId" value="">
                                            <input type="hidden" name="status" value="PAID">
                                            <button type="submit" class="btn btn-sm btn-success">Đánh dấu đã thanh toán</button>
                                        </form>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
