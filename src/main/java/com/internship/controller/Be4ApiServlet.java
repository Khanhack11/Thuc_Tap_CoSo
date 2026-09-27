package com.internship.controller;

import com.internship.model.User;
import com.internship.service.DashboardService;
import com.internship.service.EvaluationService;
import com.internship.service.EnrollmentQueryService;
import com.internship.service.TaskService;
import com.internship.service.WeeklyReportService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

/** JSON endpoints consumed by FE2/FE3. Actor identity always comes from the login session. */
@WebServlet({"/hr/be4/*", "/mentor/be4/*", "/intern/be4/*"})
public class Be4ApiServlet extends HttpServlet {
    private static final String CSRF_KEY = "be4CsrfToken";
    private static final SecureRandom RANDOM = new SecureRandom();

    private TaskService tasks;
    private WeeklyReportService reports;
    private EvaluationService evaluations;
    private DashboardService dashboards;
    private EnrollmentQueryService enrollments;

    @Override
    public void init() {
        tasks = new TaskService();
        reports = new WeeklyReportService();
        evaluations = new EvaluationService();
        dashboards = new DashboardService();
        enrollments = new EnrollmentQueryService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        dispatch(request, response, false);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        dispatch(request, response, true);
    }

    private void dispatch(HttpServletRequest request, HttpServletResponse response, boolean post)
            throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");
        response.setHeader("X-Content-Type-Options", "nosniff");
        try {
            HttpSession session = request.getSession(false);
            if (session == null || !(session.getAttribute("currentUser") instanceof User actor)) {
                send(response, 401, Be4Json.fields("error", "Cần đăng nhập"));
                return;
            }
            String area = request.getServletPath();
            String role = actor.getRole() == null ? null : actor.getRole().getRoleName();
            if (!areaAllowed(area, role)) {
                send(response, 403, Be4Json.fields("error", "Không có quyền truy cập"));
                return;
            }
            String path = request.getPathInfo();
            if (path == null) path = "/";
            if (!post && "/csrf".equals(path)) {
                send(response, 200, Be4Json.fields("csrfToken", csrfToken(session)));
                return;
            }
            if (post) {
                String contentType = request.getContentType();
                if (contentType == null || !contentType.toLowerCase(java.util.Locale.ROOT)
                        .startsWith("application/x-www-form-urlencoded")) {
                    send(response, 415, Be4Json.fields("error", "POST yêu cầu form-urlencoded"));
                    return;
                }
                request.setCharacterEncoding("UTF-8");
                String submitted = request.getHeader("X-CSRF-Token");
                if (submitted == null) submitted = request.getParameter("_csrf");
                if (!csrfValid(session, submitted)) {
                    send(response, 403, Be4Json.fields("error", "CSRF token không hợp lệ"));
                    return;
                }
            }
            Object payload = post ? postPayload(area, path, actor.getUserId(), request)
                    : getPayload(area, path, actor.getUserId(), request);
            send(response, 200, payload);
        } catch (UnknownRoute exception) {
            send(response, 404, Be4Json.fields("error", exception.getMessage()));
        } catch (IllegalArgumentException exception) {
            send(response, 400, Be4Json.fields("error", exception.getMessage()));
        } catch (SecurityException exception) {
            send(response, 403, Be4Json.fields("error", exception.getMessage()));
        } catch (IllegalStateException exception) {
            send(response, 409, Be4Json.fields("error", exception.getMessage()));
        } catch (SQLException exception) {
            getServletContext().log("BE4 database operation failed", exception);
            send(response, 500, Be4Json.fields("error", "Lỗi dữ liệu, vui lòng thử lại"));
        }
    }

    private Object getPayload(String area, String path, long userId, HttpServletRequest request)
            throws SQLException {
        if ("/hr/be4".equals(area) && "/dashboard".equals(path)) {
            return Be4Json.hrDashboard(dashboards.getHrDashboard(userId));
        }
        if ("/mentor/be4".equals(area) && "/dashboard".equals(path)) {
            return Be4Json.mentorDashboard(dashboards.getMentorDashboard(userId));
        }
        if ("/intern/be4".equals(area)) {
            return switch (path) {
                case "/enrollments" -> enrollments.findForIntern(userId).stream()
                        .map(Be4Json::enrollment).toList();
                case "/tasks" -> tasks.findTasksForIntern(userId, intParam(request, "enrollmentId"))
                        .stream().map(Be4Json::task).toList();
                case "/assignments" -> tasks.findAssignmentsForIntern(userId, intParam(request, "enrollmentId"))
                        .stream().map(Be4Json::assignment).toList();
                case "/progress" -> tasks.findProgressHistory(userId, longParam(request, "assignmentId"))
                        .stream().map(Be4Json::progress).toList();
                case "/reports" -> reports.findForIntern(userId, intParam(request, "enrollmentId"))
                        .stream().map(Be4Json::report).toList();
                case "/feedback" -> reports.findFeedback(userId, longParam(request, "reportId"))
                        .stream().map(Be4Json::feedback).toList();
                case "/evaluation" -> Be4Json.nullableEvaluation(
                        evaluations.findForActor(userId, intParam(request, "enrollmentId")));
                default -> throw new UnknownRoute();
            };
        }
        if ("/mentor/be4".equals(area)) {
            return switch (path) {
                case "/enrollments" -> enrollments.findForMentor(userId).stream()
                        .map(Be4Json::enrollment).toList();
                case "/tasks" -> tasks.findTasksForMentor(userId, intParam(request, "enrollmentId"))
                        .stream().map(Be4Json::task).toList();
                case "/assignments" -> tasks.findAssignmentsForMentor(userId, intParam(request, "enrollmentId"))
                        .stream().map(Be4Json::assignment).toList();
                case "/progress" -> tasks.findProgressHistory(userId, longParam(request, "assignmentId"))
                        .stream().map(Be4Json::progress).toList();
                case "/reports" -> reports.findForMentor(userId, intParam(request, "enrollmentId"))
                        .stream().map(Be4Json::report).toList();
                case "/feedback" -> reports.findFeedback(userId, longParam(request, "reportId"))
                        .stream().map(Be4Json::feedback).toList();
                case "/evaluation" -> Be4Json.nullableEvaluation(
                        evaluations.findForActor(userId, intParam(request, "enrollmentId")));
                default -> throw new UnknownRoute();
            };
        }
        if ("/hr/be4".equals(area) && "/evaluation".equals(path)) {
            return Be4Json.nullableEvaluation(
                    evaluations.findForActor(userId, intParam(request, "enrollmentId")));
        }
        throw new UnknownRoute();
    }

    private Object postPayload(String area, String path, long userId, HttpServletRequest request)
            throws SQLException {
        if ("/mentor/be4".equals(area)) {
            return switch (path) {
                case "/tasks" -> Be4Json.task(tasks.createTask(userId,
                        request.getParameter("title"), request.getParameter("description"),
                        optionalDate(request, "dueDate")));
                case "/assignments" -> Be4Json.assignment(tasks.assignTask(userId,
                        longParam(request, "taskId"), intParam(request, "enrollmentId")));
                case "/feedback" -> Be4Json.feedback(reports.review(userId,
                        longParam(request, "reportId"), request.getParameter("comment"),
                        optionalInteger(request, "rating")));
                case "/evaluation" -> Be4Json.evaluation(evaluations.create(userId,
                        intParam(request, "enrollmentId"), decimalParam(request, "score"),
                        request.getParameter("comment")));
                default -> throw new UnknownRoute();
            };
        }
        if ("/intern/be4".equals(area)) {
            return switch (path) {
                case "/progress" -> Be4Json.progress(tasks.updateProgress(userId,
                        longParam(request, "assignmentId"), intParam(request, "completionPercentage"),
                        request.getParameter("note")));
                case "/reports" -> Be4Json.report(reports.createDraft(userId,
                        intParam(request, "enrollmentId"), shortParam(request, "weekNumber"),
                        request.getParameter("content")));
                case "/reports/update" -> Be4Json.report(reports.updateDraft(userId,
                        longParam(request, "reportId"), request.getParameter("content")));
                case "/reports/submit" -> Be4Json.report(reports.submit(userId,
                        longParam(request, "reportId")));
                default -> throw new UnknownRoute();
            };
        }
        throw new UnknownRoute();
    }

    private static boolean areaAllowed(String area, String role) {
        if (role == null) return false;
        return ("/hr/be4".equals(area) && ("HR".equals(role) || "ADMIN".equals(role)))
                || ("/mentor/be4".equals(area) && "MENTOR".equals(role))
                || ("/intern/be4".equals(area) && "INTERN".equals(role));
    }

    private static int intParam(HttpServletRequest request, String name) {
        try {
            return Integer.parseInt(required(request, name));
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(name + " phải là số nguyên", exception);
        }
    }

    private static short shortParam(HttpServletRequest request, String name) {
        try {
            return Short.parseShort(required(request, name));
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(name + " phải là số nguyên", exception);
        }
    }

    private static long longParam(HttpServletRequest request, String name) {
        try {
            return Long.parseLong(required(request, name));
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(name + " phải là số nguyên", exception);
        }
    }

    private static BigDecimal decimalParam(HttpServletRequest request, String name) {
        try {
            return new BigDecimal(required(request, name));
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(name + " phải là số thập phân", exception);
        }
    }

    private static Integer optionalInteger(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value == null || value.isBlank()) return null;
        return intParam(request, name);
    }

    private static LocalDate optionalDate(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value == null || value.isBlank()) return null;
        try {
            return LocalDate.parse(value);
        } catch (DateTimeParseException exception) {
            throw new IllegalArgumentException(name + " phải là YYYY-MM-DD", exception);
        }
    }

    private static String required(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value == null || value.isBlank()) throw new IllegalArgumentException("Thiếu " + name);
        return value.trim();
    }

    private static String csrfToken(HttpSession session) {
        synchronized (session) {
            String token = (String) session.getAttribute(CSRF_KEY);
            if (token == null) {
                byte[] bytes = new byte[32];
                RANDOM.nextBytes(bytes);
                token = java.util.HexFormat.of().formatHex(bytes);
                session.setAttribute(CSRF_KEY, token);
            }
            return token;
        }
    }

    private static boolean csrfValid(HttpSession session, String supplied) {
        Object stored = session.getAttribute(CSRF_KEY);
        return stored instanceof String token && supplied != null
                && java.security.MessageDigest.isEqual(
                token.getBytes(java.nio.charset.StandardCharsets.UTF_8),
                supplied.getBytes(java.nio.charset.StandardCharsets.UTF_8));
    }

    private static void send(HttpServletResponse response, int status, Object body) throws IOException {
        response.setStatus(status);
        response.getWriter().write(Be4Json.stringify(body));
    }

    private static final class UnknownRoute extends IllegalArgumentException {
        private UnknownRoute() {
            super("Không tìm thấy đường dẫn BE4");
        }
    }
}
