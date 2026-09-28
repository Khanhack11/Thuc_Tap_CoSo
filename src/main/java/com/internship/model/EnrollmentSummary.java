package com.internship.model;

import java.time.LocalDate;

/** Minimal BE3 enrollment data required to navigate BE4 screens. */
public record EnrollmentSummary(int enrollmentId, String internName, String programName,
                                String status, LocalDate startDate, LocalDate endDate) {
}
