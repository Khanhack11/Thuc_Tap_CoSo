<%--
    sidebar.jsp - Menu điều hướng theo role. Owner: FE1

    Quy ước:
    - Trang đặt <c:set var="activePage" value="..."/> TRƯỚC khi include header.
    - Mục chưa có route thật (BE/FE khác chưa làm xong) render bằng
      <span class="app-nav__link is-soon">, KHÔNG dùng <a> để tránh link chết 404.
      Khi route sẵn sàng thì đổi span thành a và bỏ class is-soon.

    ============================================================================
    HỢP ĐỒNG SESSION VỚI BE1 - KHÔNG ĐƯỢC ĐỔI TÊN
    ----------------------------------------------------------------------------
    LoginServlet đặt vào session:
        currentUser : com.internship.model.User
        currentRole : String - "ADMIN" | "HR" | "MENTOR" | "INTERN"

    User của BE1 KHÔNG có isAdmin()/isHR()/isIntern().
    Nên TUYỆT ĐỐI không viết ${sessionScope.currentUser.admin} -> ném
    PropertyNotFoundException -> HTTP 500.

    Lấy role: dùng currentRole (đã chốt với BE1 ngày 28/09/2026). KHÔNG dùng
    ${sessionScope.currentUser.role.roleName} - hiện cho cùng kết quả
    (currentRole = user.getRole().getRoleName()) nhưng không phải key đã chốt,
    và sẽ lệch nếu cách tính currentRole ở LoginServlet thay đổi.
        ${sessionScope.currentRole eq 'ADMIN'}

    Trước 28/09/2026 file này đọc sessionScope.user - attribute KHÔNG ai set -
    nên cả 4 khối <c:if> theo role đều false và menu luôn rỗng với mọi role.
    ============================================================================
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<aside class="app-sidebar" id="appSidebar">

    <a class="app-brand" href="${ctx}/">
        <i class="bi bi-mortarboard-fill"></i>
        <span>Internship Manager</span>
    </a>

    <nav class="app-nav" aria-label="Menu chính">

        <%-- ============================ INTERN ============================ --%>
        <c:if test="${sessionScope.currentRole eq 'INTERN'}">

            <div class="app-nav__group">Thực tập của tôi</div>

            <a class="app-nav__link ${activePage eq 'profile' ? 'is-active' : ''}"
               href="${ctx}/intern/profile">
                <i class="bi bi-person-vcard"></i><span>Hồ sơ cá nhân</span>
            </a>

            <%-- /intern/profile phuc vu 2 muc: "Hồ sơ cá nhân" (khong tham so) va
                 muc nay. Truoc day cho nay de nhan "CV và đơn ứng tuyển" nhung
                 activePage='documents' KHONG trang nao set (profile.jsp luon dat
                 'profile' vi #documents khong duoc gui len server), nen bam vao
                 muc nay thi sidebar sang nham "Hồ sơ cá nhân" - trong nhu bam
                 khong co gi xay ra. Nay profile.jsp tu dat 'documents' theo
                 ?view=documents. --%>
            <a class="app-nav__link ${activePage eq 'documents' ? 'is-active' : ''}"
               href="${ctx}/intern/profile?view=documents#documents">
                <i class="bi bi-folder2-open"></i><span>Tài liệu của tôi</span>
            </a>

            <%-- /intern/applications (InternApplicationServlet) - truoc day route nay
                 KHONG co muc nao trong menu, TTS chi vao duoc bang cach go URL.
                 activePage rieng 'intern-applications', KHONG dung 'documents':
                 'documents' thuoc muc "Tài liệu của tôi" o tren. --%>
            <a class="app-nav__link ${activePage eq 'intern-applications' ? 'is-active' : ''}"
               href="${ctx}/intern/applications">
                <i class="bi bi-send"></i><span>Đơn ứng tuyển của tôi</span>
            </a>

            <a class="app-nav__link ${activePage eq 'contract' ? 'is-active' : ''}"
               href="${ctx}/contract/view">
                <i class="bi bi-file-earmark-text"></i><span>Hợp đồng thực tập</span>
            </a>

            <%-- /intern/enrollment (US14) - BE3 da co route tu Sprint 1, BE3 bo sung
                 departmentName/startDate/endDate o Sprint 2. --%>
            <a class="app-nav__link ${activePage eq 'intern-enrollment' ? 'is-active' : ''}"
               href="${ctx}/intern/enrollment">
                <i class="bi bi-calendar3"></i><span>Chương trình thực tập</span>
            </a>

            <div class="app-nav__group">Công việc</div>

            <a class="app-nav__link ${activePage eq 'intern-tasks' ? 'is-active' : ''}"
               href="${ctx}/intern/tasks">
                <i class="bi bi-list-check"></i><span>Nhiệm vụ của tôi</span>
            </a>

            <a class="app-nav__link ${activePage eq 'intern-reports' ? 'is-active' : ''}"
               href="${ctx}/intern/reports">
                <i class="bi bi-journal-text"></i><span>Báo cáo tuần</span>
            </a>

            <a class="app-nav__link ${activePage eq 'intern-evaluation' ? 'is-active' : ''}"
               href="${ctx}/intern/evaluation">
                <i class="bi bi-clipboard-check"></i><span>Đánh giá cuối kỳ</span>
            </a>

            <div class="app-nav__group">Thời gian và quyền lợi</div>

            <%-- ============ Sprint 3 - trang thai tung muc (cap nhat 10/10/2026) ====
                 Quy tac giu nguyen: muc nao CHUA co route THAT thi van la
                 <span class="app-nav__link is-soon">, KHONG doi thanh <a href>.
                 Route co that nhung trang loi thi cung KHONG duoc bat - bam vao
                 se thay mot trang vo nghia, te hon la thay 404.

                     - 21.2 Chấm công        -> /intern/attendance      (BE2)
                          Route CO nhung trang KHONG dung duoc. Da truy den
                          nguyen nhan goc (10/10/2026):
                            AttendanceDAO.java:51
                              "JOIN intern_profiles ip ON pe.intern_id = ip.profile_id"
                            nhung bang program_enrollments KHONG co cot intern_id
                            (cot that la intern_profile_id) -> SQLException
                            "Unknown column 'pe.intern_id'".
                          AttendanceServlet bat (SQLException|IllegalArgumentException)
                          roi FORWARD sang /error/500.jsp -> nguoi dung nhan trang
                          "500 - Lỗi hệ thống" NHUNG ma HTTP van la 200, va servlet
                          KHONG log lai exception (chi set attribute "error" ma
                          trang 500 khong in ra) => rat kho chan doan tu ngoai.
                          Ngoai ra view con: EL rong, dau tieng Viet thanh '?',
                          include sidebar 2 lan (header da co sidebar roi).
                          => GIU "Sắp có", da bao BE2 kem nguyen nhan tren.
                     - 23.3 Lịch làm việc    -> /intern/schedule       (BE3)
                          BE3 moi co JSON /api/intern/work-schedules, KHONG co
                          route tra ve trang -> chua bat duoc.
                     - 24.2 Nghỉ phép        -> /intern/leave-requests (BE3)
                          Nhu tren: chi co JSON, khong co route trang.
                     - 26.2 Phụ cấp          -> /intern/allowances     (BE2)
                          Cung loi y het 21.2: AllowanceDAO.java:41 join
                          "pe.intern_id = ip.profile_id" (cot khong ton tai)
                          -> 500. GIU "Sắp có".
                     - 35.5 Lịch họp         -> /intern/meetings       (BE1)
                          DA BAT. Route InternMeetingPageServlet + view
                          intern/meetings.jsp + intern-meetings.js deu da merge.
                     - 36.2 Thông báo -> /intern/notifications (BE1)
                          Route InternNotificationPageServlet mở view FE1 cho
                          INTERN ACTIVE; dữ liệu đọc từ JSON /notifications.
                 ==================================================================== --%>

            <span class="app-nav__link is-soon" aria-disabled="true">
                <i class="bi bi-clock-history"></i><span>Chấm công</span>
                <span class="app-nav__soon">Sắp có</span>
            </span>

            <span class="app-nav__link is-soon" aria-disabled="true">
                <i class="bi bi-calendar-week"></i><span>Lịch làm việc</span>
                <span class="app-nav__soon">Sắp có</span>
            </span>

            <span class="app-nav__link is-soon" aria-disabled="true">
                <i class="bi bi-calendar-x"></i><span>Nghỉ phép</span>
                <span class="app-nav__soon">Sắp có</span>
            </span>

            <%-- 26.2 Phu cap: da TAT 10/10/2026. Truoc day la <a href> that, nhung
                 /intern/allowances tra ve trang 500 (AllowanceDAO:41 join cot
                 khong ton tai - xem ghi chu dau file). De nguyen link thi bam vao
                 la gap trang loi. Khi BE2 sua DAO thi doi lai thanh <a> nhu cu:
                    <a class="app-nav__link ${activePage eq 'allowances' ? 'is-active' : ''}"
                       href="${ctx}/intern/allowances">
                        <i class="bi bi-cash-coin"></i><span>Phụ cấp</span>
                    </a>
            --%>
            <span class="app-nav__link is-soon" aria-disabled="true">
                <i class="bi bi-cash-coin"></i><span>Phụ cấp</span>
                <span class="app-nav__soon">Sắp có</span>
            </span>

            <div class="app-nav__group">Hỗ trợ và trao đổi</div>

            <a class="app-nav__link ${activePage eq 'support' ? 'is-active' : ''}"
               href="${ctx}/intern/support">
                <i class="bi bi-life-preserver"></i><span>Yêu cầu hỗ trợ</span>
            </a>

            <%-- BE1 da merge InternMeetingPageServlet (@WebServlet("/intern/meetings"))
                 forward sang WEB-INF/views/intern/meetings.jsp. Servlet tu chan:
                 khong co session -> /auth/login, khong phai INTERN ACTIVE -> 403.
                 View doc GET ${ctx}/meetings (JSON) qua intern-meetings.js.
                 activePage 'intern-meetings' do chinh meetings.jsp set. --%>
            <a class="app-nav__link ${activePage eq 'intern-meetings' ? 'is-active' : ''}"
               href="${ctx}/intern/meetings">
                <i class="bi bi-camera-video"></i><span>Lịch họp</span>
            </a>

            <a class="app-nav__link ${activePage eq 'intern-notifications' ? 'is-active' : ''}"
               href="${ctx}/intern/notifications">
                <i class="bi bi-bell"></i><span>Thông báo</span>
            </a>

        </c:if>

        <%-- ============================== HR ============================== --%>
        <%-- ADMIN đi qua nhánh ADMIN bên dưới; AuthorizationFilter cũng cho ADMIN
             qua mọi /hr/*, nên nếu cần menu HR cho ADMIN thì bổ sung có chủ đích. --%>
        <c:if test="${sessionScope.currentRole eq 'HR'}">

            <div class="app-nav__group">Tuyển dụng</div>

            <a class="app-nav__link ${activePage eq 'interns' ? 'is-active' : ''}"
               href="${ctx}/hr/interns">
                <i class="bi bi-people"></i><span>Hồ sơ thực tập sinh</span>
            </a>

            <a class="app-nav__link ${activePage eq 'hr-applications' ? 'is-active' : ''}"
               href="${ctx}/hr/applications">
                <i class="bi bi-inbox"></i><span>Duyệt hồ sơ</span>
            </a>

            <div class="app-nav__group">Chương trình</div>

            <a class="app-nav__link ${activePage eq 'hr-catalog' ? 'is-active' : ''}"
               href="${ctx}/hr/catalog">
                <i class="bi bi-diagram-3"></i><span>Chương trình thực tập</span>
            </a>

            <a class="app-nav__link ${activePage eq 'hr-enrollments' ? 'is-active' : ''}"
               href="${ctx}/hr/enrollments">
                <i class="bi bi-person-plus"></i><span>Ghi danh thực tập</span>
            </a>

            <a class="app-nav__link ${activePage eq 'hr-mentors' ? 'is-active' : ''}"
               href="${ctx}/hr/mentors">
                <i class="bi bi-person-badge"></i><span>Đội ngũ mentor</span>
            </a>

            <a class="app-nav__link ${activePage eq 'hr-mentor-assignments' ? 'is-active' : ''}"
               href="${ctx}/hr/enrollments?ui=mentor">
                <i class="bi bi-person-lines-fill"></i><span>Phân công mentor</span>
            </a>

            <div class="app-nav__group">Thời gian và quyền lợi</div>

            <%-- 21.2 Cham cong (HR) + 26.2 Phu cap (HR): da TAT 10/10/2026, cung ly do
                 nhu muc tuong ung cua Thuc tap sinh - /hr/attendance va
                 /hr/allowances deu tra ve trang 500 (DAO join cot khong ton tai).
                 Truoc day 2 muc nay la <a href> that trong khi ban INTERN cua cung
                 tinh nang da de "Sắp có" -> khong nhat quan. Khi BE2 sua DAO, doi lai:
                    <a class="app-nav__link ${activePage eq 'hr-attendance' ? 'is-active' : ''}"
                       href="${ctx}/hr/attendance">...<span>Chấm công</span></a>
                    <a class="app-nav__link ${activePage eq 'hr-allowances' ? 'is-active' : ''}"
                       href="${ctx}/hr/allowances">...<span>Phụ cấp</span></a>
            --%>
            <span class="app-nav__link is-soon" aria-disabled="true">
                <i class="bi bi-clock-history"></i><span>Chấm công</span>
                <span class="app-nav__soon">Sắp có</span>
            </span>

            <span class="app-nav__link is-soon" aria-disabled="true">
                <i class="bi bi-cash-coin"></i><span>Phụ cấp</span>
                <span class="app-nav__soon">Sắp có</span>
            </span>

            <div class="app-nav__group">Hỗ trợ</div>

            <a class="app-nav__link ${activePage eq 'hr-support' ? 'is-active' : ''}"
               href="${ctx}/hr/support">
                <i class="bi bi-life-preserver"></i><span>Yêu cầu hỗ trợ</span>
            </a>

            <div class="app-nav__group">Báo cáo</div>

            <a class="app-nav__link ${activePage eq 'hr-evaluations' ? 'is-active' : ''}"
               href="${ctx}/hr/evaluations">
                <i class="bi bi-award"></i><span>Kết quả đánh giá</span>
            </a>

            <a class="app-nav__link ${activePage eq 'hr-dashboard' ? 'is-active' : ''}"
               href="${ctx}/hr/dashboard">
                <i class="bi bi-bar-chart"></i><span>Thống kê</span>
            </a>

        </c:if>

        <%-- ============================ MENTOR ============================ --%>
        <c:if test="${sessionScope.currentRole eq 'MENTOR'}">

            <div class="app-nav__group">Hướng dẫn</div>

            <a class="app-nav__link ${activePage eq 'mentor-dashboard' ? 'is-active' : ''}"
               href="${ctx}/mentor/dashboard">
                <i class="bi bi-speedometer2"></i><span>Dashboard và TTS</span>
            </a>

            <a class="app-nav__link ${activePage eq 'mentor-tasks' ? 'is-active' : ''}"
               href="${ctx}/mentor/tasks">
                <i class="bi bi-list-check"></i><span>Giao nhiệm vụ</span>
            </a>

            <div class="app-nav__group">Theo dõi</div>

            <a class="app-nav__link ${activePage eq 'mentor-reports' ? 'is-active' : ''}"
               href="${ctx}/mentor/reports">
                <i class="bi bi-journal-text"></i><span>Báo cáo tuần</span>
            </a>

            <a class="app-nav__link ${activePage eq 'mentor-evaluation' ? 'is-active' : ''}"
               href="${ctx}/mentor/evaluation">
                <i class="bi bi-clipboard-check"></i><span>Đánh giá</span>
            </a>

        </c:if>

        <%-- ============================= ADMIN ============================ --%>
        <c:if test="${sessionScope.currentRole eq 'ADMIN'}">

            <div class="app-nav__group">Quản trị hệ thống</div>

            <a class="app-nav__link ${activePage eq 'hr-mentors' ? 'is-active' : ''}"
               href="${ctx}/hr/mentors">
                <i class="bi bi-person-badge"></i><span>Đội ngũ mentor</span>
            </a>
            <a class="app-nav__link ${activePage eq 'hr-mentor-assignments' ? 'is-active' : ''}"
               href="${ctx}/hr/enrollments?ui=mentor">
                <i class="bi bi-person-lines-fill"></i><span>Phân công mentor</span>
            </a>

            <a class="app-nav__link ${activePage eq 'hr-evaluations' ? 'is-active' : ''}"
               href="${ctx}/hr/evaluations">
                <i class="bi bi-award"></i><span>Kết quả đánh giá</span>
            </a>

            <a class="app-nav__link ${activePage eq 'admin-accounts' ? 'is-active' : ''}"
               href="${ctx}/admin/accounts">
                <i class="bi bi-person-gear"></i><span>Tài khoản nội bộ</span>
            </a>

            <span class="app-nav__link is-soon" aria-disabled="true">
                <i class="bi bi-shield-lock"></i><span>Phân quyền</span>
                <span class="app-nav__soon">Sắp có</span>
            </span>

            <span class="app-nav__link is-soon" aria-disabled="true">
                <i class="bi bi-clock-history"></i><span>Nhật ký hoạt động</span>
                <span class="app-nav__soon">Sắp có</span>
            </span>

        </c:if>

        <%-- Trường hợp chưa đăng nhập hoặc role không xác định --%>
        <c:if test="${empty sessionScope.currentUser}">
            <div class="app-nav__group">Phiên làm việc</div>
            <a class="app-nav__link" href="${ctx}/auth/login">
                <i class="bi bi-box-arrow-in-right"></i><span>Đăng nhập</span>
            </a>
        </c:if>

    </nav>
</aside>
