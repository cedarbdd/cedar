Feature:
  As a user,
  I should be able to use Cedar templates

  Scenario: Add Cedar spec bundle target
    Given an Xcode OS X project

    When I add an OS X Spec bundle target
    Then the `rake Specs` should work

  Scenario: Add Cedar spec suite target
    Given an Xcode OS X project

    When I add an OS X Spec suite target
    Then the `rake Specs` should work

  Scenario: Failing Spec suite tests
    Given an Xcode OS X project

    When I add an OS X Spec suite target
    And I add a failing test
    Then running the specs from the rake task should fail

  Scenario: Failing Spec bundle tests
    Given an Xcode OS X project

    When I add an OS X Spec bundle target
    And I add a failing test
    Then running the specs from the rake task should fail

