When(/^I add a failing test$/) do
  `cp features/support/templates/FailingSpec.mm template-project/Specs/ExampleSpec.mm`
end

When(/^I reference AppDelegate in the test$/) do
  `cp features/support/templates/ExampleSpec.mm template-project/Specs`
end
