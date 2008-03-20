# == Schema Information
# Schema version: 18
#
# Table name: feedbacks
#
#  id           :integer(11)     not null, primary key
#  email        :string(68)      not null
#  category     :string(50)      not null
#  subject      :string(256)     not null
#  description  :text            not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer(11)     default(0), not null
#

class Feedback < ActiveRecord::Base
  CATEGORY_OPTIONS = [[' -- Select a feedback category -- ',''],
    'Feature request', 
    'Report a bug',
    'Report inappropriate conduct',
    'How do I?',
    'Suggestions',
    'Glowing praise or scathing criticism!',
    'Other...'
  ]
  @scaffold_columns = [ 
    AjaxScaffold::ScaffoldColumn.new(self, { :name => 'email', :eval =>  'feedback.obstructed_email'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => 'category' }),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => 'subject'}),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => 'description'})
  ]
  
  attr_accessor :key 
  before_update :editable?
  before_destroy :editable?
  
  validates_format_of :email,
    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
    :message => 'email must be valid'
  
  def obstructed_email
    self.email[0...3] << '...' unless self.email.nil? or self.email.size < 3
  end
  
  def editable_key
    if self.created_at
      self.created_at.to_s.hash
    end
  end
  
  def editable? 
    return true if !self.created_at.nil? and !self.key.nil? and self.created_at.to_s.hash.to_s == self.key.to_s
      
    self.errors.add_to_base 'Not authorized to edit!' 
    false
  end
end
