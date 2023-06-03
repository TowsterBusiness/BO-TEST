package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;

class CustomAnimatedTransition extends MusicBeatSubstate {
    public static var finishCallback:Void->Void;
    public static var nextCamera:FlxCamera;
    var transitionScreen:FlxSprite = new FlxSprite();

    public function new(switchedState:Bool) {
        super();

        if (!switchedState) {
            transitionScreen.frames = Paths.getSparrowAtlas("spiralTransition/TransitionSpiral");
            transitionScreen.animation.addByPrefix('loading', 'SpiralGif0', 36, false);
            transitionScreen.scale.set(2.16,2.16);
        } else {
            transitionScreen.frames = Paths.getSparrowAtlas("spiralTransition/OpenTransition");
            transitionScreen.animation.addByPrefix('loading', 'Symbol0', 36, false);
            transitionScreen.scale.set(1.59,1.59);
        }
		transitionScreen.screenCenter();
		add(transitionScreen);
		transitionScreen.animation.play('loading');
        transitionScreen.animation.finishCallback = name ->
		{
			if (switchedState)
				close();
			else if (finishCallback != null)
				finishCallback();
				
		};

        if(nextCamera != null) {
			transitionScreen.cameras = [nextCamera];
		}
		nextCamera = null;
    }

    override function destroy() {
        if (transitionScreen != null) {
           finishCallback();
        }
		super.destroy();
	}
}