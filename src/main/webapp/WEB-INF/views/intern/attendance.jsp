<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Chấm công thực tập" />
</jsp:include>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-clock-history me-2"></i> Chấm công (US21)</h2>
</div>

<c:if test="">
    <div class="alert alert-danger"><c:out value=""/></div>
</c:if>
<c:if test="">
    <div class="alert alert-success">Thao tác thành công.</div>
</c:if>

<div class="card mb-4">
    <div class="card-body">
        <form action="/intern/attendance" method="post" class="d-flex align-items-end gap-3">
            <input type="hidden" name="csrfToken" value="<%= com.internship.util.CsrfToken.expose(request) %>">
            <div>
                <label class="form-label">Mã Ghi Danh (Enrollment ID)</label>
                <input type="number" name="enrollmentId" class="form-control" value="<c:out value=''/>" required>
            </div>
            <button type="submit" name="action" value="checkin" class="btn btn-primary"><i class="bi bi-box-arrow-in-right"></i> Check-in</button>
            <button type="submit" name="action" value="checkout" class="btn btn-warning"><i class="bi bi-box-arrow-right"></i> Check-out</button>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header bg-white">
        <h5 class="mb-0">Báo cáo chấm công (US22)</h5>
    </div>
    <div class="card-body">
        <form action="/intern/attendance" method="get" class="row g-3 mb-4">
            <input type="hidden" name="enrollmentId" value="<c:out value=''/>">
            <div class="col-md-4">
                <label class="form-label">Từ ngày</label>
                <input type="date" name="from" class="form-control" value="<c:out value=''/>">
            </div>
            <div class="col-md-4">
                <label class="form-label">Đến ngày</label>
                <input type="date" name="to" class="form-control" value="<c:out value=''/>">
            </div>
            <div class="col-md-4 d-flex align-items-end">
                <button type="submit" class="btn btn-secondary w-100">Lọc</button>
            </div>
        </form>
        
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>Ngày</th>
                    <th>Ca làm</th>
                    <th>Check-in</th>
                    <th>Check-out</th>
                    <th>Trạng thái</th>
                    <th>Giờ làm (h)</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="">
                        <tr><td colspan="6" class="text-center">Không có dữ liệu chấm công.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="row" items="">
                            <tr>
                                <td><c:out value="" /></td>
                                <td><c:out value=" - " /></td>
                                <td><c:out value="" /></td>
                                <td><c:out value="" /></td>
                                <td><c:out value="" /></td>
                                <td><fmt:formatNumber value="" maxFractionDigits="2" /></td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
