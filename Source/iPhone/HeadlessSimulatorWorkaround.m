#import "HeadlessSimulatorWorkaround.h"
#import <objc/runtime.h>

void setUpFakeWorkspaceIfRequired() {
#if TARGET_IPHONE_SIMULATOR
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSInteger majorVersion = [[[systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
    if (majorVersion >= 6 && CFMessagePortCreateRemote(NULL, (CFStringRef)@"PurpleWorkspacePort") == NULL) {
        NSLog(@"No workspace port detected, creating one and disabling -[UIWindow _createContext]...");
        CFMessagePortCreateLocal(NULL, (CFStringRef)@"PurpleWorkspacePort", NULL, NULL, NULL);
        class_replaceMethod([UIWindow class], @selector(_createContext), imp_implementationWithBlock(^{}), "v@:");
    }
    [pool drain];
#endif
}
