<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Báo cáo tuần" />
<c:set var="activePage" value="mentor-reports" />
<c:set var="pageStylesheet" value="fe3.css" />
<c:set var="pageScript" value="fe3.js" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="fe3-page" id="fe3App" data-page="mentor-reports" data-context="${ctx}">
    <p class="fe3-intro">Xem báo cáo đã nộp và gửi phản hồi cho TTS đang hướng dẫn.</p>
    <div id="fe3Notice" class="alert d-none" role="status" aria-live="polite"></div>
    <div class="fe3-panel">
        <label class="form-label" for="enrollmentSelect">Đợt thực tập</label>
        <select class="form-select" id="enrollmentSelect"><option value="">Đang tải…</option></select>
    </div>
    <div class="fe3-two-column">
        <div class="fe3-panel">
            <h2>Báo cáo đã nộp</h2>
            <div id="reportList" class="fe3-list" aria-live="polite">Chọn đợt thực tập.</div>
        </div>
        <div class="fe3-panel">
            <h2>Chi tiết và phản hồi</h2>
            <div id="reportDetail" class="fe3-report-content">Chọn một báo cáo.</div>
            <div id="feedbackList" class="fe3-feedback-list"></div>
            <form id="feedbackForm" class="d-none mt-3">
                <label class="form-label" for="feedbackComment">Nhận xét</label>
                <textarea class="form-control mb-3" id="feedbackComment" name="comment" rows="4"></textarea>
                <label class="form-label" for="feedbackRating">Điểm phản hồi (1–5, không bắt buộc)</label>
                <input class="form-control mb-3" id="feedbackRating" name="rating" type="number" min="1" max="5">
                <button class="btn btn-primary" type="submit">Gửi phản hồi</button>
            </form>
        </div>
    </div>
</section>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
