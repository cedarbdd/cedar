#import "CDRSymbolicator.h"
#import <objc/runtime.h>
#import <mach-o/dyld.h>
#import <libunwind.h>
#import <regex.h>

const NSString *kCDRSymbolicatorErrorDomain = @"kCDRSymbolicatorErrorDomain";
const NSString *kCDRSymbolicatorErrorMessageKey = @"kCDRSymbolicatorErrorMessage";

NSUInteger CDRCallerStackAddress() {
#if !CDR_SYMBOLICATION_AVAILABLE
    return 0;
#else
    unw_context_t uc;
    if (unw_getcontext(&uc) != 0) return 0;

    unw_cursor_t cursor;
    if (unw_init_local(&cursor, &uc) != 0) return 0;

    NSUInteger stackAddress = 0;
    int depth = 2; // caller of caller of CDRCallerStackAddress

    while (unw_step(&cursor) > 0 && depth-- > 0) {
        unw_word_t ip;
        if (unw_get_reg(&cursor, UNW_REG_IP, &ip) != 0) return 0;
        stackAddress = (NSUInteger)(ip - 4);
    }
    return stackAddress;
#endif
}

@interface CDRSymbolicator ()
@property (nonatomic, retain) NSMutableArray *addresses;
@property (nonatomic, retain) NSMutableArray *fileNames;
@property (nonatomic, retain) NSMutableArray *lineNumbers;
@end

@implementation CDRSymbolicator

@synthesize
    addresses = addresses_,
    fileNames = fileNames_,
    lineNumbers = lineNumbers_;

- (id)init {
    if (self = [super init]) {
        addresses_ = [[NSMutableArray alloc] init];
        fileNames_ = [[NSMutableArray alloc] init];
        lineNumbers_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    self.addresses = nil;
    self.fileNames = nil;
    self.lineNumbers = nil;
    [super dealloc];
}

- (NSString *)fileNameForStackAddress:(NSUInteger)address {
    NSUInteger index = [self.addresses indexOfObject:[NSNumber numberWithUnsignedInteger:address]];
    return (index == NSNotFound) ? nil : [self.fileNames objectAtIndex:index];
}

- (NSUInteger)lineNumberForStackAddress:(NSUInteger)address {
    NSUInteger index = [self.addresses indexOfObject:[NSNumber numberWithUnsignedInteger:address]];
    return (index == NSNotFound) ? 0 : [[self.lineNumbers objectAtIndex:index] unsignedIntegerValue];
}

- (BOOL)symbolicateAddresses:(NSArray *)addresses error:(NSError **)error {
#if !CDR_SYMBOLICATION_AVAILABLE
    if (error) {
        *error = self.buildNotAvailableError;
    }
    return NO;
#else
    NSArray *validAddresses = [self.class validAddresses:addresses];
    if (validAddresses.count == 0) {
        if (error) {
            *error = self.buildNoAddressesError;
        }
        return NO;
    }

    CDRAtosTask *atosTask = [CDRAtosTask taskForCurrentTestExecutable];
    atosTask.addresses = validAddresses;
    [atosTask launch];

    BOOL atLeastOneSuccessfulSymbolication = NO;

    for (int i=0; i<validAddresses.count; i++) {
        NSString *fileName = nil;
        NSNumber *lineNumber = [NSNumber numberWithInt:0];
        [atosTask valuesOnLineNumber:i fileName:&fileName lineNumber:&lineNumber];

        if (fileName) {
            atLeastOneSuccessfulSymbolication = YES;
            [self.addresses addObject:[validAddresses objectAtIndex:i]];
            [self.fileNames addObject:fileName];
            [self.lineNumbers addObject:lineNumber];
        }
    }

    if (!atLeastOneSuccessfulSymbolication) {
        if (error) {
            *error = self.buildNotSuccessfulError;
        }
        return NO;
    }

    return YES;
#endif
}

- (NSError *)buildNoAddressesError {
    NSString *message = @"Must provide at least one address.\n";
    return [self buildErrorWithCode:kCDRSymbolicatorErrorNoAddresses message:message];
}

- (NSError *)buildNotAvailableError {
    NSString *message = @"atos is not available to symbolicate.\n";
    return [self buildErrorWithCode:kCDRSymbolicatorErrorNotAvailable message:message];
}

- (NSError *)buildNotSuccessfulError {
    NSString *message =
        @"atos was not able to symbolicate.\n"
         "Try setting compiler Optimization Level to None (-O0).\n";
    return [self buildErrorWithCode:kCDRSymbolicatorErrorNotSuccessful message:message];
}

- (NSError *)buildErrorWithCode:(NSUInteger)code message:(NSString *)message {
    NSDictionary *details =
        [NSDictionary dictionaryWithObjectsAndKeys:
         message, kCDRSymbolicatorErrorMessageKey, nil];
    return [NSError errorWithDomain:(id)kCDRSymbolicatorErrorDomain code:code userInfo:details];
}

+ (NSArray *)validAddresses:(NSArray *)addresses {
    NSMutableArray *validAddresses = [NSMutableArray array];
    for (NSNumber *address in addresses) {
        if (address.unsignedIntegerValue > 0)
            [validAddresses addObject:address];
    }
    return validAddresses;
}
@end


@interface CDRAtosTask ()
@property (retain, nonatomic) NSArray *outputLines;
@end

@interface CDRAtosTask (NSTaskStubs)
- (void)setLaunchPath:(NSString *)path;
- (void)setArguments:(NSArray *)arguments;
- (void)setEnvironment:(NSDictionary *)dict;

- (void)setStandardOutput:(NSPipe *)pipe;
- (void)setStandardError:(NSPipe *)pipe;
- (void)launch;
- (void)waitUntilExit;
@end

@implementation CDRAtosTask

@synthesize
    executablePath = executablePath_,
    slide = slide_,
    addresses = addresses_,
    outputLines = outputLines_;

- (id)initWithExecutablePath:(NSString *)executablePath slide:(long)slide addresses:(NSArray *)addresses {
    if (self = [super init]) {
        self.executablePath = executablePath;
        self.slide = slide;
        self.addresses = addresses;
    }
    return self;
}

- (void)dealloc {
    self.executablePath = nil;
    self.addresses = nil;
    self.outputLines = nil;
    [super dealloc];
}

- (void)launch {
    // atos must have at least one address to symbolicate
    // because it will otherwise wait for stdin.
    if (self.addresses.count == 0) {
        [[NSException
            exceptionWithName:NSInvalidArgumentException
            reason:@"Must provide at least one address"
            userInfo:nil] raise];
    }

    NSMutableArray *arguments = [NSMutableArray arrayWithObjects:@"-o", self.executablePath, nil];

    // Position-independent executables addresses need to be adjusted hence the slide argument
    // https://developer.apple.com/library/mac/#technotes/tn2004/tn2123.html
    [arguments addObject:@"-s"];
    [arguments addObject:[NSString stringWithFormat:@"%lx", self.slide]];

    for (NSNumber *address in self.addresses) {
        [arguments addObject:[NSString stringWithFormat:@"%lx", (long)address.unsignedIntegerValue]];
    }

    // NB: this will almost always fail if the version of Xcode at this location differs from the version used to build the tests
    NSString *command = [DEVELOPER_BIN_DIR stringByAppendingPathComponent:@"atos"];
    NSString *output = [self.class shellOutWithCommand:command arguments:arguments];
    self.outputLines = [output componentsSeparatedByString:@"\n"];
}

+ (regex_t)lineRegex {
    static regex_t *rx = NULL;
    if (!rx) {
        rx = malloc(sizeof(regex_t));
        regcomp(rx, "^.+\\((.+):([[:digit:]]+)\\)$", REG_EXTENDED); // __block_global_1 (in Specs) (SpecSpec2.m:12)
    }
    return *rx; // leaks rx; regfree(&rx);
}

- (void)valuesOnLineNumber:(NSUInteger)line fileName:(NSString **)fileName lineNumber:(NSNumber **)lineNumber {
    if (line >= self.outputLines.count) return;

    regex_t rx = [self.class lineRegex];
    regmatch_t *matches = (regmatch_t *)malloc((rx.re_nsub+1) * sizeof(regmatch_t));

    const char *buf = [[self.outputLines objectAtIndex:line] UTF8String];

    if (regexec(&rx, buf, rx.re_nsub+1, matches, 0) == 0) {
        *fileName = [[[NSString alloc]
            initWithBytes:(buf + matches[1].rm_so)
            length:(NSInteger)(matches[1].rm_eo - matches[1].rm_so)
            encoding:NSUTF8StringEncoding] autorelease];

        NSString *lineNumberStr = [[[NSString alloc]
            initWithBytes:(buf + matches[2].rm_so)
            length:(NSInteger)(matches[2].rm_eo - matches[2].rm_so)
            encoding:NSUTF8StringEncoding] autorelease];

        *lineNumber = [NSNumber numberWithInteger:lineNumberStr.integerValue];
    }
    free(matches);
}

+ (NSString *)shellOutWithCommand:(NSString *)command arguments:(NSArray *)arguments {
    id task = [[NSClassFromString(@"NSTask") alloc] init]; // trick iOS SDK in simulator
    [task setEnvironment:[NSDictionary dictionary]];
    [task setLaunchPath:command];
    [task setArguments:arguments];

    NSPipe *standardOutput = [NSPipe pipe];
    // toss stderr, but suppress its output
    NSPipe *standardError = [NSPipe pipe];
    if (standardOutput) {
        [task setStandardOutput:standardOutput];
        [task setStandardError:standardError];
    } else return nil;

    @try {
        [task launch];
    } @catch (NSException *exception) {
        // e.g. NSInvalidArgumentException reason: 'launch path is invalid'
        if (exception.name == NSInvalidArgumentException) {
            return nil;
        } else @throw;
    }

    NSData *data = [[standardOutput fileHandleForReading] readDataToEndOfFile];
    [task waitUntilExit];

    NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    [task release];

    return string;
}
@end

@implementation CDRAtosTask (CurrentTestExecutable)

+ (CDRAtosTask *)taskForCurrentTestExecutable {
    uint32_t imageCount =  _dyld_image_count();
    BOOL runningWithTestBundle = objc_getClass("SenTestProbe") || objc_getClass("XCTestProbe");

    for (uint32_t imageIndex = 0; imageIndex < imageCount; imageIndex++) {
        NSString *imageName = [NSString stringWithCString:_dyld_get_image_name(imageIndex) encoding:NSUTF8StringEncoding];
        if ([imageName hasPrefix: @"/Applications/Xcode"]) {
            continue;
        }

        if (runningWithTestBundle && ![self isImagePathATestBundle:imageName]) {
            continue;
        }

        long slide = _dyld_get_image_vmaddr_slide(imageIndex);

        return [[[self alloc] initWithExecutablePath:imageName
                                               slide:slide
                                           addresses:nil] autorelease];
    }

    return nil;
}

+ (BOOL)isImagePathATestBundle:(NSString *)imageName {
    BOOL isOCTestBundle = [imageName rangeOfString:@".octest/"].location != NSNotFound;
    BOOL isXCTestBundle = [imageName rangeOfString:@".xctest/"].location != NSNotFound;
    return isOCTestBundle || isXCTestBundle;
}

@end
