#import "SpecHelper.h"
#import <CoreLocation/CoreLocation.h>

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;

SPEC_BEGIN(CLLocationEqualSpec)

describe(@"CLLocation struct comparison", ^{
    describe(@"comparing CLLocationCoordinate2D", ^{
        it(@"should be possible", ^{
            CLLocationCoordinate2D thisCoord = CLLocationCoordinate2DMake(10, 20);
            CLLocationCoordinate2D thatCoord = CLLocationCoordinate2DMake(10, 20);

            thisCoord should equal(thatCoord);
        });

        it(@"should fail with a reasonable message", ^{
            expectFailureWithMessage(@"Expected <CLLocationCoordinate2D{lat=10.000000, long=20.000000}> to equal <CLLocationCoordinate2D{lat=11.000000, long=22.000000}>", ^{
                CLLocationCoordinate2D thisCoord = CLLocationCoordinate2DMake(10, 20);
                CLLocationCoordinate2D thatCoord = CLLocationCoordinate2DMake(11, 22);

                thisCoord should equal(thatCoord);
            });
        });
    });
});

SPEC_END
