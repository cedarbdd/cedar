# Cedar

[![Build Status](https://travis-ci.org/pivotal/cedar.png?branch=master)](https://travis-ci.org/pivotal/cedar)

Cedar is a BDD-style Objective-C testing framework with an expressive matcher DSL and convenient test doubles.

```objc
describe(@"Example specs on NSString", ^{
    it(@"lowercaseString returns a new string with everything in lower case", ^{
        [@"FOOBar" lowercaseString] should equal(@"foobar");
    });

    it(@"length returns the number of characters in the string", ^{
        [@"internationalization" length] should equal(20);
    });

    describe(@"isEqualToString:", ^{
        it(@"should return true if the strings are the same", ^{
            [@"someString" isEqualToString:@"someString"] should be_truthy;
        });

        it(@"should return false if the strings are not the same", ^{
            [@"someString" isEqualToString:@"anotherString"] should be_falsy;
        });
    });
});
```

## Note for Xcode 7 users

With Xcode 7, Apple has introduced changes to `XCTest.framework` which are incompatible with Cedar's test bundle
runner. (See [#333](https://github.com/pivotal/cedar/issues/333) for more details.) Support for Xcode 7 is 
being actively developed on the `Xcode7` [branch](https://github.com/pivotal/cedar/tree/Xcode7) which should be
used until we feel that the Xcode 7 betas have stabilized and we are ready to merge this work into the `master` branch.

# Quick start

* Install the Xcode command line tools package (Under the Preferences tab 'Downloads') if you haven't already done so
* Run the following in a terminal to install Xcode templates for ease of use:

```
    $ curl -L https://raw.github.com/pivotal/cedar/master/install.sh | bash
```

* If you wish to specify a version. Run the following command: (version_name is v0.11.0, v0.10.0 etc...)

```
    $ bash <(echo "set -- --version 'version_name'; $(curl -L https://raw.github.com/pivotal/cedar/master/install.sh)")
```

* Or if you want to install from HEAD. Run:

```
    $ bash <(echo "set -- --head; $(curl -L https://raw.github.com/pivotal/cedar/master/install.sh)")
```

* Restart Xcode
* Add new targets or files to your project using the Xcode templates, or create a new project to test-drive from scratch
* Start writing specs!

# Documentation

Documentation can be found on the [Cedar Wiki](https://github.com/pivotal/cedar/wiki).

# Support and feedback

* Search past discussions: [http://groups.google.com/group/cedar-discuss](http://groups.google.com/group/cedar-discuss)
* Send an e-mail to the discussion list: [mailto:cedar-discuss@googlegroups.com](mailto:cedar-discuss@googlegroups.com)
* View the project backlog on Pivotal Tracker: [http://www.pivotaltracker.com/projects/77775](http://www.pivotaltracker.com/projects/77775).
* Follow us on twitter: [@cedarbdd](http://twitter.com/cedarbdd)

# Contributing

Please read the [Contributor Guide](https://github.com/pivotal/cedar/wiki/Contributor-guide) on the wiki.

# Maintainers

* [Andrew Kitchen](mailto:akitchen@pivotallabs.com) ([akitchen](https://github.com/akitchen)), Pivotal Labs, San Francisco
* [Brian Croom](mailto: bcroom@pivotallabs.com) ([pivotal-brian-croom](https://github.com/pivotal-brian-croom)), Pivotal Labs, Toronto
* [Jeff Hui](mailto:jhui@pivotallabs.com) ([jeffh](http://github.com/jeffh)), Pivotal Labs, San Francisco
* [Sam Coward](mailto:scoward@pivotallabs.com) ([idoru](http://github.com/idoru)), Pivotal Labs, New York

Copyright (c) 2010-2014 Pivotal Labs. This software is licensed under the MIT License. [![Mixpanel](https://api.mixpanel.com/track/?data=CXsiZXZlbnQiOiAiSG9tZSBWaXNpdCIsIA0KICAgIAkJInByb3BlcnRpZXMiOiB7ICAJDQogICAgICAgIAkidG9rZW4iOiAiNmJjZmE3MmQ5OGU2ZjdhZjFkNjQ3YWNmY2Q2NjMwNTEiICAgDQogICAgICAgICAgICAgICAgfQ0KICAgICAgICB9&ip=1&img=1)](http://mixpanel.com)
