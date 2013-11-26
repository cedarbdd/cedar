#import <Foundation/Foundation.h>
#import "CedarDouble.h"

@interface CDRSpy : NSProxy<CedarDouble>

+ (void)interceptMessagesForInstance:(id)instance;
+ (void)stopInterceptingMessagesForInstance:(id)instance;

@end

namespace Cedar { namespace Doubles {
    inline void CDR_spy_on(id instance) {
        [CDRSpy interceptMessagesForInstance:instance];
    }

    inline void CDR_stop_spying_on(id instance) {
        [CDRSpy stopInterceptingMessagesForInstance:instance];
    }
}}

#ifndef CEDAR_DOUBLES_COMPATIBILITY_MODE
#define spy_on(x) CDR_spy_on((x))
#define stop_spying_on(x) CDR_stop_spying_on((x))
#endif
