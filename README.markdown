# Cedar

[![Build Status](https://travis-ci.org/pivotal/cedar.png?branch=master)](https://travis-ci.org/pivotal/cedar)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

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


# Quick start

* Add Cedar to your project via [Cocoapods](https://cocoapods.org/pods/Cedar) (`pod 'Cedar'`), [Carthage](https://github.com/Carthage/Carthage) (`github "pivotal/cedar"`), or [another method](https://github.com/pivotal/cedar/wiki/Installation#available-installation-methods)
* Install the Cedar Xcode file templates using the [Alcatraz package manager](http://alcatraz.io/) or by running this command in a terminal:
```
    $ curl -L https://raw.github.com/pivotal/cedar/master/install.sh | bash
```
* Or if you want to install from HEAD. Run:
```
    $ bash <(echo "set -- --head; $(curl -L https://raw.github.com/pivotal/cedar/master/install.sh)")
```

* Restart Xcode
* Add new spec files to your project's Test Bundle using the Xcode templates
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
* [Brian Croom](mailto:bcroom@pivotal.io) ([briancroom](https://github.com/briancroom)), Pivotal Labs, Toronto
* [Jeff Hui](mailto:jhui@pivotallabs.com) ([jeffh](https://github.com/jeffh)), Pivotal Labs, San Francisco
* [Sam Coward](mailto:scoward@pivotallabs.com) ([idoru](https://github.com/idoru)), Pivotal Labs, New York
* [Tim Jarratt](mailto:tjarratt@pivotal.io) ([tjarratt](https://github.com/tjarratt)), Pivotal Labs, San Francisco

Copyright (c) 2010-2014 Pivotal Labs. This software is licensed under the MIT License. [![Mixpanel](https://api.mixpanel.com/track/?data=CXsiZXZlbnQiOiAiSG9tZSBWaXNpdCIsIA0KICAgIAkJInByb3BlcnRpZXMiOiB7ICAJDQogICAgICAgIAkidG9rZW4iOiAiNmJjZmE3MmQ5OGU2ZjdhZjFkNjQ3YWNmY2Q2NjMwNTEiICAgDQogICAgICAgICAgICAgICAgfQ0KICAgICAgICB9&ip=1&img=1)](http://mixpanel.com)
