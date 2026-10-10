<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="My Support Requests" />
</jsp:include>

<h2>Support Requests</h2>

<c:if test="">
    <div class="alert alert-danger"><c:out value=""/></div>
</c:if>
<c:if test="">
    <div class="alert alert-success">Request created successfully.</div>
</c:if>

<div class="card mb-4">
    <div class="card-header bg-white">
        <h5 class="mb-0">Create New Request</h5>
    </div>
    <div class="card-body">
        <form action="/intern/support" method="post">
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
                    <c:when test="">
                        <tr><td colspan="6" class="text-center">No support requests found.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="req" items="">
                            <tr>
                                <td><c:out value="" /></td>
                                <td><c:out value="" /></td>
                                <td><c:out value="" /></td>
                                <td>
                                    <span class="badge ">
                                        <c:out value="" />
                                    </span>
                                </td>
                                <td><c:out value="" /></td>
                                <td><c:out value="" /></td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
