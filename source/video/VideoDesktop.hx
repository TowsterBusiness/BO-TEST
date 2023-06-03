package video;

import flixel.FlxG;
import openfl.Lib;
import openfl.events.Event;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;

#if sys
import sys.FileSystem;
#end
#if desktop
import hxcodec.vlc.VLCBitmap;
#end

/**
 * Handles video playback.
 * Use bitmap to connect to a graphic or use `VideoSprite`.
 */
#if desktop
class VideoDesktop extends VLCBitmap
{
    
	public var canSkip:Bool = true;
	public var canUseSound:Bool = true;
	public var canUseAutoResize:Bool = true;
	public var canTravel:Bool = true;

	public var openingCallback:Void->Void = null;
	public var finishCallback:Void->Void = null;
	public var pauseCallback:Void->Void = null;

	private var pauseMusic:Bool = false;

	public function new(IndexModifier:Int = 0):Void
	{
		super();
		
		onOpening = onVLCOpening;
		onEndReached = onVLCEndReached;
		onEncounteredError = onVLCEncounteredError;

		FlxG.addChildBelowMouse(this, IndexModifier);
	}

	private function onVLCOpening():Void 
	{
		trace("the video is opening!");
		width = videoWidth;
		height = videoHeight;
		if (openingCallback != null)
		    openingCallback();
	}

	private function onVLCEncounteredError():Void
	{
		Lib.application.window.alert('Error cannot be specified', "VLC Error!");
		onVLCEndReached();
	}

	private function onVLCEndReached():Void
	{
		kill();

		if (finishCallback != null)
			finishCallback();
	}

	/**
	 * Plays a video.
	 *
	 * @param Path Example: `your/video/here.mp4`
	 * @param Loop Loop the video.
	 * @param PauseMusic Pause music until the video ends.
	 */
	public function playVideo(Path:String, Loop:Bool = false, PauseMusic:Bool = false):Void
	{
		pauseMusic = PauseMusic;

		if (FlxG.sound.music != null && PauseMusic)
			FlxG.sound.music.pause();

		FlxG.stage.addEventListener(Event.ENTER_FRAME, update);

		if (FlxG.autoPause)
		{
			FlxG.signals.focusGained.add(resume);
			FlxG.signals.focusLost.add(pause);
		}

		// in case if you want to use another dir then the application one.
		// android can already do this, it can't use application's storage.
		if (FileSystem.exists(Sys.getCwd() + Path))
			play(Sys.getCwd() + Path, Loop);
		else
			play(Path, Loop);
	}

	private function update(?E:Event):Void
	{

		if (canUseAutoResize && (videoWidth > 0 && videoHeight > 0))
		{
			width = calcSize(0);
			height = calcSize(1);
		}

		volume = #if FLX_SOUND_SYSTEM Std.int(((FlxG.sound.muted || !canUseSound) ? 0 : 1) * (FlxG.sound.volume * 100)) #else FlxG.sound.volume * 100 #end;
	}

	public function checkPause()
	{
		if (isPlaying)
			pause();
		else
			resume();
	}
	
	override function pause()
	{
		super.pause();
				
		if (pauseCallback != null)
			pauseCallback();
	}

	override function resume()
	{
		super.resume();
	
		if (pauseCallback != null)
			pauseCallback();
	}

	public function calcSize(Ind:Int):Int
	{
		var appliedWidth:Float = Lib.current.stage.stageHeight * (FlxG.width / FlxG.height);
		var appliedHeight:Float = Lib.current.stage.stageWidth * (FlxG.height / FlxG.width);

		if (appliedHeight > Lib.current.stage.stageHeight)
			appliedHeight = Lib.current.stage.stageHeight;

		if (appliedWidth > Lib.current.stage.stageWidth)
			appliedWidth = Lib.current.stage.stageWidth;

		switch (Ind)
		{
			case 0:
				return Std.int(appliedWidth);
			case 1:
				return Std.int(appliedHeight);
		}

		return 0;
	}

	public function kill() {
		if (FlxG.sound.music != null && pauseMusic)
			FlxG.sound.music.resume();

		if (FlxG.stage.hasEventListener(Event.ENTER_FRAME))
			FlxG.stage.removeEventListener(Event.ENTER_FRAME, update);

		if (FlxG.autoPause)
		{
			if (FlxG.signals.focusGained.has(resume))
				FlxG.signals.focusGained.remove(resume);

			if (FlxG.signals.focusLost.has(pause))
				FlxG.signals.focusLost.remove(pause);
		}

		dispose();

		FlxG.removeChild(this);
	}
}
#end