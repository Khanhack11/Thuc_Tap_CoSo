<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Ch?m c?ng th? c?ng" />
</jsp:include>

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />

        <div class="col-md-9 col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2><i class="bi bi-clock-history me-2"></i> Ch?m c?ng (US21)</h2>
            </div>
            
            <c:if test="">
                <div class="alert alert-danger"></div>
            </c:if>
            <c:if test="">
                <div class="alert alert-success">Thao t?c th?nh c?ng.</div>
            </c:if>

            <div class="card mb-4">
                <div class="card-body">
                    <form action="/intern/attendance" method="post" class="d-flex align-items-end gap-3">
                        <input type="hidden" name="csrfToken" value="">
                        <div>
                            <label class="form-label">M? Ghi Danh (Enrollment ID)</label>
                            <input type="number" name="enrollmentId" class="form-control" value="" required>
                        </div>
                        <button type="submit" name="action" value="checkin" class="btn btn-primary"><i class="bi bi-box-arrow-in-right"></i> Check-in</button>
                        <button type="submit" name="action" value="checkout" class="btn btn-warning"><i class="bi bi-box-arrow-right"></i> Check-out</button>
                    </form>
                </div>
            </div>

            <div class="card">
                <div class="card-header bg-white">
                    <h5 class="mb-0">B?o c?o ch?m c?ng (US22)</h5>
                </div>
                <div class="card-body">
                    <form action="" method="get" class="row g-3 mb-4">
                        <input type="hidden" name="enrollmentId" value="">
                        <div class="col-md-4">
                            <label class="form-label">T? ng?y</label>
                            <input type="date" name="from" class="form-control" value="">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">??n ng?y</label>
                            <input type="date" name="to" class="form-control" value="">
                        </div>
                        <div class="col-md-4 d-flex align-items-end">
                            <button type="submit" class="btn btn-secondary w-100">L?c</button>
                        </div>
                    </form>
                    
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th>Ng?y</th>
                                <th>Ca l?m</th>
                                <th>Check-in</th>
                                <th>Check-out</th>
                                <th>Tr?ng th?i</th>
                                <th>Gi? l?m (h)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="row" items="">
                                <tr>
                                    <td><c:out value="" /></td>
                                    <td><c:out value="" /> - <c:out value="" /></td>
                                    <td><c:out value="" /></td>
                                    <td><c:out value="" /></td>
                                    <td><c:out value="" /></td>
                                    <td><fmt:formatNumber value="" maxFractionDigits="2" /></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
