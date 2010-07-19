#import "jasmine-iphone/jasmine-uiautomation.js"
#import "jasmine-iphone/jasmine-uiautomation-reporter.js"

// Import your JS spec files here.
#import "uiautomation-spec.js"

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();
