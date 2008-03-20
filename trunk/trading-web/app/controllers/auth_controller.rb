class AuthController < ApplicationController
  before_filter :update_params_filter

  def index
    del_location
    @title = "User Interface"
    unless user_logged_in?
      redirect_to :action => "login"
    end
  end

  # Gets the account information through a javascript call
  def jsinfo
    render :layout=>false
    headers["Content-Type"] = "text/plain" 
  end

  def remoteinfo
    if request.xhr?
      render :layout=>false
    end
  end

  def resendnewemail
    require_auth
    @user.reload

    Notification.deliver_emailchange(@user, @app)
    flash['notice'] = "We have resent you an email."
    redirect_to :action => "info"

  end

  def info
    require_auth

    @title = "Your preferences"
    @newuser = nil

    @user.reload

    if request.post?
      @newuser = User.find(:first, :conditions => {:login => @user.login, :confirmed => 1})
      @newuser.lastname = params[:post][:lastname]
      @newuser.firstname= params[:post][:firstname]
      notice = ""
      if not params[:post][:password].empty? and not params[:post][:passwordbis].empty?
        if params[:post][:password] == params[:post][:passwordbis]
          @newuser.password = params[:post][:password]
        else
          notice += "Your password don't match!"
        end
      end
			
      if params[:post][:picture] and not params[:post][:picture] == "" and
          not params[:post][:picture].original_filename.empty?
        if not params[:post][:picture].content_type.chomp =~ /^image/
          notice += "Your picture isn't an image !" 
          return false
        else
          require 'GD'
          require 'tempfile'

          tempfile = Tempfile.new('tmp')
          tempfile.write params[:post][:picture].read
          tempfile.flush
          File::open(tempfile.path, mode="r") { |f|
            img = nil
            case params[:post][:picture].content_type.chomp
            when "image/jpeg" then
              img = GD::Image.newFromJpeg(f)
            when "image/png" then
              img = GD::Image.newFromPng(f)
            when "image/pjpeg" then
              img = GD::Image.newFromJpeg(f)
            when "image/x-png" then
              img = GD::Image.newFromPng(f)
            end

            if not img.nil?
              if img.bounds[0] == @app[:icon_size] and img.bounds[1] == @app[:icon_size]
                @newuser.image = img.pngStr  # = params[:post][:picture].read
              else
                #								notice += "Your image isn't #{@app[:icon_size]}x#{@app[:icon_size]}!"
                aspect_ratio = img.width.to_f / img.height.to_f
                if aspect_ratio > 1.0
                  nHeight = @app[:icon_size]
                  nWidth  = @app[:icon_size] * aspect_ratio
                else
                  nWidth  = @app[:icon_size]
                  nHeight = @app[:icon_size] / aspect_ratio
                end                
                thumb = GD::Image.newTrueColor(@app[:icon_size], @app[:icon_size])
                img.copyResized(thumb, 0,0,0,0,nWidth, nHeight, img.width, img.height)
                @newuser.image = thumb.pngStr # = params[:post][:picture].read
                thumb.destroy
              end
              img.destroy
            end
          }
        end
        expire_page :action => 'image', :id => "#{@newuser.login}.png"
      end
			
      sentemail = false
      unless params[:post][:newemail].empty? or params[:post][:newemail] == @user.email
        puts  params[:post][:newemail]
        tmpuser = User.find(:first, :conditions => {:email => params[:post][:newemail]})
        if tmpuser.nil?
          @newuser.newemail = params[:post][:newemail]
          sentemail = true
          @newuser.generate_validkey(@newuser.newemail)

          Notification.deliver_emailchange(@newuser, @app)
        else
          notice = "An account already uses this email address."
        end
      end

      if not notice.empty?
        flash.now['notice'] = notice
      else
        if not @newuser.nil? and @newuser.save
          flash.now['notice'] = "Your preferences have been saved.\n"

          if sentemail == true
            flash.now['notice'] = "We sent you a message, please check your email."
          end

          self.saveSession(@newuser, @user.expire_at)
          @user = @newuser
          @user.reload
        else
          flash.now['notice'] = "An error occured while saving your preferences"
        end
      end
    end
  end

  def remotelogin
    if request.method == :post
      unless params[:post].nil? or params[:post][:login].nil?
        user = User.authenticate(params[:post][:login], params[:post][:password])
        if user
          @err = 0
          self.saveSession(user, params[:post][:keepalive].to_i)
          render :layout => false
        else
          @err = 2 
          render :layout => false
        end
      else
        render :layout => false
      end
    end
  end

  def login
    if request.method == :post
      user = User.authenticate(params[:members][:login], params[:members][:password])
      if user
        self.saveSession(user, params[:members][:keepalive].to_i)
        flash[:notice] = "Login successful."
        redirect_back_or_default :controller => 'home', :action => 'index'
      else
        flash.now[:errors] = "Oops, unknown username or password.<br/> " \
          "Have you signed up yet?<br/>If you've forgotten your password, we can email it to you."
        @login = params[:members][:login]
        @keepalive = params[:members][:keepalive]
      end
    end
  end

  def resendsignup
    if cookies[:email] and not cookies[:email].nil?
      @email = cookies[:email]
    elsif request.post? and not params[:post].nil? and not params[:post][:email].empty?
      @email = params[:post][:email]
    else
      @email = nil
    end

    if not @email.nil?
      user = User.find(:first, :conditions => ["email = ? and validkey != 'NULL' and confirmed=0",@email])
      if user.nil?
        flash.now['errors'] = "There is no account pending with this email!<br/> "
        flash['errors'] << "Either your account has been confirmed or you need to make a new one"
      else
        Notification.deliver_signup(user,@app)
        cookies[:email] = { :value => user.email, :expires => nil }
        flash['notice'] = "We have sent a message to #{user.email}. "
        flash['notice'] << "<br/>Please paste the validation key it includes."
        redirect_to :action => "confirm"
      end
    end
  end
  
  def signup
    if not @app[:allow_self_registration]
      flash[:notice] = "Account creation is disabled."
      redirect_to :action => "login"
    end

    if request.post?
      @newuser = User.new(params[:post])
      @newuser.confirmed= 0
      @newuser.ipaddr = request.remote_ip
      @newuser.domains = { 'USERS' => 1 }
      @newuser.password=params[:post][:password]

      if @newuser.save
        if @newuser.id == 1
          @newuser.domains = { 'USERS' => 1, 'ADMIN'=> 1 }
          @newuser.save
        end
        Notification.deliver_signup(@newuser, @app)
        cookies[:email] = { :value => @newuser.email, :expires => nil }
        flash['notice'] = "We have sent a message to #{@newuser.email}. "
        flash['notice'] << "Please paste the validation key it includes."
        redirect_to :action => "confirm"
      else
        flash.now['notice']  = "An error occured while creating this account."
      end
    else
      if user_logged_in?
        flash.now['notice']  = "You already have an account and are authentified. Are you sure you want to create a new account ?"
      end
    end      
  end  
  
  def logout
    self.cancelSession()
    flash[:notice] = 'Thank You for visititing our website! You are logged out now. |  <a href="/feedbacks/new">Leave a feedback? &#187;</a> |'
    redirect_to :controller => 'home', :action => 'index'
  end

  def confirm
    @email = ""
    if request.get? and params[:from] and params[:key]
      @email = params[:from]
      validkey = params[:key]
    elsif request.post? and params[:user][:validkey]
      @email = params[:user][:email]
      validkey = params[:user][:validkey]
    end

    unless validkey.nil? or @email.empty?
      user = User.find(:first, :conditions => {:email => @email})

      if not user.nil? and user.validkey == validkey
        # User is confirming his account
        if not user.confirmed?
          user.confirmed= 1
          user.validkey = nil

          if user.save
            cookies[:email] = nil
            self.saveSession user
            flash['notice'] = "Your account is confirmed. Please take some time to setup your preferences."
            redirect_to :action => "info"
          else
            flash['errors'] = "An error occured while saving your account"
          end
          # The user is asking for an email address change
        elsif user.confirmed? and not user.newemail.nil?
          if user.class.email_change_isvalid?(user.newemail, validkey)
            user.email = user.newemail
            user.newemail = nil
            user.validkey = nil
            if user.save
              self.saveSession(user, @user.expire_at)
              flash['notice'] = "Your email has been changed."
              redirect_to :action => "info"
            else
              flash['errors'] = "An error occured while saving your account."
            end
          else
            flash.now['errors'] = "This validation key is incorrect."
          end
        end
      else
        flash.now['errors']  = "This validation key is incorrect.<br/> Maybe you already confirmed your account?"
      end
    end

    if cookies[:email] and not cookies[:email].nil?
      @email = cookies[:email]
    elsif not params[:user].nil? and params[:user][:email]
      @email = params[:user][:email]
    end
  end

  def lostpassword
    if user_logged_in?
      @user.generate_validkey
      @user.save

      Notification.deliver_forgot(@user, @app)
      flash['notice']  = "We sent you a message, please check your email."
      redirect_back_or_default :action => "index"
    end

    if request.post? and params[:post][:email]
      @newuser = User.find(:first, :conditions => {:email => params[:post][:email]})
      if not @newuser.nil?
        @newuser.generate_validkey
        if @newuser.save
          Notification.deliver_forgot(@newuser, @app)
          flash[:notice]  = "We sent you a message, please check your email."
          redirect_to :action => "login" 
        else    
          flash[:notice]  = "An error occured while saving informations."
          logger.info "An error occured while saving user informations."
        end     
      else    
        flash[:notice] = "Couldn't find an account with this email address."
      end     
    else    
      if @user
        @email = @user.email
      else    
        @email = ""
      end     
    end


  end

  def reset
    if params[:post]
      @login = params[:post][:login]
      @validkey = params[:post][:validkey]
    else
      @login = params[:login]
      @validkey = params[:validkey]
    end
    
    # If validation key is wrong, we leave right now
    user = User.find(:first, :conditions => {:login => @login})
    if user and user.validkey != @validkey
      flash['notice']  = "Your validation key is incorrect, please request your password again."
      redirect_back_or_default :action => "lostpassword"
      return
    end
		
    if request.post?
      if params[:post][:password] != params[:post][:passwordconf]
        flash.now['errors'] = "The passwords you entered do not match!"
      else
        # Dont need this verification, but who knows... :]
        if user.validkey == @validkey
          user.password = params[:post][:password]
          user.confirmed = 1 # Just in case...
          if user.errors.count == 0 and user.save
            user.validkey = nil
            user.save
            cookies[:email] = nil
            self.saveSession user
            flash['notice'] = "Your password has been changed."
            redirect_back_or_default :controller => 'home', :action => 'index'
          else
            # There is a problem, we give the view access to this informations
            flash.now['errors'] = "There were an error while saving your new password."
            @newuser = user
          end
        end
      end
    end
  end
    
  def denied
    render :layout => false
  end

  protected

  def saveSession(user, keepalive=nil)
    if not keepalive.nil? and keepalive > 0
      if keepalive == 1
        cookies[:user] = { 
          :value => user.sessionstring(60.days.from_now),
          :expires => 60.days.from_now 
        }
      else
        cookies[:user] = { 
          :value => user.sessionstring(60.days.from_now),
          :expires => Time.at(keepalive)
        }
      end
    else
      cookies[:user] = { 
        :value => user.sessionstring,
        :expires => nil
      }
    end
  end

  def cancelSession
    cookies[:user] = nil
    @user = User.new
  end

  def this_auth
    @app
  end
  helper_method :this_auth
 
  
  private 
  def update_params_filter
    @stylesheets = %w[ajax_scaff]
  end
  
end
