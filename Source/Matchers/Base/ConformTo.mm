#import <Foundation/Foundation.h>
#import "ConformTo.h"

namespace Cedar { namespace Matchers { namespace Private {

    ConformTo::ConformTo(Protocol *protocol)
    : expectedProtocolName_([NSStringFromProtocol(protocol) UTF8String]) {}

    ConformTo::ConformTo(const char *protocolName)
    : expectedProtocolName_(protocolName) {}

    ConformTo::~ConformTo() {}

    /*virtual*/ NSString *ConformTo::failure_message_end() const {
        return [NSString stringWithFormat:@"conform to <%@> protocol",
                @(expectedProtocolName_)];
    }

    /*virtual*/ bool ConformTo::matches(const id subject) const {
        return [subject conformsToProtocol:NSProtocolFromString(@(expectedProtocolName_))];
    }
}}}
