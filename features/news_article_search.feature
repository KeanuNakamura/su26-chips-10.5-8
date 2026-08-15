Feature: Choosing a representative and issue to search news for

  As a voter
  I want to pick a representative and an issue
  So that I can search for articles instead of typing them in by hand

  Background:
    Given the following representatives exist:
      | name           | title          |
      | Gavin Newsom   | governor       |
      | Lateefah Simon | representative |
    And I am logged in
    And I visit the new news article page for "Gavin Newsom"

  Scenario: The page no longer asks for article details
    Then I should not see a "Title" field
    And I should not see a "Link" field
    And I should not see a "Description" field

  Scenario: The page offers a representative, an issue, and a search button
    Then I should see a "Representative" field
    And I should see an "Issue" field
    And I should see a "Search" button

  Scenario: The representative from the URL is pre-selected
    Then "Representative" should be set to "Gavin Newsom"

  Scenario: Every issue is offered in the dropdown
    Then the "Issue" dropdown should have 17 issues

  Scenario: Issue options have no stray whitespace
    Then the "Issue" dropdown should include "Social Security and Medicare"
    And the "Issue" dropdown should include "Net Neutrality"

  Scenario: Searching carries the issue and the representative forward
    When I select "Climate Change" from "Issue"
    And I press "Search"
    Then I should see "Issue: Climate Change"
    And I should see "Representative: Gavin Newsom"

  Scenario: The representative links to their profile page
    When I select "Climate Change" from "Issue"
    And I press "Search"
    And I follow the representative link
    Then I should land on the profile page for "Gavin Newsom"

  Scenario: A different representative can be chosen
    When I select "Lateefah Simon" from "Representative"
    And I select "Immigration" from "Issue"
    And I press "Search"
    Then I should see "Representative: Lateefah Simon"

  Scenario: Searching with no issue is rejected
    When I press "Search"
    Then I should see "Choose an issue to search for"