package;

import Controls.Control;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;
import TweeningSprite.TweeningSprite;
import flixel.FlxSubState;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;
import flixel.effects.FlxFlicker;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<FlxSprite>;
	var grpCharacterShit:FlxTypedGroup<TweeningSprite>;
	var randomExcluded:Array<Int> = [];

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Toggle Botplay', 'Exit to menu'];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Toggle Botplay', 'Exit to menu'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);
	var highBlackBar:FlxSprite = new FlxSprite();
	var lowBlackBar:FlxSprite = new FlxSprite();
	//var botplayText:FlxText;

	public static var songName:String = 'None';

	public function new(x:Float, y:Float)
	{
		super();
		//if(CoolUtil.difficulties.length < 2) menuItemsOG.remove('Change Difficulty'); //No need to change difficulty if there is only one!

		/*if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Leave Charting Mode');
			
			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'Skip Time');
			}
			menuItemsOG.insert(3 + num, 'End Song');
			menuItemsOG.insert(4 + num, 'Toggle Practice Mode');
		}
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficulties.length) {
			var diff:String = '' + CoolUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');*/


		pauseMusic = new FlxSound();
		if(songName != null) {
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		} else if (songName != 'None') {
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		highBlackBar.makeGraphic(FlxG.width, 100, FlxColor.BLACK);
		highBlackBar.setPosition(0,-100);
		add(highBlackBar);

		lowBlackBar.makeGraphic(FlxG.width, 100,FlxColor.BLACK);
		lowBlackBar.setPosition(0,FlxG.height);
		add(lowBlackBar);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('vcr.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		grpCharacterShit = new FlxTypedGroup<TweeningSprite>();
		add(grpCharacterShit);

		grpMenuShit = new FlxTypedGroup<FlxSprite>();
		add(grpMenuShit);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		FlxTween.tween(highBlackBar, {y: highBlackBar.y + 100}, 0.2, {ease: FlxEase.quadInOut});
		FlxTween.tween(lowBlackBar, {y: lowBlackBar.y - 100}, 0.2, {ease: FlxEase.quadInOut});
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		regenCharacters();
		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case 'Skip Time':
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if(holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}

					if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if(curTime < 0) curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		if (accepted && (cantUnpause <= 0 || !ClientPrefs.controllerMode))
		{
			if (menuItems == difficultyChoices)
			{
				if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {
					var name:String = PlayState.SONG.song;
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.chartingMode = false;
					return;
				}

				menuItems = menuItemsOG;
				regenMenu();
			}
			var nb = 0;

			grpMenuShit.forEach(function(spr:FlxSprite) {
				if (nb == curSelected) {
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxFlicker.flicker(spr, 0.7, 0.1, true, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.1, function (tmr:FlxTimer) {
							optionEffects(daSelected);
						});
					});
				}
				nb ++;
			});
		}
	}

	function deleteSkipTimeText()
	{
		if(skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);

		if (curSelected < 0) curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length) curSelected = 0;

		var nb = 0;

		grpMenuShit.forEach(function(spr:FlxSprite)
		{
			if (nb == curSelected) {
				spr.animation.play('selected');
			} else {
				spr.animation.play('idle');
			}
			nb ++;
		});

		var bullShit:Int = 0;
	}

	function regenMenu():Void {
		for (i in 0...menuItems.length) {
			var optionAnim:FlxSprite = new FlxSprite();
			optionAnim.frames = Paths.getSparrowAtlas('pauseMenu/' + menuItems[i]);
			optionAnim.animation.addByPrefix('idle', 'idle0', 24, false);
			optionAnim.animation.addByPrefix('selected', 'selected0', 24, false);
			optionAnim.animation.play('idle');
			optionAnim.scrollFactor.set();
			optionAnim.updateHitbox();
			optionAnim.screenCenter();
			optionAnim.y += -190;
			optionAnim.y += 125 * i;
			optionAnim.alpha = 0;
			if (i % 2 == 0) {
				optionAnim.x += -180;
				FlxTween.tween(optionAnim, {x: optionAnim.x + 180,alpha: 1}, 0.2, {ease: FlxEase.quadInOut});
			}
			if (i % 2 == 1) {
				optionAnim.x += 180;
				FlxTween.tween(optionAnim, {x: optionAnim.x - 180, alpha: 1}, 0.2, {ease: FlxEase.quadInOut});
			}
			add(optionAnim);
			grpMenuShit.add(optionAnim);
		}

		curSelected = 0;
		changeSelection();
	}

	function regenCharacters():Void {
		var availibleDirections:Array<String> = ['00','01','10','20','21','30'];
		var arrayNames:Array<String> = [];
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'ghost-picnic' | 'boo' | 'stumble-station' | 'satellite-picnic' | 'tricky-or-treat' | 'boo-sticky' | "it-s-okay":
				arrayNames.push('BooSmol');
			case 'tricks' | 'deadly-colors':
				arrayNames = ['BiggsSmol', 'BuggsSmol'];
			case 'treats':
				arrayNames.push('DaisySmol');
			case 'heart-of-gold' | 'skeleton-passion':
				arrayNames = ['BooSmol', 'TulipSmol'];
			case 'meteorite-waltz':
				arrayNames = ['BooSmol', 'TulipSmol', 'DaisySmol', 'LunaSmol'];
			case "earth-s-sister":
				arrayNames = ['BooSmol', 'TulipSmol', 'DaisySmol'];
			case 'caramel':
				arrayNames.push('LunaSmol');
		}

		FlxG.random.shuffle(availibleDirections);
		trace(availibleDirections);
		for (i in 0...arrayNames.length) {
			var smol:TweeningSprite;
			smol = new TweeningSprite(0,0);
			smol.loadGraphic(Paths.image('titlestate/' + arrayNames[i]));
			smol.antialiasing = ClientPrefs.globalAntialiasing;
			smol.tweenFromString(availibleDirections[0]);
			availibleDirections.remove(availibleDirections[0]);
			add(smol);
			grpCharacterShit.add(smol);
		}
		trace(availibleDirections);
	}
	
	function updateSkipTextStuff()
	{
		if(skipTimeText == null || skipTimeTracker == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}

	function optionEffects(daSelected:String):Void {
		switch (daSelected)
			{
				case "Resume":
					grpCharacterShit.forEach(function(spr:TweeningSprite) {
						spr.tweenBack();
					});

					FlxTween.tween(highBlackBar, {y: highBlackBar.y - 100}, 0.2, {ease: FlxEase.quadInOut});
					FlxTween.tween(lowBlackBar, {y: lowBlackBar.y + 100}, 0.2, {ease: FlxEase.quadInOut});

					var nb = 0;
					grpMenuShit.forEach(function(spr:FlxSprite)
					{
						if (nb % 2 == 0) {
							FlxTween.tween(spr, {x: spr.x - 180,alpha: 0}, 0.2, {ease: FlxEase.quadInOut});
						} else if (nb % 2 == 1) {
							FlxTween.tween(spr, {x: spr.x + 180, alpha: 0}, 0.2, {ease: FlxEase.quadInOut});
						}
						nb ++;
					});

					new FlxTimer().start(0.2, function(tmr:FlxTimer) 
					{
						close();
					});
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					deleteSkipTimeText();
					regenMenu();
				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case "Restart Song":
					restartSong();
				case "Leave Charting Mode":
					restartSong();
					PlayState.chartingMode = false;
				case 'Skip Time':
					if(curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}
				case "End Song":
					close();
					PlayState.instance.finishSong(true);
				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;
				case "Exit to menu":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					WeekData.loadTheFirstEnabledMod();
					if(PlayState.isStoryMode) {
						MusicBeatState.switchAnimatedState(new StoryMenuState());
					} else {
						switch(PlayState.fromMenu)
						{
							case 0:
								MusicBeatState.switchAnimatedState(new FreeplayState());
							case 1:
								MusicBeatState.switchAnimatedState(new PasswordState());
						}
					}
					PlayState.cancelMusicFadeTween();
					FlxG.sound.playMusic(Paths.music('HungryMenuMusic'));
					FlxG.sound.music.time = 9150;
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
			}
	}
}
