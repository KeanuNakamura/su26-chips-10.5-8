# frozen_string_literal: true

# You should add your own steps and support functions here.

# These steps here are scaffolds, which might be useful.

Given /^I am logged in via (github|google|developer) as (".*")/i do |provider, _data|
  # This is just a start. You may want to setup Omniauth differently.
  # Look up Omniauth.test_mode
  page.find_link(text: "#{provider.capitalize} Login")
end

# Suggest Steps that Interact with the Map.
# The Map is rendered as a bunch of SVG elements, which clock can
# 'click' on and the user will be taken to the hopefully right page.
# You should inspect the HTML generated in the browser.
# As a hint you should be able to write some JavaScript
# Example JS: let ca = $('path[data-state-symbol="CA"]')
# This will find all elements based on those data attributes.

# <path class="actionmap-view-region" d="" tabindex="0" data-state-name="California"
#    data-state-fips-code="06" data-state-symbol="CA"></path>

Then /I click the state "(\w\w)"/i do |state|
  # Find the element, assert it exists.
  # then 'fake click' it by directly visiting the URL
  # IDEALLY we could call .click on the element directly, but
  # this currently errors in Chrome with SVG elements / doesn't navigate.
  expect(page).to have_css("path[data-state-symbol='#{state}']")
  visit state_map_path(state)
end

Then /I click the county "(.*)"/i do |county_name|
  selector =
    county_path_selector('data-county-name', county_name)

  expect(page).to have_css(selector, wait: 10)
  visit_county_representatives(county_name)
end

Then /I click the county with FIPS Code "(.*)"/i do |fips_code|
  selector = county_path_selector(
    'data-county-fips-code',
    fips_code.rjust(3, '0')
  )
  county_region = first(selector, wait: 10)
  visit_county_representatives(
    county_region['data-county-name']
  )
end

Then /I should see (\d+) (states|counties)/i do |count, region_type|
  attribute = region_type.casecmp('states').zero? ? 'data-state-symbol' : 'data-county-name'
  selector = "path[#{attribute}]"

  expect(page).to have_css(selector, minimum: 1, wait: 10)

  region_names = all(selector).pluck(attribute)
  expect(region_names.uniq.size).to eq(count.to_i)
end

When /I search for representatives in "(.*)"/i do |query|
  visit search_representatives_path(address: query)
end

Given /^there are no representative records$/ do
  expect(Representative.count).to eq(0)
end

Then /^(\d+) representative records should exist$/ do |count|
  expect(Representative.count).to eq(count.to_i)
end

module ActionMapStepHelpers
  INFO_CONTAINER_ID = 'actionmap-info-container'

  def current_state_symbol
    state_json =
      find_by_id(INFO_CONTAINER_ID, visible: :all)['data-state']

    JSON.parse(state_json).fetch('symbol')
  end

  def county_path_selector(attribute, value)
    %(path[#{attribute}="#{value}"])
  end

  def visit_county_representatives(county_name)
    address = "#{county_name}, #{current_state_symbol}"
    visit search_representatives_path(address: address)
  end
end

World(ActionMapStepHelpers)
