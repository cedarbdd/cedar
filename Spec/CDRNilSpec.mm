#import <Cedar/Cedar.h>
#import "CDRNil.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CDRNilSpec)

describe(@"CDRNil", ^{
    __block CDRNil *nilObject;

    beforeEach(^{
        nilObject = [CDRNil nilObject];
    });

    it(@"should return itself when copied", ^{
        CDRNil *copiedNil = [[nilObject copy] autorelease];
        copiedNil should be_same_instance_as(nilObject);
    });

    it(@"should be equal to other instances of CDRNil", ^{
        CDRNil *anotherNil = [CDRNil nilObject];
        anotherNil should equal(nilObject);
    });

    it(@"should have a clear description indicating what it represents", ^{
        [nilObject description] should equal(@"<nil>");
    });
});

SPEC_END
