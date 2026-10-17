package com.internship.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Đảm bảo toàn bộ request và response của hệ thống đều sử dụng UTF-8
 * Giải quyết dứt điểm lỗi font chữ tiếng Việt, vỡ ký tự và mojibake.
 */
@WebFilter("/*")
public class CharacterEncodingFilter implements Filter {

    private static final String ENCODING = "UTF-8";

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain chain)
            throws IOException, ServletException {
        if (servletRequest instanceof HttpServletRequest request) {
            if (request.getCharacterEncoding() == null) {
                request.setCharacterEncoding(ENCODING);
            }
        }
        if (servletResponse instanceof HttpServletResponse response) {
            response.setCharacterEncoding(ENCODING);
        }
        chain.doFilter(servletRequest, servletResponse);
    }
}
