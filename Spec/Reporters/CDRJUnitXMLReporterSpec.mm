#import "Cedar.h"
#import "GDataXMLNode.h"
#import "ExampleWithPublicRunDates.h"

using namespace Cedar::Matchers;

// Test class overrides actually writing XML to a file for speed and easier assertions
@interface TestCDRJUnitXMLReporter : CDRJUnitXMLReporter {
@private
    NSString *xml_;
    GDataXMLDocument *xmlDocument_;
    GDataXMLElement *xmlRootElement_;
}

@property (nonatomic, copy) NSString *xml;
@property (nonatomic, strong) GDataXMLDocument *xmlDocument;
@property (nonatomic, strong) GDataXMLElement *xmlRootElement;
@end

@implementation TestCDRJUnitXMLReporter

@synthesize xml = xml_;
@synthesize xmlDocument = xmlDocument_;
@synthesize xmlRootElement = xmlRootElement_;

- (instancetype)initWithCedarVersion:(NSString *)cedarVersionString {
    if (self = [super initWithCedarVersion:cedarVersionString]) {

    }
    return self;
}

- (void)dealloc {
    self.xml = nil;
    self.xmlRootElement = nil;
    self.xmlDocument = nil;
    [super dealloc];
}

- (void)writeXmlToFile:(NSString *)xmlString {
    self.xml = xmlString;
}

// Temporarily redirect stdout to avoid unnecessary output when running tests
- (void)runDidComplete {
    FILE *realStdout = stdout;
    stdout = fopen("/dev/null", "w");

    @try {
        [super runDidComplete];
    }
    @finally {
        fclose(stdout);
        stdout = realStdout;
    }

    self.xmlDocument = [[[GDataXMLDocument alloc] initWithXMLString:self.xml options:0 error:nil] autorelease];
    self.xmlRootElement = self.xmlDocument.rootElement;
}
@end


// Allow setting state for testing purposes
@interface CDRExample (SpecPrivate)
- (void)setState:(CDRExampleState)state;
@end

@implementation CDRExample (Spec)

+ (id)exampleWithText:(NSString *)text andState:(CDRExampleState)state {
    CDRExample *example = [[self class] exampleWithText:text andBlock:^{}];
    [example setState:state];
    return example;
}
@end


SPEC_BEGIN(CDRJUnitXMLReporterSpec)

describe(@"runDidComplete", ^{
    __block TestCDRJUnitXMLReporter *reporter;
    NSString *cedarVersionString = @"0.1.2 (a71e8f)";

    beforeEach(^{
        reporter = [[[TestCDRJUnitXMLReporter alloc] initWithCedarVersion:cedarVersionString] autorelease];
    });

    context(@"when no specs are run", ^{
        it(@"should output a blank test suite report", ^{
            [reporter runDidComplete];
            expect(reporter.xmlDocument).to_not(be_nil);
            expect(reporter.xmlRootElement).to_not(be_nil);
            expect(reporter.xmlRootElement.name).to(equal(@"testsuite"));
        });
    });

    describe(@"each passing spec", ^{
        it(@"should be written to the XML file", ^{
            CDRExample *example1 = [CDRExample exampleWithText:@"Passing spec 1" andState:CDRExampleStatePassed];
            [reporter reportOnExample:example1];

            CDRExample *example2 = [CDRExample exampleWithText:@"Passing spec 2" andState:CDRExampleStatePassed];
            [reporter reportOnExample:example2];

            [reporter runDidComplete];
            expect(reporter.xmlDocument).to_not(be_nil);
            expect(reporter.xmlRootElement).to_not(be_nil);

            NSArray *testCases = [reporter.xmlRootElement elementsForName:@"testcase"];
            expect(testCases.count).to(equal(2));

            GDataXMLElement *example1XML = [testCases objectAtIndex:0];
            expect([[example1XML attributeForName:@"classname"] stringValue]).to(equal(@"Cedar"));
            expect([[example1XML attributeForName:@"name"] stringValue]).to(equal(@"Passing spec 1"));

            GDataXMLElement *example2XML = [testCases objectAtIndex:1];
            expect([[example2XML attributeForName:@"classname"] stringValue]).to(equal(@"Cedar"));
            expect([[example2XML attributeForName:@"name"] stringValue]).to(equal(@"Passing spec 2"));
        });

        it(@"should have its name escaped", ^{
            NSString *stringToEscape = @"Special ' characters \" should < be & escaped > ";
            CDRExample *example = [CDRExample exampleWithText:stringToEscape andState:CDRExampleStatePassed];
            [reporter reportOnExample:example];

            [reporter runDidComplete];
            GDataXMLElement *exampleXML = [[reporter.xmlRootElement elementsForName:@"testcase"] objectAtIndex:0];
            expect([[exampleXML attributeForName:@"name"] stringValue]).to(equal(stringToEscape));
        });

        it(@"should have its running time", ^{
            ExampleWithPublicRunDates *example = [ExampleWithPublicRunDates exampleWithText:@"Running task" andState:CDRExampleStatePassed];
            NSDate *startDate = [NSDate date];
            [example setStartDate:startDate];
            [example setEndDate:[startDate dateByAddingTimeInterval:5]];

            [reporter reportOnExample:example];

            [reporter runDidComplete];
            GDataXMLElement *exampleXML = [[reporter.xmlRootElement elementsForName:@"testcase"] objectAtIndex:0];
            expect([[exampleXML attributeForName:@"time"] stringValue]).to_not(be_nil);
            expect([[[exampleXML attributeForName:@"time"] stringValue] floatValue]).to(be_close_to(5));
        });

        it(@"should have it's classname", ^{
            CDRExample *example = [CDRExample exampleWithText:@"Spec" andState:CDRExampleStatePassed];
            example.spec = [[CDRSpec new] autorelease];
            [reporter reportOnExample:example];

            CDRExample *junitExample = [CDRExample exampleWithText:@"JUnitExample" andState:CDRExampleStatePassed];
            junitExample.spec = [[CDRJUnitXMLReporterSpec new] autorelease];
            [reporter reportOnExample:junitExample];

            [reporter runDidComplete];
            GDataXMLElement *exampleXML = [[reporter.xmlRootElement elementsForName:@"testcase"] objectAtIndex:0];
            expect([[exampleXML attributeForName:@"classname"] stringValue]).to(equal(@"CDRSpec"));
            GDataXMLElement *junitExampleXML = [[reporter.xmlRootElement elementsForName:@"testcase"] objectAtIndex:1];
            expect([[junitExampleXML attributeForName:@"classname"] stringValue]).to(equal(@"CDRJUnitXMLReporterSpec"));
        });

        it(@"should have it's classname to default value if spec filename is empty", ^{
            CDRExample *example = [CDRExample exampleWithText:@"Spec" andState:CDRExampleStatePassed];

            [reporter reportOnExample:example];

            [reporter runDidComplete];
            GDataXMLElement *exampleXML = [[reporter.xmlRootElement elementsForName:@"testcase"] objectAtIndex:0];
            expect([[exampleXML attributeForName:@"classname"] stringValue]).to(equal(@"Cedar"));
        });
    });

    describe(@"each failing spec", ^{
        it(@"should be written to the XML file", ^{
            CDRExample *example1 = [CDRExample exampleWithText:@"Failing spec 1" andState:CDRExampleStateFailed];
            example1.failure = [CDRSpecFailure specFailureWithReason:@"Failure reason 1"];
            [reporter reportOnExample:example1];

            CDRExample *example2 = [CDRExample exampleWithText:@"Failing spec 2" andState:CDRExampleStateFailed];
            example2.failure = [CDRSpecFailure specFailureWithReason:@"Failure reason 2"];
            [reporter reportOnExample:example2];

            [reporter runDidComplete];

            NSArray *testCases = [reporter.xmlRootElement elementsForName:@"testcase"];
            expect(testCases.count).to(equal(2));

            GDataXMLElement *example1XML = [testCases objectAtIndex:0];
            expect([[example1XML attributeForName:@"classname"] stringValue]).to(equal(@"Cedar"));
            expect([[example1XML attributeForName:@"name"] stringValue]).to(equal(@"Failing spec 1"));
            expect([[[example1XML nodesForXPath:@"failure/@type" error:nil] objectAtIndex:0] stringValue]).to(equal(@"Failure"));
            expect([[[example1XML nodesForXPath:@"failure/text()" error:nil] objectAtIndex:0] stringValue]).to(equal(@"Failure reason 1"));


            GDataXMLElement *example2XML = [testCases objectAtIndex:1];
            expect([[example2XML attributeForName:@"classname"] stringValue]).to(equal(@"Cedar"));
            expect([[example2XML attributeForName:@"name"] stringValue]).to(equal(@"Failing spec 2"));
            expect([[[example2XML nodesForXPath:@"failure/@type" error:nil] objectAtIndex:0] stringValue]).to(equal(@"Failure"));
            expect([[[example2XML nodesForXPath:@"failure/text()" error:nil] objectAtIndex:0] stringValue]).to(equal(@"Failure reason 2"));
        });

        it(@"should have its name escaped", ^{
            NSString *stringToEscape = @"Special ' characters \" should < be & escaped > ";
            CDRExample *example = [CDRExample exampleWithText:stringToEscape andState:CDRExampleStateFailed];
            [reporter reportOnExample:example];

            [reporter runDidComplete];
            GDataXMLElement *exampleXML = [[reporter.xmlRootElement elementsForName:@"testcase"] objectAtIndex:0];
            expect([[exampleXML attributeForName:@"name"] stringValue]).to(equal(stringToEscape));
        });

        it(@"should escape the failure reason", ^{
            NSString *exampleName = @"Failing spec 1";
            NSString *failureReason = @" Special ' characters \" should < be & escaped > ";
            NSString *fullExampleText = [NSString stringWithFormat:@"%@\n%@", exampleName, failureReason];
            CDRExample *example = [CDRExample exampleWithText:fullExampleText andState:CDRExampleStateFailed];
            example.failure = [CDRSpecFailure specFailureWithReason:failureReason];

            [reporter reportOnExample:example];

            [reporter runDidComplete];

            expect([[[reporter.xmlRootElement nodesForXPath:@"testcase/failure/text()" error:nil] objectAtIndex:0] stringValue]).to(equal(failureReason));
        });

        it(@"should have its running time", ^{
            ExampleWithPublicRunDates *example = [ExampleWithPublicRunDates exampleWithText:@"Failing spec\nFailure reason" andState:CDRExampleStateFailed];
            NSDate *startDate = [NSDate date];
            [example setStartDate:startDate];
            [example setEndDate:[startDate dateByAddingTimeInterval:5]];
            [reporter reportOnExample:example];

            [reporter runDidComplete];
            GDataXMLElement *exampleXML = [[reporter.xmlRootElement elementsForName:@"testcase"] objectAtIndex:0];
            expect([[exampleXML attributeForName:@"time"] stringValue]).to_not(be_nil);
            expect([[[exampleXML attributeForName:@"time"] stringValue] floatValue]).to(be_close_to(5));
        });

        it(@"should have it's classname", ^{
            CDRExample *example = [CDRExample exampleWithText:@"Spec" andState:CDRExampleStateFailed];
            example.spec = [[CDRSpec new] autorelease];
            [reporter reportOnExample:example];

            CDRExample *junitExample = [CDRExample exampleWithText:@"JUnitExample" andState:CDRExampleStateFailed];
            junitExample.spec = [[CDRJUnitXMLReporterSpec new] autorelease];
            [reporter reportOnExample:junitExample];

            [reporter runDidComplete];
            GDataXMLElement *exampleXML = [[reporter.xmlRootElement elementsForName:@"testcase"] objectAtIndex:0];
            expect([[exampleXML attributeForName:@"classname"] stringValue]).to(equal(@"CDRSpec"));
            GDataXMLElement *junitExampleXML = [[reporter.xmlRootElement elementsForName:@"testcase"] objectAtIndex:1];
            expect([[junitExampleXML attributeForName:@"classname"] stringValue]).to(equal(@"CDRJUnitXMLReporterSpec"));
        });

        it(@"should have it's classname to default value if spec filename is empty", ^{
            CDRExample *example = [CDRExample exampleWithText:@"Spec" andState:CDRExampleStateFailed];

            [reporter reportOnExample:example];

            [reporter runDidComplete];
            GDataXMLElement *exampleXML = [[reporter.xmlRootElement elementsForName:@"testcase"] objectAtIndex:0];
            expect([[exampleXML attributeForName:@"classname"] stringValue]).to(equal(@"Cedar"));
        });

    });

    describe(@"each spec that causes an error", ^{
        it(@"should be handled the same as a failing spec", ^{
            CDRExample *example = [CDRExample exampleWithText:@"Failing spec\nFailure reason" andState:CDRExampleStateError];
            [reporter reportOnExample:example];

            [reporter runDidComplete];

            expect([[[reporter.xmlRootElement nodesForXPath:@"testcase/@classname" error:nil] objectAtIndex:0] stringValue]).to(equal(@"Cedar"));
            expect([[[reporter.xmlRootElement nodesForXPath:@"testcase/@name" error:nil] objectAtIndex:0] stringValue]).to(equal(@"Failing spec"));
            expect([[[reporter.xmlRootElement nodesForXPath:@"testcase/failure/@type" error:nil] objectAtIndex:0] stringValue]).to(equal(@"Failure"));
            expect([[[reporter.xmlRootElement nodesForXPath:@"testcase/failure/text()" error:nil] objectAtIndex:0] stringValue]).to(equal(@"Failure reason"));
        });
    });
});

SPEC_END
