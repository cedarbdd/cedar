#import "NSOrderedSet+ExplicitDescription.h"

@implementation NSOrderedSet (ExplicitDescription)

- (NSString *)cdr_explicitDescription {
    NSMutableArray *elementDescriptions = [NSMutableArray arrayWithCapacity:self.count];
    for (id element in self) {
        if ([element respondsToSelector:@selector(cdr_explicitDescription)]) {
            NSString *indentedDescription = [[element cdr_explicitDescription] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n    "];
            [elementDescriptions addObject:[@"    " stringByAppendingString:indentedDescription]];
        } else {
            [elementDescriptions addObject:[NSString stringWithFormat:@"    %@ (%@)", element, [element class]]];
        }
    }
    return [NSString stringWithFormat:@"{(\n%@\n)}", [elementDescriptions componentsJoinedByString:@",\n"]];
}

@end
