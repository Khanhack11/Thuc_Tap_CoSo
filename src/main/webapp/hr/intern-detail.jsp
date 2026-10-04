<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
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
                            <c:otherwise>
                                <span class="badge bg-secondary"><c:out value="${profile.status}" /></span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Nút chuyển trạng thái hồ sơ (BE2 Logic) -->
                    <div class="border-top pt-3">
                        <form action="${pageContext.request.contextPath}/intern/profile" method="post">
                            <input type="hidden" name="action" value="update_status">
                            <input type="hidden" name="profileId" value="${profile.profileId}">
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
                                ${profile.gpa != null ? profile.gpa : 'N/A'}
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
                                <c:out value="${profile.status}" />
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
                                        <!-- Mockup Item: Đang chờ duyệt -->
                                        <tr>
                                            <td class="ps-3"><i class="fas fa-file-pdf text-danger me-2 fs-5"></i><strong>NguyenVanA_CV.pdf</strong></td>
                                            <td>Sơ yếu lý lịch (CV)</td>
                                            <td><span class="badge bg-warning text-dark">Chờ duyệt</span></td>
                                            <td class="text-center pe-3">
                                                <button class="btn btn-sm btn-success shadow-sm me-1" title="Duyệt" onclick="alert('Đã DUYỆT tài liệu')">
                                                    <i class="fas fa-check me-1"></i>Duyệt
                                                </button>
                                                <button class="btn btn-sm btn-danger shadow-sm" title="Từ chối" onclick="alert('Đã TỪ CHỐI tài liệu')">
                                                    <i class="fas fa-times me-1"></i>Từ chối
                                                </button>
                                            </td>
                                        </tr>
                                        <!-- Mockup Item: Đã duyệt -->
                                        <tr>
                                            <td class="ps-3"><i class="fas fa-file-word text-primary me-2 fs-5"></i><strong>DonXinThucTap.docx</strong></td>
                                            <td>Đơn xin thực tập</td>
                                            <td><span class="badge bg-success">Đã duyệt</span></td>
                                            <td class="text-center pe-3">
                                                <button class="btn btn-sm btn-outline-secondary" disabled>
                                                    <i class="fas fa-check-circle me-1"></i>Đã xử lý
                                                </button>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Tab Hợp đồng -->
                        <div class="tab-pane fade" id="contract" role="tabpanel" aria-labelledby="contract-tab">
                            <h6 class="mb-3 text-secondary"><i class="fas fa-cloud-upload-alt me-1"></i>Đính kèm hợp đồng thực tập</h6>
                            <form onsubmit="event.preventDefault(); alert('Upload Hợp đồng thành công!');">
                                <div class="row g-3">
                                    <div class="col-md-5">
                                        <label class="form-label fw-semibold">Ngày ký <span class="text-danger">*</span></label>
                                        <input type="date" class="form-control" name="signDate" required>
                                    </div>
                                    <div class="col-md-7">
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
            <form id="editProfileForm" onsubmit="handleEditProfileSubmit(event)">
                <div class="modal-header bg-light">
                    <h5 class="modal-title fw-bold" id="editProfileModalLabel">
                        <i class="fas fa-user-edit me-2 text-primary"></i>Cập nhật thông tin Thực tập sinh
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <!-- RÀNG BUỘC BẢO MẬT: CHỈ CÓ profileId LÀ TRƯỜNG ẨN DUY NHẤT -->
                    <!-- TUYỆT ĐỐI KHÔNG chứa thông tin về Role, UserID, hay Application Status -->
                    <input type="hidden" name="profileId" value="${profile.profileId}">
                    
                    <div class="row g-3">
                        <!-- Nhóm thông tin cá nhân -->
                        <div class="col-12">
                            <h6 class="fw-bold border-bottom pb-2 mb-2 text-secondary"><i class="fas fa-info-circle me-1"></i>Thông tin cá nhân</h6>
                        </div>
                        
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Họ và tên <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="fullName" value="${profile.fullName}" required>
                        </div>
                        
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Ngày sinh</label>
                            <input type="date" class="form-control" name="dob" value="${profile.dob}">
                        </div>
                        
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Số điện thoại <span class="text-danger">*</span></label>
                            <input type="tel" class="form-control" name="phone" value="${profile.phone}" required>
                        </div>
                        
                        <!-- Lưu ý: Email, Giới tính, Status không thuộc whitelist nên KHÔNG hiển thị và KHÔNG ẩn -->

                        <!-- Nhóm học vấn -->
                        <div class="col-12 mt-4">
                            <h6 class="fw-bold border-bottom pb-2 mb-2 text-secondary"><i class="fas fa-graduation-cap me-1"></i>Học vấn & Kỹ năng</h6>
                        </div>
                        
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Trường Đại học/Cao đẳng</label>
                            <input type="text" class="form-control" name="university" value="${profile.university}">
                        </div>
                        
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Chuyên ngành</label>
                            <input type="text" class="form-control" name="major" value="${profile.major}">
                        </div>
                        
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Điểm GPA</label>
                            <input type="number" step="0.01" min="0" max="4" class="form-control" name="gpa" value="${profile.gpa}">
                        </div>
                        
                        <div class="col-md-12">
                            <label class="form-label fw-semibold">Kỹ năng chuyên môn</label>
                            <textarea class="form-control" name="skills" rows="3" placeholder="Ví dụ: Java, Spring Boot, MySQL...">${profile.skills}</textarea>
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

<script>
    function handleEditProfileSubmit(event) {
        event.preventDefault();
        
        // Basic Frontend Validation and Fake Submit
        alert('Dữ liệu hợp lệ! Đã sẵn sàng submit Form HTML để lưu thay đổi hồ sơ (US02) qua Backend.');
        
        // Hide modal on fake success
        const modalEl = document.getElementById('editProfileModal');
        const modal = bootstrap.Modal.getInstance(modalEl);
        if (modal) {
            modal.hide();
        }
    }
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
