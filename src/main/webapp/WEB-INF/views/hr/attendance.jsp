<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="B?o c?o ch?m c?ng (HR)" />
</jsp:include>

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />

        <div class="col-md-9 col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2><i class="bi bi-clock-history me-2"></i> B?o c?o ch?m c?ng (US22)</h2>
            </div>
            
            <c:if test="">
                <div class="alert alert-danger"></div>
            </c:if>

            <div class="card mb-4">
                <div class="card-body">
                    <form action="/hr/attendance" method="get" class="row g-3">
                        <div class="col-md-3">
                            <label class="form-label">M? Ghi Danh (Enrollment ID)</label>
                            <input type="number" name="enrollmentId" class="form-control" value="">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">M? Ch??ng Tr?nh (Program ID)</label>
                            <input type="number" name="programId" class="form-control" value="">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">T? ng?y</label>
                            <input type="date" name="from" class="form-control" value="">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">??n ng?y</label>
                            <input type="date" name="to" class="form-control" value="">
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
                                <th>Ch??ng tr?nh</th>
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
                                    <td><c:out value="" /> (E:#<c:out value="" />)</td>
                                    <td><c:out value="" /></td>
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
