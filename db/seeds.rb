# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Plan.create([
  {
    default: true,
    name_en: 'Cornichon',
    cost_gbp: 0,
    url_count: 10,
    test_file_count: 1,
    test_frequency: 86400
  },
  {
    name_en: 'Gherkin',
    cost_gbp: 1000,
    url_count: 500,
    test_file_count: -1,
    test_frequency: 43200
  },
  {
    name_en: 'Cucumber',
    cost_gbp: 50,
    url_count: -1,
    test_file_count: -1,
    test_frequency: 3600
  }
])
