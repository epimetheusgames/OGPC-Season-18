# Godot Rules

## Testing With GodotSteam

Below are step-by-step instructions on running the project with the GodotSteam
multiplayer setup. If the project is closing on startup with no error message,
make sure you've followed these steps.

### Testing with only one client (SinglePlayer).

1. Make sure steam is open.
2. Go to https://godotsteam.com, and scroll down to the "What Are You Making?" section.
3. Under "Singleplayer or Steam Networking" select "Pre-compiled Editor and Templates"
4. Download the zip for your respective OS, and unzip it into an easily accessible folder.
5. If you have Godot running, close it.
6. Run the "godotsteam.43.editor.[os-specific-extension]" executable.
7. Open the project and edit as normal.

### Testing with two clients (MultiPlayer)

This is much more complicated and should only be used if you *really* want to test 
multiplayer and can't just ask a friend to test it with you.

1. Follow the prior section for your first setup.
2. Head to https://www.virtualbox.org/ and download and setup VirtualBox (yes, this is the only way).
3. Go to https://www.microsoft.com/en-us/software-download/windows11 and scroll down to "Download 
   Windows 11 Disk Image (ISO) for x64 devices".
4. Download the iso.
5. Go to VirtualBox and at the top bar select Machine->New.
6. Name it whatever you like.
7. Select the windows ISO image we downloaded earlier. 
8. Under "Hard Disk" set the hard disk size to 64 gigabytes (This ammount won't actually be used in 
   your disk).
9. Boot up the new VM.
10. If you get an error about the disk not mounted, select the ISO from before and try again.
11. Continue with Windows installation (Select "I don't have a product key"). This will take a while.
12. Once Windows has started, at the top bar of the VirtualBox window select Devices->Insert Guest 
	Additions CD Image.
13. Open file explorer and navigate to CD Drive (D:) VirtualBox Guest Additions (Below This PC menu 
	and above Network and CD Drive (E:)).
14. Double click the VBoxWindowsAdditions executable, and proceed with installation, and select 
	Reboot now at the end.
15. Now, in the top bar of the VirtualBox window select Devices->Shared Folders->Shared Folders Settings.
16. Click on "Machine Folders" and then click on the folder icon with a green plus.
17. Select a folder path (DO NOT USE C:\ USE A FOLDER LIKE DOWNLOADS OR YOUR USER DIRECTORY). Mine is 
	C:\Users\cbates
18. Select Auto-mount and Make Permanent, and then select OK.
19. Select OK in the settings menu.
20. Reboot the virtual machine.
21. In the file system, navigate to the Network folder and enable network sharing. Ensure that there 
	is a computer named VBOXSVR in that folder.
22. Download and install Steam. Sign into a different account than on your non-vm computer.
23. Now we will install MESA drivers so that Godot can work. The reason we do this is because VirtualBox
	only supports OpenGL 2 and Godot needs Opengl 3.3. In the VM navigate to 
	https://github.com/pal1000/mesa-dist-win/releases. 
24. Download mesa3d-24.2.4-release-mingw.7z, and unzip it.
25. Double click systemwidedeploy, more info, and Run anyway.
26. For the Enter choice dialog type 1.
27: Press 9 and enter to exit once you get the Enter choice dialog again.
28: On the non-vm computer switch the project renderer to Compatability and restart Godot. 
	Unfortuantely, this means that boids will not work for now as OpenGL doesn't support compute
	shaders. I will update these instructions once I figure out how to use Vulkan on VirtualBox.
28: Download GodotSteam.
30: Open PowerShell and CD to the folder you install GodotSteam in.
29: Run this command: ".\godotsteam.43.editor.windows.64.exe --rendering-driver opengl3"
30: If all went well, Godot should open. 
31: First, go to the windows file dialog and go to Network->VBOXSVR->\\VBOXSVR\[shared-folder-name]
	navigate to your project and copy the file path at the top.
32: Select Import delete all the text in the file path. The file dialog should proceed to break.
33: Try to push cancel (move your mouse below the button).
34: In the new dialog with an error, replace the text with the filepath we copied earlier. Then push
	Import & Edit.
35: Once the editor loads, go to Debug->Customize Run Instances, and change the launch argument 
	'host' to 'client', and select OK. If the window was broken, full screen it and it should be 
	usable.
36: Now that you have everything set up you can test multiplayer. When writing code try to write it
	in the VM because it will update on your main computer immediately but that doesn't seem to be 
	the case vis versa.
37: Happy editing!

## Naming

### General
- Use descriptive names
- Numbers go at the end

### Scenes, Scripts, Nodes, Folders, Files, and Classes
- PascalCase
- The reason these are all PascalCase is because these are all object-like structures which if you
  go down the tree far enough contian more fundamental things like functions/variables, neither of 
  which can "permanently" store any information.

### Variables
- snake_case variables
- Use underscores at the beginning of variables to make them private (variables are not *actually* private)
- CONSTANT_CASE constants
- PascalCase for enum names and CONSTANT_CASE for their members, as they are constants
- Booleans start with “is”, “has”, "does", "are"

### Functions:
- snake_case function name 
- Verb-noun naming (ie play_sound)

## Code

### Indentation / Empty Space
- Each indent level should be one greater than the block containing it
- Use 2 indent levels to distinguish continuation lines from regular code blocks (Exceptions to this rule are arrays, dictionaries, and enums)
- Use a trailing comma on the last line in arrays, dictionaries, and enums (except with single-line lists)
- Surround functions with one blank line and class definitions with two blank lines

### Boolean Operators
- Prefer the plain English versions of boolean operators, as they are the most accessible:
- Use and instead of &&
- Use or instead of ||
- Use not instead of !

### Commenting
- Comments (#) should start with a space, but not code that you comment out.
- Double hashtag (##) for file descriptors.
- Use TODO it makes it orange.
- Use correct grammar.
- Don't end your comment with a period, unless it has multiple sentences
- If your comment is more than one sentence, maybe your code is too complicated

### Numbers
- Don't remove the leading or trailing zero in floating-point numbers. Otherwise, this makes them less readable and harder to distinguish from integers at a glance
- Take advantage of GDScript's underscores in literals to make large numbers more readable (1_000_000)
- Don't hardcode large numbers

### Ordering
```
01. ## [Script description (optional but recomended)]
02. @tool
03. class_name
04. extends
05. # docstring

06. signals
07. enums
08. constants
09. @export variables
10. public variables
11. private variables
12. @onready variables

13. optional built-in virtual _init method
14. optional built-in virtual _enter_tree() method
15. optional built-in virtual _ready method
16. optional built-in _process method
17. optional built-in _physics_process method
17. public methods
18. private methods
19. subclasses (not reccomended, they should be their own script)
```

### Classes
- If the code is meant to run in the editor, place the @tool annotation on the first line of the script

### Static Typing
- Static type all variables, unless it is impossible (for example a built-in function that returns a Variant, meaning that you cannot static type the variable that you are assigning the result of the function to.)
```
var health := 0 # The type can be int or float, and thus should be stated explicitly.
var health: float = 0 # The editor knows this is a float because of the explicit statement.
var another_number := 0.0 # This is a float for the interpreter.
var direction := Vector3(1, 2, 3) # The type is clearly inferred as Vector3.
```
- Also use "as CertainType" to static type

---

## General Coding Practices

- If you inherit from a script class always make sure to call its custom _ready/_process function from your _ready/_process function. 
  Yeah I know, I wish the overriden functions would get called too ...
- Never set properties of a node from a different node, especially player / core objects. (player.velocity = 100 from another script is never allowed.)
- Each scene should be able to run by itself without causing a runtime exception.
- Use setters/getters instead of setting/getting a property directly.
- Instead of referencing a node with get_node(), use @export_node_path or @export var name: TypeInheritsNode which will change if the node's 
  name or path is changed.

---

- Do not commit broken code
- Do not try and fix merge conflicts if you are unsure of how (everythings gonna die) (ask someone for help)
- Never use commands like "rebase", "reset", "revert", "branch -d", without making sure, these can blow away progress easily
- In general never delete anything unless it is necessary (git wise)

## Collision BitMasks (for non-coliding hitboxes e.g. Area2D)

1  (0000001): General Collision
2  (0000010): Player Hurtbox / Enemy Attackbox
4  (0000100): Light
8  (0001000): Movement
16 (0010000): Wall Layer 2
32 (0100000): Player Attackbox / Enemy Hurtbox
64 (1000000): Interaction

Sound should be based on a pathfind to the sound.
