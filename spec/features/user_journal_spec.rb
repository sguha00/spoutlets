require 'spec_helper'

feature "User wanting to view entries" do

  let(:user) {FactoryGirl.create(:user)}
  background { login user }

  scenario "needs to register an account" do
    #NOTE: since a user has already signed in in the background section, I need to sign him out
    visit signout_path
    visit new_user_registration_path
    click_button "Register"
    page.should have_content "problems"
    fill_in "user_email", with: "test@test.com"
    fill_in "user_password", with: "dontellanyone"
    fill_in "user_password_confirmation", with: "dontellanyone"
    click_button "Register"
    page.should have_content "Welcome! You have signed up successfully."
    page.should have_content 'Shared entries'
    current_path.should == entries_path
  end

  scenario "must be signed in" do
    #NOTE: user has logged in in the background section of the feature
    page.should have_content "Signed in successfully."
    visit signout_path
    page.should have_content "Signed out successfully."
  end

  %w(happiness anxiety irritation).each do |emotional_state|
    scenario "#{emotional_state} bar should be visible when value is > 0" do
      FactoryGirl.create(:entry, user: user)
      visit entries_path
      page.should have_content(emotional_state)
      visit home_path
      page.should have_content(emotional_state)
      visit user_path(user)
      page.should have_content(emotional_state)
    end

    scenario "anxiety bar should not be visible when value is 0" do
      entry = FactoryGirl.create(:entry_without_emotional_state, user: user)
      visit entries_path
      page.should_not have_content(emotional_state)
      visit home_path
      page.should_not have_content(emotional_state)
      visit user_path(user)
      page.should_not have_content(emotional_state)
    end
  end
end
