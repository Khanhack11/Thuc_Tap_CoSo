package com.internship.model;

import java.time.Instant;

public record AuditLog(long id, Long actorUserId, String action, String objectType,
                       Long objectId, Instant occurredAt, String result) {}
