package com.internship.service;

import com.internship.controller.Be4ApiChecks;
import org.junit.jupiter.api.Test;

/** Runs the existing BE4 checks as part of the normal Maven test phase. */
class Be4ChecksTest {

    @Test
    void taskRules() throws Exception {
        TaskServiceTest.main(new String[0]);
    }

    @Test
    void reportEvaluationAndDashboardRules() throws Exception {
        Be4WorkflowChecks.main(new String[0]);
    }

    @Test
    void httpBoundaryRules() throws Exception {
        Be4ApiChecks.main(new String[0]);
    }
}
