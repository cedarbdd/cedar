#import <Foundation/Foundation.h>

NSUInteger CDRCallerStackAddress();

extern NSString *kCDRSymbolicatorErrorDomain;
extern NSString *kCDRSymbolicatorErrorMessageKey;

typedef enum {
    kCDRSymbolicatorErrorNotAvailable = 100,
    kCDRSymbolicatorErrorNotSuccessful,
    kCDRSymbolicatorErrorNoAddresses,
} kCDRSymbolicatorError;

@interface CDRSymbolicator : NSObject
- (BOOL)symbolicateAddresses:(NSArray *)addresses error:(NSError **)error;
- (NSString *)fileNameForStackAddress:(NSUInteger)address;
- (NSUInteger)lineNumberForStackAddress:(NSUInteger)address;
@end


@interface CDRAtosTask : NSObject {
    NSString *executablePath_;
    long slide_;
    NSArray *addresses_;
    NSArray *outputLines_;
}

@property (retain, nonatomic) NSString *executablePath;
@property (assign, nonatomic) long slide;
@property (retain, nonatomic) NSArray *addresses;

- (id)initWithExecutablePath:(NSString *)executablePath slide:(long)slide addresses:(NSArray *)addresses;
- (void)launch;
- (void)valuesOnLineNumber:(NSUInteger)line fileName:(NSString **)fileName lineNumber:(NSNumber **)lineNumber;
@end

@interface CDRAtosTask (CurrentTestExecutable)
+ (CDRAtosTask *)taskForCurrentTestExecutable;
@end
