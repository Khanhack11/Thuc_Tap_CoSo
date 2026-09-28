package com.internship.model;

import java.math.BigDecimal;
import java.util.List;

public record HrDashboard(
        long totalInterns,
        long activeEnrollments,
        long completedEnrollments,
        BigDecimal completionRatePercent,
        List<DashboardCount> internsByUniversity,
        List<DashboardCount> internsByMajor,
        List<DashboardCount> activeInternsByMentor
) {
}
