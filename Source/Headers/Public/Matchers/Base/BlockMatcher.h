#import "Base.h"

#ifdef __cplusplus

// The SDKs that ship with Xcode 7 define OBJC_BOOL_IS_BOOL or OBJC_BOOL_IS_CHAR depending
// on the current platform. Here we enable backwards-compatibility
#if defined(OBJC_BOOL_IS_BOOL)
    #define CDR_OBJC_BOOL_IS_BOOL OBJC_BOOL_IS_BOOL
#elif !defined(OBJC_BOOL_IS_CHAR) && (TARGET_OS_IPHONE && __LP64__)
    #define CDR_OBJC_BOOL_IS_BOOL 1
#endif

#if __has_feature(objc_arc)
#define CDR_RELEASE(X)
#else
#define CDR_RELEASE(X) if (X != nil) { [X release]; }
#endif

namespace Cedar { namespace Matchers {
    typedef NSString *(^FailureMessageEndBlock)(void);

#pragma mark - private interface
    namespace Private {
        template<typename T>
        class BlockMatcher : public Base<> {
        private:
            BlockMatcher<T> & operator=(const BlockMatcher<T> &);

        public:
            BlockMatcher(bool (^const matchesBlock)(T subject), FailureMessageEndBlock failureMessageEndBlock);
            BlockMatcher(const BlockMatcher<T> &obj);
            ~BlockMatcher();

            bool matches(const T &) const;

        protected:
            virtual NSString * failure_message_end() const;

        private:
            bool (^const matchesBlock_)(T);
            const FailureMessageEndBlock failureMessageEndBlock_;
        };

        template<typename T>
        BlockMatcher<T>::BlockMatcher(bool (^const matchesBlock)(T), FailureMessageEndBlock failureMessageEndBlock)
        : matchesBlock_([matchesBlock copy]), failureMessageEndBlock_([failureMessageEndBlock copy]) {}

        template<typename T>
        BlockMatcher<T>::BlockMatcher(const BlockMatcher<T> &obj)
        : matchesBlock_([obj.matchesBlock_ copy]), failureMessageEndBlock_([obj.failureMessageEndBlock_ copy]) {}

        template<typename T>
        BlockMatcher<T>::~BlockMatcher() {
            CDR_RELEASE(matchesBlock_);
            CDR_RELEASE(failureMessageEndBlock_);
        }

        template<typename T>
        NSString *BlockMatcher<T>::failure_message_end() const {
            return failureMessageEndBlock_ ? failureMessageEndBlock_() : @"";
        }

        template<typename T>
        bool BlockMatcher<T>::matches(const T &subject) const {
            return matchesBlock_(subject);
        }


        template<typename T>
        struct BlockMatcherBuilder {
            BlockMatcherBuilder(bool (^matchesBlock)(T subject));
            BlockMatcherBuilder(const BlockMatcherBuilder<T> &obj);
             ~BlockMatcherBuilder();

            BlockMatcher<T> matcher() const; // Explicit builder function
            operator BlockMatcher<T>() const; // Implicit builder function

            BlockMatcherBuilder<T> & with_failure_message_end(NSString * const message);
            BlockMatcherBuilder<T> & with_failure_message_end(FailureMessageEndBlock failureMessageEndBlock);

        private:
            bool (^const matchesBlock_)(T);
            FailureMessageEndBlock failureMessageEndBlock_;
        };

        template<typename T>
        BlockMatcherBuilder<T>::BlockMatcherBuilder(bool (^matchesBlock)(T))
        : matchesBlock_([matchesBlock copy]), failureMessageEndBlock_([^{ return @"pass a test"; } copy]) {}

        template<typename T>
        BlockMatcherBuilder<T>::BlockMatcherBuilder(const BlockMatcherBuilder &obj)
        : matchesBlock_([obj.matchesBlock_ copy]), failureMessageEndBlock_([obj.failureMessageEndBlock_ copy]) {}

        template<typename T>
        BlockMatcherBuilder<T>::~BlockMatcherBuilder() {
            CDR_RELEASE(matchesBlock_);
            CDR_RELEASE(failureMessageEndBlock_);
        }

        template<typename T>
        BlockMatcher<T> BlockMatcherBuilder<T>::matcher() const {
            return BlockMatcher<T>(matchesBlock_, failureMessageEndBlock_);
        }

        template <typename T>
        BlockMatcherBuilder<T>::operator BlockMatcher<T>() const {
            return matcher();
        }

        template<typename T>
        BlockMatcherBuilder<T> & BlockMatcherBuilder<T>::with_failure_message_end(NSString * const message) {
            return with_failure_message_end(^{ return message; });
        }

        template<typename T>
        BlockMatcherBuilder<T> & BlockMatcherBuilder<T>::with_failure_message_end(FailureMessageEndBlock failureMessageEndBlock) {
            CDR_RELEASE(failureMessageEndBlock_);
            failureMessageEndBlock_ = [failureMessageEndBlock copy];
            return *this;
        }
    }

#pragma mark - public interface
    template<typename T>
    using CedarBlockMatcher = Cedar::Matchers::Private::BlockMatcher<T>;

    template<typename T>
    using CedarBlockMatcherBuilder = Cedar::Matchers::Private::BlockMatcherBuilder<T>;

    template<typename T>
    CedarBlockMatcherBuilder<T> expectationVerifier(bool (^matchesBlock)(T subject)) {
        return CedarBlockMatcherBuilder<T>(matchesBlock);
    }

    template<typename T>
    CedarBlockMatcher<T> matcherFor(NSString * const failureMessageEnd, bool (^matchesBlock)(T subject)) {
        return expectationVerifier(matchesBlock).with_failure_message_end(failureMessageEnd);
    }

#if !CDR_OBJC_BOOL_IS_BOOL
    template<typename T>
    CedarBlockMatcherBuilder<T> expectationVerifier(BOOL (^matchesBlock)(T subject)) {
        return CedarBlockMatcherBuilder<T>(^(T subject){ return !(matchesBlock(subject) == NO); });
    }

    template<typename T>
    CedarBlockMatcher<T> matcherFor(NSString * const failureMessageEnd, BOOL (^matchesBlock)(T subject)) {
        return expectationVerifier(matchesBlock).with_failure_message_end(failureMessageEnd);
    }
#endif
}}

#undef CDR_RELEASE

#endif // __cplusplus
