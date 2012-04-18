CARD_TYPES = [
  ['Visa', 'visa'],
  ['MasterCard', 'master'],
  ['Discover', 'discover']
]

MONTHS = Date::MONTHNAMES.collect.with_index{|x, i| [x,i] }.slice(1,12)

NEXT_TEN_YEARS = (0..10).to_a.collect{|x| Date.today.year + x }
