# executive_planner  
A to-do list/calendar app.

## Branch Description

This branch is meant for the development of CI/CD, unit tests, and other automated error-checking functionality.
Will be developed in parallel to the `development` branch, and periodically merged into either `master` or `development`.

### Notable Changes
 - Specific unit tests can be found in the `test` folder. Ideally, there should be a unit test file for each distinct component of the project.
 - The GitHub actions script for running tests and building can be found in `.github > workflows > tests.yaml`.
 - To test locally, run `flutter analysis` for static code analysis and `flutter test` for unit tests.


## Requirements

This project requires the packages:  
json_annotation  
json_serializable  
build_runner  
shared_preferences  
intl
syncfusion_flutter_calendar

To add package:  
`flutter pub add {package}`  
To reload json functions:  
`flutter pub run build_runner`

## Before merging with master  
Add subevent JSON (this may take a while).  
Do not repeat subevents in main event list.  
Make events aware of their sub and super-events, and update their tags accordingly.  
Expand search functionality.

## Immediate future plans  
Introducing event recurrences.  
Making the calendar work.

## Farther future but still maybe soon  
Mass edit of searched events.  
Leveling system (maybe).
