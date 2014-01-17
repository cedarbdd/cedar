#import "ExampleWithPublicRunDates.h"


@implementation ExampleWithPublicRunDates

- (void)setStartDate:(NSDate *)startDate {
    if (startDate_) { [startDate_ autorelease];};
    startDate_ = [startDate retain];
}


- (void)setEndDate:(NSDate *)endDate {
    if (endDate_) { [endDate_ autorelease];};
    endDate_ = [endDate retain];
}

@end
