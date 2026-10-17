package com.internship.controller;

import com.internship.model.User;
import com.internship.service.AttendanceService;
import com.internship.service.AttendanceService.AttendanceReportRow;
import com.internship.util.UserRoleChecks;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Collections;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import com.internship.util.DBConnection;

@WebServlet({"/intern/attendance", "/hr/attendance"})
public class AttendanceServlet extends HttpServlet {

    private AttendanceService attendanceService;

    public AttendanceServlet() {}

    AttendanceServlet(AttendanceService attendanceService) {
        this.attendanceService = attendanceService;
    }

    @Override
    public void init() {
        if (attendanceService == null) {
            attendanceService = new AttendanceService();
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        String path = req.getServletPath();
        
        try {
            if ("/intern/attendance".equals(path)) {
                if (!UserRoleChecks.isIntern(currentUser)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                    return;
                }
                
                String enrollParam = req.getParameter("enrollmentId");
                String emailParam = req.getParameter("email");
                Integer enrollmentId = null;
                if (enrollParam != null && !enrollParam.trim().isEmpty()) {
                    try {
                        enrollmentId = Integer.parseInt(enrollParam.trim());
                    } catch (NumberFormatException e) { }
                    if (enrollmentId == null && enrollParam.contains("@")) {
                        emailParam = enrollParam.trim();
                    }
                }
                if (enrollmentId == null && emailParam != null && !emailParam.trim().isEmpty()) {
                    enrollmentId = findActiveEnrollmentIdByEmail(emailParam);
                }
                if (enrollmentId == null && currentUser != null) {
                    enrollmentId = findActiveEnrollmentIdByUserId(currentUser.getUserId());
                }
                
                LocalDate from = LocalDate.now().minusDays(30);
                LocalDate to = LocalDate.now();
                try {
                    if (req.getParameter("from") != null && !req.getParameter("from").isEmpty()) {
                        from = LocalDate.parse(req.getParameter("from"));
                    }
                    if (req.getParameter("to") != null && !req.getParameter("to").isEmpty()) {
                        to = LocalDate.parse(req.getParameter("to"));
                    }
                } catch (Exception e) {
                    // use defaults
                }
                
                List<AttendanceReportRow> report = attendanceService.getReport(currentUser, enrollmentId != null && enrollmentId > 0 ? enrollmentId : null, null, from, to);
                Map<String, Object> details = enrollmentId != null && enrollmentId > 0 ? findEnrollmentDetails(enrollmentId) : null;
                req.setAttribute("enrollmentDetails", details);
                req.setAttribute("internEmail", details != null ? details.get("email") : (currentUser != null ? currentUser.getEmail() : null));
                req.setAttribute("report", report);
                req.setAttribute("from", from);
                req.setAttribute("to", to);
                req.setAttribute("enrollmentId", enrollmentId);
                req.getRequestDispatcher("/WEB-INF/views/intern/attendance.jsp").forward(req, resp);
                
            } else if ("/hr/attendance".equals(path)) {
                if (!UserRoleChecks.canManageHr(currentUser)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                    return;
                }
                
                String enrollParam = req.getParameter("enrollmentId");
                Integer enrollmentId = null;
                try {
                    enrollmentId = (enrollParam != null && !enrollParam.trim().isEmpty()) ? Integer.parseInt(enrollParam.trim()) : null;
                } catch (NumberFormatException e) { }

                String emailParam = req.getParameter("email");
                if (emailParam != null) {
                    emailParam = emailParam.trim();
                    if (emailParam.isEmpty()) {
                        emailParam = null;
                    }
                }
                if (enrollmentId == null && enrollParam != null && enrollParam.contains("@")) {
                    emailParam = enrollParam.trim();
                }

                if (enrollmentId == null && emailParam != null) {
                    enrollmentId = findActiveEnrollmentIdByEmail(emailParam);
                } else if (enrollmentId != null && emailParam == null) {
                    Map<String, Object> det = findEnrollmentDetails(enrollmentId);
                    if (det != null && det.get("email") != null) {
                        emailParam = (String) det.get("email");
                    }
                }
                
                String progParam = req.getParameter("programId");
                Integer programId = null;
                try {
                    programId = (progParam != null && !progParam.trim().isEmpty()) ? Integer.parseInt(progParam) : null;
                } catch (NumberFormatException e) { }
                
                LocalDate from = LocalDate.now().minusDays(30);
                LocalDate to = LocalDate.now();
                try {
                    if (req.getParameter("from") != null && !req.getParameter("from").isEmpty()) {
                        from = LocalDate.parse(req.getParameter("from"));
                    }
                    if (req.getParameter("to") != null && !req.getParameter("to").isEmpty()) {
                        to = LocalDate.parse(req.getParameter("to"));
                    }
                } catch (Exception e) { }
                
                String status = req.getParameter("status");
                List<AttendanceReportRow> report;
                if (emailParam != null && enrollmentId == null) {
                    report = Collections.emptyList();
                    req.setAttribute("warning", "Thực tập sinh với email \"" + emailParam + "\" chưa có mã ghi danh hoặc chưa tham gia chương trình thực tập nào.");
                } else {
                    report = attendanceService.getReport(currentUser, enrollmentId, programId, from, to, (status != null && !status.trim().isEmpty()) ? status.trim() : null);
                }

                // Cung MOT payload phuc vu ca hai duong lay du lieu ma FE2 duoc giao:
                // tra thang JSON, hoac nhung vao the <script> cua trang HTML.
                String json = toJson(report);
                if (wantsJson(req)) {
                    writeJson(resp, json);
                    return;
                }
                req.setAttribute("attendanceJson", json);
                req.setAttribute("report", report);
                req.setAttribute("from", from);
                req.setAttribute("to", to);
                req.setAttribute("enrollmentId", enrollmentId);
                req.setAttribute("internEmail", emailParam);
                req.setAttribute("activeInterns", findAllActiveInternsForHr());
                req.setAttribute("programId", programId);
                req.setAttribute("status", status);
                req.getRequestDispatcher("/WEB-INF/views/hr/attendance.jsp").forward(req, resp);
            }
        } catch (SQLException | IllegalArgumentException e) {
            // Client xin JSON thi phai nhan JSON: neu forward sang /error/500.jsp thi
            // ho nhan ve HTML, va loi nhap lieu (khoang > 367 ngay, from > to) bi bao
            // nham thanh 500.
            if (wantsJson(req)) {
                resp.setStatus(e instanceof IllegalArgumentException
                        ? HttpServletResponse.SC_BAD_REQUEST
                        : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                writeJson(resp, "{\"error\":" + quote(e.getMessage()) + "}");
                return;
            }
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/error/500.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!com.internship.util.CsrfToken.valid(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF Token");
            return;
        }

        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        String path = req.getServletPath();
        
        if ("/intern/attendance".equals(path)) {
            String action = req.getParameter("action");
            Integer enrollmentId = null;
            String enrollParam = req.getParameter("enrollmentId");
            if (enrollParam != null && !enrollParam.trim().isEmpty()) {
                try {
                    enrollmentId = Integer.parseInt(enrollParam.trim());
                } catch (NumberFormatException e) { }
            }
            if (enrollmentId == null || enrollmentId <= 0) {
                String emailParam = req.getParameter("email");
                if (emailParam != null && !emailParam.trim().isEmpty()) {
                    enrollmentId = findActiveEnrollmentIdByEmail(emailParam);
                }
            }
            if ((enrollmentId == null || enrollmentId <= 0) && currentUser != null) {
                enrollmentId = findActiveEnrollmentIdByUserId(currentUser.getUserId());
            }
            
            if (enrollmentId == null || enrollmentId <= 0) {
                resp.sendRedirect(req.getContextPath() + "/intern/attendance?error=" + java.net.URLEncoder.encode("Không tìm thấy đợt thực tập đang hoạt động liên kết với tài khoản/Gmail này.", "UTF-8"));
                return;
            }
            
            try {
                if ("checkin".equals(action)) {
                    attendanceService.checkIn(currentUser, enrollmentId);
                    resp.sendRedirect(req.getContextPath() + "/intern/attendance?enrollmentId=" + enrollmentId + "&success=true");
                } else if ("checkout".equals(action)) {
                    attendanceService.checkOut(currentUser, enrollmentId);
                    resp.sendRedirect(req.getContextPath() + "/intern/attendance?enrollmentId=" + enrollmentId + "&success=true");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/intern/attendance?enrollmentId=" + enrollmentId + "&error=" + java.net.URLEncoder.encode("Hành động không hợp lệ", "UTF-8"));
                }
            } catch (SQLException | IllegalArgumentException e) {
                resp.sendRedirect(req.getContextPath() + "/intern/attendance?enrollmentId=" + enrollmentId + "&error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            }
        }
    }

    /** Client xin JSON qua ?format=json, hoac qua header Accept chua application/json. */
    private static boolean wantsJson(HttpServletRequest req) {
        if ("json".equalsIgnoreCase(req.getParameter("format"))) {
            return true;
        }
        String accept = req.getHeader("Accept");
        return accept != null && accept.contains("application/json");
    }

    private static void writeJson(HttpServletResponse resp, String json) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Cache-Control", "no-store");
        resp.getWriter().write(json);
    }

    /**
     * Chuoi JSON nay dung cho CA HAI duong: lam body cua response JSON, va nhung vao
     * the &lt;script id="attendance-data"&gt; cua trang HTML. Vi vay moi '&lt;' duoc escape
     * thanh < de chuoi khong the dong the script som; van la JSON hop le.
     */
    // Package-private (khong phai private) de AttendanceReportJsonTest goi truc tiep,
    // theo dung loi Be4Json + EvaluationSummaryJsonTest da co trong repo.
    static String toJson(List<AttendanceReportRow> rows) {
        StringBuilder out = new StringBuilder(rows.size() * 220 + 2).append('[');
        for (int i = 0; i < rows.size(); i++) {
            AttendanceReportRow r = rows.get(i);
            if (i > 0) {
                out.append(',');
            }
            out.append("{\"enrollmentId\":").append(r.getEnrollmentId())
               .append(",\"internName\":").append(quote(r.getInternName()))
               .append(",\"programName\":").append(quote(r.getProgramName()))
               .append(",\"workDate\":").append(quote(text(r.getWorkDate())))
               .append(",\"startTime\":").append(quote(text(r.getStartTime())))
               .append(",\"endTime\":").append(quote(text(r.getEndTime())))
               .append(",\"checkInTime\":").append(quote(text(r.getCheckInTime())))
               .append(",\"checkOutTime\":").append(quote(text(r.getCheckOutTime())))
               .append(",\"approvedLeave\":").append(r.isApprovedLeave())
               .append(",\"status\":").append(quote(r.getStatus()))
               .append(",\"workedHours\":").append(workedHours(r.getWorkedHours()))
               .append('}');
        }
        return out.append(']').toString();
    }

    private static String text(Object value) {
        return value == null ? null : value.toString();
    }

    /** NaN/vo cuc khong phai JSON hop le, nen quy ve 0.0. */
    private static String workedHours(double value) {
        return (Double.isFinite(value) && value >= 0) ? String.valueOf(value) : "0.0";
    }

    private static String quote(String value) {
        if (value == null) {
            return "null";
        }
        StringBuilder out = new StringBuilder(value.length() + 2).append('"');
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            switch (c) {
                case '"' -> out.append("\\\"");
                case '\\' -> out.append("\\\\");
                case '\n' -> out.append("\\n");
                case '\r' -> out.append("\\r");
                case '\t' -> out.append("\\t");
                case '<' -> out.append("\\u003c");
                default -> {
                    if (c < 0x20) {
                        out.append(String.format("\\u%04x", (int) c));
                    } else {
                        out.append(c);
                    }
                }
            }
        }
        return out.append('"').toString();
    }

    private Integer findActiveEnrollmentIdByUserId(long userId) {
        String sql = """
            SELECT pe.enrollment_id
            FROM users u
            JOIN intern_profiles ip ON ip.user_id = u.user_id
            JOIN program_enrollments pe ON pe.intern_profile_id = ip.profile_id
            JOIN internship_programs p ON p.program_id = pe.program_id
            WHERE u.user_id = ? AND pe.status = 'ACTIVE' AND p.status = 'ACTIVE'
            LIMIT 1
            """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { }
        return null;
    }

    private Integer findActiveEnrollmentIdByEmail(String email) {
        if (email == null || email.trim().isEmpty()) return null;
        String clean = email.trim();
        String sql = """
            SELECT pe.enrollment_id
            FROM users u
            JOIN intern_profiles ip ON ip.user_id = u.user_id
            JOIN program_enrollments pe ON pe.intern_profile_id = ip.profile_id
            LEFT JOIN internship_programs p ON p.program_id = pe.program_id
            WHERE (LOWER(u.email) = LOWER(?) OR LOWER(ip.email) = LOWER(?) OR LOWER(u.username) = LOWER(?))
            ORDER BY (pe.status = 'ACTIVE') DESC, (p.status = 'ACTIVE') DESC, pe.enrollment_id DESC
            LIMIT 1
            """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, clean);
            ps.setString(2, clean);
            ps.setString(3, clean);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { }
        return null;
    }

    private Map<String, Object> findEnrollmentDetails(int enrollmentId) {
        String sql = """
            SELECT pe.enrollment_id, ip.full_name, u.email, u.username, p.program_name, p.program_id
            FROM program_enrollments pe
            JOIN intern_profiles ip ON ip.profile_id = pe.intern_profile_id
            JOIN users u ON u.user_id = ip.user_id
            JOIN internship_programs p ON p.program_id = pe.program_id
            WHERE pe.enrollment_id = ?
            """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, enrollmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("enrollmentId", rs.getInt("enrollment_id"));
                    map.put("fullName", rs.getString("full_name"));
                    map.put("email", rs.getString("email"));
                    map.put("username", rs.getString("username"));
                    map.put("programName", rs.getString("program_name"));
                    map.put("programId", rs.getInt("program_id"));
                    return map;
                }
            }
        } catch (SQLException e) { }
        return null;
    }

    private List<Map<String, Object>> findAllActiveInternsForHr() {
        String sql = """
            SELECT pe.enrollment_id, ip.full_name, COALESCE(u.email, ip.email) AS email, p.program_name
            FROM intern_profiles ip
            JOIN users u ON u.user_id = ip.user_id
            LEFT JOIN program_enrollments pe ON pe.intern_profile_id = ip.profile_id AND pe.status = 'ACTIVE'
            LEFT JOIN internship_programs p ON p.program_id = pe.program_id
            ORDER BY (pe.enrollment_id IS NOT NULL) DESC, ip.full_name ASC
            """;
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                int eid = rs.getInt("enrollment_id");
                map.put("enrollmentId", rs.wasNull() ? null : eid);
                map.put("fullName", rs.getString("full_name"));
                map.put("email", rs.getString("email"));
                map.put("programName", rs.getString("program_name"));
                list.add(map);
            }
        } catch (SQLException e) { }
        return list;
    }
}
