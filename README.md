# Reflection By Example Demos

This project contains the demos and examples used in the "Reflection by Example" presentation for WWDC 2021

The goal of the presentation was to show what is possible, not necessarily what is best for a full and complex business application.

The Demos:
* rec - A simple record introspection.
* sql2arr - A simple example of executing an SQL select and loading the result into an array.
* main - Using library code to display a record and an array dynamically.
* interactive - Using library code show data from DB in list and allow record view update.
* type - Introspection of a 'type' that has methods.
* sort - Using a library that sorts an array using a varity of sorting methods.

The Libraries:
* custom_sort - Custom sorting methods.
* dynUI - Library that users the record structure from rObj to build and show a UI.
* prettyName - Make a variable name pretty for a form label / table column title
* rObj - reflect object to an array and to stdout.
* sql2array - SQL to an array.
* simpleDump - dump a record structure to a file. Recursive to handle nested records / arrays / types ( including types from another module )

NOTE: Some of these examples are of dynamic generic library code that can be helpful to quickly make simple maintenance programs for simple tables. More complex code could be used with call back functions to handle business rules and validation but generally using normal 4gl dialogs will provide less complex and therefore easier to maintain programs.


