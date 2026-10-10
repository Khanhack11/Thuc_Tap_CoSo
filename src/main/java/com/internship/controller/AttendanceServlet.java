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
                int enrollmentId = enrollParam != null ? Integer.parseInt(enrollParam) : 0;
                
                // For intern, show report
                LocalDate from = req.getParameter("from") != null ? LocalDate.parse(req.getParameter("from")) : LocalDate.now().minusDays(30);
                LocalDate to = req.getParameter("to") != null ? LocalDate.parse(req.getParameter("to")) : LocalDate.now();
                
                List<AttendanceReportRow> report = attendanceService.getReport(currentUser, enrollmentId > 0 ? enrollmentId : null, null, from, to);
                req.setAttribute("report", report);
                req.getRequestDispatcher("/WEB-INF/views/intern/attendance.jsp").forward(req, resp);
                
            } else if ("/hr/attendance".equals(path)) {
                if (!UserRoleChecks.canManageHr(currentUser)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                    return;
                }
                
                String enrollParam = req.getParameter("enrollmentId");
                Integer enrollmentId = (enrollParam != null && !enrollParam.isEmpty()) ? Integer.parseInt(enrollParam) : null;
                
                String progParam = req.getParameter("programId");
                Integer programId = (progParam != null && !progParam.isEmpty()) ? Integer.parseInt(progParam) : null;
                
                LocalDate from = req.getParameter("from") != null && !req.getParameter("from").isEmpty() ? LocalDate.parse(req.getParameter("from")) : LocalDate.now().minusDays(30);
                LocalDate to = req.getParameter("to") != null && !req.getParameter("to").isEmpty() ? LocalDate.parse(req.getParameter("to")) : LocalDate.now();
                
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
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        String path = req.getServletPath();
        
        if ("/intern/attendance".equals(path)) {
            String action = req.getParameter("action");
            int enrollmentId = Integer.parseInt(req.getParameter("enrollmentId"));
            
            try {
                if ("checkin".equals(action)) {
                    attendanceService.checkIn(currentUser, enrollmentId);
                } else if ("checkout".equals(action)) {
                    attendanceService.checkOut(currentUser, enrollmentId);
                }
                resp.sendRedirect(req.getContextPath() + "/intern/attendance?enrollmentId=" + enrollmentId + "&success=true");
            } catch (SQLException | IllegalArgumentException e) {
                resp.sendRedirect(req.getContextPath() + "/intern/attendance?enrollmentId=" + enrollmentId + "&error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            }
        }
    }
}
