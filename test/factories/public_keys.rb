Factory.sequence :public_key_source do |n|
  "ssh-rsa AAAAB3NzaC1xc2EAAAABIwAAAQEArkpuwTFR1KlSvO2gntMP6QjvTbQS1y5ENm1/XCttr6cVuQLt0ydUcwht0KqTgxJtcMyXOF4ZLcGRj4SC1UUdn/DJqgWfcNakMa8xq9vetX5dpD44Y3/OS51+vedGtBzlA3i4dX4B1EC/XSbPbmeC5hHz2NiUPAJgnAoLzrQdeC7/e7xXs3/a9P0VXzd+Z7ElOezy2uk4YKpHzX988f6t5Npi5ze+PUUNV4KIY6gfNmUMnZ/LwIASbfYwWCXV81lRdVjFs9zn8VWYb1zxAHQsuwxlLc755zUFFvLViBcZozPy1Y6eX827WGx1MaGHlHb79LICy6lkGRyKxdfKUp9vHQ#{n}"
end

Factory.define :public_key do |record|
  record.description 'Testkey of Christian'
  record.email 'test@namics.com'
  record.source { Factory.next(:public_key_source) }   
end