# Cedar

BDD-style testing using Objective-C


## Usage

* Build the Cedar framework.  Note that you must build for an Objective-C 
  runtime that supports blocks; this means Mac OS X 10.6, or a runtime from 
  Plausible Labs (see below).
* Create a command-line executable target for your tests in your project.  Name
  this target Specs, unless you have another name you'd prefer.
* Add the Cedar framework to your project, and link your Specs target to it.
* Do the Copy Framework Dance:
    - Add a Copy Files build phase to your Specs target.
    - Select the Frameworks destination for the build phase.
    - Add Cedar to the new build phase.
* Add a main.m that looks like this:

        #import "Cedar.h"
        
        int main (int argc, const char *argv[]) {
          return runAllSpecs();
        }

* Write your specs.  Cedar provides the SpecHelper.h file with some minimal
  macros to remove as much distraction as possible from your specs.  A spec
  file need not have a header file, and looks like this:

        #import "SpecHelper.h"
        
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
  order to run your specs.


## Matchers

Cedar does not provide matchers, but it works with the fine array of matchers 
provided by the Hamcrest project (http://code.google.com/p/hamcrest/); you can
fetch the Objective-C port from the Hamcrest SVN repo.  Build and link the 
Hamcrest framework by following their instructions, and add the following at 
the top of your spec files:

    #define HC_SHORTHAND
    #import <OCHamcrest/OCHamcrest.h>


## But I'm writing an iPhone app!

Unfortunately, Apple has made Objective-C blocks, upon which Cedar depends,
only available in the Mac OS X 10.6 runtime.  This means if you're not building
on a Snow Leopard machine and targeting the desktop runtime then anything using
blocks will fail to compile.  There are a couple ways around this:

* Plausible Labs provides patched versions of the GCC compiler and runtime for
  Leopard and iPhone OS (http://code.google.com/p/plblocks/).  I wrote most of 
  Cedar on a Leopard machine with the 10.5 PLBlocks runtime.

* Split your project into OS-dependent and OS-independent targets.  Domain 
  models and business logic shouldn't (theoretically) depend on the available
  UI frameworks.  Test everything that doesn't require UIKit/CoreGraphics/etc.
  using Cedar; test the UI using something else.

* I'm open to suggestions.


## Contributions

Welcomed!  Feel free to join and contribute to the public Tracker project here:
http://www.pivotaltracker.com/projects/77775


## License

Copyright (c) 2010 Pivotal Labs (www.pivotallabs.com)
Contact email: amilligan@pivotallabs.com

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
