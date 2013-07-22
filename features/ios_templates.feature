Feature:
  As a user,
  I should be able to use Cedar templates

  Scenario: Add Cedar spec bundle target
    Given an Xcode iOS project

    When I add an iOS Spec bundle target
    Then the `rake Spec` should work

  Scenario: Add Cedar spec suite target
    Given an Xcode iOS project

    When I add an iOS Spec suite target
    Then the `rake Spec` should work
