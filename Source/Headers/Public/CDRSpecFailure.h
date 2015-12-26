#import <Foundation/Foundation.h>
#import "CDRNullabilityCompat.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDRSpecFailure : NSException {
    NSString *fileName_;
    int lineNumber_;
    NSArray *callStackReturnAddresses_;
}

@property (nonatomic, retain, readonly, nullable) NSString *fileName;
@property (nonatomic, assign, readonly) int lineNumber;
@property (copy, readonly, nullable) NSArray *callStackReturnAddresses;

+ (id)specFailureWithReason:(NSString *)reason;
+ (id)specFailureWithReason:(NSString *)reason fileName:(NSString *)fileName lineNumber:(int)lineNumber;
+ (id)specFailureWithRaisedObject:(NSObject *)object;

- (id)initWithReason:(NSString *)reason;
- (id)initWithReason:(NSString *)reason fileName:(NSString *)fileName lineNumber:(int)lineNumber;
- (id)initWithRaisedObject:(NSObject *)object;

- (nullable NSString *)callStackSymbolicatedSymbols:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
