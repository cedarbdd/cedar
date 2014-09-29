#if TARGET_OS_IPHONE
// Normally you would include this file out of the framework.  However, we're
// testing the framework here, so including the file from the framework will
// conflict with the compiler attempting to include the file from the project.
#import "Cedar-iOS.h"
#else
#import <Cedar/Cedar.h>
#endif

// https://github.com/pivotal/cedar/issues/53 sums things up nicely
#if defined(_OBJC_RUNTIME_H) || defined(_OBJC_MESSAGE_H)
#error Objective-C runtime headers should not be exposed via public headers
#endif
