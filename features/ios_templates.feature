Feature:
  As a user,
  I should be able to use Cedar templates

  Scenario: Add Cedar spec bundle target
    Given an Xcode iOS project

    When I add an iOS Spec bundle target
    Then the `rake Specs` should work

  Scenario: Add Cedar spec suite target
    Given an Xcode iOS project

    When I add an iOS Spec suite target
    Then the `rake Specs` should work

  Scenario: Create new test suite and refererence AppDelegate in test
    Given an Xcode iOS project

    When I add an iOS Spec bundle target
    And I reference AppDelegate in the test
    Then the `rake Specs` should work

  Scenario: Failing Spec suite tests
    Given an Xcode iOS project

    When I add an iOS Spec suite target
    And I add a failing test
    Then running the specs from the rake task should fail

  Scenario: Failing spec bundle tests
    Given an Xcode iOS project
  
    When I add an iOS Spec bundle target
    And I add a failing test
    Then running the specs from the rake task should fail

