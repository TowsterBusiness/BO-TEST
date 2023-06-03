import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.graphics.frames.FlxFilterFrames;
import openfl.filters.GlowFilter;

class TweeningText extends FlxText {
    public var tweenText:FlxTween;
    public var tweenSize:FlxTween;
    public var filterFrames:FlxFilterFrames;
    public var glowFilter:GlowFilter;

    public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true) {
        super(X, Y);
        x = X;
        y = Y;
        fieldWidth = FieldWidth;
        text = Text;
        size = Size;
        textField.embedFonts = EmbeddedFont;
    }

    public function updateFilter() {
        glowFilter = new GlowFilter(0xFF0000, 1, 20, 20, 2, 1);
        this.filterFrames = FlxFilterFrames.fromFrames(this.frames, 10, 10, [glowFilter]);
        this.filterFrames.applyToSprite(this, false, true);
    }
}