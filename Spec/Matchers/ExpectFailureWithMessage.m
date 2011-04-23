#import "ExpectFailureWithMessage.h"
#import "CDRSpec.h"
#import "CDRSpecFailure.h"

void expectFailureWithMessage(NSString *message, CDRSpecBlock block) {
    @try {
        block();
    }
    @catch (CDRSpecFailure *x) {
        if (![message isEqualToString:x.reason]) {
            fail([NSString stringWithFormat:@"Expected failure message: <%@> but received failure message <%@>", message, x.reason]);
        }
        return;
    }

    fail(@"Expectation should have failed.");
}
