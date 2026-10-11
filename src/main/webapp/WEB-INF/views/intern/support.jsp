<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="My Support Requests" />
</jsp:include>

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />

        <div class="col-md-9 col-lg-10">
            <h2>Support Requests</h2>
            
            <c:if test="${not empty param.error}">
                <div class="alert alert-danger">${param.error}</div>
            </c:if>
            <c:if test="${param.success == 'true'}">
                <div class="alert alert-success">Request created successfully.</div>
            </c:if>

            <div class="card mb-4">
                <div class="card-header bg-white">
                    <h5 class="mb-0">Create New Request</h5>
                </div>
                <div class="card-body">
                    <form action="${pageContext.request.contextPath}/intern/support" method="post">
                        <input type="hidden" name="csrfToken" value="${csrfToken}">
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
                            <c:forEach var="req" items="${requests}">
                                <tr>
                                    <td>${req.requestId}</td>
                                    <td>${req.requestType}</td>
                                    <td>${req.title}</td>
                                    <td>
                                        <span class="badge ${req.status == 'PENDING' ? 'bg-warning text-dark' : (req.status == 'RESOLVED' ? 'bg-success' : 'bg-secondary')}">
                                            ${req.status}
                                        </span>
                                    </td>
                                    <td>${req.createdAt}</td>
                                    <td>${req.response != null ? req.response : 'N/A'}</td>
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
