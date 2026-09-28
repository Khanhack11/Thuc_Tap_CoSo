package com.internship.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** HR-facing evaluation list item with stable enrollment and evaluator details. */
public record EvaluationSummary(
        long evaluationId,
        int enrollmentId,
        String internName,
        String programName,
        String mentorName,
        BigDecimal score,
        String comment,
        LocalDateTime createdAt) {
}
