package com.internship.model;

import java.time.LocalDateTime;

public class ReportFeedback {

    private long feedbackId;
    private long reportId;
    private long reviewerUserId;
    private String comment;
    private Integer rating;
    private LocalDateTime createdAt;

    public ReportFeedback() {
    }

    public ReportFeedback(
            long feedbackId,
            long reportId,
            long reviewerUserId,
            String comment,
            Integer rating,
            LocalDateTime createdAt
    ) {
        this.feedbackId = feedbackId;
        this.reportId = reportId;
        this.reviewerUserId = reviewerUserId;
        this.comment = comment;
        this.rating = rating;
        this.createdAt = createdAt;
    }

    public long getFeedbackId() {
        return feedbackId;
    }

    public void setFeedbackId(long feedbackId) {
        this.feedbackId = feedbackId;
    }

    public long getReportId() {
        return reportId;
    }

    public void setReportId(long reportId) {
        this.reportId = reportId;
    }

    public long getReviewerUserId() {
        return reviewerUserId;
    }

    public void setReviewerUserId(long reviewerUserId) {
        this.reviewerUserId = reviewerUserId;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Integer getRating() {
        return rating;
    }

    public void setRating(Integer rating) {
        this.rating = rating;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "ReportFeedback{" +
                "feedbackId=" + feedbackId +
                ", reportId=" + reportId +
                ", reviewerUserId=" + reviewerUserId +
                ", rating=" + rating +
                ", createdAt=" + createdAt +
                '}';
    }
}
