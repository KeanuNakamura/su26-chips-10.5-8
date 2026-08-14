# frozen_string_literal: true

Given /^I visit the new news article page for "([^"]*)"$/ do |name|
  visit representative_new_my_news_item_path(Representative.find_by!(name: name))
end

Then /^I should not see an? "([^"]*)" field$/ do |label|
  expect(page).to have_no_field(label)
end

Then /^I should see an? "([^"]*)" field$/ do |label|
  expect(page).to have_field(label)
end

Then /^I should see an? "([^"]*)" button$/ do |label|
  expect(page).to have_button(label)
end

Then /^"([^"]*)" should be set to "([^"]*)"$/ do |field, value|
  expect(find_field(field).find('option[selected]').text).to eq value
end

# The blank prompt option is excluded so the count matches NewsItem::ISSUES.
Then /^the "([^"]*)" dropdown should have (\d+) issues$/ do |field, count|
  options = find_field(field).all('option').map(&:value).compact_blank

  expect(options.length).to eq count.to_i
end

Then /^the "([^"]*)" dropdown should include "([^"]*)"$/ do |field, value|
  options = find_field(field).all('option').map(&:value)

  expect(options).to include(value)
end

Then /^I should land on the profile page for "([^"]*)"$/ do |name|
  expected = representative_path(Representative.find_by!(name: name))
  expect(page).to have_current_path(expected, wait: 5)
end

Given /^the following representatives exist:$/ do |table|
  table.hashes.each { |attrs| Representative.create!(attrs) }
end

Given /^I am logged in$/ do
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
    'provider' => 'github',
    'uid'      => '12345',
    'info'     => { 'name' => 'Test User', 'email' => 'test@example.com' }
  )

  visit '/auth/github/callback'
end

When /^I follow the representative link$/ do
  find('#ci-search-representative a').click
end
