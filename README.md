# Executive Planner

A to-do list/calendar app, created for Software Design & Documentation in Spring 2022.

![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/delexagon/executive-planner/Executive_Planner_Tests/testing?label=Testing&style=flat-square) 
![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/delexagon/executive-planner/Executive_Planner_Tests/development?label=Development%20&style=flat-square)
![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/delexagon/executive-planner/Executive_Planner_Tests/master?label=Master&style=flat-square)


---
**Team Members:** Zachary Love, Michael Kokkatt, Sam DeMarrais, Miriam Rundell, Kevin Scott


[Documentation (In Progress)](https://executive-planner.readthedocs.io/en/latest/) 

## Introduction
Have you ever woken up and realized you missed a deadline? Put off a task until tomorrow, then forgot about it until it was too late?

You're not alone- nearly half of all students struggle with staying organized and prepared (Greenfield Online). After all, with so many deadlines, meetings, and personal obligations to keep track of, it's easy to fall behind.

With poor organization, even simple tasks can become challenging and infuriating, putting you at a disadvantage when compared to your peers. 

Our platform aims to even the playing field, by offering a one-stop-shop for organizing your life, flexible tools to learn YOUR way, and systems for keeping you motivated and involved in your work.

Together, we will make working accessible, rewarding, and fun!

---

## Builds

Linux: 
A precompiled executable is available at https://drive.google.com/drive/folders/133vc1G6YLBMPvDmW1OHYQ0aQpELW666M.  
Note that Ubuntu users will manually have to set the XDG_DATA_HOME directory to some folder or other in .bashrc 

### Design Philosophy

The Executive Planner project makes use of Dart, an object oriented programming language that emphasizes abstract programming through its use of modular widgets. Our objective is to make full use of the widget-based functionality provided by Dart to lean into the principles of encapsulation, polymorphism, and abstraction and simplify the process of building our project according to specification.

To accomplish this objective, we have split our project into three main subsets of functionality:
Backend classes manage the storing and retrieval of data, alongside any functionality that operates on the data and is not associated with user input.
Frontend classes contain both Widgets and operations that affect the visual representation of components and/or rely on user input.
Widgets are collections of interlinked frontend components that define either a page or a component within a page, and are passed to controller methods to be combined into a cohesive frontend view.
The Controller is a set of classes that encapsulate both the frontend and backend components. These classes communicate with the backend, pass data to the frontend, and extend Dart functionality like routing and compiling widgets into a view.

Each functional component of the Executive Planner project is represented as a separate class that performs a specific task or several similar tasks. Each component receives data through its constructor, executes a task, and passes relevant data along through the MaterialApp to other components. Components are designed to be largely self-encapsulated and only communicate with other components when absolutely necessary, and when communication is required, data is passed through channels defined in the controller classes to provide maximum control and flexibility.


## Installation of source code

1. Clone this repository to a directory of your choice.
2. Ensure that you have [Flutter v.2.10.0](https://flutter.dev/) or above. You can follow the [official guide](https://docs.flutter.dev/get-started/install) for platform-specific installation steps.
3. Choose a preferred IDE or text editor and [set up flutter for it](https://docs.flutter.dev/get-started/editor)
4. Once Flutter is installed, be sure to update to the most recent Dart version by running `flutter upgrade`.
5. Be sure to install the related dependencies for whatever platform you plan on building for.
6. Run `flutter doctor` to see a report on your installation and a list of missing components (if any)
7. In the directory containing the cloned repository, run `flutter pub install` to install Executive Planner's dependencies.
8. You're done! Edit and run the project from your preferred IDE, and use `flutter analyze` and `flutter test` to test your code before committing.


### Additional Info

## Requirements

This project requires the Flutter packages:    
shared_preferences  
intl
table_calendar

To add these packages:  
`flutter pub get`

## Notable issues  
Subevents do not currently work
They'll take a while to implement, sorry

## Immediate future plans  
Bugfixing
Options menu
Leveling system
