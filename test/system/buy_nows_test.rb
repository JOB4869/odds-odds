require "application_system_test_case"

class BuyNowsTest < ApplicationSystemTestCase
  setup do
    @buy_now = buy_nows(:one)
  end

  test "visiting the index" do
    visit buy_nows_url
    assert_selector "h1", text: "Buy nows"
  end

  test "should create buy now" do
    visit buy_nows_url
    click_on "New buy now"

    fill_in "Amount", with: @buy_now.amount
    fill_in "Proof of payment", with: @buy_now.proof_of_payment
    fill_in "Status", with: @buy_now.status
    fill_in "User", with: @buy_now.user_id
    click_on "Create Buy now"

    assert_text "Buy now was successfully created"
    click_on "Back"
  end

  test "should update Buy now" do
    visit buy_now_url(@buy_now)
    click_on "Edit this buy now", match: :first

    fill_in "Amount", with: @buy_now.amount
    fill_in "Proof of payment", with: @buy_now.proof_of_payment
    fill_in "Status", with: @buy_now.status
    fill_in "User", with: @buy_now.user_id
    click_on "Update Buy now"

    assert_text "Buy now was successfully updated"
    click_on "Back"
  end

  test "should destroy Buy now" do
    visit buy_now_url(@buy_now)
    accept_confirm { click_on "Destroy this buy now", match: :first }

    assert_text "Buy now was successfully destroyed"
  end
end
