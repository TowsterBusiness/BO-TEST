package;

import flixel.tweens.FlxEase;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import LoadingState.LoadingsState;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import WeekData;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 0;

	var bg:FlxSprite;

	var txtWeekTitle:FlxTypedGroup<FlxText>;
	var txtStoryName:FlxTypedGroup<FlxText>;
	var scoreWeek:FlxTypedGroup<FlxText>;
	var bgSprite:FlxTypedGroup<FlxSprite>;
	var tweening:Bool = false;

	private static var curWeek:Int = 0;

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var loadedWeeks:Array<WeekData> = [];

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		if (SpookEndingState.comesFromEndWeek) {
			FlxG.sound.playMusic(Paths.music('HungryMenuMusic'));
			FlxG.sound.music.time = 9150;
			SpookEndingState.comesFromEndWeek = false;
		}

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite();
		bg.frames = Paths.getSparrowAtlas('storymode/DarkBG');
		bg.animation.addByPrefix('idle', 'BGMove0', 24, true);
		bg.animation.play('idle');
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		txtWeekTitle = new FlxTypedGroup<FlxText>();
		txtStoryName = new FlxTypedGroup<FlxText>();
		scoreWeek = new FlxTypedGroup<FlxText>();
		bgSprite = new FlxTypedGroup<FlxSprite>();

		for (i in 0...WeekData.weeksList.length)
		{
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			loadedWeeks.push(leWeek);

			var txtWeek:FlxText;
			txtWeek = new FlxText(0 + (FlxG.width * (i - curWeek)), FlxG.height * 0.8, FlxG.width, WeekData.weeksList[i], 64);
			txtWeek.setFormat("VCR OSD Mono", 64, FlxColor.WHITE, CENTER);

			var txtStory:FlxText = new FlxText(0 + (FlxG.width * (i - curWeek)), FlxG.height * 0.9, FlxG.width, leWeek.storyName, 40);
			txtStory.setFormat("VCR OSD Mono", 40, FlxColor.WHITE, CENTER);

			#if !switch
			var intendedScore:Int = Highscore.getWeekScore(loadedWeeks[i].fileName, 0);
			trace(intendedScore);
			#end

			//lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 1));
			//if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

			var scoreText:FlxText = new FlxText(10 + (FlxG.width * (i - curWeek)), 10, 0, "WEEK SCORE:" + intendedScore, 32);
			scoreText.setFormat("VCR OSD Mono", 32);

			var assetName:String = leWeek.weekBackground;
			var weekSprite:FlxSprite = new FlxSprite(); 
			if(assetName == null || assetName.length < 1) {
				bgSprite.visible = false;
			} else {
				weekSprite.loadGraphic(Paths.image('storymode/weekBackgrounds/' + assetName));
				weekSprite.screenCenter();
				weekSprite.x += FlxG.width * (i - curWeek);
				weekSprite.y += FlxG.height * -0.07;
			}

			txtWeekTitle.add(txtWeek);
			txtStoryName.add(txtStory);
			scoreWeek.add(scoreText);
			bgSprite.add(weekSprite);
		}

		rightArrow = new FlxSprite(FlxG.width * 0.75, FlxG.height * 0.78);
		rightArrow.frames = Paths.getSparrowAtlas('storymode/Arrow');
		rightArrow.animation.addByPrefix('idle', 'Arrow0', 24, true);
		rightArrow.animation.addByPrefix('press', 'ArrowPress0', 1, false);
		rightArrow.scale.set(0.7,0.7);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(rightArrow);

		leftArrow = new FlxSprite(FlxG.width * 0.15, FlxG.height * 0.78);
		leftArrow.frames = Paths.getSparrowAtlas('storymode/Arrow');
		leftArrow.animation.addByPrefix('idle', 'Arrow0', 24, true);
		leftArrow.animation.addByPrefix('press', 'ArrowPress0', 1, false);
		leftArrow.scale.set(0.7,0.7);
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		leftArrow.flipX = true;
		add(leftArrow);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		add(bgSprite);

		add(rightArrow);
		add(leftArrow);

		txtWeekTitle.forEach(function(txt:FlxText)
		{
			add(txt);
		});
		txtStoryName.forEach(function(txt:FlxText)
		{
			add(txt);
		});
		scoreWeek.forEach(function(txt:FlxText)
		{
			add(txt);
		});
		bgSprite.forEach(function(spr:FlxSprite)
		{
			add(spr);
		});

		changeWeek();
		//changeDifficulty();

		var num = 0;
		scoreWeek.forEach(function(txt:FlxText)
		{
			var intendedScore:Int = Highscore.getWeekScore(loadedWeeks[num].fileName, curDifficulty);
			txt.text = "WEEK SCORE:" + intendedScore;
			num ++;
		});

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		if (!movedBack && !selectedWeek)
		{
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			if (!tweening) 
				{
				if (controls.UI_RIGHT_P && curWeek + 1 < WeekData.weeksList.length)
				{
					changeWeek(1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}

				if (controls.UI_LEFT_P && curWeek - 1 >= 0)
				{
					changeWeek(-1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}

			if (controls.UI_RIGHT) rightArrow.animation.play('press');
			else rightArrow.animation.play('idle');
			if (controls.UI_LEFT) leftArrow.animation.play('press');
			else leftArrow.animation.play('idle');

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeWeek(-FlxG.mouse.wheel);
				changeDifficulty();
			}

			/*
			if (controls.UI_RIGHT_P)
				changeDifficulty(1);
			else if (controls.UI_LEFT_P)
				changeDifficulty(-1);
			else if (upP || downP)
				changeDifficulty();
			*/

			if (!tweening) 
			{
				if(FlxG.keys.justPressed.CONTROL)
				{
					persistentUpdate = false;
					openSubState(new GameplayChangersSubstate());
				}
				else if(controls.RESET)
				{
					persistentUpdate = false;
					openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
					//FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				else if (controls.ACCEPT)
				{
					selectWeek();
				}
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchAnimatedState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				stopspamming = true;
			}

			var num:Int = 0;
			txtWeekTitle.forEach(function(txt:FlxText)
			{
				if (num == curWeek) txt.color = 0xFFF9CF51;
				num ++;
			});

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				MusicBeatState.switchState(LoadingState.getNextState(new LoadingsState(), false));
				FreeplayState.destroyFreeplayVocals();
			});
		} else {
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	var tweenDifficulty:FlxTween;
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = CoolUtil.difficulties[curDifficulty];

		lastDifficultyName = diff;
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;
		tweening = true;

		txtWeekTitle.forEach(function(txt:FlxText)
		{
			var txtX = txt.x + (-change * FlxG.width);
			FlxTween.tween(txt, {x: txtX}, 1.0, {ease: FlxEase.quadInOut});
		});
		txtStoryName.forEach(function(txt:FlxText)
		{
			var txtX = txt.x + (-change * FlxG.width);
			FlxTween.tween(txt, {x: txtX}, 1.0, {ease: FlxEase.quadInOut});
		});
		scoreWeek.forEach(function(txt:FlxText)
		{
			var txtX = txt.x + (-change * FlxG.width);
			FlxTween.tween(txt, {x: txtX}, 1.0, {ease: FlxEase.quadInOut});
		});
		bgSprite.forEach(function(spr:FlxSprite)
		{
			var sprX = spr.x + (-change * FlxG.width);
			FlxTween.tween(spr, {x: sprX}, 1.0, {
				ease: FlxEase.quadInOut,
				onComplete: function(twn:FlxTween) {
					tweening = false;
				}
			});
		});

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		PlayState.storyWeek = curWeek;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}
		

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		updateText();
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var leWeek:WeekData = loadedWeeks[curWeek];
	}
}
