namespace Cedar { namespace Doubles {
    class StubbedMethodPrototype;
    class StubbedMethod;
}}

@protocol CedarDouble<NSObject>

- (const Cedar::Doubles::StubbedMethodPrototype &)stub_method;
- (Cedar::Doubles::StubbedMethod &)create_stubbed_method_for:(SEL)selector;
- (NSArray *)sent_messages;

@end
