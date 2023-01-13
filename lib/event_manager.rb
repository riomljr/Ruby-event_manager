require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'
require 'date'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone_numbers(phone)
  number = phone.gsub(/[^\d]/, "").rjust(10,'0')[0..9]
end

def get_time(day)
 get_hour = DateTime.strptime(day, '%m/%d/%Y %H:%M')
 get_hour.strftime("%l %P")
end

def get_day(date)
  day_of_the_week = DateTime.strptime(date, '%m/%d/%Y %H:%M')
  Date::DAYNAMES[day_of_the_week.wday]
end


puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
hours = []
days =[]

def find_most_of(hours)
  hours.reduce(Hash.new(0)) do |result, hour|
    result[hour] += 1
    result 
  end
end

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  phone = clean_phone_numbers(row[:homephone])

  hours.push(get_time(row[:regdate]))
  days.push(get_day(row[:regdate]))
  
  #form_letter = erb_template.result(binding)

  #save_thank_you_letter(id,form_letter)
end
p find_most_of(hours)
p find_most_of(days)



