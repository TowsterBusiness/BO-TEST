package;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIInputText;
import flixel.FlxState;

class TestState extends FlxState {
    var passwordText:FlxUIInputText;
    var inputTest:BadFlxUIInput;
    var testText:FlxText;

    override function create() {
        FlxG.mouse.visible = true; 

        //"assets/fonts/Retroville_NC.ttf" - does not work
        //"assets/fonts/Retroville_NC.otf" - does not work
        //"VCR OSD Mono" - does not work
        //Paths.font("vcr.ttf") - does not work
        // passwordText = new FlxUIInputText(0, 300, 550, 'Hello World', 36, FlxColor.BLACK, FlxColor.WHITE);
		// passwordText.setFormat("assets/fonts/Retroville_NC.ttf");
		// passwordText.maxLength = 18;
		// passwordText.screenCenter(X);
		// passwordText.y += 75;
		// add(passwordText);

        inputTest = new BadFlxUIInput(0, 0, 500, 60, "Hello World", 36);
        inputTest.screenCenter(XY);
        add(inputTest);

        testText = new FlxText(10, 0, 0, "Hello World");
        testText.setFormat("assets/fonts/Retroville_NC.otf", 36, FlxColor.WHITE);
        add(testText);
        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}   