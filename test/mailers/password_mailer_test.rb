# encoding: utf-8

require "test_helper"

class PasswordMailerTest < ActionMailer::TestCase
  test "reset" do
    user = users(:one)
    mail = PasswordMailer.with(user: user).reset
    assert_equal "Reset", mail.subject
    assert_equal [ user.email ], mail.to
    assert_equal [ "from@example.com" ], mail.from
  end
end
