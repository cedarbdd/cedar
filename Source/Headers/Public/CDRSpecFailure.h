#import <Foundation/Foundation.h>

@interface CDRSpecFailure : NSException {
    NSString *fileName_;
    int lineNumber_;
    NSArray *callStackReturnAddresses_;
}

@property (nonatomic, retain, readonly) NSString *fileName;
@property (nonatomic, assign, readonly) int lineNumber;
@property (copy, readonly) NSArray *callStackReturnAddresses;

+ (id)specFailureWithReason:(NSString *)reason;
+ (id)specFailureWithReason:(NSString *)reason fileName:(NSString *)fileName lineNumber:(int)lineNumber;
+ (id)specFailureWithRaisedObject:(NSObject *)object;

- (id)initWithReason:(NSString *)reason;
- (id)initWithReason:(NSString *)reason fileName:(NSString *)fileName lineNumber:(int)lineNumber;
- (id)initWithRaisedObject:(NSObject *)object;

- (NSString *)callStackSymbolicatedSymbols:(NSError **)error;

@end
