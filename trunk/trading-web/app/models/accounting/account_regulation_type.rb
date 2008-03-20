class AccountRegulationType < ActiveRecord::Base
  acts_as_enumerated :on_lookup_failure => :enforce_none
end
