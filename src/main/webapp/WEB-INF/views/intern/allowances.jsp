<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="L?ch s? ph? c?p" />
</jsp:include>

<div class="container-fluid py-4">
    <div class="row">
        <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />

        <div class="col-md-9 col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2><i class="bi bi-cash-coin me-2"></i> L?ch s? ph? c?p (US26)</h2>
            </div>
            
            <c:if test="">
                <div class="alert alert-danger"></div>
            </c:if>

            <div class="card">
                <div class="card-body">
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th>K? ?p d?ng</th>
                                <th>Lo?i ph? c?p</th>
                                <th>S? ti?n (VN?)</th>
                                <th>Tr?ng th?i</th>
                                <th>Ng?y thanh to?n</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="a" items="">
                                <tr>
                                    <td><c:out value="" /></td>
                                    <td><c:out value="" /></td>
                                    <td><fmt:formatNumber value="" type="currency" currencySymbol="" /></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="">
                                                <span class="badge bg-success">?? thanh to?n</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-warning">Ch? thanh to?n</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="">
                                                <fmt:parseDate value="" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both" />
                                                <fmt:formatDate pattern="dd/MM/yyyy HH:mm" value="" />
                                            </c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
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
