package com.internship.model;

public record MentorDashboard(
        long activeInterns,
        long tasksTodo,
        long tasksInProgress,
        long tasksDone,
        long reportsSubmitted,
        long reportsReviewed,
        long evaluationsCompleted
) {
}
