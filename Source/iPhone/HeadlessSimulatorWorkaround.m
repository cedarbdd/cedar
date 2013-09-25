#import "HeadlessSimulatorWorkaround.h"
#import <objc/runtime.h>

void CDRSimulatorWorkaround_CreateFakePurpleWorkspacePort() {
    if (CFMessagePortCreateRemote(NULL, (CFStringRef)@"PurpleWorkspacePort") == NULL) {
        NSLog(@"No workspace port detected, creating one and disabling -[UIWindow _createContext]...");
        CFMessagePortCreateLocal(NULL, (CFStringRef)@"PurpleWorkspacePort", NULL, NULL, NULL);
        SEL _createContextSelector = NSSelectorFromString(@"_createContext");
        class_replaceMethod([UIWindow class], _createContextSelector, imp_implementationWithBlock(^{}), "v@:");
    }
}

void CDRSimulatorWorkaround_HideBKSetAccelerometerClientEventsEnabled() {
    NSLog(@"Hiding 'BKSetAccelerometerClientEventsEnabled failed: (ipc/send) invalid destination port'");
    SEL _serverWasRestartedSelector = NSSelectorFromString(@"_serverWasRestarted");
    // Found out via `sudo dtruss -p PID -s`
    class_replaceMethod(
        NSClassFromString(@"BKSAccelerometer"),
        _serverWasRestartedSelector,
        imp_implementationWithBlock(^{}),
        "v@:"
    );
}

void setUpFakeWorkspaceIfRequired() {
#if TARGET_IPHONE_SIMULATOR
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSInteger majorVersion = [[[systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];

    if (majorVersion >= 6) {
        CDRSimulatorWorkaround_CreateFakePurpleWorkspacePort();
        CDRSimulatorWorkaround_HideBKSetAccelerometerClientEventsEnabled();
    }
    [pool drain];
#endif
}
