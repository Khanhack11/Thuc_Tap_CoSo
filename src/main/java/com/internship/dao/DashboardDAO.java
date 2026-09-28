package com.internship.dao;

import com.internship.model.DashboardCount;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Read-only aggregates; cancelled enrollments are excluded from HR completion rate. */
public class DashboardDAO {

    public long countDistinctInterns(Connection connection) throws SQLException {
        return count(connection, """
                SELECT COUNT(DISTINCT intern_profile_id) FROM program_enrollments
                WHERE status <> 'CANCELLED'
                """);
    }

    public long countEnrollments(Connection connection, String status) throws SQLException {
        return count(connection, "SELECT COUNT(*) FROM program_enrollments WHERE status = ?", status);
    }

    public List<DashboardCount> internsByUniversity(Connection connection) throws SQLException {
        return counts(connection, """
                SELECT COALESCE(NULLIF(TRIM(ip.university), ''), 'Không rõ') AS label,
                       COUNT(DISTINCT pe.intern_profile_id) AS item_count
                FROM program_enrollments pe
                JOIN intern_profiles ip ON ip.profile_id = pe.intern_profile_id
                WHERE pe.status <> 'CANCELLED'
                GROUP BY label
                ORDER BY item_count DESC, label ASC
                """);
    }

    public List<DashboardCount> internsByMajor(Connection connection) throws SQLException {
        return counts(connection, """
                SELECT COALESCE(NULLIF(TRIM(ip.major), ''), 'Không rõ') AS label,
                       COUNT(DISTINCT pe.intern_profile_id) AS item_count
                FROM program_enrollments pe
                JOIN intern_profiles ip ON ip.profile_id = pe.intern_profile_id
                WHERE pe.status <> 'CANCELLED'
                GROUP BY label
                ORDER BY item_count DESC, label ASC
                """);
    }

    public List<DashboardCount> activeInternsByMentor(Connection connection) throws SQLException {
        return counts(connection, """
                SELECT CONCAT(u.full_name, ' (#', m.mentor_id, ')') AS label,
                       COUNT(DISTINCT ma.enrollment_id) AS item_count
                FROM mentor_assignments ma
                JOIN mentors m ON m.mentor_id = ma.mentor_id
                JOIN users u ON u.user_id = m.user_id
                JOIN program_enrollments pe ON pe.enrollment_id = ma.enrollment_id
                WHERE ma.ended_at IS NULL AND pe.status = 'ACTIVE'
                GROUP BY m.mentor_id, u.full_name
                ORDER BY item_count DESC, label ASC
                """);
    }

    public Integer findMentorIdByUser(Connection connection, long userId) throws SQLException {
        String sql = "SELECT mentor_id FROM mentors WHERE user_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? resultSet.getInt(1) : null;
            }
        }
    }

    public long countActiveInternsForMentor(Connection connection, int mentorId) throws SQLException {
        return count(connection, """
                SELECT COUNT(DISTINCT ma.enrollment_id)
                FROM mentor_assignments ma
                JOIN program_enrollments pe ON pe.enrollment_id = ma.enrollment_id
                WHERE ma.mentor_id = ? AND ma.ended_at IS NULL AND pe.status = 'ACTIVE'
                """, mentorId);
    }

    public long countTasksForMentor(Connection connection, int mentorId, String status) throws SQLException {
        return count(connection, """
                SELECT COUNT(*) FROM task_assignments ta
                JOIN mentor_assignments ma ON ma.enrollment_id = ta.enrollment_id
                JOIN program_enrollments pe ON pe.enrollment_id = ta.enrollment_id
                WHERE ma.mentor_id = ? AND ma.ended_at IS NULL
                  AND pe.status = 'ACTIVE' AND ta.status = ?
                """, mentorId, status);
    }

    public long countReportsForMentor(Connection connection, int mentorId, String status) throws SQLException {
        return count(connection, """
                SELECT COUNT(*) FROM weekly_reports wr
                JOIN mentor_assignments ma ON ma.enrollment_id = wr.enrollment_id
                JOIN program_enrollments pe ON pe.enrollment_id = wr.enrollment_id
                WHERE ma.mentor_id = ? AND ma.ended_at IS NULL
                  AND pe.status = 'ACTIVE' AND wr.status = ?
                """, mentorId, status);
    }

    public long countEvaluationsForMentor(Connection connection, int mentorId) throws SQLException {
        return count(connection, "SELECT COUNT(*) FROM evaluations WHERE mentor_id = ?", mentorId);
    }

    private long count(Connection connection, String sql, Object... values) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            for (int index = 0; index < values.length; index++) {
                statement.setObject(index + 1, values[index]);
            }
            try (ResultSet resultSet = statement.executeQuery()) {
                resultSet.next();
                return resultSet.getLong(1);
            }
        }
    }

    private List<DashboardCount> counts(Connection connection, String sql) throws SQLException {
        List<DashboardCount> values = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                values.add(new DashboardCount(resultSet.getString("label"), resultSet.getLong("item_count")));
            }
        }
        return values;
    }
}
