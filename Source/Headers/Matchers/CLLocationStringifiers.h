#import <sstream>
#import "StringifiersBase.h"
#import <CoreLocation/CoreLocation.h>

namespace Cedar { namespace Matchers { namespace Stringifiers {
    inline NSString * string_for(const CLLocationCoordinate2D value) {
        return [NSString stringWithFormat:@"CLLocationCoordinate2D{lat=%f, long=%f}", value.latitude, value.longitude];
    }
}}}
