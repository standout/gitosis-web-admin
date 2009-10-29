Factory.define :permission do |record|  
  record.association :public_key
  record.association :repository
end