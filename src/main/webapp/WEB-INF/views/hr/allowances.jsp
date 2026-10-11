<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Qu?n l? ph? c?p" />
</jsp:include>

<div class="container-fluid py-4">
    <div class="row">
        <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />

        <div class="col-md-9 col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2><i class="bi bi-cash-coin me-2"></i> Qu?n l? ph? c?p (US25)</h2>
            </div>
            
            <c:if test="">
                <div class="alert alert-danger"></div>
            </c:if>
            <c:if test="">
                <div class="alert alert-success">Thao t?c th?nh c?ng.</div>
            </c:if>

            <div class="card mb-4">
                <div class="card-header bg-white"><h5 class="mb-0">T?o m?i ph? c?p</h5></div>
                <div class="card-body">
                    <form action="/hr/allowances" method="post" class="row g-3">
                        <input type="hidden" name="csrfToken" value="">
                        <input type="hidden" name="action" value="create">
                        <div class="col-md-3">
                            <label class="form-label">M? Ghi Danh (Enrollment ID)</label>
                            <input type="number" name="enrollmentId" class="form-control" required>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Lo?i ph? c?p</label>
                            <select name="allowanceType" class="form-select" required>
                                <option value="MEAL">?n tr?a</option>
                                <option value="TRAVEL">?i l?i</option>
                                <option value="SALARY">L??ng TTS</option>
                                <option value="OTHER">Kh?c</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">K? (VD: 2026-10)</label>
                            <input type="text" name="period" class="form-control" required>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">S? ti?n (VN?)</label>
                            <input type="number" name="amount" class="form-control" required min="0" step="1000">
                        </div>
                        <div class="col-md-2 d-flex align-items-end">
                            <button type="submit" class="btn btn-primary w-100"><i class="bi bi-plus-circle"></i> T?o m?i</button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="card">
                <div class="card-body">
                    <form action="/hr/allowances" method="get" class="mb-3">
                        <div class="input-group" style="max-width: 400px;">
                            <input type="number" name="enrollmentId" class="form-control" placeholder="L?c theo Enrollment ID" value="">
                            <button class="btn btn-outline-secondary" type="submit">L?c</button>
                        </div>
                    </form>
                    
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th>TTS</th>
                                <th>K? ?p d?ng</th>
                                <th>Lo?i</th>
                                <th>S? ti?n</th>
                                <th>Tr?ng th?i</th>
                                <th>Thao t?c</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="a" items="">
                                <tr>
                                    <td><c:out value="" /> (#<c:out value="" />)</td>
                                    <td><c:out value="" /></td>
                                    <td><c:out value="" /></td>
                                    <td><fmt:formatNumber value="" type="currency" currencySymbol="" /> ?</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="">
                                                <span class="badge bg-success">?? thanh to?n</span><br>
                                                <small class="text-muted"><c:out value="" /></small>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-warning">Ch? thanh to?n</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:if test="">
                                            <form action="/hr/allowances" method="post" style="display:inline;">
                                                <input type="hidden" name="csrfToken" value="">
                                                <input type="hidden" name="action" value="update_status">
                                                <input type="hidden" name="allowanceId" value="">
                                                <input type="hidden" name="status" value="PAID">
                                                <button type="submit" class="btn btn-sm btn-success">??nh d?u ?? thanh to?n</button>
                                            </form>
                                        </c:if>
                                    </td>
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
