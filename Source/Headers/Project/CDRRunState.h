#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CedarRunState) {
    CedarRunStateNotYetStarted   = 0,
    CedarRunStatePreparingTests  = 1,
    CedarRunStateRunningTests    = 2,
    CedarRunStateFinished        = 3
};

OBJC_EXPORT CedarRunState CDRCurrentState();
OBJC_EXPORT void CDRSetCurrentRunState(CedarRunState);
