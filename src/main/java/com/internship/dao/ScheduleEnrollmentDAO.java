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

    public record InternDetail(int enrollmentId, String email, String fullName, String university,
                              String major, String phone, String programName, Integer programId, String status) { }

    public java.util.List<InternDetail> listEnrolledInterns(Connection connection) throws SQLException {
        String sql = """
                SELECT e.enrollment_id, COALESCE(u.email, ip.email) AS email,
                       COALESCE(ip.full_name, u.full_name) AS full_name,
                       ip.university, ip.major, ip.phone,
                       p.program_name, p.program_id, e.status
                FROM users u
                LEFT JOIN intern_profiles ip ON ip.user_id = u.user_id
                LEFT JOIN program_enrollments e ON e.intern_profile_id = ip.profile_id AND e.status = 'ACTIVE'
                LEFT JOIN internship_programs p ON p.program_id = e.program_id
                WHERE u.role_id = 4
                ORDER BY (e.enrollment_id IS NOT NULL) DESC, e.enrollment_id DESC, u.user_id ASC
                """;
        try (PreparedStatement s = connection.prepareStatement(sql);
             ResultSet r = s.executeQuery()) {
            java.util.List<InternDetail> list = new java.util.ArrayList<>();
            while (r.next()) {
                list.add(new InternDetail(
                        r.getInt("enrollment_id"),
                        r.getString("email"),
                        r.getString("full_name"),
                        r.getString("university"),
                        r.getString("major"),
                        r.getString("phone"),
                        r.getString("program_name"),
                        (Integer) r.getObject("program_id"),
                        r.getString("status")
                ));
            }
            return java.util.List.copyOf(list);
        }
    }

    public Integer findEnrollmentIdByEmail(String email, Connection connection) throws SQLException {
        if (email == null || email.isBlank()) return null;
        String sql = """
                SELECT e.enrollment_id
                FROM program_enrollments e
                JOIN intern_profiles ip ON ip.profile_id = e.intern_profile_id
                LEFT JOIN users u ON u.user_id = ip.user_id
                WHERE (LOWER(TRIM(u.email)) = LOWER(?) OR LOWER(TRIM(ip.email)) = LOWER(?))
                  AND e.status = 'ACTIVE'
                LIMIT 1
                """;
        try (PreparedStatement s = connection.prepareStatement(sql)) {
            String trimmed = email.trim();
            s.setString(1, trimmed);
            s.setString(2, trimmed);
            try (ResultSet r = s.executeQuery()) {
                return r.next() ? r.getInt("enrollment_id") : null;
            }
        }
    }

    public Integer findEnrollmentIdByEmail(String email) throws SQLException {
        try (Connection conn = com.internship.util.DBConnection.getConnection()) {
            return findEnrollmentIdByEmail(email, conn);
        }
    }

    public java.util.List<InternDetail> listEnrolledInterns() throws SQLException {
        try (Connection conn = com.internship.util.DBConnection.getConnection()) {
            return listEnrolledInterns(conn);
        }
    }

    public java.util.Map<Integer, String> getEnrollmentEmailMap(Connection connection) throws SQLException {
        String sql = """
                SELECT e.enrollment_id, COALESCE(u.email, ip.email) AS email
                FROM program_enrollments e
                JOIN intern_profiles ip ON ip.profile_id = e.intern_profile_id
                LEFT JOIN users u ON u.user_id = ip.user_id
                """;
        try (PreparedStatement s = connection.prepareStatement(sql);
             ResultSet r = s.executeQuery()) {
            java.util.Map<Integer, String> map = new java.util.HashMap<>();
            while (r.next()) {
                String mail = r.getString("email");
                if (mail != null) {
                    map.put(r.getInt("enrollment_id"), mail);
                }
            }
            return map;
        }
    }
}
