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
  reg_time = registration_date.split(' ')[1]
  Time.strptime(reg_time, '%H:%M').strftime('%-I %p')
end

def find_registration_day(registration_date)
  reg_date = registration_date.split(' ')[0]
  Date.strptime(reg_date, '%m/%d/%y').strftime('%A')
end

def find_max_values(registration_times)
  registration_times.find_all { |_k, v| v == registration_times.values.max }
end

def display_peak_reg_times(hours, days)
  peak_hours = hours.map(&:first).join(', ')
  people_per_hour = hours.map(&:last).uniq.join(', ')
  puts "The peak hour(s) for registration are #{peak_hours} where #{people_per_hour} people registered per hour."

  peak_days = days.map(&:first).join(', ')
  people_per_day = days.map(&:last).uniq.join(', ')
  puts "The peak day(s) for registration are #{peak_days} where #{people_per_day} people registered per day."
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

hours_hash = registration_hours_array.tally
days_hash = registration_days_array.tally

peak_hours = find_max_values(hours_hash)
peak_days = find_max_values(days_hash)

display_peak_reg_times(peak_hours, peak_days)

puts 'Event manager complete.'
