package com.internship.dao;

import com.internship.model.Task;
import com.internship.model.TaskStatus;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class TaskDAO {

    public Task create(Connection connection, Task task) throws SQLException {
        String sql = """
                INSERT INTO tasks (title, description, created_by_user_id, status, due_date)
                VALUES (?, ?, ?, ?, ?)
                """;
        long taskId;
        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, task.getTitle());
            statement.setString(2, task.getDescription());
            statement.setLong(3, task.getCreatedByUserId());
            statement.setString(4, task.getStatus().name());
            if (task.getDueDate() == null) {
                statement.setNull(5, java.sql.Types.DATE);
            } else {
                statement.setDate(5, Date.valueOf(task.getDueDate()));
            }
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException("Không lấy được task_id sau khi tạo task");
                }
                taskId = keys.getLong(1);
            }
        }
        return findById(connection, taskId);
    }

    public Task findById(Connection connection, long taskId) throws SQLException {
        String sql = "SELECT * FROM tasks WHERE task_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, taskId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? map(resultSet) : null;
            }
        }
    }

    public List<Task> findByEnrollment(Connection connection, int enrollmentId) throws SQLException {
        String sql = """
                SELECT t.* FROM tasks t
                JOIN task_assignments ta ON ta.task_id = t.task_id
                WHERE ta.enrollment_id = ?
                ORDER BY ta.assigned_at DESC, ta.assignment_id DESC
                """;
        List<Task> tasks = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, enrollmentId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    tasks.add(map(resultSet));
                }
            }
        }
        return tasks;
    }

    private Task map(ResultSet resultSet) throws SQLException {
        Task task = new Task();
        task.setTaskId(resultSet.getLong("task_id"));
        task.setTitle(resultSet.getString("title"));
        task.setDescription(resultSet.getString("description"));
        task.setCreatedByUserId(resultSet.getLong("created_by_user_id"));
        task.setStatus(TaskStatus.valueOf(resultSet.getString("status")));
        Date dueDate = resultSet.getDate("due_date");
        if (dueDate != null) {
            task.setDueDate(dueDate.toLocalDate());
        }
        Timestamp createdAt = resultSet.getTimestamp("created_at");
        if (createdAt != null) {
            task.setCreatedAt(createdAt.toLocalDateTime());
        }
        Timestamp updatedAt = resultSet.getTimestamp("updated_at");
        if (updatedAt != null) {
            task.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        return task;
    }
}
