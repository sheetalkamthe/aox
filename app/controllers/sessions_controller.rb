# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.rhtml
  def new
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:email], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/home')
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      @login       = params[:email]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

  # *Description*
  # * Resets the password for the user
  # *MethodRequestType*
  # * POST
  # *Parameters*
  # * user[:email] -  email of the user
  # *Returns*
  # * None
  # *Errors*
  # * None
  def forgot_password
    if request.post?
      @user = User.find(:first, :conditions => ["email = ?", params[:user][:email] ])
      if @user
        flash[:notice] = "Your password changed successfully. Check your email."
        new_password = '123456'
        @user.update_attributes(:password => new_password, :password_confirmation => new_password)
        UserMailer.deliver_forgot_password(@user, new_password)
        redirect_to login_url
      else
        flash[:notice] = "Please enter valid email."
      end
    end
  end

  # *Description*
  # * Changes and saves the user's password
  # *MethodRequestType*
  # * POST
  # *Parameters*
  # * old_password - old password of the user
  # * password - new password of the user
  # * password_confirmation - password confirmation for the new password
  # *Returns*
  # * None
  # *Errors*
  # * None
  def change_password
    if request.post?
      login, password = params[:login], params[:password]
      confirmation = params[:password_confirmation]
      if login.blank?
        user = User.authenticate(current_user.login, params[:old_password])
      else
        user = User.authenticate(login, params[:old_password])
      end
      if user && check_password_and_confirmation(password, confirmation)
        user.update_attributes(:password => password, :password_confirmation => confirmation)
        flash[:notice] = "Password changed successfully" 
        redirect_to '/'
      else
        flash[:notice] = "Wrong password or Password doesn't match with confirmation"
        redirect_to change_password_session_path({:login => login}) unless login.blank?
      end
    end
  end

  protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  private
  def check_password_and_confirmation(password, password_confirmation)
    !password_confirmation.blank? && !password.blank? && password_confirmation == password
  end
end
