# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Brand.create!([
	{ name: 'ha', resource: '/advertisers/0020' }, 
	{ name: 'hr', resource: '/advertisers/0021'  }, 
	{ name: 'vv', resource: '/advertisers/0022'  }, 
	{ name: 'ab', resource: '/advertisers/0023'  }
])

