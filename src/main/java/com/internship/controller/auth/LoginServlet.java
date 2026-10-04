package com.internship.controller.auth;

import java.io.IOException;

import com.internship.model.User;
import com.internship.service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/auth/login")
public class LoginServlet extends HttpServlet {

    private AuthService authService;

    @Override
    public void init() {
        authService = new AuthService();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        if (session != null
                && session.getAttribute("currentUser") instanceof User user) {

            response.sendRedirect(
                    request.getContextPath() + getLandingPath(user)
            );

            return;
        }

        request.getRequestDispatcher(
                "/login.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username =
                request.getParameter("username");

        String password =
                request.getParameter("password");

        try {

            User user =
                    authService.authenticate(
                            username,
                            password
                    );

            if (user == null) {

                request.setAttribute(
                        "error",
                        "Tên đăng nhập hoặc mật khẩu không hợp lệ."
                );

                request.setAttribute(
                        "username",
                        username
                );

                request.getRequestDispatcher(
                        "/login.jsp"
                ).forward(request, response);

                return;
            }

            HttpSession oldSession =
                    request.getSession(false);

            if (oldSession != null) {
                oldSession.invalidate();
            }

            HttpSession newSession =
                    request.getSession(true);

            newSession.setAttribute(
                    "currentUser",
                    user
            );

            newSession.setAttribute(
                    "currentRole",
                    user.getRole().getRoleName()
            );

            response.sendRedirect(
                    request.getContextPath() + getLandingPath(user)
            );

        } catch (Exception e) {

            throw new ServletException(
                    "Authentication failed.",
                    e
            );
        }
    }

    private String getLandingPath(User user) {

        if (user == null
                || user.getRole() == null
                || user.getRole().getRoleName() == null) {
            return "/";
        }

        return switch (user.getRole().getRoleName()) {
            case "HR" -> "/hr/dashboard";
            case "MENTOR" -> "/mentor/dashboard";
            case "INTERN" -> "/intern/profile";
            case "ADMIN" -> "/admin/accounts";
            default -> "/";
        };
    }
}