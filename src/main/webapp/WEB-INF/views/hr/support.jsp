<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Manage Support Requests" />
</jsp:include>

<div class="container-fluid py-4">
    <div class="row">
        <!-- Sidebar -->
        <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />

        <div class="col-md-9 col-lg-10">
            <h2>Manage Support Requests</h2>
            
            <c:if test="${not empty param.error}">
                <div class="alert alert-danger">${param.error}</div>
            </c:if>
            <c:if test="${param.success == 'true'}">
                <div class="alert alert-success">Request updated successfully.</div>
            </c:if>

            <div class="card">
                <div class="card-header bg-white">
                    <h5 class="mb-0">All Support Requests</h5>
                </div>
                <div class="card-body">
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Intern</th>
                                <th>Type</th>
                                <th>Title</th>
                                <th>Content</th>
                                <th>Status</th>
                                <th>Date</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="req" items="${requests}">
                                <tr>
                                    <td>${req.requestId}</td>
                                    <td>${req.internName}</td>
                                    <td>${req.requestType}</td>
                                    <td>${req.title}</td>
                                    <td>${req.content}</td>
                                    <td>
                                        <span class="badge ${req.status == 'PENDING' ? 'bg-warning text-dark' : (req.status == 'RESOLVED' ? 'bg-success' : 'bg-secondary')}">
                                            ${req.status}
                                        </span>
                                    </td>
                                    <td>${req.createdAt}</td>
                                    <td>
                                        <button type="button" class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#respondModal${req.requestId}">
                                            Respond
                                        </button>

                                        <!-- Modal -->
                                        <div class="modal fade" id="respondModal${req.requestId}" tabindex="-1">
                                            <div class="modal-dialog">
                                                <div class="modal-content">
                                                    <form action="${pageContext.request.contextPath}/hr/support" method="post">
                                                        <input type="hidden" name="csrfToken" value="${csrfToken}">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title">Respond to Request #${req.requestId}</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <input type="hidden" name="requestId" value="${req.requestId}">
                                                            <div class="mb-3">
                                                                <label class="form-label">Status</label>
                                                                <select name="status" class="form-select">
                                                                    <option value="PENDING" ${req.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                                                                    <option value="IN_PROGRESS" ${req.status == 'IN_PROGRESS' ? 'selected' : ''}>In Progress</option>
                                                                    <option value="RESOLVED" ${req.status == 'RESOLVED' ? 'selected' : ''}>Resolved</option>
                                                                    <option value="CLOSED" ${req.status == 'CLOSED' ? 'selected' : ''}>Closed</option>
                                                                </select>
                                                            </div>
                                                            <div class="mb-3">
                                                                <label class="form-label">Response</label>
                                                                <textarea name="response" class="form-control" rows="4">${req.response}</textarea>
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                                            <button type="submit" class="btn btn-primary">Save changes</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
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
