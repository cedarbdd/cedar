#import "ActualValue.h"

namespace Cedar { namespace Matchers {

    void fail(const NSString *failureMessage) {
        [[CDRSpecFailure specFailureWithReason:[NSString stringWithFormat:@"Failure: %@", failureMessage]] raise];
    }

#pragma mark toEqual
    template<> template<>
    void ActualValue<NSObject *>::toEqual(NSObject * const & expectedValue) const {
        if (![expectedValue isEqual:value_]) {
            std::stringstream message;
            message << "Expected NSObject <" << value_ << "> to equal NSObject <" << expectedValue << ">";

            [[CDRSpecFailure specFailureWithReason:[NSString stringWithCString:message.str().c_str() encoding:NSUTF8StringEncoding]] raise];
        }
    }

}}
