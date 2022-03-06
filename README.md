# executive_planner  
A to-do list/calendar app.

## Description

Differences with master:  
Added search function.  
Added subevents (not fully implemented).  
Restructured file structure.

This project requires the packages:  
json_annotation  
json_serializable  
build_runner  
shared_preferences  
intl

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
Introducing event recurrences, descriptions, tags, location.  
Allow event tiles to show description on tap.  
Update events to current time.

## Farther future but still maybe soon  
Mass edit of searched events.  
Leveling system (maybe).  
App menu.
