#import "Base.h"

namespace Cedar { namespace Matchers {
    class Raise : public Base {
        typedef void (^empty_block_t)();

    private:
        Raise & operator=(const Raise &);

    public:
        explicit Raise(Class);
        ~Raise();
        // Allow default copy ctor.

        bool matches(empty_block_t) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        const Class expectedExceptionClass_;
    };

    inline Raise raise(Class expectedExceptionClass = nil) {
        return Raise(expectedExceptionClass);
    }

    inline Raise::Raise(Class expectedExceptionClass)
    : Base(), expectedExceptionClass_(expectedExceptionClass) {
    }

    inline Raise::~Raise() {
    }

    /*virtual*/ inline NSString * Raise::failure_message_end() const {
        NSString *message = [NSString stringWithFormat:@"raise an exception"];
        if (expectedExceptionClass_) {
            message = [NSString stringWithFormat:@"%@ of type <%@>", message, NSStringFromClass(expectedExceptionClass_)];
        }
        return message;
    }

    inline bool Raise::matches(empty_block_t block) const {
        this->build_failure_message_start(@"specified block");
        @try {
            block();
        }
        @catch (NSException *exception) {
            return !expectedExceptionClass_ || [exception isMemberOfClass:expectedExceptionClass_];
        }
        return false;
    }
}}
