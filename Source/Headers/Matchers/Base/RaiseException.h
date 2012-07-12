#import "Base.h"

namespace Cedar { namespace Matchers {
    class RaiseException : public Base<> {
        typedef void (^empty_block_t)();

    private:
        RaiseException & operator=(const RaiseException &);

    public:
        explicit RaiseException(Class = nil, bool = false);
        explicit RaiseException(NSObject *);
        ~RaiseException();
        // Allow default copy ctor.

        RaiseException operator()() const;
        RaiseException operator()(Class) const;
        RaiseException operator()(NSObject *) const;

        RaiseException & or_subclass();
        RaiseException or_subclass() const;

        bool matches(empty_block_t) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        bool exceptionMatchesExpectedClass(NSObject * const exception) const;
        bool exceptionMatchesExpectedInstance(NSObject * const exception) const;

    private:
        const NSObject *expectedExceptionInstance_;
        const Class expectedExceptionClass_;
        bool allowSubclasses_;
    };

    RaiseException raise() __attribute__((deprecated)); // Please use raise_exception
    inline RaiseException raise() {
        return RaiseException();
    }

    static const RaiseException raise_exception = RaiseException();

    inline RaiseException::RaiseException(Class expectedExceptionClass /*= nil*/, bool allowSubclasses /*= false */)
    : Base<>(), expectedExceptionInstance_(NULL), expectedExceptionClass_(expectedExceptionClass), allowSubclasses_(allowSubclasses) {
    }

    inline RaiseException::RaiseException(NSObject *expectedExceptionInstance)
    : Base<>(), expectedExceptionInstance_(expectedExceptionInstance), expectedExceptionClass_(NULL), allowSubclasses_(false) {
    }

    inline RaiseException::~RaiseException() {
    }

    inline RaiseException RaiseException::operator()() const {
        return RaiseException();
    }

    inline RaiseException RaiseException::operator()(Class expectedExceptionClass) const {
        return RaiseException(expectedExceptionClass);
    }

    inline RaiseException RaiseException::operator()(NSObject *expectedExceptionInstance) const {
        return RaiseException(expectedExceptionInstance);
    }

    inline RaiseException & RaiseException::or_subclass() {
        allowSubclasses_ = true;
        return *this;
    }

    inline RaiseException RaiseException::or_subclass() const {
        return RaiseException(expectedExceptionClass_, true);
    }

    inline bool RaiseException::matches(empty_block_t block) const {
        @try {
            block();
        }
        @catch (NSObject *exception) {
            if (expectedExceptionClass_) {
                return this->exceptionMatchesExpectedClass(exception);
            } else if (expectedExceptionInstance_) {
                return this->exceptionMatchesExpectedInstance(exception);
            } else {
                return true;
            }
        }
        return false;
    }

    inline bool RaiseException::exceptionMatchesExpectedClass(NSObject * const exception) const {
        if (allowSubclasses_) {
            return [exception isKindOfClass:expectedExceptionClass_];
        }
        return [exception isMemberOfClass:expectedExceptionClass_];
    }

    inline bool RaiseException::exceptionMatchesExpectedInstance(NSObject * const exception) const {
        return [expectedExceptionInstance_ isEqual:exception];
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
        return message;
    }
}}
