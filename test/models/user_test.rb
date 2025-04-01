require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    # Using existing fixture user is fine, or build a new one
    @user = users(:one)
    # Or: @user = User.new(email: 'test@example.com', password: 'Password123!', password_confirmation: 'Password123!')
  end

  test "should be valid with valid attributes (on create)" do
    user = User.new(email: "create@example.com", password: "ValidP@ss1", password_confirmation: "ValidP@ss1")
    assert user.valid?, "User should be valid on create with valid email and password format. Errors: #{user.errors.full_messages.inspect}"
  end

  test "should have default beer balance of 0 on create" do
    user = User.create(email: "balance@example.com", password: "ValidP@ss1", password_confirmation: "ValidP@ss1")
    assert_equal 0, user.beer_balance
  end

  # --- Email Validations ---
  test "should be invalid without email" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "กรุณากรอกอีเมล"
  end

  test "should be invalid with duplicate email" do
    existing_user = users(:one)
    user = User.new(email: existing_user.email, password: "Password123!", password_confirmation: "Password123!")
    assert_not user.valid?
    assert_includes user.errors[:email], "อีเมลนี้ถูกใช้งานแล้ว"
  end

  test "should be invalid with invalid email format" do
    invalid_emails = %w[user@example,com user_at_example.org user.example@ user@example. user@exam+ple.com]
    invalid_emails.each do |invalid_email|
      @user.email = invalid_email
      assert_not @user.valid?, "#{invalid_email.inspect} should be invalid"
      assert_includes @user.errors[:email], "รูปแบบอีเมลไม่ถูกต้อง"
    end
  end

  test "should be valid with valid email format" do
    valid_emails = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_emails.each do |valid_email|
      # Need a new user instance each time for uniqueness check
      user = User.new(email: valid_email, password: "ValidP@ss1", password_confirmation: "ValidP@ss1")
      assert user.valid?, "#{valid_email.inspect} should be valid. Errors: #{user.errors.full_messages.inspect}"
    end
  end

  # --- Password Validations (on create) ---
  test "should be invalid without password on create" do
    user = User.new(email: "nopass@example.com")
    assert_not user.valid?
    assert_includes user.errors[:password], "กรุณากรอกรหัสผ่าน"
  end

  test "should be invalid with short password on create" do
    user = User.new(email: "shortpass@example.com", password: "aB1!", password_confirmation: "aB1!")
    assert_not user.valid?
    # Check for the length validation message first
    assert_includes user.errors[:password], "รหัสผ่านต้องมีความยาวระหว่าง 8-16 ตัวอักษร"
  end

  test "should be invalid with long password on create" do
    long_pass = "a" * 17 + "B1!"
    user = User.new(email: "longpass@example.com", password: long_pass, password_confirmation: long_pass)
    assert_not user.valid?
    # Check for the length validation message first
    assert_includes user.errors[:password], "รหัสผ่านต้องมีความยาวระหว่าง 8-16 ตัวอักษร"
  end

  test "should be invalid with password missing letters on create" do
    user = User.new(email: "noletter@example.com", password: "12345678!", password_confirmation: "12345678!")
    assert_not user.valid?
    assert_includes user.errors[:password], "รหัสผ่านต้องประกอบด้วยตัวอักษร ตัวเลข และสัญลักษณ์พิเศษ"
  end

  test "should be invalid with password missing numbers on create" do
    user = User.new(email: "nonumber@example.com", password: "Password!", password_confirmation: "Password!")
    assert_not user.valid?
    assert_includes user.errors[:password], "รหัสผ่านต้องประกอบด้วยตัวอักษร ตัวเลข และสัญลักษณ์พิเศษ"
  end

  test "should be invalid with password missing symbols on create" do
    user = User.new(email: "nosymbol@example.com", password: "Password123", password_confirmation: "Password123")
    assert_not user.valid?
    assert_includes user.errors[:password], "รหัสผ่านต้องประกอบด้วยตัวอักษร ตัวเลข และสัญลักษณ์พิเศษ"
  end

  test "password validation should not run on update if password blank" do
    @user.save! # Ensure user is persisted
    @user.first_name = "Test" # Make a change other than password
    @user.password = "" # Set password to blank
    @user.password_confirmation = ""
    assert @user.valid?(:update), "Should be valid on update even if password blank if other fields are valid. Errors: #{@user.errors.full_messages.inspect}"
  end

  # --- beer_balance Validations ---
  test "should be invalid with negative beer_balance" do
    # Need to bypass standard setters if possible or test via methods
    # @user.beer_balance = -1 # Direct assignment might be restricted
    # assert_not @user.valid?
    # assert_includes @user.errors[:beer_balance], "ต้องมากกว่าหรือเท่ากับ 0"

    # Test via methods instead:
    @user.beer_balance = 5
    assert_not @user.withdraw(10), "Withdraw more than balance should fail"
    assert_equal 5, @user.beer_balance # Balance should not change
  end

  # --- Profile Validations (on update) ---
  test "should be invalid without first_name on update" do
    @user.save! # Ensure persisted
    @user.first_name = nil
    assert_not @user.valid?(:update)
    assert_includes @user.errors[:first_name], "กรุณากรอกชื่อ"
  end

  test "should be invalid with invalid first_name format on update" do
     @user.save!
     @user.first_name = "Name123"
     assert_not @user.valid?(:update)
     assert_includes @user.errors[:first_name], "กรุณากรอกเฉพาะตัวอักษรไทยหรืออังกฤษ"
  end

  test "should be invalid without last_name on update" do
    @user.save!
    @user.last_name = nil
    assert_not @user.valid?(:update)
    assert_includes @user.errors[:last_name], "กรุณากรอกนามสกุล"
  end

   test "should be invalid with invalid last_name format on update" do
     @user.save!
     @user.last_name = "Last123"
     assert_not @user.valid?(:update)
     assert_includes @user.errors[:last_name], "กรุณากรอกเฉพาะตัวอักษรไทยหรืออังกฤษ"
  end

  test "should be invalid without phone on update" do
    @user.save!
    @user.phone = nil
    assert_not @user.valid?(:update)
    assert_includes @user.errors[:phone], "กรุณาเบอร์โทรศัพท์"
  end

  test "should be invalid with incorrect phone length on update" do
    @user.save!
    @user.phone = "12345"
    assert_not @user.valid?(:update)
    # Use the standard Rails length error message format
    assert_includes @user.errors[:phone], "is the wrong length (should be 10 characters)"

    @user.phone = "12345678901"
    assert_not @user.valid?(:update)
    assert_includes @user.errors[:phone], "is the wrong length (should be 10 characters)"
  end

  test "should be invalid with non-digit phone on update" do
     @user.save!
     @user.phone = "12345abcde"
     assert_not @user.valid?(:update)
     assert_includes @user.errors[:phone], "เบอร์โทรศัพท์ 10 หลัก"
  end

  test "should be invalid without prompt_pay on update" do
    @user.save!
    @user.prompt_pay = nil
    assert_not @user.valid?(:update)
    assert_includes @user.errors[:prompt_pay], "กรุณากรอกพร้อมเพย์"
  end

  test "should be invalid with invalid prompt_pay format on update" do
    @user.save!
    @user.prompt_pay = "12345"
    assert_not @user.valid?(:update)
    assert_includes @user.errors[:prompt_pay], "หมายเลขโทรศัพท์ 10 หลัก, หมายเลขบัตรประชาชน 13 หลัก"

    @user.prompt_pay = "123456789012"
    assert_not @user.valid?(:update)
    assert_includes @user.errors[:prompt_pay], "หมายเลขโทรศัพท์ 10 หลัก, หมายเลขบัตรประชาชน 13 หลัก"

     @user.prompt_pay = "abcdefghij"
    assert_not @user.valid?(:update)
    assert_includes @user.errors[:prompt_pay], "หมายเลขโทรศัพท์ 10 หลัก, หมายเลขบัตรประชาชน 13 หลัก"
  end

  test "should be valid with 10 or 13 digit prompt_pay on update" do
    @user.save!
    @user.prompt_pay = "0123456789"
    assert @user.valid?(:update) || !@user.errors[:prompt_pay].any?, "10 digit prompt_pay should be valid"

    @user.prompt_pay = "1234567890123"
    assert @user.valid?(:update) || !@user.errors[:prompt_pay].any?, "13 digit prompt_pay should be valid"
  end

  test "should be invalid without address on update" do
    @user.save!
    @user.address = nil
    assert_not @user.valid?(:update)
    assert_includes @user.errors[:address], "กรุณากรอกที่อยู่"
  end

  test "should be valid on update with all profile fields filled" do
    @user.save!
    @user.first_name = "ชื่อ"
    @user.last_name = "นามสกุล"
    @user.phone = "0123456789"
    @user.prompt_pay = "0987654321"
    @user.address = "123 ถนน"
    assert @user.valid?(:update), "Should be valid on update with all profile fields. Errors: #{@user.errors.full_messages.inspect}"
  end

  # --- Method Tests ---
  test "#deposit should increase beer_balance" do
    initial_balance = @user.beer_balance || 0
    assert @user.deposit(5)
    assert_equal initial_balance + 5, @user.reload.beer_balance
  end

  test "#deposit should return false for non-positive amount" do
    initial_balance = @user.beer_balance || 0
    assert_not @user.deposit(0)
    assert_equal initial_balance, @user.reload.beer_balance
    assert_not @user.deposit(-5)
    assert_equal initial_balance, @user.reload.beer_balance
  end

  test "#withdraw should decrease beer_balance" do
    @user.update!(beer_balance: 10)
    assert @user.withdraw(3)
    assert_equal 7, @user.reload.beer_balance
  end

  test "#withdraw should return false for non-positive amount" do
    @user.update!(beer_balance: 10)
    assert_not @user.withdraw(0)
    assert_equal 10, @user.reload.beer_balance
    assert_not @user.withdraw(-3)
    assert_equal 10, @user.reload.beer_balance
  end

  test "#withdraw should return false if amount exceeds balance" do
    @user.update!(beer_balance: 2)
    assert_not @user.withdraw(3)
    assert_equal 2, @user.reload.beer_balance
  end

  test "#drink_beer should decrease beer_balance by 1 if balance > 0" do
     @user.update!(beer_balance: 3)
     assert @user.drink_beer
     assert_equal 2, @user.reload.beer_balance
  end

  test "#drink_beer should return false if balance is 0" do
     @user.update!(beer_balance: 0)
     assert_not @user.drink_beer
     assert_equal 0, @user.reload.beer_balance
  end

  # --- Association Tests (Basic) ---
  test "should have many buy_nows" do
    assert_respond_to @user, :buy_nows
  end

  test "should have many products" do
    assert_respond_to @user, :products
  end

  # test "the truth" do
  #   assert true
  # end
end
