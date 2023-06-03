package;

import openfl.utils.Future;
import openfl.media.Sound;
import flixel.system.FlxSound;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import Achievements;
import flixel.FlxCamera;
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

using StringTools;

class SpookEndingState extends MusicBeatState
{
	private var camAchievement:FlxCamera;
	public static var comesFromEndWeek:Bool = false;

	override function create()
	{
		var bg:FlxSprite = new FlxSprite();
		var weekName:String = WeekData.getWeekFileName().toLowerCase();
		FlxG.sound.playMusic(Paths.music('pausetheme'));

		switch(weekName)
		{
			case 'spweeked':
				bg = new FlxSprite().loadGraphic(Paths.image('specialThanks', 'spweeked'));
			case 'holidays':
				bg = new FlxSprite().loadGraphic(Paths.image('specialThanks', 'winterweek'));
			case 'golden-days':
				bg = new FlxSprite().loadGraphic(Paths.image('specialThanks', 'goldendays'));
		}
		add(bg);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (controls.BACK || controls.ACCEPT)
		{
			comesFromEndWeek = true;
			MusicBeatState.switchAnimatedState(new StoryMenuState());
		}
	}
}