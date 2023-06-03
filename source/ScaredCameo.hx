import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import openfl.Assets as AssetsFileSystem;
#if sys
import sys.FileSystem;
#end

using StringTools;

class ScaredCameo extends FlxSprite {
    public var scared = false;
    public var speed:Float;
    public var cameoName:String;
    public static var cameoList:Array<String> = [];
	public static var scaredCameoPath:String = "assets/spweeked/images/street/Cameos/Scared Cameos";
    public static var quickerScaredCameoPath:String = "street/Cameos/Scared Cameos";

	public function new(initNB:Int)
	{
		super();

        cameoName = FlxG.random.getObject(cameoList);

        speed = -3.5;

        new FlxSprite(1000, 600);
		frames = Paths.getSparrowAtlas(quickerScaredCameoPath + '/' + cameoName, 'spweeked');
		animation.addByPrefix('walk', 'Cameo0', 24, false);
		animation.addByPrefix('scared', 'CameoScared0', 24, false);
		animation.addByPrefix('smoke', 'SmokePuff0', 24, false);
		scrollFactor.set();
		updateHitbox();

        repos();
        trace(height);
        cameoList.remove(cameoName);
    }


    public function reloadWalkingChar() {
        if (cameoList.length == 0) initialize();

        cameoName = FlxG.random.getObject(cameoList);

        alpha = 0;

		frames = Paths.getSparrowAtlas(quickerScaredCameoPath + '/' + cameoName, 'spweeked');
		animation.addByPrefix('walk', 'Cameo0', 24, false);
		animation.addByPrefix('scared', 'CameoScared0', 24, true);
		animation.addByPrefix('smoke', 'SmokePuff0', 24, true);
		scrollFactor.set();
		updateHitbox();

        repos();

        cameoList.remove(cameoName);
        
        alpha = 1;
    }

    public function repos():Void {
        screenCenter();
        x += 600;
        y += 20;
    }

    public function outOfBound():Void {
        screenCenter();
        x += 10000;
        y += 20;
    }

    public function scaredAway():Void {
        scared = true;
        speed = 0;
        animation.play('scared');
        new FlxTimer().start(0.5, function(tmr:FlxTimer)
        {
            animation.play('smoke');
            new FlxTimer().start(0.5, function(tmr:FlxTimer)
            {
                x += 10000;
                speed = -3.5;
                scared = false;
            });
        });
    }

    public static function initialize() {
        cameoList = Paths.getDirectory(scaredCameoPath, "Cameo");
    }

}