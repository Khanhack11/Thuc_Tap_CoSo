package com.internship.model;

import java.time.LocalDateTime;

public class WeeklyReport {

    private long reportId;
    private int enrollmentId;
    private short weekNumber;
    private String content;
    private WeeklyReportStatus status;
    private LocalDateTime submittedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public WeeklyReport() {
    }

    public WeeklyReport(
            long reportId,
            int enrollmentId,
            short weekNumber,
            String content,
            WeeklyReportStatus status,
            LocalDateTime submittedAt,
            LocalDateTime createdAt,
            LocalDateTime updatedAt
    ) {
        this.reportId = reportId;
        this.enrollmentId = enrollmentId;
        this.weekNumber = weekNumber;
        this.content = content;
        this.status = status;
        this.submittedAt = submittedAt;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public long getReportId() {
        return reportId;
    }

    public void setReportId(long reportId) {
        this.reportId = reportId;
    }

    public int getEnrollmentId() {
        return enrollmentId;
    }

    public void setEnrollmentId(int enrollmentId) {
        this.enrollmentId = enrollmentId;
    }

    public short getWeekNumber() {
        return weekNumber;
    }

    public void setWeekNumber(short weekNumber) {
        this.weekNumber = weekNumber;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public WeeklyReportStatus getStatus() {
        return status;
    }

    public void setStatus(WeeklyReportStatus status) {
        this.status = status;
    }

    public LocalDateTime getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(LocalDateTime submittedAt) {
        this.submittedAt = submittedAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "WeeklyReport{" +
                "reportId=" + reportId +
                ", enrollmentId=" + enrollmentId +
                ", weekNumber=" + weekNumber +
                ", status=" + status +
                ", submittedAt=" + submittedAt +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
