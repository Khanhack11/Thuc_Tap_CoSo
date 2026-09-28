package com.internship.controller;

import com.internship.model.Role;
import com.internship.model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.Map;

/** Standalone HTTP-boundary checks without changing the shared Maven POM. */
public class Be4ApiChecks {
    public static void main(String[] args) throws Exception {
        Be4ApiServlet servlet = new Be4ApiServlet();
        Session session = new Session("INTERN");
        Result token = call(servlet, session, false, "/intern/be4", "/csrf", null, null);
        check(token.status == 200 && token.body.contains("csrfToken"), "CSRF token GET");
        Result missingToken = call(servlet, session, true, "/intern/be4", "/progress",
                "application/x-www-form-urlencoded", null);
        check(missingToken.status == 403, "POST without CSRF rejected");
        Result wrongMedia = call(servlet, session, true, "/intern/be4", "/progress",
                "application/json", null);
        check(wrongMedia.status == 415, "POST wrong media rejected");
        Result missingRoute = call(servlet, session, false, "/intern/be4", "/does-not-exist", null, null);
        check(missingRoute.status == 404, "unknown route rejected");
        Result wrongRole = call(servlet, session, false, "/mentor/be4", "/csrf", null, null);
        check(wrongRole.status == 403, "wrong role rejected");
        String storedToken = (String) session.values.get("be4CsrfToken");
        Result validToken = call(servlet, session, true, "/intern/be4", "/does-not-exist",
                "application/x-www-form-urlencoded", storedToken);
        check(validToken.status == 404, "valid CSRF reaches route dispatch");
        check(Be4Json.stringify(Be4Json.fields("x", "<tag>\n\"&"))
                .contains("\\u003ctag\\u003e\\n\\\"\\u0026"), "JSON escaping");
        System.out.println("BE4 HTTP boundary checks passed: 7");
    }

    private static Result call(Be4ApiServlet servlet, Session session, boolean post,
                               String area, String path, String contentType, String token) throws Exception {
        StringWriter body = new StringWriter();
        PrintWriter writer = new PrintWriter(body);
        int[] status = {200};
        HttpServletRequest request = (HttpServletRequest) Proxy.newProxyInstance(
                Be4ApiChecks.class.getClassLoader(), new Class<?>[]{HttpServletRequest.class},
                (proxy, method, arguments) -> switch (method.getName()) {
                    case "getSession" -> session.proxy;
                    case "getServletPath" -> area;
                    case "getPathInfo" -> path;
                    case "getContentType" -> contentType;
                    case "getHeader" -> token;
                    case "getParameter" -> null;
                    default -> null;
                });
        HttpServletResponse response = (HttpServletResponse) Proxy.newProxyInstance(
                Be4ApiChecks.class.getClassLoader(), new Class<?>[]{HttpServletResponse.class},
                (proxy, method, arguments) -> {
                    if ("setStatus".equals(method.getName())) status[0] = (int) arguments[0];
                    if ("getWriter".equals(method.getName())) return writer;
                    return null;
                });
        if (post) servlet.doPost(request, response);
        else servlet.doGet(request, response);
        writer.flush();
        return new Result(status[0], body.toString());
    }

    private static void check(boolean condition, String label) {
        if (!condition) throw new AssertionError(label);
    }

    private record Result(int status, String body) {
    }

    private static final class Session {
        private final Map<String, Object> values = new HashMap<>();
        private final HttpSession proxy;

        private Session(String roleName) {
            User user = new User();
            user.setUserId(1);
            Role role = new Role();
            role.setRoleName(roleName);
            user.setRole(role);
            values.put("currentUser", user);
            proxy = (HttpSession) Proxy.newProxyInstance(
                    Be4ApiChecks.class.getClassLoader(), new Class<?>[]{HttpSession.class},
                    (unused, method, arguments) -> switch (method.getName()) {
                        case "getAttribute" -> values.get((String) arguments[0]);
                        case "setAttribute" -> {
                            values.put((String) arguments[0], arguments[1]);
                            yield null;
                        }
                        default -> null;
                    });
        }
    }
}
