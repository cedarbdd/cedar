#import "Base.h"

namespace Cedar { namespace Matchers {
    class RaiseException : public Base<> {
        typedef void (^empty_block_t)();

    private:
        RaiseException & operator=(const RaiseException &);

    public:
        explicit RaiseException(NSObject * = nil, Class = nil, bool = false, NSString * = nil);
        ~RaiseException();
        // Allow default copy ctor.

        RaiseException operator()() const;
        RaiseException operator()(Class) const;
        RaiseException operator()(NSObject *) const;

        RaiseException & or_subclass();
        RaiseException or_subclass() const;

        RaiseException & with_reason(NSString * const reason);
        RaiseException with_reason(NSString * const reason) const;

        bool matches(empty_block_t) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        bool exception_matches_expected_class(NSObject * const exception) const;
        bool exception_matches_expected_instance(NSObject * const exception) const;
        bool exception_matches_expected_reason(NSObject * const exception) const;

    private:
        const NSObject *expectedExceptionInstance_;
        const Class expectedExceptionClass_;
        bool allowSubclasses_;
        NSString *expectedReason_;
    };

    RaiseException raise() __attribute__((deprecated)); // Please use raise_exception
    inline RaiseException raise() {
        return RaiseException();
    }

    static const RaiseException raise_exception = RaiseException();

    inline RaiseException::RaiseException(NSObject *expectedExceptionInstance /*= nil*/,
                                          Class expectedExceptionClass /*= nil*/,
                                          bool allowSubclasses /*= false */,
                                          NSString *reason /*= nil*/) :
    Base<>(),
    expectedExceptionInstance_([expectedExceptionInstance retain]),
    expectedExceptionClass_(expectedExceptionClass),
    allowSubclasses_(allowSubclasses),
    expectedReason_([reason retain]) {
    }

    inline RaiseException::~RaiseException() {
        [expectedExceptionInstance_ release];
        [expectedReason_ release];
    }

    inline RaiseException RaiseException::operator()() const {
        return RaiseException();
    }

    inline RaiseException RaiseException::operator()(Class expectedExceptionClass) const {
        return RaiseException(nil, expectedExceptionClass);
    }

    inline RaiseException RaiseException::operator()(NSObject *expectedExceptionInstance) const {
        return RaiseException(expectedExceptionInstance);
    }

    inline RaiseException & RaiseException::or_subclass() {
        allowSubclasses_ = true;
        return *this;
    }

    inline RaiseException RaiseException::or_subclass() const {
        return RaiseException(nil, expectedExceptionClass_, true);
    }

    inline RaiseException & RaiseException::with_reason(NSString * const reason) {
        expectedReason_ = reason;
        return *this;
    }

    inline RaiseException RaiseException::with_reason(NSString * const reason) const {
        return RaiseException(nil, nil, false, reason);
    }

#pragma mark - Exception matcher
    inline bool RaiseException::matches(empty_block_t block) const {
        @try {
            block();
        }
        @catch (NSObject *exception) {
            return this->exception_matches_expected_class(exception) &&
            this->exception_matches_expected_instance(exception) &&
            this->exception_matches_expected_reason(exception);
        }
        return false;
    }

    /*virtual*/ inline NSString * RaiseException::failure_message_end() const {
        NSMutableString *message = [NSMutableString stringWithFormat:@"raise an exception"];
        if (expectedExceptionClass_) {
            [message appendString:@" of class"];
            if (allowSubclasses_) {
                [message appendString:@", or subclass of class,"];
            }
            [message appendFormat:@" <%@>", NSStringFromClass(expectedExceptionClass_)];
        }
        if (expectedReason_) {
            [message appendFormat:@" with reason <%@>", expectedReason_];
        }
        return message;
    }

#pragma mark - Private interface
    inline bool RaiseException::exception_matches_expected_class(NSObject * const exception) const {
        bool foo = !expectedExceptionClass_ || (allowSubclasses_ ? [exception isKindOfClass:expectedExceptionClass_] : [exception isMemberOfClass:expectedExceptionClass_]);
        return foo;
    }

    inline bool RaiseException::exception_matches_expected_instance(NSObject * const exception) const {
        return !expectedExceptionInstance_ || [expectedExceptionInstance_ isEqual:exception];
    }

    inline bool RaiseException::exception_matches_expected_reason(NSObject * const exception) const {
        return !expectedReason_ || ([exception isKindOfClass:[NSException class]] && [expectedReason_ isEqualToString:[id(exception) reason]]);
    }

}}
