<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Báo cáo chấm công (HR)" />
</jsp:include>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-clock-history me-2"></i> Báo cáo chấm công (US22)</h2>
</div>

<c:if test="">
    <div class="alert alert-danger"><c:out value=""/></div>
</c:if>

<div class="card mb-4">
    <div class="card-body">
        <form action="/hr/attendance" method="get" class="row g-3">
            <div class="col-md-3">
                <label class="form-label">Mã Ghi Danh (Enrollment ID)</label>
                <input type="number" name="enrollmentId" class="form-control" value="<c:out value=''/>">
            </div>
            <div class="col-md-3">
                <label class="form-label">Mã Chương Trình (Program ID)</label>
                <input type="number" name="programId" class="form-control" value="<c:out value=''/>">
            </div>
            <div class="col-md-2">
                <label class="form-label">Từ ngày</label>
                <input type="date" name="from" class="form-control" value="<c:out value=''/>">
            </div>
            <div class="col-md-2">
                <label class="form-label">Đến ngày</label>
                <input type="date" name="to" class="form-control" value="<c:out value=''/>">
            </div>
            <div class="col-md-2 d-flex align-items-end">
                <button type="submit" class="btn btn-primary w-100"><i class="bi bi-search"></i> Xem</button>
            </div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>TTS</th>
                    <th>Chương trình</th>
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
                        <tr><td colspan="8" class="text-center">Không có dữ liệu chấm công.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="row" items="">
                            <tr>
                                <td><c:out value="" /> (E:#<c:out value="" />)</td>
                                <td><c:out value="" /></td>
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
