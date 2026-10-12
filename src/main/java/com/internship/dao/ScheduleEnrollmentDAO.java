package com.internship.dao;

import java.sql.*;
import java.time.LocalDate;

/** Parent enrollment locks serialize schedule/leave mutations for the same intern. */
public class ScheduleEnrollmentDAO {
    public record Context(int enrollmentId, long userId, String enrollmentStatus,
                          String programStatus, LocalDate startDate, LocalDate endDate) { }

    public Context find(int id, boolean lock, Connection connection) throws SQLException {
        if (lock) {
            Integer program = null;
            try (PreparedStatement s = connection.prepareStatement("SELECT program_id FROM program_enrollments WHERE enrollment_id=?")) {
                s.setInt(1, id);
                try (ResultSet r = s.executeQuery()) { if (r.next()) program = r.getInt(1); }
            }
            if (program == null) return null;
            new InternshipProgramDAO().lockProgram(program, connection);
        }
        String sql = """
                SELECT e.enrollment_id, ip.user_id, e.status AS enrollment_status,
                       p.status AS program_status, p.start_date, p.end_date
                FROM program_enrollments e
                JOIN intern_profiles ip ON ip.profile_id=e.intern_profile_id
                JOIN internship_programs p ON p.program_id=e.program_id
                WHERE e.enrollment_id=?
                """ + (lock ? " FOR UPDATE" : "");
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? new Context(result.getInt("enrollment_id"), result.getLong("user_id"),
                        result.getString("enrollment_status"), result.getString("program_status"),
                        result.getDate("start_date").toLocalDate(), result.getDate("end_date").toLocalDate()) : null;
            }
        }
    }
}
