#import <Foundation/Foundation.h>

@class CDRReportDispatcher;
@class CDRExample;

@interface NSInvocation (CDRXExample)

@property (nonatomic, retain, setter=cdr_setDispatcher:) CDRReportDispatcher *cdr_dispatcher;
@property (nonatomic, retain, setter=cdr_setExample:) CDRExample *cdr_example;
@property (nonatomic, retain, setter=cdr_setSpecClassName:) NSString *cdr_specClassName;

@end
