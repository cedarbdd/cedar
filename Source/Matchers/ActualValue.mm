#import "ActualValue.h"

namespace Cedar {
namespace Matchers {

void fail(const NSString *failureMessage) {
    [[CDRSpecFailure specFailureWithReason:[NSString stringWithFormat:@"Failure: %@", failureMessage]] raise];
}

}
}
