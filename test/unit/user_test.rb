require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_initialize_activation_code_upon_creation
    user = create_user
    user.reload
    assert_not_nil user.activation_code
  end

  def test_should_create_and_start_in_pending_state
    user = create_user
    user.reload
    assert user.pending?
  end


  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    users(:user_1).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:user_1), User.authenticate('sheetal_kamthe@persistent.co.in', 'new password')
  end

  def test_should_not_rehash_password
    users(:user_1).update_attributes(:email => 'sheetal_kamthe1@persistent.co.in')
    assert_equal users(:user_1), User.authenticate('sheetal_kamthe1@persistent.co.in', 'monkey')
  end

  def test_should_authenticate_user
    assert_equal users(:user_1), User.authenticate('sheetal_kamthe@persistent.co.in', 'monkey')
  end

  def test_should_set_remember_token
    users(:user_1).remember_me
    assert_not_nil users(:user_1).remember_token
    assert_not_nil users(:user_1).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:user_1).remember_me
    assert_not_nil users(:user_1).remember_token
    users(:user_1).forget_me
    assert_nil users(:user_1).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:user_1).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:user_1).remember_token
    assert_not_nil users(:user_1).remember_token_expires_at
    assert users(:user_1).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:user_1).remember_me_until time
    assert_not_nil users(:user_1).remember_token
    assert_not_nil users(:user_1).remember_token_expires_at
    assert_equal users(:user_1).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    users(:user_1).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:user_1).remember_token
    assert_not_nil users(:user_1).remember_token_expires_at
    assert users(:user_1).remember_token_expires_at.between?(before, after)
  end

  def test_should_register_passive_user
    user = create_user(:password => nil, :password_confirmation => nil)
    assert user.passive?
    user.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    user.register!
    assert user.pending?
  end

  def test_should_suspend_user
    users(:user_1).suspend!
    assert users(:user_1).suspended?
  end

  def test_suspended_user_should_not_authenticate
    users(:user_1).suspend!
    assert_not_equal users(:user_1), User.authenticate('sheetal_kamthe@persistent.co.in', 'test')
  end

  def test_should_unsuspend_user_to_active_state
    users(:user_1).suspend!
    assert users(:user_1).suspended?
    users(:user_1).unsuspend!
    assert users(:user_1).active?
  end

  def test_should_unsuspend_user_with_nil_activation_code_and_activated_at_to_passive_state
    users(:user_1).suspend!
    User.update_all :activation_code => nil, :activated_at => nil
    assert users(:user_1).suspended?
    users(:user_1).reload.unsuspend!
    assert users(:user_1).passive?
  end

  def test_should_unsuspend_user_with_activation_code_and_nil_activated_at_to_pending_state
    users(:user_1).suspend!
    User.update_all :activation_code => 'foo-bar', :activated_at => nil
    assert users(:user_1).suspended?
    users(:user_1).reload.unsuspend!
    assert users(:user_1).pending?
  end

  def test_should_delete_user
    assert_nil users(:user_1).deleted_at
    users(:user_1).delete!
    assert_not_nil users(:user_1).deleted_at
    assert users(:user_1).deleted?
  end

protected
  def create_user(options = {})
    record = User.new({  :email => 'quire@example.com', :password => 'quire69',:password_confirmation => 'quire69',:email_confirmation => 'quire@example.com', :first_name => "qyure", :last_name => "guire" }.merge(options))
    record.register! if record.valid?
    record
  end
end
