<%--
    hr/intern-detail.jsp - HR xem chi tiết hồ sơ thực tập sinh. Owner: FE2
    View do InternProfileServlet#handleViewProfileDetail (BE2) forward sang với
    profile / documents / contract.

    QA Sprint 2 (06/10/2026) - các lỗi đã sửa trong file này:
      QA-02  Modal "Chỉnh sửa hồ sơ" POST vào /hr/intern-detail nên rơi vào
             handleSaveProfile (luồng TTS) và thiếu email mà service bắt buộc.
             Nay POST /hr/interns/edit và bổ sung email + gender theo whitelist.
      QA-03  Form "Từ chối" không gửi rejectReason nên DocumentService từ chối
             request. Nay có modal nhập lý do bắt buộc; danh sách hiển thị lý do
             và thời điểm xử lý của tài liệu đã bị từ chối.
      QA-04  Form upload hợp đồng gửi profileId trong khi
             DocumentUploadServlet#handleUploadContract cần applicationId.
             Nay gửi contract.applicationId, bỏ trường signDate (backend không
             dùng) và ẩn form khi chưa có hợp đồng.
             CÒN PHỤ THUỘC BE2: view chưa được cấp Application đã duyệt nên
             applicationId chỉ suy ra được từ hợp đồng đã có. Lần upload ĐẦU
             TIÊN cho hồ sơ chưa từng có hợp đồng vẫn cần BE2 truyền thêm
             attribute (xem ghi chú ở tab Hợp đồng).
      QA-05  Nút chuyển trạng thái POST /intern/profile -> 403 vì
             AuthorizationFilter yêu cầu role INTERN cho /intern/*. Nay POST
             /hr/intern-detail; doPost của InternProfileServlet kiểm tra
             action=update_status TRƯỚC nên vẫn vào handleUpdateStatus, và
             handler tự kiểm tra HR/Admin.
      QA-11  Dữ liệu hồ sơ trong modal được chèn thẳng vào HTML -> stored XSS.
             Nay bọc <c:out> toàn bộ, chú ý 2 ngữ cảnh khác nhau:
                 - trong attribute: value="<c:out value="${profile.x}"/>"
                 - trong textarea : ><c:out value="${profile.x}"/></textarea>

    CHƯA SỬA - QA-07 (CSRF): các form trong file này chưa có csrfToken vì 4
    servlet của BE2 chưa gọi CsrfToken.expose()/valid(). Thêm token lúc này sẽ
    render rỗng, phải thêm cùng nhịp khi BE2 sửa CSRF.
--%>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%-- Chốt locale cho fmt:* theo đúng quy ước của intern/contract.jsp. Thiếu
     dòng này, request không có Accept-Language (curl, bot, một số proxy) làm
     JSTL không xác định được locale và rơi về value.toString(): ngày ra
     "2026-09-05 02:00:00.0" thay vì "05/09/2026 02:00". Đã dựng lại được
     bằng probe JSP trên Tomcat 10.1.60 ngày 06/10/2026. --%>
<fmt:setLocale value="vi_VN" />

<c:set var="pageTitle" value="Chi tiết Thực Tập Sinh" />
<c:set var="activePage" value="interns" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<!-- Thêm thư viện FontAwesome -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<div class="container-fluid mt-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 mb-0">Hồ Sơ Thực Tập Sinh: <c:out value="${profile.fullName}" /></h2>
        <a href="${pageContext.request.contextPath}/hr/interns" class="btn btn-outline-secondary shadow-sm">
            <i class="fas fa-arrow-left me-1"></i>Quay lại danh sách
        </a>
    </div>

    <div class="row">
        <!-- Thông tin tóm tắt bên trái (FE2 Layout + BE2 Action) -->
        <div class="col-lg-4 col-md-5 mb-4">
            <div class="card shadow-sm mb-4 border-0">
                <div class="card-body text-center p-4">
                    <div class="bg-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3 fw-bold shadow" style="width: 80px; height: 80px; font-size: 1.8rem;">
                        <c:choose>
                            <c:when test="${not empty profile.fullName}">
                                <c:out value="${fn:toUpperCase(fn:substring(profile.fullName, 0, 1))}" />
                            </c:when>
                            <c:otherwise>TTS</c:otherwise>
                        </c:choose>
                    </div>
                    <h5 class="card-title fw-bold mb-1"><c:out value="${profile.fullName}" /></h5>
                    <p class="text-muted small mb-2"><c:out value="${profile.email}" /></p>
                    <div class="mb-3">
                        <c:choose>
                            <c:when test="${profile.status == 'ACTIVE'}">
                                <span class="badge bg-success">Đang thực tập</span>
                            </c:when>
                                <c:when test="${profile.status == 'PENDING'}">
                                    <span class="badge bg-warning text-dark">Chờ duyệt</span>
                                </c:when>
                                <c:when test="${profile.status == 'APPROVED'}">
                                    <span class="badge bg-info text-dark">Đã duyệt</span>
                                </c:when>
                                <c:when test="${profile.status == 'REJECTED'}">
                                    <span class="badge bg-danger">Đã từ chối</span>
                                </c:when>
                                <c:when test="${profile.status == 'INACTIVE'}">
                                    <span class="badge bg-secondary">Tạm dừng</span>
                                </c:when>

                            <c:otherwise>
                                <span class="badge bg-secondary"><c:out value="${profile.status}" /></span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Nút chuyển trạng thái hồ sơ (BE2 Logic) -->
                    <!-- QA-05: truoc day POST /intern/profile nen AuthorizationFilter
                         chan HR (yeu cau role INTERN cho /intern/*) -> 403 truoc khi
                         toi handler. /hr/intern-detail nam trong khu vuc HR; doPost cua
                         InternProfileServlet kiem tra action=update_status TRUOC cac
                         nhanh khac nen van vao handleUpdateStatus, va handler tu kiem
                         tra HR/Admin. KHONG mo quyen HR cho toan bo /intern/*. -->
                    <div class="border-top pt-3">
                        <form action="${pageContext.request.contextPath}/hr/intern-detail" method="post">
                            <input type="hidden" name="action" value="update_status">
                            <input type="hidden" name="profileId" value="<c:out value="${profile.profileId}" />">
                            <input type="hidden" name="status" value="${profile.status == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE'}">
                            <button type="submit" class="btn btn-sm ${profile.status == 'ACTIVE' ? 'btn-outline-danger' : 'btn-outline-success'} w-100">
                                <i class="fas fa-sync-alt me-1"></i>Chuyển sang ${profile.status == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE'}
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- Chi tiết hồ sơ bên phải (FE2 Layout + BE2 Data & Forms) -->
        <div class="col-lg-8 col-md-7">
            <!-- Thông tin chi tiết cá nhân & học vấn -->
            <div class="card shadow-sm mb-4 border-0">
                <div class="card-header bg-white fw-bold py-3 border-bottom d-flex justify-content-between align-items-center">
                    <div>
                        <i class="fas fa-address-card me-2 text-primary"></i>Thông tin chi tiết hồ sơ (#${profile.profileId})
                    </div>
                    <!-- Nút mở Modal Cập nhật hồ sơ (US02) -->
                    <button class="btn btn-sm btn-primary shadow-sm" data-bs-toggle="modal" data-bs-target="#editProfileModal">
                        <i class="fas fa-edit me-1"></i>Chỉnh sửa hồ sơ
                    </button>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-sm-4 text-muted">Họ và tên:</div>
                        <div class="col-sm-8 fw-semibold"><c:out value="${profile.fullName}" /></div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-sm-4 text-muted">Ngày sinh:</div>
                        <div class="col-sm-8"><c:out value="${profile.dob}" /></div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-sm-4 text-muted">Giới tính:</div>
                        <div class="col-sm-8"><c:out value="${profile.gender}" /></div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-sm-4 text-muted">Số điện thoại:</div>
                        <div class="col-sm-8"><c:out value="${profile.phone}" /></div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-sm-4 text-muted">Email liên hệ:</div>
                        <div class="col-sm-8"><c:out value="${profile.email}" /></div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-sm-4 text-muted">Trường Đại học/Cao đẳng:</div>
                        <div class="col-sm-8 fw-semibold"><c:out value="${profile.university}" /></div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-sm-4 text-muted">Chuyên ngành:</div>
                        <div class="col-sm-8"><c:out value="${profile.major}" /></div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-sm-4 text-muted">Điểm GPA:</div>
                        <div class="col-sm-8">
                            <span class="badge ${profile.gpa >= 3.2 ? 'bg-success' : 'bg-primary'} fs-6">
                                <c:out value="${profile.gpa != null ? profile.gpa : 'N/A'}" />
                            </span>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-sm-4 text-muted">Kỹ năng chuyên môn:</div>
                        <div class="col-sm-8"><c:out value="${profile.skills}" /></div>
                    </div>
                    <div class="row">
                        <div class="col-sm-4 text-muted">Trạng thái hồ sơ:</div>
                        <div class="col-sm-8">
                            <span class="badge ${profile.status == 'ACTIVE' ? 'bg-success' : 'bg-secondary'}">
                                <c:choose>
                                    <c:when test="${profile.status == 'PENDING'}">Chờ duyệt</c:when>
                                    <c:when test="${profile.status == 'APPROVED'}">Đã duyệt</c:when>
                                    <c:when test="${profile.status == 'REJECTED'}">Đã từ chối</c:when>
                                    <c:when test="${profile.status == 'ACTIVE'}">Đang thực tập</c:when>
                                    <c:when test="${profile.status == 'INACTIVE'}">Tạm dừng</c:when>
                                    <c:otherwise><c:out value="${profile.status}" /></c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Card Tài liệu & Hợp đồng (US05, US09) -->
            <div class="card shadow-sm mb-4 border-0">
                <div class="card-header bg-white pt-3 pb-0 border-bottom">
                    <ul class="nav nav-tabs border-bottom-0" id="docContractTab" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active fw-bold" style="color: #4e73df;" id="docs-tab" data-bs-toggle="tab" data-bs-target="#docs" type="button" role="tab" aria-controls="docs" aria-selected="true">
                                <i class="fas fa-file-alt me-1"></i>Duyệt tài liệu (US05)
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fw-bold text-success" id="contract-tab" data-bs-toggle="tab" data-bs-target="#contract" type="button" role="tab" aria-controls="contract" aria-selected="false">
                                <i class="fas fa-file-signature me-1"></i>Hợp đồng (US09)
                            </button>
                        </li>
                    </ul>
                </div>
                <div class="card-body">
                    <div class="tab-content" id="docContractTabContent">
                        <!-- Tab Duyệt Tài Liệu -->
                        <div class="tab-pane fade show active" id="docs" role="tabpanel" aria-labelledby="docs-tab">
                            <h6 class="mb-3 text-secondary"><i class="fas fa-list me-1"></i>Danh sách tài liệu đã nộp</h6>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0 border rounded">
                                    <thead class="table-light">
                                        <tr>
                                            <th class="ps-3">Tên file</th>
                                            <th>Loại tài liệu</th>
                                            <th>Trạng thái</th>
                                            <th class="text-center pe-3">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="doc" items="${documents}">
                                            <tr>
                                                <td class="ps-3">
                                                    <i class="fas fa-file text-primary me-2 fs-5"></i>
                                                    <a href="${pageContext.request.contextPath}/document/download?id=${doc.documentId}" target="_blank" class="text-decoration-none"><strong><c:out value="${doc.fileName}" /></strong></a>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${doc.documentType == 'CV'}">CV / sơ yếu lý lịch</c:when>
                                                        <c:when test="${doc.documentType == 'APPLICATION_LETTER'}">Đơn xin thực tập</c:when>
                                                        <c:when test="${doc.documentType == 'OTHER'}">Tài liệu khác</c:when>
                                                        <c:otherwise><c:out value="${doc.documentType}" /></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${doc.status == 'PENDING'}">
                                                            <span class="badge bg-warning text-dark">Chờ duyệt</span>
                                                        </c:when>
                                                        <c:when test="${doc.status == 'APPROVED'}">
                                                            <span class="badge bg-success">Đã duyệt</span>
                                                        </c:when>
                                                        <c:when test="${doc.status == 'REJECTED'}">
                                                            <span class="badge bg-danger">Đã từ chối</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary"><c:out value="${doc.status}" /></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <%-- QA-03: truoc day tai lieu REJECTED van hien badge
                                                         xanh "REJECTED" va khong co ly do. Nay hien ly do
                                                         + thoi diem xu ly de HR biet vi sao da tu choi. --%>
                                                    <c:if test="${doc.status == 'REJECTED' and not empty doc.rejectReason}">
                                                        <div class="small text-danger mt-1">Lý do: <c:out value="${doc.rejectReason}" /></div>
                                                    </c:if>
                                                    <c:if test="${not empty doc.reviewedAt}">
                                                        <div class="small text-muted">
                                                            Xử lý: <fmt:formatDate value="${doc.reviewedAt}" pattern="dd/MM/yyyy HH:mm" />
                                                        </div>
                                                    </c:if>
                                                </td>
                                                <td class="text-center pe-3">
                                                    <c:choose>
                                                        <c:when test="${doc.status == 'PENDING'}">
                                                            <!-- Form Duyệt tài liệu -->
                                                            <form action="${pageContext.request.contextPath}/document/review" method="POST" style="display: inline-block; margin-bottom: 0;">
                                                                <input type="hidden" name="documentId" value="${doc.documentId}">
                                                                <input type="hidden" name="action" value="approve">
                                                                <button type="submit" class="btn btn-sm btn-success shadow-sm me-1" title="Duyệt">
                                                                    <i class="fas fa-check me-1"></i>Duyệt
                                                                </button>
                                                            </form>

                                                            <!-- QA-03: nut Tu choi mo modal de nhap ly do bat buoc.
                                                                 Truoc day form gui thang documentId + action=reject
                                                                 nhung khong co rejectReason nen
                                                                 DocumentService#rejectDocument tu choi request va
                                                                 tai lieu van PENDING. -->
                                                            <button type="button" class="btn btn-sm btn-danger shadow-sm" title="Từ chối"
                                                                    data-bs-toggle="modal" data-bs-target="#rejectDocModal"
                                                                    data-doc-id="${doc.documentId}"
                                                                    data-doc-name="<c:out value="${doc.fileName}" />">
                                                                <i class="fas fa-times me-1"></i>Từ chối
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button class="btn btn-sm btn-outline-secondary" disabled>
                                                                <i class="fas fa-check-circle me-1"></i>Đã xử lý
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty documents}">
                                            <tr>
                                                <td colspan="4" class="text-center py-4 text-muted">
                                                    <i class="fas fa-folder-open fs-3 d-block mb-2 text-light"></i>
                                                    Không có tài liệu nào.
                                                </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Tab Hợp đồng -->
                        <div class="tab-pane fade" id="contract" role="tabpanel" aria-labelledby="contract-tab">
                            <%-- QA-04: DocumentUploadServlet#handleUploadContract CAN
                                 applicationId (khong phai profileId) va chi nhan don
                                 APPROVED. handleViewProfileDetail cua BE2 hien chi tra
                                 ve `contract`, nen applicationId suy ra tu
                                 contract.applicationId - tuc chi co khi ho so DA co
                                 hop dong. Lan upload DAU TIEN van can BE2 truyen them
                                 Application da duyet sang view. --%>
                            <c:choose>
                                <c:when test="${not empty contract}">
                                    <h6 class="mb-3 text-secondary"><i class="fas fa-file-signature me-1"></i>Hợp đồng hiện tại</h6>
                                    <ul class="list-unstyled mb-4">
                                        <li class="mb-1"><span class="text-muted">Mã đơn ứng tuyển:</span> <strong>#<c:out value="${contract.applicationId}" /></strong></li>
                                        <li class="mb-1"><span class="text-muted">Tên file:</span> <strong><c:out value="${contract.fileName}" /></strong></li>
                                        <li class="mb-1">
                                            <span class="text-muted">Trạng thái:</span>
                                            <c:choose>
                                                <c:when test="${contract.status == 'CONFIRMED'}">
                                                    <span class="badge bg-success">TTS đã xác nhận</span>
                                                </c:when>
                                                <c:when test="${contract.status == 'PENDING_CONFIRMATION'}">
                                                    <span class="badge bg-warning text-dark">Chờ TTS xác nhận</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary"><c:out value="${contract.status}" /></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </li>
                                        <c:if test="${not empty contract.uploadedAt}">
                                            <li class="mb-1"><span class="text-muted">Ngày tải lên:</span> <fmt:formatDate value="${contract.uploadedAt}" pattern="dd/MM/yyyy HH:mm" /></li>
                                        </c:if>
                                        <c:if test="${not empty contract.confirmedAt}">
                                            <li class="mb-1"><span class="text-muted">Ngày TTS xác nhận:</span> <fmt:formatDate value="${contract.confirmedAt}" pattern="dd/MM/yyyy HH:mm" /></li>
                                        </c:if>
                                    </ul>

                                    <c:choose>
                                        <c:when test="${contract.status == 'CONFIRMED'}">
                                            <%-- DocumentService#saveContract chan ghi de ban CONFIRMED,
                                                 nen khong hien form de HR khong bam vao roi nhan loi. --%>
                                            <div class="alert alert-info mb-0">
                                                <i class="fas fa-lock me-1"></i>
                                                Hợp đồng đã được thực tập sinh xác nhận nên không thể thay thế trong Sprint 2.
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <h6 class="mb-3 text-secondary"><i class="fas fa-cloud-upload-alt me-1"></i>Thay hợp đồng</h6>
                                            <form action="${pageContext.request.contextPath}/contract/upload" method="POST" enctype="multipart/form-data">
                                                <input type="hidden" name="applicationId" value="<c:out value="${contract.applicationId}" />">
                                                <input type="hidden" name="redirectUrl" value="${pageContext.request.contextPath}/hr/intern-detail?id=<c:out value="${profile.profileId}" />">
                                                <div class="row g-3">
                                                    <div class="col-md-12">
                                                        <label class="form-label fw-semibold">File hợp đồng đính kèm <span class="text-danger">*</span></label>
                                                        <input type="file" class="form-control" name="contractFile" accept=".pdf,.doc,.docx" required>
                                                        <div class="form-text">Định dạng hỗ trợ: PDF, DOC, DOCX. Tối đa 5MB.</div>
                                                    </div>
                                                    <div class="col-12 mt-4 text-end">
                                                        <button type="submit" class="btn btn-success px-4 shadow-sm">
                                                            <i class="fas fa-upload me-2"></i>Tải lên Hợp đồng
                                                        </button>
                                                    </div>
                                                </div>
                                            </form>
                                        </c:otherwise>
                                    </c:choose>
                                </c:when>
                                <c:otherwise>
                                    <div class="alert alert-warning mb-0">
                                        <i class="fas fa-triangle-exclamation me-1"></i>
                                        Hồ sơ này chưa có hợp đồng nên chưa xác định được đơn ứng tuyển đã duyệt.
                                        Việc tải lên hợp đồng đầu tiên đang chờ BE2 truyền mã đơn APPROVED sang trang
                                        chi tiết (QA-04). HR tạm thời tải lên từ màn hình có sẵn mã đơn.
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal Cập nhật hồ sơ (US02) -->
<div class="modal fade" id="editProfileModal" tabindex="-1" aria-labelledby="editProfileModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <%-- QA-02: POST /hr/interns/edit de doPost cua InternProfileServlet
                 re vao handleHrEditProfile (whitelist HR). Truoc day form POST
                 /hr/intern-detail khong co action nen roi vao handleSaveProfile
                 (luong TTS) va bao thieu email. --%>
            <form action="${pageContext.request.contextPath}/hr/interns/edit" method="POST">
                <div class="modal-header bg-light">
                    <h5 class="modal-title fw-bold" id="editProfileModalLabel">
                        <i class="fas fa-user-edit me-2 text-primary"></i>Cập nhật thông tin Thực tập sinh
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <!-- RÀNG BUỘC BẢO MẬT: CHỈ CÓ profileId LÀ TRƯỜNG ẨN DUY NHẤT -->
                    <!-- TUYỆT ĐỐI KHÔNG chứa thông tin về Role, UserID, hay Application Status -->
                    <input type="hidden" name="profileId" value="<c:out value="${profile.profileId}" />">

                    <div class="row g-3">
                        <!-- Nhóm thông tin cá nhân -->
                        <div class="col-12">
                            <h6 class="fw-bold border-bottom pb-2 mb-2 text-secondary"><i class="fas fa-info-circle me-1"></i>Thông tin cá nhân</h6>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Họ và tên <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="fullName" value="<c:out value="${profile.fullName}" />" required maxlength="100">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Ngày sinh</label>
                            <input type="date" class="form-control" name="dob" value="<c:out value="${profile.dob}" />">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Giới tính</label>
                            <%-- QA-02: gender nam trong whitelist cua handleHrEditProfile
                                 (InternProfileService#updateProfileByHr). Bo trong form thi
                                 HR khong bao gio sua duoc gioi tinh sai. --%>
                            <select class="form-select" name="gender">
                                <option value="Nam" ${profile.gender eq 'Nam' ? 'selected' : ''}>Nam</option>
                                <option value="Nữ" ${profile.gender eq 'Nữ' ? 'selected' : ''}>Nữ</option>
                                <option value="Khác" ${profile.gender eq 'Khác' ? 'selected' : ''}>Khác</option>
                            </select>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Số điện thoại <span class="text-danger">*</span></label>
                            <input type="tel" class="form-control" name="phone" value="<c:out value="${profile.phone}" />" required>
                        </div>

                        <div class="col-md-6">
                            <%-- QA-02: email BAT BUOC theo InternProfileService#validateProfile.
                                 Truoc day modal khong co truong nay nen handleSaveProfile/
                                 handleHrEditProfile luon bao "Email là thông tin bắt buộc". --%>
                            <label class="form-label fw-semibold">Email liên hệ <span class="text-danger">*</span></label>
                            <input type="email" class="form-control" name="email" value="<c:out value="${profile.email}" />" required maxlength="150">
                        </div>

                        <!-- Lưu ý: Status KHÔNG thuộc whitelist nên KHÔNG hiển thị và KHÔNG ẩn -->

                        <!-- Nhóm học vấn -->
                        <div class="col-12 mt-4">
                            <h6 class="fw-bold border-bottom pb-2 mb-2 text-secondary"><i class="fas fa-graduation-cap me-1"></i>Học vấn & Kỹ năng</h6>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Trường Đại học/Cao đẳng <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="university" value="<c:out value="${profile.university}" />" required maxlength="150">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Chuyên ngành <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="major" value="<c:out value="${profile.major}" />" required maxlength="100">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Điểm GPA</label>
                            <input type="number" step="0.01" min="0" max="4" class="form-control" name="gpa" value="<c:out value="${profile.gpa}" />">
                        </div>

                        <div class="col-md-12">
                            <label class="form-label fw-semibold">Kỹ năng chuyên môn</label>
                            <textarea class="form-control" name="skills" rows="3" maxlength="1000" placeholder="Ví dụ: Java, Spring Boot, MySQL..."><c:out value="${profile.skills}" /></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-primary px-4"><i class="fas fa-save me-1"></i> Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal Từ chối tài liệu (QA-03) - dung chung cho moi dong PENDING,
     JS ben duoi nap documentId + ten file theo nut vua bam. -->
<div class="modal fade" id="rejectDocModal" tabindex="-1" aria-labelledby="rejectDocModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <form action="${pageContext.request.contextPath}/document/review" method="POST">
                <div class="modal-header bg-light">
                    <h5 class="modal-title fw-bold" id="rejectDocModalLabel">
                        <i class="fas fa-times-circle me-2 text-danger"></i>Từ chối tài liệu
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <input type="hidden" name="documentId" value="">
                    <input type="hidden" name="action" value="reject">
                    <input type="hidden" name="redirectUrl" value="${pageContext.request.contextPath}/hr/intern-detail?id=<c:out value="${profile.profileId}" />">

                    <p class="mb-3">Tài liệu: <strong id="rejectDocName">-</strong></p>

                    <label class="form-label fw-semibold" for="rejectReason">Lý do từ chối <span class="text-danger">*</span></label>
                    <textarea class="form-control" id="rejectReason" name="rejectReason" rows="3" maxlength="500" required
                              placeholder="Ví dụ: Bản CV thiếu thông tin liên hệ, vui lòng nộp lại."></textarea>
                    <div class="form-text">Lý do bắt buộc - DocumentService#rejectDocument từ chối request không có lý do.</div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-danger px-4"><i class="fas fa-paper-plane me-1"></i>Xác nhận từ chối</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // QA-03: nap documentId va ten file vao modal Tu choi theo nut vua bam.
    (function () {
        var rejectModal = document.getElementById('rejectDocModal');
        if (!rejectModal) {
            return;
        }
        rejectModal.addEventListener('show.bs.modal', function (event) {
            var button = event.relatedTarget;
            rejectModal.querySelector('[name="documentId"]').value = button.getAttribute('data-doc-id') || '';
            document.getElementById('rejectDocName').textContent = button.getAttribute('data-doc-name') || '-';
            document.getElementById('rejectReason').value = '';
        });
    })();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
