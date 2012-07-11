#import <Foundation/Foundation.h>
#import "CedarDouble.h"

@interface CDRSpy : NSProxy<CedarDouble>

+ (void)interceptMessagesForInstance:(id)instance;

- (NSArray *)sent_messages;

@end

namespace Cedar { namespace Doubles {
    inline void CDR_spy_on(id instance) {
        if (![instance respondsToSelector:@selector(sent_messages)]) {
            [CDRSpy interceptMessagesForInstance:instance];
        }
    }
}}

#ifndef CEDAR_DOUBLES_COMPATIBILITY_MODE
#define spy_on(x) CDR_spy_on((x))
#endif
