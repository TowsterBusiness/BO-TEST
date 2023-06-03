import flixel.FlxSprite;
import flixel.math.FlxRandom;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import openfl.Assets as AssetsFileSystem;
#if sys
import sys.FileSystem;
#end

using StringTools;

class TeintedCameo extends FlxSprite {
    public var speed:Float;
    public var cameoName:String;
    public static var cameoList:Array<String> = [];
	public static var teintedCameoPath:String = "assets/spweeked/images/street/Cameos/Tinted BGs";
    public static var quickerTeintedCameoPath:String = "street/Cameos/Tinted BGs";

	public function new(initNB:Int)
	{
		super();
    
        cameoName = FlxG.random.getObject(cameoList);
        //trace(cameoName);

        new FlxSprite(1000, 600);
		frames = Paths.getSparrowAtlas(quickerTeintedCameoPath + '/' + cameoName, 'spweeked');
		animation.addByPrefix('walk', 'Walkin0', 24, false);

		cameoList.remove(cameoName);
		speed = -1.2;

        screenCenter();
        x += 200 + (initNB * 300);
        y += 300;
    }

    public function reloadWalkingChar() {
        if (cameoList.length == 0) initialize();

        cameoName = FlxG.random.getObject(cameoList);

        alpha = 0;

		frames = Paths.getSparrowAtlas(quickerTeintedCameoPath + '/' + cameoName, 'spweeked');
		animation.addByPrefix('walk', 'Walkin0', 24, false);

        cameoList.remove(cameoName);
		speed = -1.2;

        screenCenter();
        x += 600;
        y += 300;
        alpha = 1;
    }

    public static function initialize() {
        cameoList = Paths.getDirectory(teintedCameoPath, "Walkin", 'png', 1);

        trace(cameoList);
    }

}