# == Schema Information
# Schema version: 18
#
# Table name: users
#
#  id            :integer(11)     not null, primary key
#  login         :string(80)      
#  cryptpassword :string(40)      
#  validkey      :string(40)      
#  email         :string(100)     
#  newemail      :string(100)     
#  ipaddr        :string(255)     
#  confirmed     :integer(11)     
#  domains       :string(100)     
#  image         :string(100)     
#  firstname     :string(100)     
#  lastname      :string(100)     
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  lock_version  :integer(11)     default(0), not null
#

require 'digest/sha1'

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base
  # Protecting the fields
  attr_accessible :login, :email, :image, :firstname, :lastname

  # Please change the salt to something else, 
  # Every application should use a different one 
  @@salt = 'Hrabrinaxx'
  cattr_accessor :salt
  attr_accessor :ident, :expire_at, :password, :passwordbis

  # Authenticate a user. 
  #
  # Example:
  #   @user = User.authenticate('bob', 'bobpass')
  #
  def self.authenticate(login, pass)
    return nil unless login and pass
    find :first, :conditions =>{:login => login, :cryptpassword => crypt_passwd(login,pass), :confirmed=>1}
  end  
  
  # Set the config environment
  def self.config= app
    @@config ||= app
  end
  
  def self.config
    config?
    @@config
  end
  
  def self.config?
    @@config||=nil
  end

  def name
    return login if firstname.nil? or firstname.empty?
    case @@config[:name_format]
    when 'full'
      name = "#{firstname} #{lastname} <#{email}>" unless firstname.empty? or lastname.empty?
    when 'name'
      name = "#{firstname} #{lastname}" unless firstname.empty? or lastname.empty?
    when 'first'
      name = "#{firstname}" unless firstname.empty?
    when 'last'
      name = "#{lastname}" unless lastname.empty?
    else 
      name = "#{login}"
    end
    name = "#{login}" if name.nil?
    name
  end

  def in_domain?(domain)
    if domains and !domains.empty? 
      return domains.key?(domain.upcase)
    end

    return false
  end

  def is_admin?
    return in_domain?('ADMIN')
  end

  def access_for(domain)
    domains[domain.upcase].to_i unless not in_domain?(domain) || 0
  end

  def access_granted_for?(credentials)
    priv = User.str2domain(credentials.to_s)
    priv.each { |dom, req|
      if req == 0 and in_domain?(dom); return false; end
      if req > 0 and access_for(dom) < req; return false; end
    }
    return true
  end
  alias_method :acl?, :access_granted_for?

 

  # The 2 functions below allow you to save all the authentification part in a cookie. 
  # It prevents you to make a database access to verify if the user is connected.
  #
  # If you need to add something in the cookie, check the lines carefuly
  def self.extract_from_cookies(string)
    # If you add something in the cookie, increment the number
    p = string.split(":",8)
		
    # if you add something in the cookie, add a p[num]
    chaine = "#{p[0]}:#{p[1]}:#{p[2]}:#{p[3]}:#{p[4]}:#{p[5]}:#{p[6]}"
    # If you add something in the cookie, increment the p[num]
    maxtime = p[5].to_i
    crypted = User.sha1(chaine)
    # If you add something in the cookie, increment the p[num]
    if crypted == p[7]
      params = { :login => p[0], :firstname => p[2], :lastname => p[3], :email => p[1] }
      user = User.new(params)
      if maxtime > Time.new.to_i
        user.ident = true
        user.domains = User.str2domain(p[4])
        user.expire_at = p[5].to_i

        # Remove this line if you want to remote any database access
        # You ll need this if you use the @user model to join with other objects
        # return user.reload
      else
        user.ident = false
      end
      return user
    else
      return nil
    end
  end

  # The default time for the session
  def sessionstring(expire_at=1.hours.from_now)
    session_id = AuthHelper::Utils::random_string(32)
    dom = User.domain2str(self.domains)
    # If you add something in the cookie, put it here :)
    chaine = "#{login}:#{email}:#{firstname}:#{lastname}:#{dom}:#{expire_at.to_i}:#{session_id}"
    crypted = User.sha1(chaine)
    "#{chaine}:#{crypted}"
  end

  # Before creating, we generate a validkey.
  # This is used for confirmation
  def generate_validkey(from_string = nil)
    from_string ||= User.sha1(AuthHelper::Utils::random_string(30))
    write_attribute "validkey", from_string
  end
  
  # Check if the validkey is ok.
  def self.email_change_isvalid?(email, validkey)
    User.sha1(email) == validkey
  end

  def reload
    # Just to be sure we have all the fields
    u = User.find(:first, :conditions => {:login => self.login, :confirmed => 1})
    self.validkey = u.validkey
    self.newemail = u.newemail
    self.ident = true
    self.id = u.id
    u.ident = true
    return u
  end

  protected

  # Apply SHA1 encryption to the supplied string.
  def self.sha1(chaine)
    Digest::SHA1.hexdigest("#{salt}--#{chaine}--")
  end
    
  before_create :generate_validkey
  before_save :hash_domains
  before_save :hash_password
  after_save :after_find

  #after_find :dehash_domains

  # Before saving the record to database we will base64encode the domains the
  # users belongs to
  def hash_domains
    # TODO : do we really want that?
    if self.domains.nil? or self.domains.empty? or self.domains.length < 1
      self.domains = {'USERS' => 1}
    end
    write_attribute "domains", User.domain2str(self.domains)
  end

  def self.crypt_passwd(login,pass)
    # default is sha1
    if config.nil? or not config.include? 'crypt_method'
      return UserPasswordCryptSHA.crypt(login,pass)
    else
      UserPasswordCrypt.subclasses.each do |klass|
        if klass.type == config['crypt_method']
          return klass.crypt(login,pass)
        end
      end
    end
  end

  def check_password
    unless User.valid_password?(password)
      errors.add('password','must be at least 6 characters long.')
    end
  end
 
  def validate_on_create(*methods, &block)
    check_password
  end

  def self.valid_password?(str)
    not str.nil? and str.length >= 6
  end

  def hash_password
    if User.valid_password?(password)
      write_attribute "cryptpassword", User.crypt_passwd(login,password)
    elsif not password.nil?
      errors.add('password','must be at least 6 characters long!: #{password}')
    elsif cryptpassword.nil?
      errors.add('password','must be present')
    else
      # we have an encrypted password already
    end
  end

  # After we load the user
  def after_find
    #require 'base64'
    #self.domains = Marshal.load(Base64.decode64(self.domains))
    self.domains = User.str2domain(self.domains)
  end
  
  #before_update :crypt_unless_empty
  
  # If the record is updated we will check if the password is empty.
  # If its empty we assume that the user didn't want to change his
  # password and just reset it to the old value.
  def crypt_unless_empty
    if password and password.empty?      
      user = User.find(self.id)
      self.password = user.password
    else
      #write_attribute "password", User.sha1(password)
    end        
  end  

  # Convert the domains hash to a string
  def self.domain2str(dom)
    dom = User.str2domain(dom) unless dom.is_a? Hash
    {'USERS' => 1}.merge(dom).collect { |name, level| "#{name},#{level}" }.join(' ')
  end

  # Convert domains string to a hash
  def self.str2domain(str)
    result = {}
    return result if str.nil? or str.empty?
    str.split(' ').each { |b|
      name, value = b.split(',',2)
      result[name]= value.nil? ? 1 : value.to_i
    }
    result
  end
  
  validates_uniqueness_of :login, :on => :create
  validates_uniqueness_of :login, :on => :update
  validates_uniqueness_of :email, :on => :create
  validates_uniqueness_of :email, :on => :update

  #validates_confirmation_of :password
  validates_format_of :login, :with => /^[A-Za-z][A-Za-z0-9\-\_]{2,39}$/
  validates_length_of :password, :minimum => 6, :allow_nil => true
  validates_length_of :email, :maximum=> 100
  validates_length_of :ipaddr, :maximum => 15
  validates_length_of :validkey, :maximum => 40, :allow_nil => true
  
  validates_length_of :firstname, :maximum => 40, :allow_nil => true
  validates_length_of :lastname, :maximum => 40, :allow_nil => true
  validates_format_of :lastname,:with => /^[A-Za-z0-9\-\s]*$/
  validates_format_of :firstname, :with => /^[A-Za-z0-9\-\s]*$/
	
  validates_presence_of :login, :email, :ipaddr

  validates_numericality_of :confirmed, :on => :create
  validates_numericality_of :confirmed, :on => :update

  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/
  validates_format_of :newemail, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/, :allow_nil => true
  
end


### Theses class are used for the password crypting. You can change them, add some, etc.
### To change the crypt method, add a class and herit from UserPasswordCrypt.
### See examples.

class UserPasswordCrypt
  def self.inherited(child) #:nodoc:
    @@subclasses ||= []
    @@subclasses << child
    super   
  end

  def self.subclasses
    @@subclasses
  end
end

require 'digest/sha1'
class UserPasswordCryptSHAMoreSalted < UserPasswordCrypt

  def self.crypt(login,pass)
    Digest::SHA1.hexdigest("#{login}#{pass}")
  end

  def self.type
    "SHA1moresalt"
  end
end

class UserPasswordCryptSHA < UserPasswordCrypt
  def self.crypt(login,pass)
    Digest::SHA1.hexdigest(pass)
  end

  def self.type
    "SHA1"
  end
end

class UserPasswordCryptMD5 < UserPasswordCrypt
  def self.crypt(login,pass)
    Digest::MD5.hexdigest(pass)
  end

  def self.type
    "MD5"
  end
end
