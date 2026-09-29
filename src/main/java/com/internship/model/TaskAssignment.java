package com.internship.model;

import java.time.LocalDateTime;

public class TaskAssignment {

    private long assignmentId;
    private long taskId;
    private int enrollmentId;
    private TaskAssignmentStatus status;
    private LocalDateTime assignedAt;
    private LocalDateTime updatedAt;

    public TaskAssignment() {
    }

    public TaskAssignment(
            long assignmentId,
            long taskId,
            int enrollmentId,
            TaskAssignmentStatus status,
            LocalDateTime assignedAt,
            LocalDateTime updatedAt
    ) {
        this.assignmentId = assignmentId;
        this.taskId = taskId;
        this.enrollmentId = enrollmentId;
        this.status = status;
        this.assignedAt = assignedAt;
        this.updatedAt = updatedAt;
    }

    public long getAssignmentId() {
        return assignmentId;
    }

    public void setAssignmentId(long assignmentId) {
        this.assignmentId = assignmentId;
    }

    public long getTaskId() {
        return taskId;
    }

    public void setTaskId(long taskId) {
        this.taskId = taskId;
    }

    public int getEnrollmentId() {
        return enrollmentId;
    }

    public void setEnrollmentId(int enrollmentId) {
        this.enrollmentId = enrollmentId;
    }

    public TaskAssignmentStatus getStatus() {
        return status;
    }

    public void setStatus(TaskAssignmentStatus status) {
        this.status = status;
    }

    public LocalDateTime getAssignedAt() {
        return assignedAt;
    }

    public void setAssignedAt(LocalDateTime assignedAt) {
        this.assignedAt = assignedAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "TaskAssignment{" +
                "assignmentId=" + assignmentId +
                ", taskId=" + taskId +
                ", enrollmentId=" + enrollmentId +
                ", status=" + status +
                ", assignedAt=" + assignedAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
