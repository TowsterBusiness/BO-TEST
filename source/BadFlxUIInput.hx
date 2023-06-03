package;

import haxe.Timer;
import lime.system.Clipboard;
import openfl.events.KeyboardEvent;
import flixel.FlxG;
import flixel.addons.display.shapes.FlxShapeBox;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class BadFlxUIInput extends FlxTypedSpriteGroup<FlxSprite> {

    public var text:FlxText;
    var border:FlxShapeBox;
    var cursor:FlxShapeBox;
    var cursorTimer:Timer;

    var isFocused = false;
    var maxLength:Int = 0; 

    override public function new(X:Float = 0, Y:Float = 0, Width:Float = 0, Height:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true, BackgroundColor:FlxColor = FlxColor.WHITE, BorderColor:FlxColor = FlxColor.BLACK)
    {
        super(X, Y);

        border = new FlxShapeBox(X, Y, Width, Height, {thickness: 3, color: BorderColor}, BackgroundColor);
        add(border);

        

        text = new FlxText(X + 3, Y, 0, Text, Size, EmbeddedFont);
        text.setFormat("assets/fonts/Retroville_NC.ttf", 36, FlxColor.BLACK);
        add(text);

        cursor = new FlxShapeBox(X + 6, Y + Height * 0.1, 1, Height * 0.8, {thickness: 1, color: BorderColor}, BorderColor);
        add(cursor);
        cursorTimer = new Timer(1000);
        cursorTimer.run = () -> {
            trace("Running Loop " + cursor.alpha + "::" + isFocused);
            if (!isFocused) return;
            if (cursor.alpha == 0) {
                cursor.alpha = 1;
            } else {
                cursor.alpha = 0;
            }
        }

        FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    }

    public function setMaxLength(input:Int):Void {
        maxLength = input;
        text.text = text.text.substring(0, input);
    }

    override function kill() {
        FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        cursorTimer.stop();
        super.kill();
    }

    override function update(elapsed:Float) {
        if (FlxG.mouse.justPressed) {
            if (FlxG.mouse.overlaps(border)) {
                isFocused = true; 
                cursor.alpha = 1;
            } else {
                isFocused = false;
                cursor.alpha = 0;
            }
            trace(isFocused);
        } 

        super.update(elapsed);
    }

    //ToDO Focusing and flickering cursor
    /**
	 * Handles keypresses generated on the stage. All coppied and edited from FlxInputText
	 */
	private function onKeyDown(e:KeyboardEvent):Void {
        var key:Int = e.keyCode;
        trace(key);

        if (isFocused)
        {

            // Crtl/Cmd + C to copy text to the clipboard
            // This copies the entire input, because i'm too lazy to do caret selection, and if i did it i whoud probabbly make it a pr in flixel-ui.
            #if macos
            if (key == 67 && e.commandKey) {
            #else
            if (key == 67 && e.ctrlKey) {
            #end
                Clipboard.text = text.text;
                return;
            }

            // Crtl/Cmd + V to paste in the clipboard text to the input
            #if (macos)
            if (key == 86 && e.commandKey) {
            #else
            if (key == 86 && e.ctrlKey) {
            #end
                var newText:String = filter(Clipboard.text);
                if (maxLength != 0) 
                    newText = newText.substring(0, maxLength - text.text.length);
                if (newText.length > 0) {
                    text.text += newText;
                }
                return;
            }

            // Crtl/Cmd + X to cut the text from the input to the clipboard
            // Again, this copies the entire input text because there is no caret selection.
            #if (macos)
            if (key == 88 && e.commandKey) {
            #else
            if (key == 88 && e.ctrlKey) {
            #end
                Clipboard.text = text.text;
                text.text = '';
                return;
            }

            var bannedKeyList = [16, 17, 220, 27, 37, 39, 35, 36];
            // Do nothing for Shift, Ctrl, Esc, and flixel console hotkey
            if (bannedKeyList.contains(key))
            {
                return;
            }
            // Delete
            else if (key == 46 || key == 8)
            {
                if (text.text.length > 0)
                {
                    text.text = text.text.substring(0, text.text.length - 1);
                }
            }
            // Enter
            else if (key == 13)
            {
                isFocused = false;
            }
            // Actually add some text
            else
            {
                if (e.charCode == 0) // non-printable characters crash String.fromCharCode
                {
                    return;
                }
                var newText:String = filter(String.fromCharCode(e.charCode));
                trace(newText);

                if (newText.length > 0 && (maxLength == 0 || (text.text.length + newText.length) <= maxLength))
                {
                    text.text += newText;
                }
            }
            updateCursor();
        }
    }

    private function updateCursor():Void {
        cursor.x = border.x + 6 + text.width;
    }

    private function filter(text:String) {
        var pattern:EReg = ~/[^a-zA-Z0-9 ]*/g;
        return pattern.replace(text, "");
    }
}
