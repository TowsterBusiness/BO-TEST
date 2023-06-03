package;

import haxe.display.Display.Package;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.graphics.frames.FlxAtlasFrames;

class SpookyPublic extends FlxSprite
{
	public var colorTween:FlxTween;

	public function new(x:Float, y:Float, type:String, state:String)
	{
		super(x, y);

		switch (type) {
			case "mid":
				frames = Paths.getSparrowAtlas("holidayStage/MidGround_Crowd", 'winterweek');

				animation.addByPrefix('clap', 'Cameos_Claps0', 24, true);
				animation.addByIndices('danceLeft', 'Cameos_Sway0', [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18], "", 24, false);
				animation.addByIndices('danceRight', 'Cameos_Sway0', [19,20,21,22,23,24,25,26,27,28,29], "", 24, false);

				animation.play('danceLeft');
				antialiasing = ClientPrefs.globalAntialiasing;
			
			case "fore":
				frames = Paths.getSparrowAtlas("holidayStage/Foreground", 'winterweek');

				//if (state == "empty") {
				//	animation.addByIndices('danceLeft', 'Foreground_Empty', [0,1,2], "", 30, false);
				//	animation.addByIndices('danceRight', 'Foreground_Empty', [0,1,2], "", 30, false);
				//} else {
					animation.addByIndices('danceLeft', 'Foreground_KnightandGhost0', [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18], "", 24, false);
					animation.addByIndices('danceRight', 'Foreground_KnightandGhost0', [19,20,21,22,23,24,25,26,27,28,29], "", 24, false);
				//};
				
				animation.play('danceLeft');
				antialiasing = ClientPrefs.globalAntialiasing;
		}
	}

	var danceDir:Bool = false;

	public function dance():Void
	{
		if (animation.curAnim.name == "clap") return;
		
		danceDir = !danceDir;

		if (danceDir) {
            animation.play('danceRight', true);
        }
		else {
			animation.play('danceLeft', true);
        }
	}
}