require "application_system_test_case"

class EditAccountsTest < ApplicationSystemTestCase
  setup do
    @edit_account = edit_accounts(:one)
  end

  test "visiting the index" do
    visit edit_accounts_url
    assert_selector "h1", text: "Edit accounts"
  end

  test "should create edit account" do
    visit edit_accounts_url
    click_on "New edit account"

    fill_in "Address", with: @edit_account.address
    fill_in "First name", with: @edit_account.first_name
    fill_in "Last name", with: @edit_account.last_name
    fill_in "Phone", with: @edit_account.phone
    fill_in "User", with: @edit_account.user_id
    click_on "Create Edit account"

    assert_text "Edit account was successfully created"
    click_on "Back"
  end

  test "should update Edit account" do
    visit edit_account_url(@edit_account)
    click_on "Edit this edit account", match: :first

    fill_in "Address", with: @edit_account.address
    fill_in "First name", with: @edit_account.first_name
    fill_in "Last name", with: @edit_account.last_name
    fill_in "Phone", with: @edit_account.phone
    fill_in "User", with: @edit_account.user_id
    click_on "Update Edit account"

    assert_text "Edit account was successfully updated"
    click_on "Back"
  end

  test "should destroy Edit account" do
    visit edit_account_url(@edit_account)
    accept_confirm { click_on "Destroy this edit account", match: :first }

    assert_text "Edit account was successfully destroyed"
  end
end
