Feature: ActionMap Shows State and County Maps

Scenario: Navigating States and counties
  Given I am on the homepage
  Then I should see "National Map"
  When I click the state "CA"
  Then I should see "California"
  And I should be on the state page for "CA"

Scenario: The california state map renders all county regions
  Given I am on the state page for "CA"
  Then I should see 58 counties
  When I click the county "Alameda County"
  Then I should see "Search Results"
  And I should see "Alameda County, CA"
  And I should see "Lateefah Simon"

Scenario: A county search URL returns representatives
  Given there are no representative records
  When I search for representatives in "Alameda County, CA"
  Then I should see "Search Results"
  And I should see "Table of Representatives"
  And I should see "Lateefah Simon"
  And 3 representative records should exist