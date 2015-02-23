#import <Foundation/Foundation.h>
#import "CDRDefaultReporter.h"

@interface CDRJUnitXMLReporter : CDRDefaultReporter {
    NSMutableArray *successExamples_;
    NSMutableArray *failureExamples_;
}
@end
