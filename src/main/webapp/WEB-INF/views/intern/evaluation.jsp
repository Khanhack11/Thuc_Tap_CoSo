<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Đánh giá cuối kỳ" />
<c:set var="activePage" value="intern-evaluation" />
<c:set var="pageStylesheet" value="fe3.css" />
<c:set var="pageScript" value="fe3.js" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="fe3-page" id="fe3App" data-page="intern-evaluation" data-context="${ctx}">
    <p class="fe3-intro">Xem kết quả đánh giá do mentor ghi cho đợt thực tập của bạn.</p>
    <div id="fe3Notice" class="alert d-none" role="status" aria-live="polite"></div>
    <div class="fe3-panel">
        <label class="form-label" for="enrollmentSelect">Đợt thực tập</label>
        <select class="form-select" id="enrollmentSelect"><option value="">Đang tải…</option></select>
    </div>
    <div class="fe3-panel" id="evaluationResult" aria-live="polite">Chọn đợt thực tập.</div>
</section>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
