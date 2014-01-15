#import <Foundation/Foundation.h>

namespace Cedar { namespace Doubles {
    class StubbedMethod;
    class RejectedMethod;
}}

@protocol CedarDouble<NSObject>

- (Cedar::Doubles::StubbedMethod &)add_stub:(const Cedar::Doubles::StubbedMethod &)stubbed_method;
- (void)reject_method:(const Cedar::Doubles::RejectedMethod &)rejected_method;

- (NSArray *)sent_messages;
- (void)reset_sent_messages;

- (BOOL)can_stub:(SEL)selector;
- (BOOL)has_stubbed_method_for:(SEL)selector;
- (BOOL)has_rejected_method_for:(SEL)selector;

@end

namespace Cedar { namespace Doubles {

    struct MethodStubbingMarker {
        const char *fileName;
        int lineNumber;
    };

    id<CedarDouble> operator,(id, const MethodStubbingMarker &);

    void operator,(id<CedarDouble>, const StubbedMethod &);
    void operator,(id<CedarDouble>, const RejectedMethod &);
}}

#ifndef CEDAR_MATCHERS_DISALLOW_STUB_METHOD
#define stub_method(x) ,(Cedar::Doubles::MethodStubbingMarker){__FILE__, __LINE__},Cedar::Doubles::StubbedMethod((x))
#define reject_method(x) ,(Cedar::Doubles::MethodStubbingMarker){__FILE__, __LINE__},Cedar::Doubles::RejectedMethod((x))
#endif
