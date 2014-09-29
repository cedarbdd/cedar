#import <Foundation/Foundation.h>

@class CDRReportDispatcher;

@interface CDRXTestSuite : NSObject

- (void)setDispatcher:(CDRReportDispatcher *)dispatcher;
- (CDRReportDispatcher *)dispatcher;

@end
