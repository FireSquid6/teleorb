This file was last updated on 10/21/22 and may be out of date by the time you read this.

# Teleorb
Teleorb is a 2D precision platformer currently being developed in Godot 4. FireSquid6 is the primary solo developer, however given the game's open source nature, anyone can help.  

### Controls
**These are subject to change as the project grows. Ideally a menu will be created for created for changing them and controller support is added.**  
WASD - move  
Space - Jump  
Left Click - throw orb  
Shift - hold wall  

# Installation Guide
On the right side of your screen, you should see a "releases" section. Click the latest version under that and download the file corresponding to your OS.

# Contributing
### For programmers
Look for issues taged with "type: programming" if you want to contribute code. 
  
As of 10/21/2022, the verion of Godot we are using is Godot 4 beta 3. This will most likely be updated to whatever the latest version of Godot is whenever a new build comes out.
  
In general, follow the these code conventions:
- name variables with `snake_case`
- name classes and nodes with `PascalCase`
- name constants `UPPER_SNAKE_CASE`
- You don't need to follow the rule of "give every property and method a comment." Instead, use comments to describe "why" a piece code does something, rather than what it does. ~~Alternatively, comments can be used as a means of profane ranting while debugging.~~
- Naming stuff is hard, but please try your best to make things readable

### For sprite artists, sound designers, vfx artists, or anyone else who makes assets
Look for issues taged with "type: art" or "type: sound" and contribute textures, sounds, and UI components to it.    
  
Tip: all non-exported assets are located in the /assets folder. These are primarily done in [Aseprite](https://www.aseprite.org/), a paid software. If you do not have aseprite, you can use something such as [libresprite](https://github.com/LibreSprite/LibreSprite), which is FOSS.  
  
If you are reading this and thinking "I want to help, but I have no idea how any of this github or git stuff works," feel free to send discord friend request @FireSquid#8882. I will not respond to friend requests from people I don't have a mutual server with, so join something such as the [Godot discord server](https://discord.gg/Rue49P7jm3) and contact me through direct message.

### For testers
Encounterd a bug? Have a new mechanic or feature idea? Just don't undertand something and want to ask a question? Feel free to [create a new issue](https://github.com/FireSquid6/teleorb/issues/new/choose) to suggest your idea, submit your bug report, or ask your question.

## Branch Guide
"main" - The primary branch. It contains the latest non-crashing code and may have bugs or be unstable.    
"release" - A branch that gets PR's from main. Contains the latest stable release. Each time a PR is accepeted to it, a new release is created.  
All other branches have a specific task made obvious by their name
