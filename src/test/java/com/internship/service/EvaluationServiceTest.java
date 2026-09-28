package com.internship.service;

import com.internship.dao.EvaluationDAO;
import com.internship.dao.TaskAccessDAO;
import com.internship.model.EvaluationSummary;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Proxy;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class EvaluationServiceTest {
    @Test
    void hrCanListEvaluationSummaries() throws SQLException {
        EvaluationSummary summary = new EvaluationSummary(1, 2, "Intern", "Program",
                "Mentor", new BigDecimal("85.50"), "Good", null);
        EvaluationService service = new EvaluationService(this::connection,
                new EvaluationDAO() {
                    @Override
                    public List<EvaluationSummary> findAllSummaries(Connection connection) {
                        return List.of(summary);
                    }
                }, new TaskAccessDAO() {
                    @Override
                    public boolean isActiveHrOrAdmin(Connection connection, long userId) {
                        return userId == 7;
                    }
                });

        assertEquals(List.of(summary), service.findAllForHr(7));
        assertThrows(SecurityException.class, () -> service.findAllForHr(8));
    }

    private Connection connection() {
        return (Connection) Proxy.newProxyInstance(Connection.class.getClassLoader(),
                new Class<?>[]{Connection.class}, (proxy, method, args) -> {
                    if ("close".equals(method.getName())) return null;
                    throw new UnsupportedOperationException(method.getName());
                });
    }
}
