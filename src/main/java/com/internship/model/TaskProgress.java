package com.internship.model;

import java.time.LocalDateTime;

/**
 * Mỗi bản ghi là một lần cập nhật tiến độ (append-only).
 * Không ghi đè lịch sử – truy vấn theo assignment_id
 * để xem toàn bộ lịch sử cập nhật.
 */
public class TaskProgress {

    private long progressId;
    private long assignmentId;
    private String note;
    private int completionPercentage;
    private LocalDateTime createdAt;

    public TaskProgress() {
    }

    public TaskProgress(
            long progressId,
            long assignmentId,
            String note,
            int completionPercentage,
            LocalDateTime createdAt
    ) {
        this.progressId = progressId;
        this.assignmentId = assignmentId;
        this.note = note;
        this.completionPercentage = completionPercentage;
        this.createdAt = createdAt;
    }

    public long getProgressId() {
        return progressId;
    }

    public void setProgressId(long progressId) {
        this.progressId = progressId;
    }

    public long getAssignmentId() {
        return assignmentId;
    }

    public void setAssignmentId(long assignmentId) {
        this.assignmentId = assignmentId;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public int getCompletionPercentage() {
        return completionPercentage;
    }

    public void setCompletionPercentage(int completionPercentage) {
        this.completionPercentage = completionPercentage;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "TaskProgress{" +
                "progressId=" + progressId +
                ", assignmentId=" + assignmentId +
                ", note='" + note + '\'' +
                ", completionPercentage=" + completionPercentage +
                ", createdAt=" + createdAt +
                '}';
    }
}
