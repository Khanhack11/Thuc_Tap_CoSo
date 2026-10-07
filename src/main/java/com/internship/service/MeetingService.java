package com.internship.service;

import com.internship.dao.MeetingDAO;
import com.internship.model.Meeting;
import com.internship.util.DBConnection;
import java.sql.*;
import java.time.*;
import java.util.*;

/** BE1 scheduling source. SMTP/notification side effects are intentionally outside Task 35.1. */
public class MeetingService {
    @FunctionalInterface public interface ConnectionFactory { Connection open() throws SQLException; }
    private final ConnectionFactory connections;
    private final MeetingDAO dao;
    private final Clock clock;
    public MeetingService() { this(DBConnection::getConnection, new MeetingDAO(), Clock.systemUTC()); }
    public MeetingService(ConnectionFactory connections, MeetingDAO dao, Clock clock) {
        this.connections = Objects.requireNonNull(connections);
        this.dao = Objects.requireNonNull(dao); this.clock = Objects.requireNonNull(clock);
    }

    public long create(long actor, MeetingRequest q) throws SQLException {
        positive(actor); Objects.requireNonNull(q); future(q);
        return transaction(c -> {
            String role = writer(c, actor);
            validateParticipants(c, actor, role, q.programId(), q.enrollmentIds());
            return dao.create(c, actor, q);
        });
    }

    public void update(long actor, long meetingId, int expectedRevision, MeetingRequest q) throws SQLException {
        positive(actor); positive(meetingId); Objects.requireNonNull(q); future(q);
        transaction(c -> {
            String role = writer(c, actor);
            Meeting old = existing(c, meetingId, expectedRevision);
            if (!"SCHEDULED".equals(old.status())) throw new IllegalStateException("Meeting cancelled");
            if (old.programId() != q.programId()) throw new IllegalArgumentException("Program cannot change");
            authorizeExisting(c, actor, role, old);
            validateParticipants(c, actor, role, q.programId(), q.enrollmentIds());
            dao.update(c, meetingId, q); return null;
        });
    }

    public void cancel(long actor, long meetingId, int expectedRevision) throws SQLException {
        positive(actor); positive(meetingId);
        transaction(c -> {
            String role = writer(c, actor);
            Meeting old = existing(c, meetingId, expectedRevision);
            authorizeExisting(c, actor, role, old);
            if ("SCHEDULED".equals(old.status())) dao.cancel(c, meetingId);
            return null;
        });
    }

    private Meeting existing(Connection c, long id, int revision) throws SQLException {
        if (revision < 1) throw new IllegalArgumentException("Invalid revision");
        Meeting old = dao.lockMeeting(c, id);
        if (old == null) throw new IllegalArgumentException("Meeting not found");
        if (old.revision() != revision) throw new IllegalStateException("Meeting changed; reload first");
        return old;
    }
    private String writer(Connection c, long actor) throws SQLException {
        String role = dao.lockActor(c, actor);
        if (role == null || !Set.of("ADMIN", "HR", "MENTOR").contains(role))
            throw new SecurityException("Active scheduling role required");
        return role;
    }
    private void authorizeExisting(Connection c, long actor, String role, Meeting old) throws SQLException {
        if ("MENTOR".equals(role)) {
            if (old.organizerUserId() != actor) throw new SecurityException("Only organizing mentor may modify");
            validateParticipants(c, actor, role, old.programId(), old.enrollmentIds());
        }
    }
    private void validateParticipants(Connection c, long actor, String role, int program, List<Integer> ids)
            throws SQLException {
        if (!dao.lockProgram(c, program)) throw new IllegalArgumentException("Program unavailable");
        Long mentor = "MENTOR".equals(role) ? actor : null;
        for (int id : ids)
            if (!dao.lockParticipant(c, program, id, mentor))
                throw new SecurityException("Participant outside permitted active scope");
    }
    private void future(MeetingRequest q) {
        if (!q.startsAt().isAfter(clock.instant())) throw new IllegalArgumentException("Meeting must start in future");
    }
    private static void positive(long id) {
        if (id <= 0) throw new IllegalArgumentException("Invalid ID");
    }
    @FunctionalInterface private interface Work<T> { T run(Connection c) throws SQLException; }
    private <T> T transaction(Work<T> work) throws SQLException {
        try (Connection c = connections.open()) {
            c.setAutoCommit(false);
            try {
                try (Statement s = c.createStatement()) { s.execute("SET SESSION time_zone = '+00:00'"); }
                T result = work.run(c); c.commit(); return result;
            } catch (SQLException | RuntimeException e) {
                try { c.rollback(); } catch (SQLException rollback) { e.addSuppressed(rollback); }
                throw e;
            }
        }
    }
}
