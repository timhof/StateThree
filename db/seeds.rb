# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
role_admin = Role.create(name: 'admin')
role_user = Role.create(name: 'user')
user = User.create(email: 'shared@stateli.com', password: 'shared', password_confirmation: 'shared', role_ids: [role_user.id])
pocket = Pocket.create({name: 'Unclassified', user_id: user.id})

