module AuthHelper
  # Taken from the webrick server
  module Utils
    if !const_defined? "RAND_CHARS"
      RAND_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
        "0123456789" +
        "abcdefghijklmnopqrstuvwxyz"
    end
    def random_string(len)
      rand_max = RAND_CHARS.size
      ret = ""
      len.times{ ret << RAND_CHARS[rand(rand_max)] }
      ret
    end
    module_function :random_string

  end

  def popup_account_infos
    txt = ""
    unless user_logged_in?
      txt = render(:partial => "/auth/remotelogin")
      txt = escape_javascript(txt)
      txt = javascript_tag("var modal_login = initModalWin('account_login_link',\"#{txt}\",'post_login');")
    end
    "<div id=\"accountinfo\">"+ render(:partial => "/auth/remoteinfo") + "</div>" + txt
  end
  
  # Show user informations using Ajax. Can be used on static pages / cached pages.
  def ajax_account_infos()
    txt = render(:partial => "/auth/remotelogin")
    "" + javascript_tag('function showloginform() {
        $("accountinfo").innerHTML = ' + txt + ";"+
        ' document.getElementById(\'post_login\').focus();}') + "<!-- account info --> <div id=\"accountinfo\">"+
      link_to('account', auth_url) + "</div>" + 
      javascript_tag("new Ajax.Updater('accountinfo', '/auth/remoteinfo', {asynchronous:true});")
  end

  # Show user information, don't use for static or cached page!
  def account_infos()
    txt = render(:partial => "/auth/remotelogin")
    "" + javascript_tag('function showloginform() {
        $("accountinfo").innerHTML = ' + txt + ";"+
        ' document.getElementById(\'post_login\').focus();}') + "<!-- account info --> <div id=\"accountinfo\">"+
      render(:partial => "/auth/remoteinfo") + "</div>"
  end

  # Javascript version to show user information. Can be used on static pages / cached pages.
  def js_account_infos()
    txt = render(:partial => "/auth/remotelogin")
    "" + javascript_tag('function showloginform() {'+ update_element_function("accountinfo", :content => txt) +
        ' document.getElementById(\'post_login\').focus();}') + "<!-- account info --> <div id=\"accountinfo\">" +
      "<script src=\"/account/jsinfo\" type=\"text/javascript\"></script>"+
      '<script type="text/javascript">displayAccountInfo();</script>' + "</div>"
  end

  # store current uri in the ccokies
  # we can return to this location by calling return_location
  def store_location
    cookies[:return_to] = {:value => request.request_uri, :expires => nil }
  end

  # Loading spinner indicator icon tag
  def spinner_tag(id = 'ident')
    image_tag('/images/spinner.gif', :id=>"#{id}_spinner", :align => 'absmiddle', :border=> 0, :style=> 'display: none;', :alt => 'loading...' )
  end

  def user_logged_in?
    not @user.nil? and @user.ident
  end

  def confirmation_url
    "#{@app[:url]}members/confirm?from=#{@user.email.gsub(/\@/,'%40')}&key=#{@user.validkey}"
  end
end
