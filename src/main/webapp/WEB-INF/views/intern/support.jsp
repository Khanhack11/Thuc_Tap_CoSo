<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="My Support Requests" />
</jsp:include>

<h2>Support Requests</h2>

<c:if test="${not empty param.error}">
    <div class="alert alert-danger"><c:out value="${param.error}"/></div>
</c:if>
<c:if test="${not empty param.success}">
    <div class="alert alert-success">Request created successfully.</div>
</c:if>

<div class="card mb-4">
    <div class="card-header bg-white">
        <h5 class="mb-0">Create New Request</h5>
    </div>
    <div class="card-body">
        <form action="${pageContext.request.contextPath}/intern/support" method="post">
            <input type="hidden" name="csrfToken" value="<%= com.internship.util.CsrfToken.expose(request) %>">
            <div class="mb-3">
                <label class="form-label">Type</label>
                <select name="requestType" class="form-select" required>
                    <option value="IT_SUPPORT">IT Support</option>
                    <option value="HR_INQUIRY">HR Inquiry</option>
                    <option value="OTHER">Other</option>
                </select>
            </div>
            <div class="mb-3">
                <label class="form-label">Title</label>
                <input type="text" name="title" class="form-control" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Content</label>
                <textarea name="content" class="form-control" rows="3" required></textarea>
            </div>
            <button type="submit" class="btn btn-primary">Submit Request</button>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header bg-white">
        <h5 class="mb-0">My Requests</h5>
    </div>
    <div class="card-body">
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Type</th>
                    <th>Title</th>
                    <th>Status</th>
                    <th>Date</th>
                    <th>Response</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty requests}">
                        <tr><td colspan="6" class="text-center">No support requests found.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="req" items="${requests}">
                            <tr>
                                <td><c:out value="${req.requestId}" /></td>
                                <td><c:out value="${req.requestType}" /></td>
                                <td><c:out value="${req.title}" /></td>
                                <td>
                                    <span class="badge ${req.status == 'RESOLVED' ? 'bg-success' : req.status == 'PENDING' ? 'bg-warning text-dark' : 'bg-secondary'}">
                                        <c:out value="${req.status}" />
                                    </span>
                                </td>
                                <td><c:out value="${req.createdAt}" /></td>
                                <td><c:out value="${req.response != null ? req.response : '-'}" /></td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
