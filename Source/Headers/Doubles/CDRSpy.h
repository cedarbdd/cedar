#import <Foundation/Foundation.h>

@interface CDRSpy : NSProxy

+ (void)interceptMessagesForInstance:(id)instance;

- (NSArray *)sent_messages;
- (BOOL)is_cedar_spy;

@end

namespace Cedar { namespace Doubles {
    inline void CDR_spy_on(id instance) {
        if(![instance respondsToSelector:@selector(is_cedar_spy)]) {
            [CDRSpy interceptMessagesForInstance:instance];
        }
    }
}}


#ifndef CEDAR_DOUBLES_COMPATIBILITY_MODE
#define spy_on(x) CDR_spy_on((x))
#endif
