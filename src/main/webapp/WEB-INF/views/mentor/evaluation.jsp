<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Đánh giá cuối kỳ" />
<c:set var="activePage" value="mentor-evaluation" />
<c:set var="pageStylesheet" value="fe3.css" />
<c:set var="pageScript" value="fe3.js" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="fe3-page" id="fe3App" data-page="mentor-evaluation" data-context="${ctx}">
    <p class="fe3-intro">Mỗi đợt thực tập chỉ có một đánh giá cuối kỳ. Điểm theo thang 0–100.</p>
    <div id="fe3Notice" class="alert d-none" role="status" aria-live="polite"></div>
    <div class="fe3-panel">
        <label class="form-label" for="enrollmentSelect">Đợt thực tập</label>
        <select class="form-select" id="enrollmentSelect"><option value="">Đang tải…</option></select>
    </div>
    <div class="fe3-panel">
        <div id="evaluationResult" aria-live="polite">Chọn đợt thực tập.</div>
        <form id="evaluationForm" class="d-none mt-3">
            <label class="form-label" for="evaluationScore">Điểm tổng kết</label>
            <input class="form-control mb-3" id="evaluationScore" name="score" type="number" min="0" max="100" step="0.01" required>
            <label class="form-label" for="evaluationComment">Nhận xét</label>
            <textarea class="form-control mb-3" id="evaluationComment" name="comment" rows="5"></textarea>
            <button class="btn btn-primary" type="submit">Lưu đánh giá cuối kỳ</button>
        </form>
    </div>
</section>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
