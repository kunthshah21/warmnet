---
alwaysApply: true
---

Build Target: IOS26
Make sure to use components that adhare to this build target. Dont use legacy components. Make sure to follow apple documentation for the latest insights on components and build approaches. 

Architecture:
Use a MV Architecutre -> Model View Architecture. 
Data Storage -> Swift Data Storage

Folder Management: 
Maintain seperate files and folders for views, models and screens. 
Views: Components - usually reusable components such as buttons, common items, etc. 
Screens: Each main screen should be here in this folder
Models: Logic and models
Features and Logic: This folder is a readme folder. This will only have readme documents. It should highlight specific features, design and data flow approaches that the application uses. Ideally there should be a new readme file for each screen that accesses and uses data. There should be an aggregate file which has all details and high level hirearchies. 

Coding Rules:
Make sure to write clean code which is readable and scallable
Make sure to breakdown views, when they start getting too complicated. Always limit yourself to writing both easy to understand and efficient code. 
Make sure to follow all rules in this document when making either any code updates, changes or adding new features.
When adding a new feature, or making a big update to some flow or architecture, make sure to update the readme file exising in Features and logic folder. If the readme does not exist, create one. Only create a readme, if its a big change, otherwise ignore this rule. 