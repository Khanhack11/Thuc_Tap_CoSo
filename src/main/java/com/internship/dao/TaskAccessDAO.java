package com.internship.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/** Read-only ownership checks against the BE1, BE2 and BE3 tables. */
public class TaskAccessDAO {

    public boolean isActiveMentor(Connection connection, long userId) throws SQLException {
        String sql = """
                SELECT 1 FROM mentors m
                JOIN users u ON u.user_id = m.user_id
                JOIN roles r ON r.role_id = u.role_id
                WHERE m.user_id = ? AND m.status = 'ACTIVE'
                  AND u.status = 'ACTIVE' AND r.role_name = 'MENTOR'
                """;
        return exists(connection, sql, userId, null);
    }

    public boolean isCurrentMentor(Connection connection, long userId, int enrollmentId)
            throws SQLException {
        String sql = """
                SELECT 1 FROM mentor_assignments ma
                JOIN mentors m ON m.mentor_id = ma.mentor_id
                JOIN program_enrollments pe ON pe.enrollment_id = ma.enrollment_id
                JOIN users u ON u.user_id = m.user_id
                JOIN roles r ON r.role_id = u.role_id
                WHERE m.user_id = ? AND ma.enrollment_id = ?
                  AND ma.ended_at IS NULL AND pe.status = 'ACTIVE'
                  AND m.status = 'ACTIVE' AND u.status = 'ACTIVE'
                  AND r.role_name = 'MENTOR'
                """;
        return exists(connection, sql, userId, enrollmentId);
    }

    public Integer findCurrentMentorId(Connection connection, long userId, int enrollmentId)
            throws SQLException {
        String sql = """
                SELECT m.mentor_id FROM mentor_assignments ma
                JOIN mentors m ON m.mentor_id = ma.mentor_id
                JOIN program_enrollments pe ON pe.enrollment_id = ma.enrollment_id
                JOIN users u ON u.user_id = m.user_id
                JOIN roles r ON r.role_id = u.role_id
                WHERE m.user_id = ? AND ma.enrollment_id = ?
                  AND ma.ended_at IS NULL AND pe.status = 'ACTIVE'
                  AND m.status = 'ACTIVE' AND u.status = 'ACTIVE'
                  AND r.role_name = 'MENTOR'
                """;
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, userId);
            statement.setInt(2, enrollmentId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? resultSet.getInt("mentor_id") : null;
            }
        }
    }

    public boolean isActiveHrOrAdmin(Connection connection, long userId) throws SQLException {
        String sql = """
                SELECT 1 FROM users u
                JOIN roles r ON r.role_id = u.role_id
                WHERE u.user_id = ? AND u.status = 'ACTIVE'
                  AND r.role_name IN ('HR', 'ADMIN')
                """;
        return exists(connection, sql, userId, null);
    }

    public boolean isActiveInternUser(Connection connection, long userId) throws SQLException {
        String sql = """
                SELECT 1 FROM users u JOIN roles r ON r.role_id = u.role_id
                WHERE u.user_id = ? AND u.status = 'ACTIVE' AND r.role_name = 'INTERN'
                """;
        return exists(connection, sql, userId, null);
    }

    public boolean isActiveInternOwner(Connection connection, long userId, int enrollmentId)
            throws SQLException {
        String sql = """
                SELECT 1 FROM program_enrollments pe
                JOIN intern_profiles ip ON ip.profile_id = pe.intern_profile_id
                JOIN users u ON u.user_id = ip.user_id
                JOIN roles r ON r.role_id = u.role_id
                WHERE u.user_id = ? AND pe.enrollment_id = ?
                  AND pe.status = 'ACTIVE' AND ip.status = 'ACTIVE'
                  AND u.status = 'ACTIVE' AND r.role_name = 'INTERN'
                """;
        return exists(connection, sql, userId, enrollmentId);
    }

    public boolean isInternOwner(Connection connection, long userId, int enrollmentId)
            throws SQLException {
        String sql = """
                SELECT 1 FROM program_enrollments pe
                JOIN intern_profiles ip ON ip.profile_id = pe.intern_profile_id
                JOIN users u ON u.user_id = ip.user_id
                JOIN roles r ON r.role_id = u.role_id
                WHERE u.user_id = ? AND pe.enrollment_id = ?
                  AND u.status = 'ACTIVE' AND r.role_name = 'INTERN'
                """;
        return exists(connection, sql, userId, enrollmentId);
    }

    public boolean isAssignedMentor(Connection connection, long userId, int enrollmentId)
            throws SQLException {
        String sql = """
                SELECT 1 FROM mentor_assignments ma
                JOIN mentors m ON m.mentor_id = ma.mentor_id
                JOIN users u ON u.user_id = m.user_id
                JOIN roles r ON r.role_id = u.role_id
                WHERE m.user_id = ? AND ma.enrollment_id = ? AND ma.ended_at IS NULL
                  AND u.status = 'ACTIVE' AND r.role_name = 'MENTOR'
                """;
        return exists(connection, sql, userId, enrollmentId);
    }

    private boolean exists(Connection connection, String sql, long userId, Integer enrollmentId)
            throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, userId);
            if (enrollmentId != null) {
                statement.setInt(2, enrollmentId);
            }
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }
}
