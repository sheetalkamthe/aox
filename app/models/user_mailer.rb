class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://YOURSITE/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://YOURSITE/"
  end


  def forgot_password(user, password)
    setup_email(user)
    @password = password
  end

  
  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "ADMIN"
    @subject     = "www.aox.com"
    @sent_on     = Time.now
    @body[:user] = user
  end
end
