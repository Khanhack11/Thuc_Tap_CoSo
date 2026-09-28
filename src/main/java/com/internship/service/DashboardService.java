package com.internship.service;

import com.internship.dao.DashboardDAO;
import com.internship.dao.TaskAccessDAO;
import com.internship.model.HrDashboard;
import com.internship.model.MentorDashboard;
import com.internship.util.DBConnection;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.SQLException;

public class DashboardService {
    private final Be4ConnectionFactory connections;
    private final DashboardDAO dashboards;
    private final TaskAccessDAO access;

    public DashboardService() {
        this(DBConnection::getConnection, new DashboardDAO(), new TaskAccessDAO());
    }

    DashboardService(Be4ConnectionFactory connections, DashboardDAO dashboards, TaskAccessDAO access) {
        this.connections = connections;
        this.dashboards = dashboards;
        this.access = access;
    }

    public HrDashboard getHrDashboard(long actorUserId) throws SQLException {
        requirePositive(actorUserId);
        try (Connection connection = connections.open()) {
            if (!access.isActiveHrOrAdmin(connection, actorUserId)) {
                throw new SecurityException("Chỉ HR/ADMIN được xem dashboard HR");
            }
            long active = dashboards.countEnrollments(connection, "ACTIVE");
            long completed = dashboards.countEnrollments(connection, "COMPLETED");
            BigDecimal rate = completionRate(completed, active + completed);
            return new HrDashboard(
                    dashboards.countDistinctInterns(connection), active, completed, rate,
                    dashboards.internsByUniversity(connection),
                    dashboards.internsByMajor(connection),
                    dashboards.activeInternsByMentor(connection));
        }
    }

    public MentorDashboard getMentorDashboard(long mentorUserId) throws SQLException {
        requirePositive(mentorUserId);
        try (Connection connection = connections.open()) {
            if (!access.isActiveMentor(connection, mentorUserId)) {
                throw new SecurityException("Chỉ mentor đang hoạt động được xem dashboard mentor");
            }
            Integer mentorId = dashboards.findMentorIdByUser(connection, mentorUserId);
            if (mentorId == null) {
                throw new IllegalStateException("Tài khoản mentor chưa có hồ sơ mentor");
            }
            return new MentorDashboard(
                    dashboards.countActiveInternsForMentor(connection, mentorId),
                    dashboards.countTasksForMentor(connection, mentorId, "TODO"),
                    dashboards.countTasksForMentor(connection, mentorId, "IN_PROGRESS"),
                    dashboards.countTasksForMentor(connection, mentorId, "DONE"),
                    dashboards.countReportsForMentor(connection, mentorId, "SUBMITTED"),
                    dashboards.countReportsForMentor(connection, mentorId, "REVIEWED"),
                    dashboards.countEvaluationsForMentor(connection, mentorId));
        }
    }

    static BigDecimal completionRate(long completed, long eligible) {
        if (eligible == 0) {
            return BigDecimal.ZERO.setScale(2);
        }
        return BigDecimal.valueOf(completed)
                .multiply(BigDecimal.valueOf(100))
                .divide(BigDecimal.valueOf(eligible), 2, RoundingMode.HALF_UP);
    }

    private static void requirePositive(long id) {
        if (id <= 0) {
            throw new IllegalArgumentException("userId phải lớn hơn 0");
        }
    }
}
