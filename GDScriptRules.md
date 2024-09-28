# GODOT RULES

## NAMING:

### General:
- Use descriptive names
- Preferably, numbers go at the end

### Scenes:
- PascalCase

### Scripts:
- PascalCase

### Nodes:
- PascalCase

### Variables:
- snake_case variables
- Use underscores at the beginning of variables to make them private
- CONSTANT_CASE constants
- PascalCase for enum names and CONSTANT_CASE for their members, as they are constants
- Booleans start with “is”, “has”, "does", "are"

### Functions:
- snake_case function name 
- Verb-noun naming (ie play_sound)

### Folders:

### Files:
- PascalCase

### Classes:
- PascalCase

## CODE:

### Indentation / Empty Space:
- Each indent level should be one greater than the block containing it
- Use 2 indent levels to distinguish continuation lines from regular code blocks (Exceptions to this rule are arrays, dictionaries, and enums)
- Use a trailing comma on the last line in arrays, dictionaries, and enums (except with single-line lists)
- Surround functions with one blank line and class definitions with two blank lines

### Boolean Operators:
- Prefer the plain English versions of boolean operators, as they are the most accessible:
- Use and instead of &&
- Use or instead of ||
- Use not instead of !

### Commenting:
- Comments (#) should start with a space, but not code that you comment out.
- Use correct grammar.
- Don't end your comment with a period, unless it has multiple sentences
- If your comment is more than one sentence, maybe your code is too complicated.

### Numbers:
- Don't remove the leading or trailing zero in floating-point numbers. Otherwise, this makes them less readable and harder to distinguish from integers at a glance
- Take advantage of GDScript's underscores in literals to make large numbers more readable (1_000_000)

### Ordering:
```
01. # [Script description (optional)]
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
16. remaining built-in virtual methods
18. private methods
17. public methods
19. subclasses
```

### Classes:
- If the code is meant to run in the editor, place the @tool annotation on the first line of the script

### Static Typing:
- Static type all variables, unless it is impossible (for example a built-in function that returns a Variant, meaning that you cannot static type the variable that you are assigning the result of the function to.)
```
var health: int = 0 # The type can be int or float, and thus should be stated explicitly.
var another_number := 0.0 # This is a float for the interpreter.
var direction := Vector3(1, 2, 3) # The type is clearly inferred as Vector3.
```
- Also use "as CertainType" to static type

---

## GENERAL CODING PRACICES

- Never set properties of a node from a different node, especially player / core objects.  (player.velocity = 100 from another script is never allowed.)
- Each scene should be able to run by itself without causing a runtime exception.
- Use setters/getters instead of setting/getting a property directly.
- Instead of reference a node with get_node(), use @export_node_path which will change if the node's
  name or path is changed.

---

- Do not commit broken code
- Do not try and fix merge changes if you are unsure of how 
- Never use commands like "rebase", "reset", "revert", "branch -d", without making sure, these can blow away progress easily
- In general never delete anything unless it is necessary (git wise)

## Collision BitMasks (for non-coliding hitboxes e.g. Area2D)

1: General collision
2: Hurtbox/attackbox
3: Light area hitbox
4: Noise area hitbox
5: Movement hitboxes
