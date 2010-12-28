#import <Foundation/Foundation.h>
#import <Cedar/CDRExampleBase.h>

@interface CDRExampleStateMap : NSObject {
    CFDictionaryRef stateMap_;
}

+ (id)stateMap;

- (NSString *)descriptionForState:(CDRExampleState)state;

@end
