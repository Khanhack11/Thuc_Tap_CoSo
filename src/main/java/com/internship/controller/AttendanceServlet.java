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
import java.sql.SQLException;

@WebServlet({"/intern/attendance", "/hr/attendance"})
public class AttendanceServlet extends HttpServlet {

    private AttendanceService attendanceService;

    @Override
    public void init() {
        attendanceService = new AttendanceService();
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
                int enrollmentId = 0;
                try {
                    enrollmentId = (enrollParam != null && !enrollParam.trim().isEmpty()) ? Integer.parseInt(enrollParam) : 0;
                } catch (NumberFormatException e) {
                    // ignore, keep 0
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
                
                List<AttendanceReportRow> report = attendanceService.getReport(currentUser, enrollmentId > 0 ? enrollmentId : null, null, from, to);
                req.setAttribute("report", report);
                req.getRequestDispatcher("/WEB-INF/views/intern/attendance.jsp").forward(req, resp);
                
            } else if ("/hr/attendance".equals(path)) {
                if (!UserRoleChecks.canManageHr(currentUser)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                    return;
                }
                
                String enrollParam = req.getParameter("enrollmentId");
                Integer enrollmentId = null;
                try {
                    enrollmentId = (enrollParam != null && !enrollParam.trim().isEmpty()) ? Integer.parseInt(enrollParam) : null;
                } catch (NumberFormatException e) { }
                
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
                
                List<AttendanceReportRow> report = attendanceService.getReport(currentUser, enrollmentId, programId, from, to);
                req.setAttribute("report", report);
                req.getRequestDispatcher("/WEB-INF/views/hr/attendance.jsp").forward(req, resp);
            }
        } catch (SQLException | IllegalArgumentException e) {
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
            int enrollmentId = 0;
            try {
                String enrollParam = req.getParameter("enrollmentId");
                if (enrollParam != null && !enrollParam.trim().isEmpty()) {
                    enrollmentId = Integer.parseInt(enrollParam);
                }
            } catch (NumberFormatException e) {
                resp.sendRedirect(req.getContextPath() + "/intern/attendance?error=" + java.net.URLEncoder.encode("Mã ghi danh không hợp lệ", "UTF-8"));
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
}
