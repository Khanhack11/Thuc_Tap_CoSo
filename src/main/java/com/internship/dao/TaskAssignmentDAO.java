package com.internship.dao;

import com.internship.model.TaskAssignment;
import com.internship.model.TaskAssignmentStatus;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class TaskAssignmentDAO {

    public TaskAssignment create(Connection connection, long taskId, int enrollmentId) throws SQLException {
        String sql = "INSERT INTO task_assignments (task_id, enrollment_id) VALUES (?, ?)";
        long assignmentId;
        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setLong(1, taskId);
            statement.setInt(2, enrollmentId);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException("Không lấy được assignment_id sau khi giao task");
                }
                assignmentId = keys.getLong(1);
            }
        }
        return findById(connection, assignmentId);
    }

    public TaskAssignment findById(Connection connection, long assignmentId) throws SQLException {
        return find(connection, assignmentId, false);
    }

    public TaskAssignment findByIdForUpdate(Connection connection, long assignmentId) throws SQLException {
        return find(connection, assignmentId, true);
    }

    private TaskAssignment find(Connection connection, long assignmentId, boolean lock) throws SQLException {
        String sql = "SELECT * FROM task_assignments WHERE assignment_id = ?" + (lock ? " FOR UPDATE" : "");
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, assignmentId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? map(resultSet) : null;
            }
        }
    }

    public List<TaskAssignment> findByEnrollment(Connection connection, int enrollmentId) throws SQLException {
        String sql = """
                SELECT * FROM task_assignments
                WHERE enrollment_id = ?
                ORDER BY assigned_at DESC, assignment_id DESC
                """;
        List<TaskAssignment> assignments = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, enrollmentId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    assignments.add(map(resultSet));
                }
            }
        }
        return assignments;
    }

    public void updateStatus(Connection connection, long assignmentId, TaskAssignmentStatus status)
            throws SQLException {
        String sql = "UPDATE task_assignments SET status = ? WHERE assignment_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, status.name());
            statement.setLong(2, assignmentId);
            if (statement.executeUpdate() != 1) {
                throw new SQLException("Không tìm thấy task assignment cần cập nhật");
            }
        }
    }

    private TaskAssignment map(ResultSet resultSet) throws SQLException {
        TaskAssignment assignment = new TaskAssignment();
        assignment.setAssignmentId(resultSet.getLong("assignment_id"));
        assignment.setTaskId(resultSet.getLong("task_id"));
        assignment.setEnrollmentId(resultSet.getInt("enrollment_id"));
        assignment.setStatus(TaskAssignmentStatus.valueOf(resultSet.getString("status")));
        Timestamp assignedAt = resultSet.getTimestamp("assigned_at");
        if (assignedAt != null) {
            assignment.setAssignedAt(assignedAt.toLocalDateTime());
        }
        Timestamp updatedAt = resultSet.getTimestamp("updated_at");
        if (updatedAt != null) {
            assignment.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        return assignment;
    }
}
