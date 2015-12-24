#import "ExpectFailureWithMessage.h"
#import "CedarMatchers.h"
#import "CDRSpecFailure.h"

using namespace Cedar::Matchers;

void expectFailureWithMessage(NSString *message, CDRSpecBlock block) {
    @try {
        block();
    }
    @catch (CDRSpecFailure *x) {
        if (![message isEqualToString:x.reason]) {
            NSString *reason = [NSString stringWithFormat:@"Expected failure message: <%@> but received failure message <%@>", message, x.reason];
            [[CDRSpecFailure specFailureWithReason:reason fileName:x.fileName lineNumber:x.lineNumber] raise];
        }
        return;
    }

    fail(@"Expectation should have failed.");
}

void expectExceptionWithReason(NSString *reason, CDRSpecBlock block) {
    @try {
        block();
    }
    @catch (CDRSpecFailure *x) {
        fail(@"Expected exception, but received failure.");
    }
    @catch (NSException *x) {
        if (![reason isEqualToString:x.reason]) {
            NSString *failureReason = [NSString stringWithFormat:@"Expected exception with reason: <%@> but received exception with reason <%@>", reason, x.reason];
            fail(failureReason);
        }
        return;
    }

    fail(@"Expectation should have raised an exception.");
}
