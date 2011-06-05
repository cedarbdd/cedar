//For information on TeamCity messages see: http://confluence.jetbrains.net/display/TCD65/Build+Script+Interaction+with+TeamCity

#import "CDRTeamCityReporter.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"

@implementation CDRTeamCityReporter

- (NSString *)escapeText:(NSString *)text{
    NSString *tmp = text;
    tmp = [text stringByReplacingOccurrencesOfString:@"|" withString:@"||"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"'" withString:@"|'"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"\n" withString:@"|n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"\r" withString:@"|r"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"[" withString:@"|["];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"]" withString:@"|]"];

}

- (NSString *)startedMessageForExample:(CDRExample *)example{
    return [NSString stringWithFormat:@"##teamcity[testStarted name='%@']", [self escapeText:example.fullText]];
}

- (NSString *)finishedMessageForExample:(CDRExample *)example{
    return [NSString stringWithFormat:@"##teamcity[testFinished name='%@']", [self escapeText:example.fullText]];
}

- (NSString *)pendingMessageForExample:(CDRExample *)example{
    return [NSString stringWithFormat:@"##teamcity[testIgnored name='%@']", [self escapeText:example.fullText]];
}

- (NSString *)failureMessageForExample:(CDRExample *)example{
    return [NSString stringWithFormat:@"##teamcity[testFailed name='%@' message='%@']", 
            [self escapeText:example.fullText],
            [self escapeText:example.message]];
}

- (void)reportOnExample:(CDRExample *)example {
    switch (example.state) {
        case CDRExampleStatePassed:
            printf("%s\n%s\n", 
                    [[self startedMessageForExample:example] cStringUsingEncoding:NSUTF8StringEncoding],
                    [[self finishedMessageForExample:example] cStringUsingEncoding:NSUTF8StringEncoding]);
            break;
        case CDRExampleStatePending:
            printf("%s\n", [[self pendingMessageForExample:example] cStringUsingEncoding:NSUTF8StringEncoding]);
            break;
        case CDRExampleStateError:
        case CDRExampleStateFailed:
            printf("%s\n%s\n%s\n", 
                   [[self startedMessageForExample:example] cStringUsingEncoding:NSUTF8StringEncoding],
                   [[self failureMessageForExample:example] cStringUsingEncoding:NSUTF8StringEncoding],
                   [[self finishedMessageForExample:example] cStringUsingEncoding:NSUTF8StringEncoding]);
            break;
        default:
            break;
    }
}

@end
