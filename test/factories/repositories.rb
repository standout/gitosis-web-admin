Factory.sequence :repository_name do |n|
  "my_project#{n}"
end

Factory.define :repository do |record|
  record.name { Factory.next(:repository_name) }  
  record.email 'test@namics.com' 
end