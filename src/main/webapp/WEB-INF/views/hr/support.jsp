<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Manage Support Requests" />
</jsp:include>

<h2>Manage Support Requests</h2>

<c:if test="">
    <div class="alert alert-danger"><c:out value=""/></div>
</c:if>
<c:if test="">
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
                <c:choose>
                    <c:when test="">
                        <tr><td colspan="8" class="text-center">No support requests found.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="req" items="">
                            <tr>
                                <td><c:out value="" /></td>
                                <td><c:out value="" /></td>
                                <td><c:out value="" /></td>
                                <td><c:out value="" /></td>
                                <td><c:out value="" /></td>
                                <td>
                                    <span class="badge ">
                                        <c:out value="" />
                                    </span>
                                </td>
                                <td><c:out value="" /></td>
                                <td>
                                    <button type="button" class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#respondModal">
                                        Respond
                                    </button>

                                    <!-- Modal -->
                                    <div class="modal fade" id="respondModal" tabindex="-1">
                                        <div class="modal-dialog">
                                            <div class="modal-content">
                                                <form action="/hr/support" method="post">
                                                    <input type="hidden" name="csrfToken" value="<%= com.internship.util.CsrfToken.expose(request) %>">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title">Respond to Request #<c:out value="" /></h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <input type="hidden" name="requestId" value="">
                                                        <div class="mb-3">
                                                            <label class="form-label">Status</label>
                                                            <select name="status" class="form-select">
                                                                <option value="PENDING" >Pending</option>
                                                                <option value="IN_PROGRESS" >In Progress</option>
                                                                <option value="RESOLVED" >Resolved</option>
                                                                <option value="CLOSED" >Closed</option>
                                                            </select>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label">Response</label>
                                                            <textarea name="response" class="form-control" rows="4"><c:out value="" /></textarea>
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
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
