package com.internship.service;

import com.internship.dao.MeetingDAO;
import com.internship.model.Meeting;
import org.junit.jupiter.api.Test;
import java.lang.reflect.Proxy;
import java.sql.*;
import java.time.*;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;

class MeetingServiceTest {
    private static final Instant NOW = Instant.parse("2026-10-07T14:00:00Z");
    private static MeetingRequest request(List<Integer> ids) {
        return new MeetingRequest(1," Weekly meeting ",null,"Room 1",NOW.plusSeconds(3600),NOW.plusSeconds(7200),ids);
    }
    @Test void rejectsDuplicateParticipantsBeforeOpeningDatabase() {
        assertThrows(IllegalArgumentException.class, () -> request(List.of(1,1)));
    }
    @Test void requestDefensivelyCopiesAndSortsParticipants() {
        List<Integer> source = new ArrayList<>(List.of(2,1));
        MeetingRequest q = request(source); source.clear();
        assertEquals(List.of(1,2), q.enrollmentIds()); assertEquals("Weekly meeting",q.title());
        assertThrows(UnsupportedOperationException.class, () -> q.enrollmentIds().add(3));
    }
    @Test void rejectsReversedOrOutOfRangeTimes() {
        assertThrows(IllegalArgumentException.class, () -> new MeetingRequest(1,"a",null,"b",NOW,NOW,List.of(1)));
        assertThrows(IllegalArgumentException.class, () -> new MeetingRequest(1,"a",null,"b",NOW,Instant.parse("2040-01-01T00:00:00Z"),List.of(1)));
    }
    @Test void createCommitsParticipantsAndMeetingTogether() throws Exception {
        Harness h = new Harness(); assertEquals(31,h.service().create(9,request(List.of(1))));
        assertTrue(h.committed); assertFalse(h.rolledBack); assertTrue(h.closed); assertTrue(h.wrote);
    }
    @Test void internCannotSchedule() {
        Harness h = new Harness(); h.role="INTERN";
        assertThrows(SecurityException.class, () -> h.service().create(9,request(List.of(1))));
        assertTrue(h.rolledBack); assertFalse(h.wrote);
    }
    @Test void mentorRequiresCurrentAssignmentForEveryParticipant() {
        Harness h = new Harness(); h.role="MENTOR"; h.allowed=false;
        assertThrows(SecurityException.class, () -> h.service().create(9,request(List.of(1))));
        assertEquals(9L,h.checkedMentor); assertFalse(h.wrote); assertTrue(h.rolledBack);
    }
    @Test void sqlFailureRollsBackAndCloses() {
        Harness h = new Harness(); h.failWrite=true;
        assertThrows(SQLException.class, () -> h.service().create(9,request(List.of(1))));
        assertTrue(h.rolledBack); assertFalse(h.committed); assertTrue(h.closed);
    }
    @Test void staleRevisionNeverWrites() {
        Harness h = new Harness();
        assertThrows(IllegalStateException.class, () -> h.service().update(9,31,2,request(List.of(1))));
        assertFalse(h.wrote); assertTrue(h.rolledBack);
    }
    @Test void formerMentorCannotCancelEvenIfOriginalOrganizer() {
        Harness h = new Harness(); h.role="MENTOR"; h.allowed=false;
        assertThrows(SecurityException.class, () -> h.service().cancel(9,31,1));
        assertFalse(h.wrote); assertTrue(h.rolledBack);
    }
    @Test void hrCanCancelAfterMentorChanges() throws Exception {
        Harness h = new Harness(); h.service().cancel(9,31,1);
        assertTrue(h.wrote); assertTrue(h.committed);
    }
    @Test void updateChecksOldAndNewParticipants() throws Exception {
        Harness h = new Harness(); h.role="MENTOR";
        h.service().update(9,31,1,request(List.of(2)));
        assertEquals(List.of(1,2),h.checkedIds); assertTrue(h.committed);
    }
    @Test void pastMeetingRejectedWithoutConnection() {
        var s = new MeetingService(() -> { fail("DB opened"); return null; },new MeetingDAO(),Clock.fixed(NOW.plusSeconds(4000),ZoneOffset.UTC));
        assertThrows(IllegalArgumentException.class, () -> s.create(9,request(List.of(1))));
    }
    static class Harness {
        String role="HR"; boolean allowed=true,failWrite,wrote,committed,rolledBack,closed;
        Long checkedMentor; List<Integer> checkedIds=new ArrayList<>();
        Connection connection = (Connection) Proxy.newProxyInstance(Connection.class.getClassLoader(),new Class[]{Connection.class},(p,m,a)->switch(m.getName()) {
            case "createStatement" -> Proxy.newProxyInstance(Statement.class.getClassLoader(),new Class[]{Statement.class},(sp,sm,sa)-> {
                if(sm.getName().equals("execute")) { assertEquals("SET SESSION time_zone = '+00:00'",sa[0]); return false; } return null;
            });
            case "commit" -> {committed=true; yield null;}
            case "rollback" -> {rolledBack=true; yield null;}
            case "close" -> {closed=true; yield null;}
            default -> null;
        });
        MeetingDAO dao = new MeetingDAO() {
            @Override public String lockActor(Connection c,long actor) {return role;}
            @Override public boolean lockProgram(Connection c,int program) {return true;}
            @Override public boolean lockParticipant(Connection c,int program,int enrollment,Long mentor) {
                checkedMentor=mentor;checkedIds.add(enrollment);return allowed;
            }
            @Override public long create(Connection c,long actor,MeetingRequest q) throws SQLException {
                if(failWrite)throw new SQLException("test");wrote=true;return 31;
            }
            @Override public Meeting lockMeeting(Connection c,long id) {
                return new Meeting(id,1,9,"Meeting",null,"Room",NOW.plusSeconds(3600),NOW.plusSeconds(7200),"SCHEDULED",1,List.of(1));
            }
            @Override public void update(Connection c,long id,MeetingRequest q) {wrote=true;}
            @Override public void cancel(Connection c,long id) {wrote=true;}
        };
        MeetingService service() {return new MeetingService(()->connection,dao,Clock.fixed(NOW,ZoneOffset.UTC));}
    }
}
