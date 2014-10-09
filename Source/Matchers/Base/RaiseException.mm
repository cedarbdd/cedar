#import "RaiseException.h"

namespace Cedar { namespace Matchers { namespace Private {

#pragma mark - RaiseException
    RaiseException::RaiseException(NSObject *expectedExceptionInstance /*= nil */,
                                          Class expectedExceptionClass /*= nil */,
                                          bool allowSubclasses /*= false */,
                                          NSString *reason /*= nil */,
                                          NSString *name /* = nil */) :
    Base<RaiseExceptionMessageBuilder>(),
    expectedExceptionInstance_([expectedExceptionInstance retain]),
    expectedExceptionClass_(expectedExceptionClass),
    allowSubclasses_(allowSubclasses),
    expectedReason_([reason retain]),
    expectedName_([name retain]) {
    }

    RaiseException::~RaiseException() {
        [expectedExceptionInstance_ release];
        [expectedReason_ release];
        [expectedName_ release];
    }

    RaiseException RaiseException::operator()() const {
        return RaiseException();
    }

    RaiseException RaiseException::operator()(Class expectedExceptionClass) const {
        return RaiseException(nil, expectedExceptionClass);
    }

    RaiseException RaiseException::operator()(NSObject *expectedExceptionInstance) const {
        return RaiseException(expectedExceptionInstance);
    }

    RaiseException & RaiseException::or_subclass() {
        allowSubclasses_ = true;
        return *this;
    }

    RaiseException & RaiseException::with_reason(NSString * const reason) {
        expectedReason_ = [reason retain];
        return *this;
    }

    RaiseException RaiseException::with_reason(NSString * const reason) const {
        return RaiseException(nil, nil, false, reason, nil);
    }

    RaiseException & RaiseException::with_name(NSString *const name) {
        expectedName_ = [name retain];
        return *this;
    }

    RaiseException RaiseException::with_name(NSString *const name) const {
        return RaiseException(nil, nil, false, nil, name);
    }

#pragma mark - Exception matcher
    bool RaiseException::matches(empty_block_t block) const {
        @try {
            block();
        }
        @catch (NSObject *exception) {
            return this->exception_matches_expected_class(exception) &&
            this->exception_matches_expected_instance(exception) &&
            this->exception_matches_expected_name(exception) &&
            this->exception_matches_expected_reason(exception);
        }
        return false;
    }

    /*virtual*/ NSString * RaiseException::failure_message_end() const {
        NSMutableString *message = [NSMutableString stringWithFormat:@"raise an exception"];
        if (expectedExceptionClass_) {
            [message appendString:@" of class"];
            if (allowSubclasses_) {
                [message appendString:@", or subclass of class,"];
            }
            [message appendFormat:@" <%@>", NSStringFromClass(expectedExceptionClass_)];
        }
        if (expectedName_) {
            [message appendFormat:@" with name <%@>", expectedName_];
            if (expectedReason_) {
                [message appendFormat:@" and reason <%@>", expectedReason_];
            }
        }
        else if (expectedReason_) {
            [message appendFormat:@" with reason <%@>", expectedReason_];
        }
        return message;
    }

#pragma mark - Private interface
    bool RaiseException::exception_matches_expected_class(NSObject * const exception) const {
        return !expectedExceptionClass_ || (allowSubclasses_ ? [exception isKindOfClass:expectedExceptionClass_] : [exception isMemberOfClass:expectedExceptionClass_]);
    }

    bool RaiseException::exception_matches_expected_instance(NSObject * const exception) const {
        return !expectedExceptionInstance_ || [expectedExceptionInstance_ isEqual:exception];
    }

    bool RaiseException::exception_matches_expected_reason(NSObject * const exception) const {
        return !expectedReason_ || ([exception isKindOfClass:[NSException class]] && [expectedReason_ isEqualToString:[id(exception) reason]]);
    }

    bool RaiseException::exception_matches_expected_name(NSObject *const exception) const {
        return !expectedName_ || ([exception isKindOfClass:[NSException class]] && [expectedName_ isEqualToString:[id(exception) name]]);
    }

}}}
