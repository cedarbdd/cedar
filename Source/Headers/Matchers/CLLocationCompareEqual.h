#import <CoreLocation/CoreLocation.h>

#import "ComparatorsBase.h"
#import "CLLocationStringifiers.h"

inline bool
CLLocationCoordinate2DEqualToCoordinate2D(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2)
{
    return c1.latitude == c2.latitude && c1.longitude == c2.longitude;
}

namespace Cedar { namespace Matchers { namespace Comparators {
    template<typename U>
    bool compare_equal(CLLocationCoordinate2D const actualValue, const U & expectedValue) {
        return CLLocationCoordinate2DEqualToCoordinate2D(actualValue, expectedValue);
    }
}}}
