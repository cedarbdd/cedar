# Cedar

BDD-style testing using Objective-C


## Usage

### Clone from GitHub

* Don't forget to initialize submodules:

        $ git submodule update --init


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

* Build the Cedar-iPhone static framework.  This framework contains a universal
  binary that will work both on the simulator and the device.
  NOTE: due to a bug in the build process the script that builds the framework
  will sometimes not copy all of the header files appropriately.  If after you
  build the Headers directory under the built framework is empty, try deleting
  the built framework and building again.
* Create a Cocoa Touch "Application" target for your tests in your project.  Name
  this target UISpecs, or something similar.
* Open the Info.plist file for your project and remove the "Main nib file base
  name" entry.  The project template will likely have set this to "MainWindow."
* Add the Cedar-iPhone static framework to your project, and link your UISpecs
  target with it.
* Add -ObjC and -all_load to the Other Linker Flags build setting for the
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

        #if TARGET_OS_IPHONE
        #import <Cedar-iPhone/SpecHelper.h>
        #else
        #import <Cedar/SpecHelper.h>
        #endif


## Matchers

Cedar has a new set of matchers that use C++ templates to circumvent type issues that plague other
matcher libraries.  For example, rather than this (OCHamcrest):

    assertThat(aString, equalTo(@"something"));
    assertThatInt(anInteger, equalToInt(7));
    assertThatBool(aBoolean, equalTo(YES));

you can write the following:

    expect(aString).to(equal(@"something"));
    expect(anInteger).to(equal(7));
    expect(aBoolean).to(equal(YES));

although you would more likely write the last line as:

    expect(aBoolean).to(be_truthy());

It's also theoretically very easy to add your own matchers without modifying the Cedar library
(more on this later).

This matcher library is new, and not hardly battle-hardened.  It also breaks Apple's GCC compiler,
and versions 2.0 and older of the LLVM compiler (this translates to any compiler shipped with a
version of Xcode before 4.1).  Fortunately, LLVM 2.1 fixes the issues.  If you'd prefer a more 
stable matcher library, you can still easily use [OCHamcrest](http://code.google.com/p/hamcrest/).
Build and link the Hamcrest framework by following their instructions, and add the following at
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
            expect(thing.color).to(equal(red));
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


## Global beforeEach and afterEach

In many cases you have some housekeeping you'd like to take care of before every spec in your entire
suite.  For example, loading fixtures or resetting a global variable.  Cedar will look for the
+beforeEach and +afterEach class methods on every class it loads; you can add this class method
onto any class you compile into your specs and Cedar will run it.  This allows spec libraries to 
provide global +beforeEach and +afterEach methods specific to their own functionality, and they 
will run automatically.

If you want to run your own code before or after every spec, simply declare a class and implement 
the +beforeEach and/or +afterEach methods.


## Mocks and stubs

Cedar works fine with OCMock.  You can download and use the [OCMock framework](http://www.mulle-kybernetik.com/software/OCMock/).
Pivotal also has a fork of a [GitHub import of the OCMock codebase](http://github.com/pivotal/OCMock),
which contains our iPhone-specific static framework target.  Cedar also references
the Pivotal fork of OCMock as a submodule.


## Pending specs

If you'd like to specify but not implement an example you can do so like this:

          it(@"should do something eventually", PENDING);

The spec runner will not try to run this example, but report it as pending.  The
PENDING keyword simply references a nil block pointer; if you prefer you can
explicitly pass nil as the second parameter.  The parameter is necessary because
C, and thus Objective-C, doesn't support function parameter overloading or
default parameters.


## Focused specs

Sometimes when debugging or developing a new feature it is useful to run only a
subset of your tests.  That can be achieved by marking any number/combination of
examples with an 'f'. You can use `fit`, `fdescribe` and `fcontext` like this:

          fit(@"should do something eventually", ^{
              // ...
          });

If your test suite has at least one focused example, all focused examples will
run and non-focused examples will be skipped and reported as such (shown as '>'
in default reporter output).

It might not be immediately obvious why the test runner always returns a
non-zero exit code when a test suite contains at least one focused example. That
was done to make CI fail if someone accidently forgets to unfocus focused
examples before commiting and pushing.


## Code Snippets

Xcode 4 has replaced text macros with code snippets.  If you're still using Xcode 3,
check out the xcode3 branch from git and read the section on MACROS.

You can place the codesnippet files contained in CodeSnippets directory into this location
(you may need to create the directory):

        ~/Library/Developer/XCode/UserData/CodeSnippets

Alternately, you can run the installCodeSnippets script, which will do it for you. 


## Contributions and feedback

Welcomed!  Feel free to join and contribute to the public Tracker project [here](http://www.pivotaltracker.com/projects/77775).

The [public Google group](http://groups.google.com/group/cedar-discuss) for Cedar is cedar-discuss@googlegroups.com.
Or, you can follow the growth of Cedar on Twitter: [@cedarbdd](http://twitter.com/cedarbdd).

Copyright (c) 2011 Pivotal Labs. This software is licensed under the MIT License.
