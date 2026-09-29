package com.internship.service;

import com.internship.dao.Be4EnrollmentDAO;
import com.internship.dao.TaskAccessDAO;
import com.internship.model.EnrollmentSummary;
import com.internship.util.DBConnection;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public class EnrollmentQueryService {
    private final Be4ConnectionFactory connections;
    private final Be4EnrollmentDAO enrollments;
    private final TaskAccessDAO access;

    public EnrollmentQueryService() {
        this(DBConnection::getConnection, new Be4EnrollmentDAO(), new TaskAccessDAO());
    }

    EnrollmentQueryService(Be4ConnectionFactory connections, Be4EnrollmentDAO enrollments,
                           TaskAccessDAO access) {
        this.connections = connections;
        this.enrollments = enrollments;
        this.access = access;
    }

    public List<EnrollmentSummary> findForMentor(long mentorUserId) throws SQLException {
        if (mentorUserId <= 0) throw new IllegalArgumentException("mentorUserId phải lớn hơn 0");
        try (Connection connection = connections.open()) {
            if (!access.isActiveMentor(connection, mentorUserId)) {
                throw new SecurityException("Chỉ mentor đang hoạt động được xem danh sách");
            }
            return enrollments.findForMentor(connection, mentorUserId);
        }
    }

    public List<EnrollmentSummary> findForIntern(long internUserId) throws SQLException {
        if (internUserId <= 0) throw new IllegalArgumentException("internUserId phải lớn hơn 0");
        try (Connection connection = connections.open()) {
            if (!access.isActiveInternUser(connection, internUserId)) {
                throw new SecurityException("Chỉ TTS đang hoạt động được xem danh sách");
            }
            return enrollments.findForIntern(connection, internUserId);
        }
    }
}
