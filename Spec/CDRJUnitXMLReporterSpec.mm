#if TARGET_OS_IPHONE
// Normally you would include this file out of the framework.  However, we're
// testing the framework here, so including the file from the framework will
// conflict with the compiler attempting to include the file from the project.
#import "SpecHelper.h"
#else
#import <Cedar/SpecHelper.h>
#endif

#import "CDRExample.h"
#import "CDRJUnitXMLReporter.h"
#import "CDRSpecFailure.h"

using namespace Cedar::Matchers;

// Test class overrides actually writing XML to a file for speed and easier assertions
@interface TestCDRJUnitXMLReporter : CDRJUnitXMLReporter {
@private
    NSString *xml_;
}

@property (nonatomic, copy) NSString *xml;
@end

@implementation TestCDRJUnitXMLReporter

@synthesize xml = xml_;

- (void)dealloc {
    self.xml = nil;
    [super dealloc];
}

- (void)writeXmlToFile:(NSString *)xmlString {
    self.xml = xmlString;
}

@end

// Allow setting state for testing purposes
@implementation CDRExample (Spec)

- (void)setState:(CDRExampleState)state {
    state_ = state;
}

+ (id) exampleWithText:(NSString *)text andState:(CDRExampleState)state {
    CDRExample *example = [CDRExample exampleWithText:text andBlock:^{}];
    [example setState:state];
    return example;
}

@end


SPEC_BEGIN(CDRJUnitXMLReporterSpec)

describe(@"runDidComplete", ^{
    __block TestCDRJUnitXMLReporter *reporter;

    beforeEach(^{
        reporter = [[TestCDRJUnitXMLReporter alloc] init];
    });

    afterEach(^{
        [reporter release];
    });

    context(@"When no specs are run", ^{
        it(@"should output a blank test suite report", ^{
            [reporter runDidComplete];

            expect(reporter.xml).to(equal(@"<?xml version=\"1.0\"?>\n<testsuite>\n</testsuite>\n"));
        });
    });

    describe(@"Each passing spec", ^{
        it(@"should be written to the XML file", ^{
            CDRExample *example1 = [CDRExample exampleWithText:@"Passing spec 1" andState:CDRExampleStatePassed];
            CDRExample *example2 = [CDRExample exampleWithText:@"Passing spec 2" andState:CDRExampleStatePassed];

            [reporter reportOnExample:example1];
            [reporter reportOnExample:example2];

            [reporter runDidComplete];

            expect([reporter.xml rangeOfString:@"<testcase classname=\"Cedar\" name=\"Passing spec 1\" />"].location).to_not(equal((NSUInteger)NSNotFound));
            expect([reporter.xml rangeOfString:@"<testcase classname=\"Cedar\" name=\"Passing spec 2\" />"].location).to_not(equal((NSUInteger)NSNotFound));
        });

        it(@"should have its name escaped", ^{
            CDRExample *example = [CDRExample exampleWithText:@"Special ' characters \" should < be & escaped > " andState:CDRExampleStatePassed];

            [reporter reportOnExample:example];

            [reporter runDidComplete];

            expect([reporter.xml rangeOfString:@"name=\"Special &apos; characters &quot; should &lt; be &amp; escaped &gt; \""].location).to_not(equal((NSUInteger)NSNotFound));
        });
    });

    describe(@"Each failing spec", ^{
        it(@"should be written to the XML file", ^{
            CDRExample *example1 = [CDRExample exampleWithText:@"Failing spec 1" andState:CDRExampleStateFailed];
            example1.failure = [CDRSpecFailure specFailureWithReason:@"Failure reason 1"];
            CDRExample *example2 = [CDRExample exampleWithText:@"Failing spec 2" andState:CDRExampleStateFailed];
            example2.failure = [CDRSpecFailure specFailureWithReason:@"Failure reason 2"];

            [reporter reportOnExample:example1];
            [reporter reportOnExample:example2];

            [reporter runDidComplete];

            expect([reporter.xml rangeOfString:@"<testcase classname=\"Cedar\" name=\"Failing spec 1\">\n\t\t<failure type=\"Failure\">Failure reason 1</failure>\n\t</testcase>"].location).to_not(equal((NSUInteger)NSNotFound));
            expect([reporter.xml rangeOfString:@"<testcase classname=\"Cedar\" name=\"Failing spec 2\">\n\t\t<failure type=\"Failure\">Failure reason 2</failure>\n\t</testcase>"].location).to_not(equal((NSUInteger)NSNotFound));
        });

        it(@"should have its name escaped", ^{
            CDRExample *example = [CDRExample exampleWithText:@"Special ' characters \" should < be & escaped > " andState:CDRExampleStateFailed];

            [reporter reportOnExample:example];

            [reporter runDidComplete];

            expect([reporter.xml rangeOfString:@"name=\"Special &apos; characters &quot; should &lt; be &amp; escaped &gt; \""].location).to_not(equal((NSUInteger)NSNotFound));
        });

        it(@"should escape the failure reason", ^{
            CDRExample *example1 = [CDRExample exampleWithText:@"Failing spec 1\n Special ' characters \" should < be & escaped > " andState:CDRExampleStateFailed];

            [reporter reportOnExample:example1];

            [reporter runDidComplete];

            expect([reporter.xml rangeOfString:@"<failure type=\"Failure\"> Special &apos; characters &quot; should &lt; be &amp; escaped &gt; </failure>"].location).to_not(equal((NSUInteger)NSNotFound));
        });
    });

    describe(@"Each spec that causes an error", ^{
        it(@"should be handled the same as a failing spec", ^{
            CDRExample *example = [CDRExample exampleWithText:@"Failing spec\nFailure reason" andState:CDRExampleStateError];

            [reporter reportOnExample:example];

            [reporter runDidComplete];

            expect([reporter.xml rangeOfString:@"<testcase classname=\"Cedar\" name=\"Failing spec\">\n\t\t<failure type=\"Failure\">Failure reason</failure>\n\t</testcase>"].location).to_not(equal((NSUInteger)NSNotFound));
        });
    });
});

SPEC_END
