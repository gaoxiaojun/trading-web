# == Schema Information
# Schema version: 18
#
# Table name: company_types
#
#  id   :integer(11)     not null, primary key
#  name :string(20)      not null
#

class CompanyType < ActiveRecord::Base
  acts_as_enumerated :on_lookup_failure => :enforce_none
  
  def self.parse type, branch, name, activity
    type = parse_type type
    return type if type
    type = parse_branch branch
    return type if type
    type = parse_branch name
    return type if type
    type = parse_branch activity
    return type if type
   
    CompanyType['UNSPECIFIED']
  end
  
  def self.parse_type typeName
     return nil unless typeName
     CompanyType.find(:all).each  do |current_type|
       return current_type if /#{current_type.name[0,4]}/i.match(typeName)
     end
     nil
  end
  
  def self.parse_branch sectorName
    return nil unless sectorName
    case sectorName
      when /(bank)/i ;                  CompanyType[:BANKING]
        
      when /(invest)/i ;                CompanyType[:INVESTMENT]
      when /(financ)/i ;                CompanyType[:INVESTMENT]
      when /(money)/i ;                 CompanyType[:INVESTMENT]
      when /(leasing)/i ;               CompanyType[:INVESTMENT]
      when /(broking)/i ;               CompanyType[:INVESTMENT]
      when /(fund)/i ;                  CompanyType[:INVESTMENT]
      when /(acquisition)/i ;           CompanyType[:INVESTMENT]
      when /(holding)/i ;               CompanyType[:INVESTMENT]
      when /(insurance)/i ;             CompanyType[:INVESTMENT]
      
      when /(construction)/i ;          CompanyType[:CONSTRUCTION]
      when /(build)/i ;                 CompanyType[:CONSTRUCTION]
        
      when /(tour)/i ;                  CompanyType[:TOURISM]
      when /(hotel)/i ;                 CompanyType[:TOURISM]
      when /(restaurant)/i ;            CompanyType[:TOURISM]
      when /(motels)/i ;                CompanyType[:TOURISM]
      when /(travel)/i ;                CompanyType[:TOURISM]
      
      when /(industry)/i;               CompanyType[:INDUSTRY]
      when /(manufacture)/i;            CompanyType[:INDUSTRY]
      when /(production)/i;             CompanyType[:INDUSTRY]
      when /(preserving)/i;             CompanyType[:INDUSTRY]
      when /(farming)/i;                CompanyType[:INDUSTRY]
      when /(agriculture)/i;            CompanyType[:INDUSTRY]
      when /(telecommunications)/i;     CompanyType[:INDUSTRY]
      when /(wholesale)/i;              CompanyType[:INDUSTRY]
      when /(oil)/i;                    CompanyType[:INDUSTRY]
      when /(gas)/i;                    CompanyType[:INDUSTRY]
      when /(preparation)/i;            CompanyType[:INDUSTRY]
      when /(dressing)/i;               CompanyType[:INDUSTRY]
      when /(printing)/i;               CompanyType[:INDUSTRY]
      when /(cotton)/i;                 CompanyType[:INDUSTRY]
        
      when /(estate)/i ;                CompanyType['REAL ESTATE']
      when /(propert)/i ;               CompanyType['REAL ESTATE']
      when /(resident)/i ;              CompanyType['REAL ESTATE']
      when /(rent)/i ;                  CompanyType['REAL ESTATE']
        
      when /(transport)/i ;             CompanyType[:TRANSPORT]
      when /(vehicle)/i ;               CompanyType[:TRANSPORT]
      when /(motor)/i ;                 CompanyType[:TRANSPORT]
                                              
      when /(information)/i;            CompanyType[:TECHNOLOGIES]
      when /(tech)/i;                   CompanyType[:TECHNOLOGIES]
      when /(software)/i;               CompanyType[:TECHNOLOGIES]
      when /(programing)/i;             CompanyType[:TECHNOLOGIES]
      when /(internet)/i;               CompanyType[:TECHNOLOGIES]
      when /(computer)/i;               CompanyType[:TECHNOLOGIES]
      when /(research)/i;               CompanyType[:TECHNOLOGIES]
      when /(science)/i;                CompanyType[:TECHNOLOGIES]
      else;                             nil
    end
  end
end
