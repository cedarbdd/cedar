#import <Cedar/SpecHelper.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

void expectFailure(CDRSpecBlock block) {
  @try {
    block();
  }
  @catch (CDRSpecFailure *) {
    return;
  }

  fail(@"equality expectation should have failed.");
}

SPEC_BEGIN(SpecSpec)

describe(@"Spec", ^ {
  beforeEach(^ {
//    NSLog(@"=====================> I should run before all specs.");
  });

  afterEach(^{
//    NSLog(@"=====================> I should run after all specs.");
  });

  describe(@"a nested spec", ^ {
    beforeEach(^ {
//      NSLog(@"=====================> I should run only before the nested specs.");
    });

    afterEach(^ {
//      NSLog(@"=====================> I should run only after the nested specs.");
    });

    it(@"should also run", ^ {
//      NSLog(@"=====================> Nested spec");
    });

    it(@"should also also run", ^ {
//      NSLog(@"=====================> Another nested spec");
    });
  });

  it(@"should run", ^ {
//    NSLog(@"=====================> Spec");
  });

  it(@"should be pending", PENDING);
  it(@"should also be pending", nil);
});

describe(@"The spec failure exception", ^{
//  it(@"should generate a spec failure", ^ {
//    [[SpecFailure specFailureWithReason:@"'cuz"] raise];
//  });
});

describe(@"Hamcrest matchers", ^{
  describe(@"equality", ^{
    describe(@"with Objective-C types", ^{
      __block NSNumber *expectedNumber;

      beforeEach(^{
        expectedNumber = [NSNumber numberWithInt:1];
      });

      it(@"should succeed when the two objects are equal", ^{
        assertThat(expectedNumber, equalTo([NSNumber numberWithInt:1]));
      });

      it(@"should fail when the two objects are not equal", ^{
        expectFailure(^{
          assertThat(expectedNumber, equalTo([NSNumber numberWithInt:2]));
        });
      });
    });

    describe(@"with built-in types", ^{
      __block int expectedValue = 1;

      beforeEach(^{
        expectedValue = 1;
      });

      it(@"should succeed when the two objects are equal", ^{
        assertThatInt(expectedValue, is(equalToInt(1)));
      });

      it(@"should succeed with different types that are comparable", ^{
        assertThatInt(expectedValue, is(equalToFloat(1.0)));
      });

      it(@"should fail when the objects are not equal", ^{
        expectFailure(^{
          assertThatInt(expectedValue, is(equalToInt(2)));
        });
      });
    });
  });
});

SPEC_END
