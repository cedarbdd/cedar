#import "CDRSpecFailure.h"

@implementation CDRSpecFailure

+ (id)specFailureWithReason:(NSString *)reason {
    return [[self class] exceptionWithName:@"Spec failure" reason:reason userInfo:nil];
}

@end
