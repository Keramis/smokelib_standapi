# smokelib_standapi
A drawing API that makes directX functions easier in Stand :)

# KEEP IN MIND THIS DOES NOT LIST ALL FUNCS, AS SOME ARE PERSONAL TO THE SCRIPT I'M MAKING. THESE ARE JUST THE ONES NEEDED FOR DRAWING.

# IF YOU'RE GOING TO USE THIS, PLEASE GIVE ME CREDIT! TEMPLATE:
```
Credit to scriptcat#6566 // github.com/Keramis for lib
```

---

# Functions

## GetColorFrom255
- Outputs a table with `r`, `g`, `b`, and `a` values of a range of 1.0 - 0.0.
Input values for `r` `g` and `b` are 0 - 255 (standard), while `a` takes an input of 1.0 - 0.0.
- Makes it easier to use colors gotten from the web in Stand.

## RainbowRGB
- Outputs `red`, `green`, `blue`, and `hue` values used in the function.
- Use `hue` that the function `returned` next time in the function again, to loop through hues and get a rainbow effect.
- Takes `hue`, `saturation`, `vibrance` and `speed` values.
    - `Hue`: 0 - 360
    - `Saturation` and `vibrance`: 0.0 - 1.0
    - `Speed`: Any. Don't go too fast, though!

## HSV_C
- Converts HSV values to RGB.
- Input values:
    - `Hue`: 0 - 360
    - `Saturation`: 0.0 - 1.0
    - `Vibrance`: 0.0 - 1.0

--Also includes DrawRect and DrawText renamed functions :)

## DrawRectWithOutline
-- args: `(x, y, width, height, colormain, colorpadding, amountpadding)`
- Draws a rectangle, with an outline.
- Inputs:
    - X pos (top left of rect)
    - Y pos (top left of rect)
    - Width
    - Height
    - Color of main rectangle
    - Color of outline rectangles
    - Width (amount) of outline

## DrawRectUsingMiddlePoint
-- args: `(pointx, pointy, width, height, color)`
- Draws a rectangle using a middle point as reference.
- Inputs:
    - X pos (center)
    - Y pos (center)
    - Width (from center, not total)
    - Height (from center, not total)
    - Color

## DrawRectWithOutlineUsingMiddlePoint
--args: `(pointx, pointy, width, height, colormain, colorpadding, amountpadding)`
- Draws a rectangle, with an outline, using a middle point as reference.
- Inputs:
    - X pos (center)
    - Y pos (center)
    - Width (from center, not total)
    - Height (from center, not total)
    - Color of main rectangle
    - Color of outline rectangles
    - Width (amount) of outline

## DrawRect_Outline_MidPoint_Text
--args: `(pointx, pointy, amountpaddingfromtext, amountoutline, colormain, coloroutline, colortext, scaletext, stringtext)`
- Draws a rectangle, with an outline, around text. Size of the rectangle will be issued depending on inputs and size of text, so it's dynamically allocated.
- Inputs:
    - X pos
    - Y pos
    - Distance the rectangle ends from the text (more if you want the text to be more *inside* the rectangle)
    - Amount of outline
    - Color of main rectangle
    - Color of outline rectangles
    - Color of text
    - Scale of text
    - String of text (necessary to calculate size)

## DrawRect_Outline_Midpoint_Img
--args: `(pointx, pointy, amountpaddingfromimg, amountoutline, colormain, coloroutline, textureID, pixelX, pixelY, scaleX, scaleY, windowX, windowY, textureColor)`
- Draws a rectangle, with an outline, around an image (texure). Again, it's dynamically allocated.
- Inputs:
    - X pos
    - Y pos
    - Distance the rectangle ends from the text
    - Amount of outline
    - Color of main rectangle
    - Color of outline rectangles
    - TextureID
    - Width of texture, in pixels
    - Height of texture, in pixels.
    - Scale X
    - Scale Y
    - Window X (width of resolution)
    - Window Y (height of resolution)
    > Both of these can be set to `false` to use default settings (1920x1080)
    - Texture Color
        - Set this to `white` to not override the color of the image (if your image has multiple colors)

## GetTextureSize
--args: `(windowX, windowY, textureX, textureY, sizeX, sizeY)`
- Gets the texture size (relative to the screen, between 0.0 - 1.0 on both axis)
- Inputs:
    - Resolution X
    - Resolution Y
    - Texture pixels X
    - Texture pixels Y
    - Scale X
    - Scale Y
- Returns:
    - X size
    - Y size

## GetCursorLocation
--args: `(nothing)`
- Gets the current mouse position on-screen, returning values of 0.0 - 1.0 relative to where it is on the screen, for both axis.
- Returns:
    - Mouse X position
    - Mouse Y position

## CheckForControlJustPressedOnScreen
--args: `(startx, starty, endx, endy, intcontrol, disable)`
- Checks whether a control with value of `intcontrol` has ***just been pressed*** while your mouse cursor is between a box, using the `start` inputs for the borders of the box.
- Useful for clicking on GUI elements
- Can now disable the control you set the checking to, to not mess with gameplay. Enabled by default.
- Inputs:
    - Starting X of the checking box
    - Starting Y of the checking box
    - Ending X of the checking box
    - Ending Y of the checking box
    - The control value
        - These can be found at the [FiveM docs](https://docs.fivem.net/docs/game-references/controls/)
    - Whether or not to disable the control action.

## CheckForControlPressedOnScreen
--args: `(startx, starty, endx, endy, intcontrol, disable)`
- Checks whether a control with value of `intcontrol` has ***been pressed*** while your mouse curosr is between a box, using the `start` inputs for the borders of the box.
- Useful for whether something needs to be held down, or dragging items.
- Check the above function `CheckForControlJustPressedOnScreen` for input values.

## MakeGuiButton_Text
--args: `(x, y, distfromtext, outlinewidth, colormain, coloroutline, colortext, scaletext, stringtext1, stringtext2, buttonpressactivate, buttonpressdrag, funcToTrigger, commandToTrigger, defaultactive)`
- Makes a button that has text inside of it. Text changes depending on whether it's been clicked or not, and it's draggable.
- Inputs:
    - Center X position
    - Center Y position
    - Rectangle distance from text
    - Outline Width
    - Color of main rectangle
    - Color of outline rectangles
    - Color of text
    - Scale of text
    - String text 1
    - String text 2
    > These will be used for if the button is activated or not. (Clicked or not)
    - Button to click it (activate it)
    - Button to drag it
    - Function to trigger
    - Command to trigger
    > Function takes precedence over command. If both are filled out, only func will trigger. Set func to `false` to trigger the command.
    - Default active state
    > This will be used to determine if `stringtext1` or `stringtext2` is drawn for the button.
- Returns:
    - X position of the button (to be used again for the `x` arg)
    - Y position of the button (to be used again for the `y` arg)
    - Default active (`true`/`false`, to be used again for the `defaultactive` arg)

## MakeGuiButton_Img
-- args: `(x, y, distfromimg, outlinewidth, colorbg, coloroutline, colorimg1, colorimg2, pixelX, pixelY, scaleX, scaleY, windowX, windowY, img1, img2, buttonActive, buttonDrag, funcTrigger, commandTrigger, defaultActive)`
- Literally does the exact same thing as `MakeGuiButton_Text`, but uses extra args and images instead of text.
- Please go see `MakeGuiButton_Text`.
- The rest you can accurately guess.

