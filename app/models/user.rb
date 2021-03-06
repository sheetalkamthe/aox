require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::StatefulRoles

  #  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  #  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
  validate :email_confirms
  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :email, :password, :password_confirmation, :email_confirmation, :country, :province,
    :city, :title, :company, :state, :company_url, :activation_code, :remember_token,
    :remember_token_expires_at, :deleted_at, :first_name, :last_name
  attr_accessor :email_confirmation

  def email_confirms
    errors.add('Email and Email confirmation') unless email == email_confirmation if new_record?
  end
  
  def name
    first_name + ' ' + last_name
  end
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    user = find_in_state :first, :active, :conditions => {:email => email.downcase} # need to get the salt
    user && user.authenticated?(password) ? user : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  protected
    
  # *Description*
  # * Creates Activation code with the combination of registration details and timestamp
  # *Parameters*
  # * None
  # *Returns*
  # * None
  # *Errors*
  # * None
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end
  
end
