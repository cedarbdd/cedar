#import "NSMethodSignature+Cedar.h"
#import "CDRBlockHelper.h"

static const char *Block_signature(id blockObj) {
    struct Block_literal *block = (struct Block_literal *)blockObj;
    union Block_descriptor_rest descriptor_rest = block->descriptor->rest;

    BOOL hasCopyDispose = !!(block->flags & (1<<25));

    const char *signature = hasCopyDispose ? descriptor_rest.layout_with_copy_dispose.signature : descriptor_rest.layout_without_copy_dispose.signature;

    return signature;
}

@implementation NSMethodSignature (Cedar)

+ (NSMethodSignature *)cdr_signatureFromBlock:(id)block {
    const char *signatureTypes = Block_signature(block);
    NSString *signatureTypesString = [NSString stringWithUTF8String:signatureTypes];

    NSString *quotedSubstringsPattern = @"\".*?\"";
    NSString *angleBracketedSubstringsPattern = @"<.*?>";

    NSString *strippedSignatureTypeString = signatureTypesString;
    for (NSString *pattern in @[quotedSubstringsPattern, angleBracketedSubstringsPattern]) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
        strippedSignatureTypeString = [regex stringByReplacingMatchesInString:strippedSignatureTypeString options:0 range:NSMakeRange(0, [strippedSignatureTypeString length]) withTemplate:@""];
    }

    return [NSMethodSignature signatureWithObjCTypes:[strippedSignatureTypeString UTF8String]];
}

- (NSMethodSignature *)cdr_signatureWithoutSelectorArgument {
    NSAssert([self numberOfArguments]>1 && strcmp([self getArgumentTypeAtIndex:1], ":")==0, @"Unable to remove _cmd from a method signature without a _cmd argument");

    NSMutableString *modifiedTypesString = [[[NSMutableString alloc] initWithUTF8String:[self methodReturnType]] autorelease];
    for (NSInteger argIndex=0; argIndex<[self numberOfArguments]; argIndex++) {
        if (argIndex==1) { continue; }
        [modifiedTypesString appendFormat:@"%s", [self getArgumentTypeAtIndex:argIndex]];
    }

    return [NSMethodSignature signatureWithObjCTypes:[modifiedTypesString UTF8String]];
}

@end
