package com.internship.controller;

import com.internship.model.*;
import com.internship.service.*;
import com.internship.util.CsrfToken;
import com.internship.util.UserRoleChecks;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.*;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.logging.*;

/** JSON endpoints only. FE1/FE2 own the screens; form-encoded POST follows shared CSRF contract. */
@WebServlet({"/api/hr/work-schedules", "/api/intern/work-schedules",
             "/api/hr/leave-requests", "/api/intern/leave-requests"})
public class ScheduleLeaveServlet extends HttpServlet {
    private static final Logger LOG = Logger.getLogger(ScheduleLeaveServlet.class.getName());
    private final ScheduleLeaveService service;
    public ScheduleLeaveServlet() { this(new ScheduleLeaveService()); }
    public ScheduleLeaveServlet(ScheduleLeaveService service) { this.service = Objects.requireNonNull(service); }

    @Override protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        handle(request, response, false);
    }
    @Override protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8"); handle(request, response, true);
    }

    private void handle(HttpServletRequest request, HttpServletResponse response, boolean write) throws IOException {
        response.setCharacterEncoding("UTF-8"); response.setContentType("application/json");
        response.setHeader("Cache-Control", "no-store");
        try {
            HttpSession session = request.getSession(false);
            Object attribute = session == null ? null : session.getAttribute("currentUser");
            User actor = attribute instanceof User user ? user : null;
            if (actor == null) throw new ScheduleLeaveException(401, "UNAUTHENTICATED", "Vui lòng đăng nhập.");
            boolean hrRoute = request.getServletPath().startsWith("/api/hr/");
            if (actor.getStatus() != UserStatus.ACTIVE || (hrRoute ? !UserRoleChecks.canManageHr(actor) : !UserRoleChecks.isIntern(actor)))
                throw new ScheduleLeaveException(403, "FORBIDDEN", "Không có quyền truy cập.");
            if (write && !CsrfToken.valid(request))
                throw new ScheduleLeaveException(403, "INVALID_CSRF", "Phiên biểu mẫu không hợp lệ.");
            boolean schedule = request.getServletPath().endsWith("work-schedules");
            Object data;
            if (!write) {
                if ("interns".equals(request.getParameter("action"))) {
                    try (Connection c = com.internship.util.DBContext.getConnection()) {
                        data = new com.internship.dao.ScheduleEnrollmentDAO().listEnrolledInterns(c).stream().map(i -> Be4Json.fields(
                                "enrollmentId", i.enrollmentId() == 0 ? null : i.enrollmentId(),
                                "email", i.email(),
                                "fullName", i.fullName(),
                                "university", i.university(),
                                "major", i.major(),
                                "phone", i.phone(),
                                "programName", i.programName(),
                                "programId", i.programId(),
                                "status", i.status()
                        )).toList();
                    } catch (SQLException e) {
                        data = Collections.emptyList();
                    }
                } else {
                    Map<Integer, String> emailMap = Collections.emptyMap();
                    try (Connection c = com.internship.util.DBContext.getConnection()) {
                        emailMap = new com.internship.dao.ScheduleEnrollmentDAO().getEnrollmentEmailMap(c);
                    } catch (Exception ignored) {}
                    final Map<Integer, String> fEmails = emailMap;
                    Integer enrollment = optionalId(request, "enrollmentId");
                    if (enrollment == null && request.getParameter("email") != null) {
                        try (Connection c = com.internship.util.DBContext.getConnection()) {
                            enrollment = new com.internship.dao.ScheduleEnrollmentDAO().findEnrollmentIdByEmail(request.getParameter("email"), c);
                        } catch (Exception ignored) {}
                    }
                    Integer program = optionalId(request, "programId");
                    LocalDate from = date(request, "from"), to = date(request, "to");
                    data = schedule
                            ? service.schedules(actor, enrollment, program, from, to).stream().map(s -> schedule(s, fEmails.get(s.enrollmentId()))).toList()
                            : service.leaves(actor, enrollment, program, optional(request, "status"), from, to).stream().map(l -> leave(l, fEmails.get(l.enrollmentId()))).toList();
                }
            } else {
                String action = request.getParameter("action");
                if (schedule) {
                    if (!hrRoute) throw new ScheduleLeaveException(403, "FORBIDDEN", "TTS chỉ được xem lịch.");
                    data = switch (action == null ? "" : action) {
                        case "create" -> Be4Json.fields("scheduleId", service.createSchedule(actor, resolveEnrollment(request),
                                date(request, "workDate"), time(request, "startTime"), time(request, "endTime"), request.getParameter("note")));
                        case "bulk-create" -> service.createSchedules(actor, ids(request), date(request, "workDate"),
                                time(request, "startTime"), time(request, "endTime"), request.getParameter("note")).stream()
                                .map(r -> Be4Json.fields("enrollmentId", r.enrollmentId(), "scheduleId", r.scheduleId(),
                                        "success", r.success(), "errorCode", r.errorCode())).toList();
                        case "update" -> {
                            service.updateSchedule(actor, id(request, "scheduleId"), date(request, "workDate"),
                                    time(request, "startTime"), time(request, "endTime"), request.getParameter("note")); yield null;
                        }
                        case "cancel" -> { service.cancelSchedule(actor, id(request, "scheduleId")); yield null; }
                        default -> throw invalid();
                    };
                } else if (!hrRoute && "create".equals(action)) {
                    data = Be4Json.fields("leaveId", service.requestLeave(actor, id(request, "enrollmentId"),
                            date(request, "fromDate"), date(request, "toDate"), request.getParameter("reason")));
                } else if (hrRoute && ("approve".equals(action) || "reject".equals(action))) {
                    service.decideLeave(actor, id(request, "leaveId"), "approve".equals(action), request.getParameter("rejectReason"));
                    data = null;
                } else throw invalid();
            }
            int status = write && "create".equals(request.getParameter("action")) ? 201 : 200;
            boolean success = true;
            if (write && schedule && "bulk-create".equals(request.getParameter("action"))) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> results = (List<Map<String, Object>>) data;
                long saved = results.stream().filter(item -> Boolean.TRUE.equals(item.get("success"))).count();
                success = saved == results.size();
                data = Be4Json.fields("results", results, "successCount", saved,
                        "failureCount", results.size() - saved, "allSucceeded", success);
                if (!success) status = 207;
            }
            response.setStatus(status);
            response.getWriter().write(Be4Json.stringify(Be4Json.fields("success", success, "data", data,
                    "csrfToken", CsrfToken.expose(request), "timezone", ScheduleLeaveService.BUSINESS_ZONE.getId())));
        } catch (ScheduleLeaveException e) {
            error(response, e.status(), e.code(), e.getMessage());
        } catch (DateTimeParseException | NumberFormatException e) {
            error(response, 400, "VALIDATION_ERROR", "Sai định dạng ngày, giờ hoặc mã dữ liệu.");
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Schedule/leave database operation failed", e);
            error(response, 503, "DATABASE_ERROR", "Không thể xử lý dữ liệu, vui lòng thử lại.");
        }
    }

    static Map<String, Object> schedule(WorkSchedule s) {
        return schedule(s, null);
    }
    static Map<String, Object> schedule(WorkSchedule s, String email) {
        return Be4Json.fields("scheduleId", s.scheduleId(), "enrollmentId", s.enrollmentId(),
                "internEmail", email,
                "workDate", s.workDate(), "startTime", s.startTime(), "endTime", s.endTime(),
                "note", s.note(), "status", s.status(), "internName", s.internName(),
                "programName", s.programName(), "approvedLeave", s.approvedLeave());
    }
    static Map<String, Object> leave(LeaveRequest l) {
        return leave(l, null);
    }
    static Map<String, Object> leave(LeaveRequest l, String email) {
        return Be4Json.fields("leaveId", l.leaveId(), "enrollmentId", l.enrollmentId(),
                "internEmail", email,
                "fromDate", l.fromDate(), "toDate", l.toDate(), "reason", l.reason(), "status", l.status(),
                "reviewedBy", l.reviewedBy(), "reviewedAt", l.reviewedAt() == null ? null : l.reviewedAt().toString(),
                "rejectReason", l.rejectReason(), "createdAt", l.createdAt().toString(),
                "internName", l.internName(), "programName", l.programName());
    }
    private static void error(HttpServletResponse response, int status, String code, String message) throws IOException {
        response.setStatus(status);
        response.getWriter().write(Be4Json.stringify(Be4Json.fields("success", false,
                "error", Be4Json.fields("code", code, "message", message))));
    }
    private static String optional(HttpServletRequest r, String key) {
        String value = r.getParameter(key); return value == null || value.isBlank() ? null : value.trim();
    }
    private static Integer optionalId(HttpServletRequest r, String key) {
        String value = optional(r, key); return value == null ? null : Integer.valueOf(value);
    }
    private static int id(HttpServletRequest r, String key) {
        Integer value = optionalId(r, key); if (value == null) throw invalid(); return value;
    }
    private static int resolveEnrollment(HttpServletRequest r) {
        Integer id = optionalId(r, "enrollmentId");
        if (id != null && id > 0) return id;
        String email = optional(r, "internEmail");
        if (email == null) email = optional(r, "email");
        if (email != null && !email.isBlank()) {
            try (Connection c = com.internship.util.DBContext.getConnection()) {
                Integer resolved = new com.internship.dao.ScheduleEnrollmentDAO().findEnrollmentIdByEmail(email, c);
                if (resolved != null) return resolved;
            } catch (SQLException ignored) {}
            throw new ScheduleLeaveException(400, "NOT_ENROLLED", "Không tìm thấy chương trình thực tập đang hiệu lực cho Gmail: " + email);
        }
        return id(r, "enrollmentId");
    }
    private static LocalDate date(HttpServletRequest r, String key) {
        String value = optional(r, key); if (value == null) throw invalid(); return LocalDate.parse(value);
    }
    private static LocalTime time(HttpServletRequest r, String key) {
        String value = optional(r, key); if (value == null) throw invalid(); return LocalTime.parse(value);
    }
    private static List<Integer> ids(HttpServletRequest r) {
        String value = optional(r, "enrollmentIds"); if (value == null) throw invalid();
        com.internship.dao.ScheduleEnrollmentDAO dao = new com.internship.dao.ScheduleEnrollmentDAO();
        List<Integer> list = new ArrayList<>();
        Connection conn = null;
        try {
            conn = com.internship.util.DBContext.getConnection();
        } catch (Exception ignored) {}
        try {
            for (String item : value.split(",", -1)) {
                String token = item.trim();
                if (token.isEmpty()) continue;
                if (token.matches("^[0-9]+$")) {
                    list.add(Integer.valueOf(token));
                } else if (token.contains("@") && conn != null) {
                    try {
                        Integer resolved = dao.findEnrollmentIdByEmail(token, conn);
                        list.add(resolved != null ? resolved : 999999);
                    } catch (SQLException e) {
                        list.add(999999);
                    }
                } else {
                    list.add(Integer.valueOf(token));
                }
            }
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (Exception ignored) {}
            }
        }
        return list;
    }
    private static ScheduleLeaveException invalid() {
        return new ScheduleLeaveException(400, "VALIDATION_ERROR", "Thiếu tham số hoặc hành động không hợp lệ.");
    }
}
