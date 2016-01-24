#import <Foundation/Foundation.h>

@class CDRReportDispatcher;
@class CDRExample;

@interface NSInvocation (CDRXExample)

@property (nonatomic, retain, setter=cdr_setDispatcher:) CDRReportDispatcher *cdr_dispatcher;
@property (nonatomic, retain, setter=cdr_setExamples:) NSArray *cdr_examples;
@property (nonatomic, retain, setter=cdr_setSpecClassName:) NSString *cdr_specClassName;

- (void)cdr_addSupplementaryExample:(CDRExample *)example;

@end
