require 'test_helper'

class UserTest < ActiveSupport::TestCase
    
    def setup
        @user = User.new(username: "ExampleUser", phone: 13810457408, password: "testtest", password_confirmation: "testtest")
    end
    
    test "should be valid" do
        assert @user.valid?
    end
    
    test "username should be present" do
        @user.username = ""
        assert_not @user.valid?
    end
    
    # test "email should be present" do
    #     @user.email = ""
    #     assert_not @user.valid?
    # end

    test "username should not be too long" do
        @user.username = "a" * 51
        assert_not @user.valid?
    end
    
    # test "email should not be too long" do
    #     @user.email = "a" * 244 + "@biulove.com"
    #     assert_not @user.valid?
    # end
    #
    # test "email validation should accept valid addresses" do
    #     valid_addresses = %W[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    #     valid_addresses.each do |valid_address|
    #         @user.email = valid_address
    #         assert @user.valid?, "#{valid_address.inspect} should be valid"
    #     end
    # end
    #
    # test "email validation should reject invalid addresses" do
    #     invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    #     invalid_addresses.each do |invalid_address|
    #       @user.email = invalid_address
    #       assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    #     end
    # end
    #
    # test "email addresses should be unique" do
    #     duplicate_user = @user.dup
    #     duplicate_user.email = @user.email.upcase
    #     @user.save
    #     assert_not duplicate_user.valid?
    # end
    #
    # test "email address should be saved as lower-case" do
    #     mixed_case_email = "Foo@ExamPLe.Com"
    #     @user.email = mixed_case_email
    #     @user.save
    #     assert_equal mixed_case_email.downcase, @user.reload.email
    # end
    
    test "password should have a minimum length" do
        @user.password = @user.password_confirmation = "a" * 7
        assert_not @user.valid?
    end
    
    test "phone should be present" do
        @user.phone = "  "
        assert_not @user.valid?
    end
    
    test "phone should have fix length" do
        @user.phone = "1234567890"
        assert_not @user.valid?
        @user.phone = "123456789011"
        assert_not @user.valid?
        @user.phone = "12345678901"
        assert @user.valid?
    end
    
    test "phone should be only numbers" do
        @user.phone = "asdfads1234"
        assert_not @user.valid?
    end
    
    test "phone should be unique" do
        duplicate_user = @user.dup
        duplicate_user.phone = @user.phone
        @user.save
        assert_not duplicate_user.valid?
    end
    
end
