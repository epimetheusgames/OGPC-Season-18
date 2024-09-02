# GODOT RULES

---

## NAMING:

### General:
- Use descriptive names
- Preferably, numbers go at the end

### Scenes:
- snake_case

### Scripts:
- PascalCase

### Nodes:
- PascalCase

### Variables:
- snake_case variables
- Use underscores at the beginning of variables to make them private
- CONSTANT_CASE constants
- PascalCase for enum names and CONSTANT_CASE for their members, as they are constants
- Booleans start with “is” or “has”

### Functions:
- snake_case function name 
- Verb-noun naming (ie play_sound)

### Folders:

### Files:
- PascalCase (linux had some issues with capital file names?)

### Classes:
- PascalCase (it's an object)

---

## CODE:

### Indentation / Empty Space:
- Each indent level should be one greater than the block containing it
- Use 2 indent levels to distinguish continuation lines from regular code blocks (Exceptions to this rule are arrays, dictionaries, and enums)
- Use a trailing comma on the last line in arrays, dictionaries, and enums (Trailing commas are unnecessary in single-line lists, so don't add them in this case)
- Surround functions and class definitions with two blank lines

### Boolean Operators:
- Prefer the plain English versions of boolean operators, as they are the most accessible:
- Use and instead of &&
- Use or instead of ||
- Use not instead of !

### Commenting:
- Comments (#) should start with a space, but not code that you comment out

### Numbers:
- Don't remove the leading or trailing zero in floating-point numbers. Otherwise, this makes them less readable and harder to distinguish from integers at a glance
- Take advantage of GDScript's underscores in literals to make large numbers more readable

### Ordering:
```
01. @tool
02. class_name
03. extends
04. # docstring

05. signals
06. enums
07. constants
08. @export variables
09. public variables
10. private variables
11. @onready variables

12. optional built-in virtual _init method
13. optional built-in virtual _enter_tree() method
14. built-in virtual _ready method
15. remaining built-in virtual methods
16. public methods
17. private methods
18. subclasses
```

### Classes:
- If the code is meant to run in the editor, place the @tool annotation on the first line of the script

### Static Typing:
- Static type all variables.
```
var health: int = 0 # The type can be int or float, and thus should be stated explicitly.
var direction := Vector3(1, 2, 3) # The type is clearly inferred as Vector3.
```
- Also use "as CertainType" to static type

---

## GENERAL CODING PRACICES

- Never set properties of a node from a different node, especially player / core objects.  (player.velocity = 100 from another script is never allowed.)
- Each node/scene should be able to run by itself without causing a runtime exception.
- Use setters/getters instead of setting/getting a property directly
