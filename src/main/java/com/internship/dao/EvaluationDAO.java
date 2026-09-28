package com.internship.dao;

import com.internship.model.Evaluation;
import com.internship.model.EvaluationSummary;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class EvaluationDAO {

    public Evaluation create(Connection connection, int enrollmentId, int mentorId,
                             BigDecimal score, String comment) throws SQLException {
        String sql = """
                INSERT INTO evaluations (enrollment_id, mentor_id, score, comment)
                VALUES (?, ?, ?, ?)
                """;
        long evaluationId;
        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, enrollmentId);
            statement.setInt(2, mentorId);
            statement.setBigDecimal(3, score);
            statement.setString(4, comment);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException("Không lấy được evaluation_id");
                }
                evaluationId = keys.getLong(1);
            }
        }
        return findById(connection, evaluationId);
    }

    public Evaluation findByEnrollment(Connection connection, int enrollmentId) throws SQLException {
        String sql = "SELECT * FROM evaluations WHERE enrollment_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, enrollmentId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? map(resultSet) : null;
            }
        }
    }

    public List<EvaluationSummary> findAllSummaries(Connection connection) throws SQLException {
        String sql = """
                SELECT e.evaluation_id, e.enrollment_id, ip.full_name AS intern_name,
                       p.program_name, u.full_name AS mentor_name, e.score,
                       e.comment, e.created_at
                FROM evaluations e
                JOIN program_enrollments pe ON pe.enrollment_id = e.enrollment_id
                JOIN intern_profiles ip ON ip.profile_id = pe.intern_profile_id
                JOIN internship_programs p ON p.program_id = pe.program_id
                JOIN mentors m ON m.mentor_id = e.mentor_id
                JOIN users u ON u.user_id = m.user_id
                ORDER BY e.created_at DESC, e.evaluation_id DESC
                """;
        List<EvaluationSummary> summaries = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rows = statement.executeQuery()) {
            while (rows.next()) {
                Timestamp createdAt = rows.getTimestamp("created_at");
                summaries.add(new EvaluationSummary(
                        rows.getLong("evaluation_id"), rows.getInt("enrollment_id"),
                        rows.getString("intern_name"), rows.getString("program_name"),
                        rows.getString("mentor_name"), rows.getBigDecimal("score"),
                        rows.getString("comment"),
                        createdAt == null ? null : createdAt.toLocalDateTime()));
            }
        }
        return summaries;
    }

    private Evaluation findById(Connection connection, long evaluationId) throws SQLException {
        String sql = "SELECT * FROM evaluations WHERE evaluation_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, evaluationId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? map(resultSet) : null;
            }
        }
    }

    private Evaluation map(ResultSet resultSet) throws SQLException {
        Evaluation evaluation = new Evaluation();
        evaluation.setEvaluationId(resultSet.getLong("evaluation_id"));
        evaluation.setEnrollmentId(resultSet.getInt("enrollment_id"));
        evaluation.setMentorId(resultSet.getInt("mentor_id"));
        evaluation.setScore(resultSet.getBigDecimal("score"));
        evaluation.setComment(resultSet.getString("comment"));
        Timestamp createdAt = resultSet.getTimestamp("created_at");
        if (createdAt != null) {
            evaluation.setCreatedAt(createdAt.toLocalDateTime());
        }
        Timestamp updatedAt = resultSet.getTimestamp("updated_at");
        if (updatedAt != null) {
            evaluation.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        return evaluation;
    }
}
