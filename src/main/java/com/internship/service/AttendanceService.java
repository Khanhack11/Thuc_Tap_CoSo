package com.internship.service;

import com.internship.dao.AttendanceDAO;
import com.internship.dao.WorkScheduleDAO;
import com.internship.model.Attendance;
import com.internship.model.User;
import com.internship.model.WorkSchedule;
import com.internship.util.ConnectionProvider;
import com.internship.util.DBConnection;
import com.internship.util.UserRoleChecks;

import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

public class AttendanceService {

    private final AttendanceDAO attendanceDAO;
    private final WorkScheduleDAO workScheduleDAO;
    private final ConnectionProvider connections;

    public AttendanceService() {
        this(new AttendanceDAO(), new WorkScheduleDAO(), DBConnection::getConnection);
    }

    public AttendanceService(AttendanceDAO attendanceDAO, WorkScheduleDAO workScheduleDAO, ConnectionProvider connections) {
        this.attendanceDAO = Objects.requireNonNull(attendanceDAO);
        this.workScheduleDAO = Objects.requireNonNull(workScheduleDAO);
        this.connections = Objects.requireNonNull(connections);
    }

    public void checkIn(User actor, int enrollmentId) throws SQLException {
        if (actor == null || !UserRoleChecks.isIntern(actor)) {
            throw new IllegalArgumentException("Ch? th?c t?p sinh m?i ???c ch?m c?ng.");
        }
        
        LocalDate today = LocalDate.now();
        LocalDateTime now = LocalDateTime.now();

        try (Connection c = connections.getConnection()) {
            c.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);
            c.setAutoCommit(false);
            try {
                // Validate enrollment owner
                // In a real app we might use enrollmentDAO.findById to check owner.
                // For now, WorkScheduleDAO.list with actor's userId can verify if they have a schedule today.
                List<WorkSchedule> schedules = workScheduleDAO.list(actor.getUserId(), enrollmentId, null, today, today, c);
                if (schedules.isEmpty()) {
                    throw new IllegalArgumentException("Kh?ng c? ca l?m vi?c n?o ???c l?n l?ch cho h?m nay.");
                }
                WorkSchedule todaySchedule = null;
                for (WorkSchedule s : schedules) {
                    if ("ACTIVE".equals(s.status())) {
                        todaySchedule = s;
                        break;
                    }
                }
                if (todaySchedule == null) {
                    throw new IllegalArgumentException("Kh?ng c? ca l?m vi?c ACTIVE n?o cho h?m nay.");
                }
                if (todaySchedule.approvedLeave()) {
                    throw new IllegalArgumentException("B?n ?? ???c duy?t ngh? ph?p cho h?m nay, kh?ng th? ch?m c?ng.");
                }

                Attendance existing = attendanceDAO.findByEnrollmentAndDate(enrollmentId, today, c);
                if (existing != null) {
                    throw new IllegalArgumentException("B?n ?? check-in cho ng?y h?m nay r?i.");
                }

                attendanceDAO.checkIn(enrollmentId, today, java.sql.Timestamp.valueOf(now), c);
                c.commit();
            } catch (SQLException | IllegalArgumentException e) {
                c.rollback();
                throw e;
            }
        }
    }

    public void checkOut(User actor, int enrollmentId) throws SQLException {
        if (actor == null || !UserRoleChecks.isIntern(actor)) {
            throw new IllegalArgumentException("Ch? th?c t?p sinh m?i ???c ch?m c?ng.");
        }
        
        LocalDate today = LocalDate.now();
        LocalDateTime now = LocalDateTime.now();

        try (Connection c = connections.getConnection()) {
            c.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);
            c.setAutoCommit(false);
            try {
                List<WorkSchedule> schedules = workScheduleDAO.list(actor.getUserId(), enrollmentId, null, today, today, c);
                if (schedules.isEmpty()) {
                    throw new IllegalArgumentException("Kh?ng c? ca l?m vi?c n?o cho h?m nay.");
                }

                Attendance existing = attendanceDAO.findByEnrollmentAndDate(enrollmentId, today, c);
                if (existing == null) {
                    throw new IllegalArgumentException("B?n ch?a check-in cho ng?y h?m nay.");
                }
                if (existing.getCheckOutTime() != null) {
                    throw new IllegalArgumentException("B?n ?? check-out r?i.");
                }

                attendanceDAO.checkOut(existing.getAttendanceId(), java.sql.Timestamp.valueOf(now), c);
                c.commit();
            } catch (SQLException | IllegalArgumentException e) {
                c.rollback();
                throw e;
            }
        }
    }

    // Report functionality
    public static class AttendanceReportRow {
        public int enrollmentId;
        public String internName;
        public String programName;
        public LocalDate workDate;
        public LocalTime startTime;
        public LocalTime endTime;
        public LocalDateTime checkInTime;
        public LocalDateTime checkOutTime;
        public boolean approvedLeave;
        public String status; // 'PRESENT', 'ABSENT', 'LEAVE', 'MISSING_CHECKOUT'
        public double workedHours;
    }

    public List<AttendanceReportRow> getReport(User actor, Integer enrollmentId, Integer programId, LocalDate fromDate, LocalDate toDate) throws SQLException {
        if (actor == null) throw new IllegalArgumentException("Kh?ng c? quy?n.");
        Long ownerId = UserRoleChecks.isIntern(actor) ? actor.getUserId() : null;
        if (UserRoleChecks.isIntern(actor) && enrollmentId == null) {
            // Must specify enrollment or we just filter by ownerId in dao.
        }
        
        try (Connection c = connections.getConnection()) {
            List<WorkSchedule> schedules = workScheduleDAO.list(ownerId, enrollmentId, programId, fromDate, toDate, c);
            List<Attendance> attendances = attendanceDAO.getAttendanceReport(programId != null ? programId : 0, enrollmentId != null ? enrollmentId : 0, fromDate, toDate, c);
            
            List<AttendanceReportRow> report = new ArrayList<>();
            for (WorkSchedule s : schedules) {
                if (!"ACTIVE".equals(s.status())) continue;
                
                AttendanceReportRow row = new AttendanceReportRow();
                row.enrollmentId = s.enrollmentId();
                row.internName = s.internName();
                row.programName = s.programName();
                row.workDate = s.workDate();
                row.startTime = s.startTime();
                row.endTime = s.endTime();
                row.approvedLeave = s.approvedLeave();
                
                // Find matching attendance
                Attendance a = attendances.stream().filter(att -> att.getEnrollmentId() == s.enrollmentId() && att.getWorkDate().equals(s.workDate())).findFirst().orElse(null);
                if (a != null) {
                    row.checkInTime = a.getCheckInTime();
                    row.checkOutTime = a.getCheckOutTime();
                    if (row.checkOutTime == null) {
                        row.status = "MISSING_CHECKOUT";
                        row.workedHours = 0;
                    } else {
                        row.status = "PRESENT";
                        row.workedHours = Math.max(0, Duration.between(row.checkInTime, row.checkOutTime).toMinutes() / 60.0);
                    }
                } else {
                    if (row.approvedLeave) {
                        row.status = "LEAVE";
                    } else {
                        row.status = "ABSENT";
                    }
                    row.workedHours = 0;
                }
                report.add(row);
            }
            return report;
        }
    }
}
