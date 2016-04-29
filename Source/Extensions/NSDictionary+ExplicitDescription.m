#import "NSDictionary+ExplicitDescription.h"

@implementation NSDictionary (ExplicitDescription)

- (NSString *)cdr_explicitDescription {
    NSMutableArray *elementDescriptions = [NSMutableArray arrayWithCapacity:self.count];
    for (id key in self) {
        NSMutableString *elementDescription = [NSMutableString string];
        if ([key respondsToSelector:@selector(cdr_explicitDescription)]) {
            NSString *indentedKeyDescription = [[key cdr_explicitDescription] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n    "];
            [elementDescription appendString:@"    "];
            [elementDescription appendString:indentedKeyDescription];
            [elementDescription appendString:@" = "];
        } else {
            [elementDescription appendFormat:@"    %@ (%@) = ", key, [key class]];
        }

        id element = self[key];
        if ([element respondsToSelector:@selector(cdr_explicitDescription)]) {
            NSString *indentedDescription = [[element cdr_explicitDescription] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n    "];
            [elementDescription appendString:indentedDescription];
        } else {
            [elementDescription appendFormat:@"%@ (%@)", element, [element class]];
        }
        [elementDescriptions addObject:elementDescription];
    }
    return [NSString stringWithFormat:@"{\n%@\n}", [elementDescriptions componentsJoinedByString:@",\n"]];
}

@end
