package com.internship.service;

import com.internship.dao.InternProfileDAO;
import com.internship.dao.SupportRequestDAO;
import com.internship.model.InternProfile;
import com.internship.model.SupportRequest;
import com.internship.model.User;
import com.internship.util.ConnectionProvider;
import com.internship.util.DBConnection;
import com.internship.util.UserRoleChecks;

import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;

public class SupportRequestService {

    private final SupportRequestDAO supportRequestDAO;
    private final InternProfileDAO internProfileDAO;
    private final ConnectionProvider connections;

    public SupportRequestService() {
        this(new SupportRequestDAO(), new InternProfileDAO(), DBConnection::getConnection);
    }

    public SupportRequestService(SupportRequestDAO supportRequestDAO, InternProfileDAO internProfileDAO, ConnectionProvider connections) {
        this.supportRequestDAO = Objects.requireNonNull(supportRequestDAO);
        this.internProfileDAO = Objects.requireNonNull(internProfileDAO);
        this.connections = Objects.requireNonNull(connections);
    }

    public void createRequest(User actor, String requestType, String title, String content) throws SQLException {
        if (actor == null || !UserRoleChecks.isIntern(actor)) {
            throw new IllegalArgumentException("Only interns can create support requests.");
        }
        
        InternProfile profile = internProfileDAO.getProfileByUserId(actor.getUserId());
        if (profile == null) {
            throw new IllegalArgumentException("Intern profile not found.");
        }

        SupportRequest req = new SupportRequest();
        req.setProfileId(profile.getProfileId());
        req.setRequestType(requestType);
        req.setTitle(title);
        req.setContent(content);

        try (Connection c = connections.getConnection()) {
            supportRequestDAO.insert(req, c);
        }
    }

    public void updateResponse(User actor, int requestId, String status, String response) throws SQLException {
        if (actor == null || !UserRoleChecks.canManageHr(actor)) {
            throw new IllegalArgumentException("Only HR/Admin can respond to support requests.");
        }
        
        try (Connection c = connections.getConnection()) {
            SupportRequest req = supportRequestDAO.findById(requestId, c);
            if (req == null) {
                throw new IllegalArgumentException("Support request not found.");
            }
            
            req.setStatus(status);
            req.setResponse(response);
            req.setHandledBy(actor.getUserId());
            req.setHandledAt(LocalDateTime.now());
            
            supportRequestDAO.updateResponse(req, c);
        }
    }

    public List<SupportRequest> getMyRequests(User actor) throws SQLException {
        if (actor == null || !UserRoleChecks.isIntern(actor)) {
            throw new IllegalArgumentException("Only interns can view their own support requests.");
        }
        
        InternProfile profile = internProfileDAO.getProfileByUserId(actor.getUserId());
        if (profile == null) {
            throw new IllegalArgumentException("Intern profile not found.");
        }

        try (Connection c = connections.getConnection()) {
            return supportRequestDAO.findByProfileId(profile.getProfileId(), c);
        }
    }

    public List<SupportRequest> getAllRequests(User actor) throws SQLException {
        if (actor == null || !UserRoleChecks.canManageHr(actor)) {
            throw new IllegalArgumentException("Only HR/Admin can view all support requests.");
        }
        
        try (Connection c = connections.getConnection()) {
            return supportRequestDAO.findAll(c);
        }
    }
}
