package com.internship.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Evaluation {

    private long evaluationId;
    private int enrollmentId;
    private int mentorId;
    private BigDecimal score;
    private String comment;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Evaluation() {
    }

    public Evaluation(
            long evaluationId,
            int enrollmentId,
            int mentorId,
            BigDecimal score,
            String comment,
            LocalDateTime createdAt,
            LocalDateTime updatedAt
    ) {
        this.evaluationId = evaluationId;
        this.enrollmentId = enrollmentId;
        this.mentorId = mentorId;
        this.score = score;
        this.comment = comment;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public long getEvaluationId() {
        return evaluationId;
    }

    public void setEvaluationId(long evaluationId) {
        this.evaluationId = evaluationId;
    }

    public int getEnrollmentId() {
        return enrollmentId;
    }

    public void setEnrollmentId(int enrollmentId) {
        this.enrollmentId = enrollmentId;
    }

    public int getMentorId() {
        return mentorId;
    }

    public void setMentorId(int mentorId) {
        this.mentorId = mentorId;
    }

    public BigDecimal getScore() {
        return score;
    }

    public void setScore(BigDecimal score) {
        this.score = score;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
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
        return "Evaluation{" +
                "evaluationId=" + evaluationId +
                ", enrollmentId=" + enrollmentId +
                ", mentorId=" + mentorId +
                ", score=" + score +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
