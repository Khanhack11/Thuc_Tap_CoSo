package com.internship.dao;

import com.internship.model.Attendance;
import com.internship.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class AttendanceDAO {
    
    public Attendance findByEnrollmentAndDate(int enrollmentId, LocalDate date, Connection conn) throws SQLException {
        String sql = "SELECT * FROM attendances WHERE enrollment_id = ? AND work_date = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, enrollmentId);
            stmt.setDate(2, Date.valueOf(date));
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public void checkIn(int enrollmentId, LocalDate date, Timestamp time, Connection conn) throws SQLException {
        String sql = "INSERT INTO attendances (enrollment_id, work_date, check_in_time) VALUES (?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, enrollmentId);
            stmt.setDate(2, Date.valueOf(date));
            stmt.setTimestamp(3, time);
            stmt.executeUpdate();
        }
    }

    public void checkOut(int attendanceId, Timestamp time, Connection conn) throws SQLException {
        String sql = "UPDATE attendances SET check_out_time = ? WHERE attendance_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setTimestamp(1, time);
            stmt.setInt(2, attendanceId);
            stmt.executeUpdate();
        }
    }

    public List<Attendance> getAttendanceReport(int programId, int enrollmentId, LocalDate fromDate, LocalDate toDate, Connection conn) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT a.*, ip.full_name as intern_name, p.program_name " +
            "FROM attendances a " +
            "JOIN program_enrollments pe ON a.enrollment_id = pe.enrollment_id " +
            "JOIN intern_profiles ip ON pe.intern_profile_id = ip.profile_id " +
            "JOIN internship_programs p ON pe.program_id = p.program_id " +
            "WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();
        
        if (programId > 0) {
            sql.append(" AND pe.program_id = ?");
            params.add(programId);
        }
        if (enrollmentId > 0) {
            sql.append(" AND a.enrollment_id = ?");
            params.add(enrollmentId);
        }
        if (fromDate != null) {
            sql.append(" AND a.work_date >= ?");
            params.add(Date.valueOf(fromDate));
        }
        if (toDate != null) {
            sql.append(" AND a.work_date <= ?");
            params.add(Date.valueOf(toDate));
        }
        sql.append(" ORDER BY a.work_date DESC");

        List<Attendance> result = new ArrayList<>();
        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Attendance a = mapRow(rs);
                    a.setInternName(rs.getString("intern_name"));
                    a.setProgramName(rs.getString("program_name"));
                    result.add(a);
                }
            }
        }
        return result;
    }

    private Attendance mapRow(ResultSet rs) throws SQLException {
        Attendance a = new Attendance();
        a.setAttendanceId(rs.getInt("attendance_id"));
        a.setEnrollmentId(rs.getInt("enrollment_id"));
        a.setWorkDate(rs.getDate("work_date").toLocalDate());
        a.setCheckInTime(rs.getTimestamp("check_in_time").toLocalDateTime());
        Timestamp out = rs.getTimestamp("check_out_time");
        if (out != null) a.setCheckOutTime(out.toLocalDateTime());
        a.setNotes(rs.getString("notes"));
        a.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        return a;
    }
}
