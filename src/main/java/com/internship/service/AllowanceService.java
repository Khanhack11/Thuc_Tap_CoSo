package com.internship.service;

import com.internship.dao.AllowanceDAO;
import com.internship.model.Allowance;
import com.internship.model.User;
import com.internship.util.ConnectionProvider;
import com.internship.util.DBConnection;
import com.internship.util.UserRoleChecks;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public class AllowanceService {

    private final AllowanceDAO allowanceDAO;
    private final ConnectionProvider connections;

    public AllowanceService() {
        this(new AllowanceDAO(), DBConnection::getConnection);
    }

    public AllowanceService(AllowanceDAO allowanceDAO, ConnectionProvider connections) {
        this.allowanceDAO = allowanceDAO;
        this.connections = connections;
    }

    public void createAllowance(User hrUser, Allowance allowance) throws SQLException {
        if (hrUser == null || (!UserRoleChecks.canManageHr(hrUser) && !UserRoleChecks.isAdmin(hrUser))) {
            throw new IllegalArgumentException("Kh?ng c? quy?n t?o ph? c?p.");
        }
        if (allowance.getAmount().signum() < 0) {
            throw new IllegalArgumentException("S? ti?n ph? c?p kh?ng ???c ?m.");
        }
        allowance.setCreatedBy(hrUser.getUserId());

        try (Connection c = connections.getConnection()) {
            allowanceDAO.create(allowance, c);
        }
    }

    public void updateStatus(User hrUser, int allowanceId, String status) throws SQLException {
        if (hrUser == null || (!UserRoleChecks.canManageHr(hrUser) && !UserRoleChecks.isAdmin(hrUser))) {
            throw new IllegalArgumentException("Kh?ng c? quy?n c?p nh?t ph? c?p.");
        }
        try (Connection c = connections.getConnection()) {
            allowanceDAO.updateStatus(allowanceId, status, c);
        }
    }

    public List<Allowance> getAllowances(User user, Integer enrollmentId) throws SQLException {
        if (user == null) {
            throw new IllegalArgumentException("Ch?a ??ng nh?p.");
        }
        Long ownerId = UserRoleChecks.isIntern(user) ? user.getUserId() : null;
        try (Connection c = connections.getConnection()) {
            return allowanceDAO.list(enrollmentId, ownerId, c);
        }
    }
}
