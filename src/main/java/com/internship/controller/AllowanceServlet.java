package com.internship.controller;

import com.internship.model.Allowance;
import com.internship.model.User;
import com.internship.service.AllowanceService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

@WebServlet({"/intern/allowances", "/hr/allowances"})
public class AllowanceServlet extends HttpServlet {

    private AllowanceService allowanceService;

    @Override
    public void init() {
        allowanceService = new AllowanceService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        String path = req.getServletPath();
        
        try {
            String enrollParam = req.getParameter("enrollmentId");
            Integer enrollmentId = (enrollParam != null && !enrollParam.isEmpty()) ? Integer.parseInt(enrollParam) : null;
            
            List<Allowance> list = allowanceService.getAllowances(currentUser, enrollmentId);
            req.setAttribute("allowances", list);

            if ("/intern/allowances".equals(path)) {
                req.getRequestDispatcher("/WEB-INF/views/intern/allowances.jsp").forward(req, resp);
            } else {
                req.getRequestDispatcher("/WEB-INF/views/hr/allowances.jsp").forward(req, resp);
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
        String action = req.getParameter("action");

        try {
            if ("/hr/allowances".equals(path)) {
                if ("create".equals(action)) {
                    Allowance a = new Allowance();
                    a.setEnrollmentId(Integer.parseInt(req.getParameter("enrollmentId")));
                    a.setAllowanceType(req.getParameter("allowanceType"));
                    a.setPeriod(req.getParameter("period"));
                    a.setAmount(new BigDecimal(req.getParameter("amount")));
                    
                    allowanceService.createAllowance(currentUser, a);
                } else if ("update_status".equals(action)) {
                    int id = Integer.parseInt(req.getParameter("allowanceId"));
                    String status = req.getParameter("status");
                    allowanceService.updateStatus(currentUser, id, status);
                }
                resp.sendRedirect(req.getContextPath() + "/hr/allowances?success=true");
            } else {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Not allowed.");
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/hr/allowances?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }
}
