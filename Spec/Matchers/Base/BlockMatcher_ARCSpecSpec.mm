#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(BlockMatcher_ARCSpecSpec)

describe(@"BlockMatcher", ^{
    id expectedSubject = @"subj";

    auto be_a_match = expectationVerifier(^(id subject){
        return [subject isEqual:expectedSubject];
    }).matcher();

    it(@"should be usable under ARC", ^{
        @"subj" should be_a_match;
    });
});

SPEC_END
