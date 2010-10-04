# Cedar

BDD-style testing using Objective-C


## Usage

### Non-iPhone testing

* Build the Cedar framework.  Note that you must build for an Objective-C
  runtime that supports blocks; this means Mac OS X 10.6, or a runtime from
  Plausible Labs (see below).
* Create a command-line executable target for your tests in your project.  Name
  this target Specs, unless you have another name you'd prefer.
* Add the Cedar framework to your project, and link your Specs target with it.
* Do the Copy Framework Dance:
    - Add a Copy Files build phase to your Specs target.
    - Select the Frameworks destination for the build phase.
    - Add Cedar to the new build phase.
* Add a main.m to your Specs target that looks like this:

        #import <Cedar/Cedar.h>

        int main (int argc, const char *argv[]) {
          return runAllSpecs();
        }

* Write your specs.  Cedar provides the SpecHelper.h file with some minimal
  macros to remove as much distraction as possible from your specs.  A spec
  file need not have a header file, and looks like this:

        #import <Cedar/SpecHelper.h>

        SPEC_BEGIN(FooSpec)
        describe(@"Foo", ^{
          beforeEach(^{
            ...
          });

          it(@"should do something", ^{
            ...
          });
        });
        SPEC_END

* Build and run.  Note that, unlike OCUnit, you must run your executable in
  order to run your specs.  Also unlike OCUnit this allows you to use the
  debugger when running specs.

### iPhone testing

* Build the Cedar-iPhone static framework.  This framework contains a univeral
  binary that will work both on the simulator and the device.
* Create a Cocoa Touch executable target for your tests in your project.  Name
  this target UISpecs, or something similar.
* Add the Cedar-iPhone static framework to your project, and link your UISpecs
  target with it.
* Add -ObjC, -lstdc++ and -all_load to the Other Linker Flags build setting for the
  UISpecs target.  This is necessary for the linker to correctly load symbols
  for Objective-C classes from static libraries.
* Add a main.m to your UISpecs target that looks like this:

        #import <UIKit/UIKit.h>
        #import <Cedar-iPhone/Cedar.h>

        int main(int argc, char *argv[]) {
            NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

            int retVal = UIApplicationMain(argc, argv, nil, @"CedarApplicationDelegate");
            [pool release];
            return retVal;
        }

* Build and run.  The simulator (or device) should start and display the status
  of each of your spec classes in a table view.  You can navigate the hierarchy
  of your examples by clicking on the table cells.
* If you would like to use OCHamcrest or OCMock in your UI specs, Pivotal has
  created static frameworks which will work on the iPhone for both.  These must
  be built so you can add them as available frameworks in your specs.  See the
  sections below on Matchers and Mocks for links to the relevant projects.
* If you would like to run specs both in your UI spec target and your non-UI
  spec target, you'll need to conditionally include the appropriate Cedar
  headers in your spec files depending on the target SDK.  For example:

        #define HC_SHORTHAND
        #if TARGET_OS_IPHONE
        #import <Cedar-iPhone/SpecHelper.h>
        #import <OCMock-iPhone/OCMock.h>
        #import <OCHamcrest-iPhone/OCHamcrest.h>
        #else
        #import <Cedar/SpecHelper.h>
        #import <OCMock/OCMock.h>
        #import <OCHamcrest/OCHamcrest.h>
        #endif


## Matchers

Cedar does not provide matchers, but it works with the fine array of matchers
provided by the [Hamcrest project](http://code.google.com/p/hamcrest/); you can
fetch the Objective-C port from the Hamcrest SVN repo.  Build and link the
Hamcrest framework by following their instructions, and add the following at
the top of your spec files:

    #define HC_SHORTHAND
    #import <OCHamcrest/OCHamcrest.h>

Pivotal also has a fork of a [GitHub import of the OCHamcrest codebase](http://github.com/pivotal/OCHamcrest).
This fork contains our iPhone-specific static framework target.


## Shared example groups

Cedar supports shared example groups; you can declare them in one of two ways:
either inline with your spec declarations, or separately.

Declaring shared examples inline with your specs is the simplest:

    SPEC_BEGIN(FooSpecs)

    sharedExamplesFor(@"a similarly-behaving thing", ^(NSDictionary *context) {
        it(@"should do something common", ^{
            ...
        });
    });

    describe(@"Something that shares behavior", ^{
        itShouldBehaveLike(@"a similarly-behaving thing");
    });

    describe(@"Something else that shares behavior", ^{
        itShouldBehaveLike(@"a similarly-behaving thing");
    });

    SPEC_END

Sometimes you'll want to put shared examples in a separate file so you can use
them in several specs across different files.  You can do this using macros
specifically for declaring shared example groups:

    SHARED_EXAMPLE_GROUPS_BEGIN(GloballyCommon)

    sharedExamplesFor(@"a thing with globally common behavior", ^(NSDictionary *context) {
        it(@"should do something really common", ^{
            ...
        });
    });

    SHARED_EXAMPLE_GROUPS_END

The context dictionary allows you to pass example-specific state into the shared
example group.  You can populate the context dictionary available on the SpecHelper
object, and each shared example group will receive it:

    sharedExamplesFor(@"a red thing", ^(NSDictionary *context) {
        it(@"should be red", ^{
            Thing *thing = [context objectForKey:@"thing"];
            assertThat(thing.color, equalTo(red));
        });
    });

    describe(@"A fire truck", ^{
        beforeEach(^{
            [[SpecHelper specHelper].sharedExampleContext setObject:[FireTruck fireTruck] forKey:@"thing"];
        });
        itShouldBehaveLike(@"a red thing");
    });

    describe(@"An apple", ^{
        beforeEach(^{
            [[SpecHelper specHelper].sharedExampleContext setObject:[Apple apple] forKey:@"thing"];
        });
        itShouldBehaveLike(@"a red thing");
    });

Previously, you needed to instantiate and pass in your own dictionary, but this
led to confusion and unavoidable memory leaks.  You should change any code that
uses a local context dictionary to use the global shared example context
dictionary.


## Mocks and stubs

Cedar works fine with OCMock.  You can download and use the [OCMock framework](http://www.mulle-kybernetik.com/software/OCMock/).
Pivotal also has a fork of a [GitHub import of the OCMock codebase](http://github.com/pivotal/OCMock),
which contains our iPhone-specific static framework target.


## Pending specs

If you'd like to specify but not implement an example you can do so like this:

          it(@"should do something eventually", PENDING);

The spec runner will not try to run this example, but report it as pending.  The
PENDING keyword simply references a nil block pointer; if you prefer you can
explicitly pass nil as the second parameter.  The parameter is necessary because
C, and thus Objective-C, doesn't support function parameter overloading or
default parameters.

## Macros

The project root contains a file named MACROS, which contains some useful Xcode
macros for writing Cedar specs.  To load the macros copy the contents of the
file into this file:

        ~/Library/Application\ Support/Developer/Shared/Xcode/Specifications/ObjectiveC.xctxtmacro

You may need to create that file.  If the file already exists, and contains pre-
existing macros, be careful to insert the Cedar macros inside the existing
parentheses properly.

To use the macros, type the shortcut string, followed by Ctrl-. or Ctrl-,  As an
example, typing 'cdesc' followed by Ctrl-. will expand to:

        describe(@"<#!subject under test!#>", ^{
            <#!content!#>
        });


## But I'm writing a pre-4.0 iPhone app!

Unfortunately, Apple has made Objective-C blocks, upon which Cedar depends,
only available in the Mac OS X 10.6 and iOS 4 runtime.  This means if you're not
building on a Snow Leopard machine and targeting the desktop runtime or
targeting a device or simulator that is running less than iOS 4 then anything
using blocks will fail to compile.  There are a couple ways around this:

* Plausible Labs provides patched versions of the [GCC compiler and runtime for
  Leopard and iPhone OS](http://code.google.com/p/plblocks/).  This link
  has instructions for installing this compiler and framework.  I wrote most of
  Cedar on a Leopard machine with the 10.5 PLBlocks runtime.

* Split your project into OS-dependent and OS-independent targets.  Domain
  models and business logic shouldn't (theoretically) depend on the available
  UI frameworks.  Test everything that doesn't require UIKit/CoreGraphics/etc.
  using Cedar; test the UI using something else.

* We're open to suggestions.

The Cedar-iPhone target builds a framework specifically designed for specs on
the iPhone device.  It includes a static library that includes builds targeting
both the simulator and device runtimes.

We've created a sample iPhone application that runs Cedar specs both on and off
the device.  You can check it out [here](http://github.com/pivotal/StoryAccepter).

See the Pivotal forks of OCHamcrest and OCMock on GitHub for iPhone-specific
static framework targets.


## Contributions and feedback

Welcomed!  Feel free to join and contribute to the public Tracker project [here](http://www.pivotaltracker.com/projects/77775).

The [public Google group](http://groups.google.com/group/cedar-discuss) for Cedar is cedar-discuss@googlegroups.com.
Or, you can follow the growth of Cedar on Twitter: [@cedarbdd](http://twitter.com/cedarbdd).

Copyright (c) 2010 Pivotal Labs. This software is licensed under the MIT License.
