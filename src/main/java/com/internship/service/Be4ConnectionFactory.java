package com.internship.service;

import java.sql.Connection;
import java.sql.SQLException;

@FunctionalInterface
public interface Be4ConnectionFactory {
    Connection open() throws SQLException;
}
