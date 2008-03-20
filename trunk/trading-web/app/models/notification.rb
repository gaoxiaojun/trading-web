class Notification < ActionMailer::Base
  def forgot(user, app, sent_on = Time.now)
    common_header user, app
    subject       'Password Reminder'
    body          'user' => user, 'app' => app 
    sent_on       sent_on
  end

  def signup(user, app, sent_on = Time.now)
    common_header user, app
    subject       'You have requested a new account'
    body          'user' => user, 'app' => app 
    sent_on       sent_on
  end
  
  def emailchange (user, app, sent_on = Time.now)
    common_header user, app
    subject       'Email change'
    body          'user' => user, 'app' => app
    sent_on       sent_on
  end

  def admin_newuser (user, password, app, sent_on = Time.now)
    common_header user, app
    subject       'New account'
    body          'user' => user, 'password' => password, 'app' => app
    sent_on       sent_on
  end
  
  private
  def  common_header user, app
    recipients    recipient_emails(user)
    from          from_email(app)
#    headers       current_headers(app)
  end
  
  def recipient_emails user
    "#{user.login} <#{user.email}>"
  end
  
  def from_email app
      "#{app[:title]} Community <#{app[:email]}>"
  end
  
  def current_headers app
    {"Reply-to" => from_email(app)}
  end
  
  
end
