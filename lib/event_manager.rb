# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(phone_number)
  phone_number = phone_number.to_s.gsub(/[^0-9]/, '')
  if phone_number.length == 10
    phone_number
  elsif phone_number.length == 11 && phone_number[0] == '1'
    phone_number[1..]
  else
    'Bad number'
  end
end

def find_registration_hour(registration_date)
  Time.strptime(registration_date, '%m/%d/%y %H:%M').hour
end

def find_registration_day(registration_date)
  Time.strptime(registration_date, '%m/%d/%y %H:%M').strftime('%A')
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
registration_hours_array = []
registration_days_array = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])
  legislators = legislators_by_zipcode(zipcode)

  registration_hours_array << find_registration_hour(row[:regdate])
  registration_days_array << find_registration_day(row[:regdate])

  form_letter = erb_template.result(binding)
  save_thank_you_letter(id, form_letter)
end

peak_registration_hours = registration_hours_array.tally.max_by { |_k, v| v }
peak_registration_days = registration_days_array.tally.max_by { |_k, v| v }

puts "Peak registration hour is: #{peak_registration_hours[0]}, where #{peak_registration_hours[1]} people registered."
puts "Peak registration day is: #{peak_registration_days[0]}, where #{peak_registration_days[1]} people registered."
