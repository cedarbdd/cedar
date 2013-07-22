Feature:
  As a user,
  I should be able to use Cedar templates

  Scenario: Add Cedar spec bundle target
    Given a Xcode project

    When I add a Spec bundle target
    Then the `rake Spec` should work

  Scenario: Add Cedar spec suite target
    Given a Xcode project

    When I add a Spec suite target
    Then the `rake Spec` should work
