Time::DATE_FORMATS[:result_time] = lambda { |time| time.strftime("#{time.day.ordinalize} %B %Y - %I:%M%p") }