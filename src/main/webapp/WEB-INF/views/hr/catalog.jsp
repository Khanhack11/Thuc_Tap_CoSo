<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head><meta charset="UTF-8"><title>Thiết lập thực tập</title></head>
<body>
<h1>Phòng ban, chương trình và mentor</h1>
<p><a href="${pageContext.request.contextPath}/hr/enrollments">Quản lý ghi danh</a></p>
<c:if test="${not empty successMessage}"><p><c:out value="${successMessage}"/></p></c:if>
<c:if test="${not empty errorMessage}"><p><c:out value="${errorMessage}"/></p></c:if>

<h2>Tạo phòng ban</h2>
<form method="post" action="${pageContext.request.contextPath}/hr/catalog">
    <input type="hidden" name="csrfToken" value="${csrfToken}"/>
    <input type="hidden" name="action" value="create-department"/>
    <label>Tên <input name="name" maxlength="150" required/></label>
    <label>Mô tả <input name="description"/></label>
    <button type="submit">Tạo phòng ban</button>
</form>

<h2>Tạo chương trình</h2>
<form method="post" action="${pageContext.request.contextPath}/hr/catalog">
    <input type="hidden" name="csrfToken" value="${csrfToken}"/>
    <input type="hidden" name="action" value="create-program"/>
    <label>Tên <input name="name" maxlength="200" required/></label>
    <label>Phòng ban <select name="departmentId" required>
        <c:forEach var="department" items="${departments}">
            <option value="${department.departmentId}"><c:out value="${department.departmentName}"/></option>
        </c:forEach>
    </select></label>
    <label>Bắt đầu <input type="date" name="startDate" required/></label>
    <label>Kết thúc <input type="date" name="endDate" required/></label>
    <label>Số TTS tối đa (0 = không giới hạn) <input type="number" min="0" name="maxInterns" value="0" required/></label>
    <label>Mô tả <input name="description"/></label>
    <button type="submit">Tạo chương trình PLANNED</button>
</form>

<h2>Chương trình</h2>
<form method="get" action="${pageContext.request.contextPath}/hr/catalog">
    <label>Lọc chương trình và mentor theo phòng ban:
        <select name="departmentId">
            <option value="">Tất cả phòng ban</option>
            <c:forEach var="department" items="${departments}">
                <option value="${department.departmentId}" ${selectedDepartmentId == department.departmentId ? 'selected' : ''}><c:out value="${department.departmentName}"/></option>
            </c:forEach>
        </select>
    </label>
    <button type="submit">Lọc</button>
</form>
<c:if test="${not empty editingProgram}">
    <h3>Sửa chương trình #${editingProgram.programId}</h3>
    <c:if test="${programStructureLocked}"><p>Đã có ghi danh: chỉ được sửa tên và mô tả.</p></c:if>
    <form method="post" action="${pageContext.request.contextPath}/hr/catalog">
        <input type="hidden" name="csrfToken" value="${csrfToken}"/>
        <input type="hidden" name="action" value="update-program"/>
        <input type="hidden" name="programId" value="${editingProgram.programId}"/>
        <label>Tên <input name="name" value="<c:out value='${editingProgram.programName}'/>" maxlength="200" required/></label>
        <label>Mô tả <input name="description" value="<c:out value='${editingProgram.description}'/>"/></label>
        <c:choose>
            <c:when test="${programStructureLocked}">
                <input type="hidden" name="departmentId" value="${editingProgram.departmentId}"/>
                <input type="hidden" name="startDate" value="${editingProgram.startDate}"/>
                <input type="hidden" name="endDate" value="${editingProgram.endDate}"/>
                <input type="hidden" name="maxInterns" value="${editingProgram.maxInterns}"/>
                <p>Phòng ban: <c:out value="${editingProgram.departmentName}"/>.
                    Ngày: ${editingProgram.startDate} – ${editingProgram.endDate}.
                    Sức chứa: ${editingProgram.maxInterns} (0 = không giới hạn).</p>
            </c:when>
            <c:otherwise>
                <label>Phòng ban <select name="departmentId" required>
                    <c:forEach var="department" items="${departments}">
                        <option value="${department.departmentId}" ${editingProgram.departmentId == department.departmentId ? 'selected' : ''}><c:out value="${department.departmentName}"/></option>
                    </c:forEach>
                </select></label>
                <label>Bắt đầu <input type="date" name="startDate" value="${editingProgram.startDate}" required/></label>
                <label>Kết thúc <input type="date" name="endDate" value="${editingProgram.endDate}" required/></label>
                <label>Sức chứa <input type="number" min="0" name="maxInterns" value="${editingProgram.maxInterns}" required/></label>
            </c:otherwise>
        </c:choose>
        <button type="submit">Lưu chương trình</button>
        <a href="${pageContext.request.contextPath}/hr/catalog">Hủy</a>
    </form>
</c:if>
<table border="1">
    <tr><th>Tên</th><th>Phòng ban</th><th>Thời gian</th><th>Trạng thái</th><th>Thao tác</th></tr>
    <c:forEach var="program" items="${programs}">
        <tr>
            <td><c:out value="${program.programName}"/></td>
            <td><c:out value="${program.departmentName}"/></td>
            <td><c:out value="${program.startDate}"/> – <c:out value="${program.endDate}"/></td>
            <td><c:out value="${program.status}"/></td>
            <td>
                <a href="${pageContext.request.contextPath}/hr/catalog?action=edit-program&programId=${program.programId}">Sửa</a>
                <c:if test="${program.status == 'PLANNED'}">
                <form method="post" action="${pageContext.request.contextPath}/hr/catalog">
                    <input type="hidden" name="csrfToken" value="${csrfToken}"/>
                    <input type="hidden" name="action" value="activate-program"/>
                    <input type="hidden" name="programId" value="${program.programId}"/>
                    <button type="submit">Kích hoạt</button>
                </form>
            </c:if></td>
        </tr>
    </c:forEach>
</table>

<h2>Thêm mentor</h2>
<form method="post" action="${pageContext.request.contextPath}/hr/catalog">
    <input type="hidden" name="csrfToken" value="${csrfToken}"/>
    <input type="hidden" name="action" value="create-mentor"/>
    <label>Tài khoản Mentor <select name="userId" required>
        <c:forEach var="user" items="${mentorUsers}">
            <option value="${user.userId}"><c:out value="${user.fullName}"/></option>
        </c:forEach>
    </select></label>
    <label>Phòng ban <select name="departmentId" required>
        <c:forEach var="department" items="${departments}">
            <option value="${department.departmentId}"><c:out value="${department.departmentName}"/></option>
        </c:forEach>
    </select></label>
    <label>Chuyên môn <input name="specialization" maxlength="200"/></label>
    <label>Số TTS tối đa <input type="number" min="1" name="maxMentees" value="5" required/></label>
    <button type="submit">Thêm mentor</button>
</form>

<h2>Mentor</h2>
<table border="1">
    <tr><th>Tên</th><th>Phòng ban</th><th>Chuyên môn</th><th>Trạng thái</th><th>Đang hướng dẫn</th><th>Chỗ còn lại</th><th>Tải</th></tr>
    <c:forEach var="mentor" items="${mentors}">
        <tr>
            <td><c:out value="${mentor.fullName}"/></td>
            <td><c:out value="${mentor.departmentName}"/></td>
            <td><c:out value="${mentor.specialization}"/></td>
            <td><c:out value="${mentor.status}"/></td>
            <td>${mentor.currentMenteeCount}/${mentor.maxMentees}</td>
            <td>${mentor.remainingCapacity}</td>
            <td>${mentor.atCapacity ? 'Đã đầy' : 'Còn chỗ'}</td>
        </tr>
    </c:forEach>
</table>
</body>
</html>
