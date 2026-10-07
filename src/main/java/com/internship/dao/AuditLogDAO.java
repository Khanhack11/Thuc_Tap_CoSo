package com.internship.dao;

import com.internship.model.AuditLog;
import com.internship.service.AuditLogService.Query;
import com.internship.service.AuditLogService.Page;
import com.internship.util.DBConnection;
import java.sql.*;
import java.util.*;

public class AuditLogDAO {
    public void insert(Long actor, String action, String type, Long object, String result) throws SQLException {
        try (Connection c = DBConnection.getConnection(); PreparedStatement s = c.prepareStatement(
                "INSERT INTO audit_logs(actor_user_id,action,object_type,object_id,result) VALUES(?,?,?,?,?)")) {
            s.setObject(1, actor, Types.BIGINT); s.setString(2, action); s.setString(3, type);
            s.setObject(4, object, Types.BIGINT); s.setString(5, result); s.executeUpdate();
        }
    }
    public Page search(Query q) throws SQLException {
        List<Object> args = new ArrayList<>();
        StringBuilder where = new StringBuilder(" WHERE 1=1");
        add(where,args,"actor_user_id = ?",q.actorUserId());
        add(where,args,"action = ?",q.action());
        add(where,args,"object_type = ?",q.objectType());
        add(where,args,"result = ?",q.result());
        add(where,args,"occurred_at >= ?",q.from() == null ? null : Timestamp.from(q.from()));
        add(where,args,"occurred_at < ?",q.to() == null ? null : Timestamp.from(q.to()));
        try (Connection c = DBConnection.getConnection()) {
            long total;
            try (PreparedStatement s = c.prepareStatement("SELECT COUNT(*) FROM audit_logs" + where)) {
                bind(s,args); try (ResultSet r = s.executeQuery()) { r.next(); total = r.getLong(1); }
            }
            List<AuditLog> logs = new ArrayList<>();
            try (PreparedStatement s = c.prepareStatement("SELECT * FROM audit_logs" + where
                    + " ORDER BY occurred_at DESC,audit_id DESC LIMIT ? OFFSET ?")) {
                bind(s,args); s.setInt(args.size()+1,q.size());
                s.setLong(args.size()+2,(long)(q.page()-1)*q.size());
                try (ResultSet r = s.executeQuery()) {
                    while(r.next()) logs.add(new AuditLog(r.getLong("audit_id"),
                            nullable(r,"actor_user_id"),r.getString("action"),r.getString("object_type"),
                            nullable(r,"object_id"),r.getTimestamp("occurred_at").toInstant(),r.getString("result")));
                }
            }
            return new Page(List.copyOf(logs),total,q.page(),q.size());
        }
    }
    private static Long nullable(ResultSet r,String column) throws SQLException {
        long value=r.getLong(column); return r.wasNull()?null:value;
    }
    private static void add(StringBuilder w,List<Object> a,String clause,Object value) {
        if(value!=null) { w.append(" AND ").append(clause); a.add(value); }
    }
    private static void bind(PreparedStatement s,List<Object> args) throws SQLException {
        for(int i=0;i<args.size();i++) s.setObject(i+1,args.get(i));
    }
}
