require_relative '../common_steps/common_templates_steps'

When(/^I reference AppDelegate in the test$/) do
  `cp features/support/templates/ExampleSpec.mm template-project/Specs`
end

