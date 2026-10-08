package com.internship.controller.auth;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import com.internship.service.AuditLogService;

@WebServlet("/auth/logout")
public class LogoutServlet extends HttpServlet {

    private final AuditLogService auditLog = new AuditLogService();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {

        HttpSession session =
                request.getSession(false);

        if (session != null) {
            if (session.getAttribute("currentUser") instanceof com.internship.model.User user) {
                auditLog.recordBestEffort(user.getUserId(), "LOGOUT", "USER", user.getUserId(), "SUCCESS");
            }
            session.invalidate();
        }

        response.sendRedirect(
                request.getContextPath() + "/auth/login"
        );
    }
}