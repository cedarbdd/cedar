#import "CDRJUnitXMLReporter.h"
#import "CDRExample.h"

@implementation CDRJUnitXMLReporter

- (id)init {
    if (self = [super init]) {
        successExamples_ = [[NSMutableArray alloc] init];
        failureExamples_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [successExamples_ release];
    [failureExamples_ release];
    [super dealloc];
}

#pragma mark - Overriden Methods

- (NSString *)failureMessageForExample:(CDRExample *)example {
    return [NSString stringWithFormat:@"%@\n%@\n", example.fullText, example.failure];
}

- (void)reportOnExample:(CDRExample *)example {
    switch (example.state) {
        case CDRExampleStatePassed:
            [successExamples_ addObject:example];
            break;
        case CDRExampleStateFailed:
        case CDRExampleStateError:
            [failureMessages_ addObject:[self failureMessageForExample:example]];
            [failureExamples_ addObject:example];
            break;
        default:
            break;
    }
}

- (void)runDidComplete {
    [super runDidComplete];

    NSMutableString *xml = [NSMutableString string];
    [xml appendString:@"<?xml version=\"1.0\"?>\n"];
    [xml appendString:@"<testsuite>\n"];

    for (CDRExample *example in successExamples_) {
        [xml appendFormat:@"\t<testcase classname=\"Cedar\" name=\"%@\" time=\"%f\" />\n", [self escapeString:example.fullText], example.runTime];
    }

    for (CDRExample *example in failureExamples_) {
        NSString *failureMessage = [self failureMessageForExample:example];
        NSArray *parts = [failureMessage componentsSeparatedByString:@"\n"];
        NSString *testCaseName = [parts objectAtIndex:0];
        NSString *failureDescription = [parts objectAtIndex:1];

        [xml appendFormat:@"\t<testcase classname=\"Cedar\" name=\"%@\" time=\"%f\" >\n", [self escapeString:testCaseName], example.runTime];
        [xml appendFormat:@"\t\t<failure type=\"Failure\">%@</failure>\n", [self escapeString:failureDescription]];
        [xml appendString:@"\t</testcase>\n"];
    }
    [xml appendString:@"</testsuite>\n"];

    [self writeXmlToFile:xml];
}

#pragma mark - Private

- (NSString *)escapeString:(NSString *)unescaped {
    NSString *escaped = [unescaped stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    return [escaped stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
}

- (void)writeXmlToFile:(NSString *)xml {
    char *xmlFile = getenv("CEDAR_JUNIT_XML_FILE");
    if (!xmlFile) xmlFile = "build/TEST-Cedar.xml";

    [xml writeToFile:[NSString stringWithUTF8String:xmlFile]
          atomically:YES
            encoding:NSUTF8StringEncoding
               error:NULL];
}
@end
