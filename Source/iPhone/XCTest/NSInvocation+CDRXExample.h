#import <Foundation/Foundation.h>

@class CDRReportDispatcher;
@class CDRExample;

@interface NSInvocation (CDRXExample)

@property (nonatomic, retain) CDRReportDispatcher *dispatcher;
@property (nonatomic, retain) CDRExample *example;
@property (nonatomic, retain) NSString *specClassName;

@end
