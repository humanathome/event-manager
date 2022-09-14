## The Odin Project: Event Manager
This project is a part of The Odin Project's Ruby curriculum.
Project link: [Event manager](https://www.theodinproject.com/lessons/ruby-event-manager)

### Description
This is a tutorial project that has been adapted from The Turing School’s and Jump Start Lab’s 
[Event Manager](http://tutorials.jumpstartlab.com/projects/eventmanager.html) and updated to use GoogleCivic API.  

`google-api-client` gem used in the tutorial at the point of doing this project is deprecated and has been replaced
with `google-apis-civicinfo_v2` gem. 


Goals of this project are:
- manipulate file input and output
- read content from a CSV (Comma Separated Value) file
- transform it into a standardized format
- utilize the data to contact a remote service
- populate a template with user data
- manipulate strings
- access Google’s Civic Information API through the [google-apis-civicinfo_v2](https://rubygems.org/gems/google-apis-civicinfo_v2) gem
- use ERB (Embedded Ruby) for templating

### Tasks
A number of people have registered for an upcoming event. Your task is to:
1. find the government representatives for each attendee based on their zip code
2. clean phone numbers; make sure all of the phone numbers are valid and well-formed
3. find out what the peak registration hours are
4. find out what the peak registration days are


### Built with
- ruby 3.0.0 (managed by `asdf` in [.tool-versions](.tool-versions))
- `google-apis-civicinfo_v2` gem for accessing Google Civic Information API 

### Run locally

Prerequisites: ruby >= 3.0.0

- clone the repository
```
git clone git@github.com:humanathome/event-manager.git
```

- cd into the cloned repository
```
cd event-manager
```

- install dependencies
```
gem install google-apis-civicinfo_v2 -v 0.13.0
```

- run
```
ruby lib/event_manager.rb
```

