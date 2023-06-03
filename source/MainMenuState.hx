package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import openfl.filters.ShaderFilter;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var lastSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	public var monitorShader:Monitor;

	var bg:FlxSprite;
	var cursorThing:FlxSprite;
	var window:FlxSprite;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'extras',
		'credits',
		'options'];

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	public static var firstStart:Bool = true;
	public static var finishedFunnyMove:Bool = false;
	
	var moonCode:FlxSprite;

	var cursorColored0:FlxSprite;
	var cursorColored1:FlxSprite;
	var cursorColored2:FlxSprite;
	var cursorColored3:FlxSprite;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		Paths.image('mainmenu/mouse/default');
		Paths.image('mainmenu/mouse/pink');
		Paths.image('mainmenu/menuBG');
		Paths.getSparrowAtlas('mainmenu/mooncode');
		for (i in 0...optionShit.length)
		{
			Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
		}
		Paths.getSparrowAtlas('mainmenu/windows/WindowBlue');
		Paths.getSparrowAtlas("mainmenu/windows/WindowPink");
		Paths.getSparrowAtlas("mainmenu/windows/WindowGreen");
		Paths.getSparrowAtlas("mainmenu/windows/WindowYellow");
		Paths.getSparrowAtlas("mainmenu/windows/WindowRed");
		Paths.sound('scrollMenu');
		Paths.sound('cancelMenu');

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		monitorShader = new Monitor();
		camGame.setFilters([new ShaderFilter(monitorShader)]); 

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		cursorThing = new FlxSprite().loadGraphic(Paths.image('mainmenu/mouse/default'));
		cursorThing.antialiasing = ClientPrefs.globalAntialiasing;
		cursorThing.updateHitbox();

		cursorColored0 = new FlxSprite().loadGraphic(Paths.image('mainmenu/mouse/pink'));
		cursorColored0.updateHitbox();

		persistentUpdate = persistentDraw = true;

		//var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		bg = new FlxSprite(-80).loadGraphic(Paths.image('mainmenu/menuBG'));
		bg.scrollFactor.set();
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		window = new FlxSprite(600, 100);
		
		window.frames = Paths.getSparrowAtlas('mainmenu/windows/WindowBlue');
		window.animation.addByPrefix('idle', 'slide blue');
		window.animation.play('idle');
		window.scrollFactor.set();
		window.antialiasing = ClientPrefs.globalAntialiasing;
		add(window);

		moonCode = new FlxSprite(1150, 600);
		moonCode.frames = Paths.getSparrowAtlas('mainmenu/mooncode');
		moonCode.animation.addByPrefix('idle', 'Moon code basic', 24);
		moonCode.animation.addByPrefix('selected', 'Moon code white', 24);
		moonCode.scrollFactor.set();
		moonCode.setGraphicSize(Std.int(moonCode.width * 0.25));
		moonCode.updateHitbox();
		moonCode.antialiasing = ClientPrefs.globalAntialiasing;
		add(moonCode);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(-400 + (i * -100), (i * 160) + 60);
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic0", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white0", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 2) * 0.135;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.68));
			menuItem.updateHitbox();

			if (firstStart)
			{
				menuItem.alpha = 0;
				FlxTween.tween(menuItem,{alpha: 1}, 1.3,{ease: FlxEase.expoInOut});
				FlxTween.tween(menuItem,{x: 50}, 0.7 + (i * 0.25),{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween)
				{
					finishedFunnyMove = true;
					changeItem();
				}});
			}
			else
			{
				menuItem.x = 50;
			}
		}

		firstStart = false;

		FlxG.camera.follow(camFollowPos, null, 1);

		CustomFadeTransition.nextCamera = CustomAnimatedTransition.nextCamera = camAchievement;

		/*
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		*/

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();
		//add(cursorColored0);
		add(cursorThing);
	}

	var selectedSomethin:Bool = false;

	var canClick:Bool = true;
	var usingMouse:Bool = false;
	var repeatShit:Bool = true;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		cursorThing.x = FlxG.mouse.x - 10;
		cursorThing.y = FlxG.mouse.y - 1;

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));


		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
				if (lastSelected != curSelected) {
					lastSelected = curSelected; 
					changeWindow(true);
				}
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
				if (lastSelected != curSelected) {
					lastSelected = curSelected;
					changeWindow(true);
				}
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				CustomFadeTransition.nextCamera = CustomAnimatedTransition.nextCamera = camAchievement;
				MusicBeatState.switchAnimatedState(new TitleState());
			}

			if (controls.ACCEPT && !usingMouse)
			{
				if (optionShit[curSelected] == 'extras')
				{
					CoolUtil.browserLoad('https://youtu.be/42JCu9jWmY0');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							selectedSomethin = true;
							FlxG.sound.play(Paths.sound('confirmMenu'), 20.0);

							menuItems.forEach(function(spr:FlxSprite)
							{
								if (curSelected != spr.ID)
								{
									FlxTween.tween(spr, {x: -800}, 0.4, {ease: FlxEase.quadOut});
									FlxTween.tween(window,{x: 1400}, 0.4, {ease:FlxEase.expoInOut});
								}
								else
								{
									new FlxTimer().start(0.7, function(tmr:FlxTimer)
									{
										FlxTween.tween(spr, {x: -800}, 1.7, {ease: FlxEase.quadOut});
									});
									FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
									{
										goToState();
									});
								}
							});
						}
					});
				}
			}
			#if desktop
			#if debug
			else if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				CustomFadeTransition.nextCamera = CustomAnimatedTransition.nextCamera = camAchievement;
				MusicBeatState.switchAnimatedState(new MasterEditorMenu());
			}
			#end
			#end

			menuItems.forEach(function(spr:FlxSprite)
			{
				if(usingMouse)
				{
					if(!FlxG.mouse.overlaps(spr))
					{
						spr.animation.play('idle');
					}
				}
	
				if (FlxG.mouse.overlaps(spr))
				{
					if(canClick)
					{
						curSelected = spr.ID;
						usingMouse = true;
						spr.animation.play('selected');
						camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
					}

					if (lastSelected != curSelected) {
						lastSelected = spr.ID;
						changeWindow(false);
					}

					if(FlxG.mouse.pressed && canClick)
					{
						selectSomething();
					}
				}
			});
		}

		if (FlxG.mouse.overlaps(moonCode))
		{
			if(canClick)
			{
				usingMouse = true;
				moonCode.animation.play('selected');
			}

			if(FlxG.mouse.justPressed && canClick)
			{
				selectedSomethin = true;
				CustomFadeTransition.nextCamera = CustomAnimatedTransition.nextCamera = camAchievement;
				MusicBeatState.switchAnimatedState(new PasswordState());
			}
		}
		else
		{
			moonCode.animation.play('idle');
		}

		super.update(elapsed);
	}

	function selectSomething()
		{
			if (optionShit[curSelected] == 'extras')
			{
				CoolUtil.browserLoad('https://youtu.be/42JCu9jWmY0');
			}
			else
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'), 20.0);
				
				canClick = false;
	
				menuItems.forEach(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{		
						FlxTween.tween(spr, {x: -800}, 0.4, {ease: FlxEase.quadOut});
						FlxTween.tween(window,{x: 1400}, 0.4, {ease:FlxEase.expoInOut});
						new FlxTimer().start(0.7, function(tmr:FlxTimer)
						{
							FlxTween.tween(moonCode, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
						});
					}
					else
					{
						new FlxTimer().start(0.7, function(tmr:FlxTimer)
						{
							FlxTween.tween(spr, {x: -800}, 1.7, {ease: FlxEase.quadOut});
						});
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							goToState();
						});	
					}
				});
			}
		}

	function goToState()
	{
		var daChoice:String = optionShit[curSelected];
		CustomFadeTransition.nextCamera = CustomAnimatedTransition.nextCamera = camAchievement;
	
		switch (daChoice)
		{
			case 'story_mode':
				MusicBeatState.switchAnimatedState(new StoryMenuState());
			case 'freeplay':
				MusicBeatState.switchAnimatedState(new FreeplayState());
			case 'credits':
				MusicBeatState.switchAnimatedState(new CreditsState());
			case 'options':
				MusicBeatState.switchAnimatedState(new options.OptionsState());
		}
	}

	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;
			
			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}

		usingMouse = false;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected && finishedFunnyMove && !firstStart)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}
		});
	}

	function changeWindow(tweenIt:Bool)
	{
		var daChoice:String = optionShit[curSelected];

		remove(window);
		window = new FlxSprite(950, 100);
		switch(daChoice)
		{
			case 'story_mode':
				window.frames = Paths.getSparrowAtlas('mainmenu/windows/WindowBlue');
				window.animation.addByPrefix('idle', 'slide blue', 24);
			case 'freeplay':
				window.frames = Paths.getSparrowAtlas('mainmenu/windows/WindowPink');
				window.animation.addByPrefix('idle', 'slide pink', 24);
				window.setGraphicSize(Std.int(window.width * 0.53));
				window.updateHitbox();
				window.y -= 55;
			case 'extras':
				window.frames = Paths.getSparrowAtlas('mainmenu/windows/WindowGreen');
				window.animation.addByPrefix('idle', 'slide green', 24);
			case 'credits':
				window.frames = Paths.getSparrowAtlas('mainmenu/windows/WindowYellow');
				window.animation.addByPrefix('idle', 'slide yellow', 24);
			case 'options':
				window.frames = Paths.getSparrowAtlas('mainmenu/windows/WindowRed');
				window.animation.addByPrefix('idle', 'slide red', 24);
		}
		if(tweenIt)
		{	
			if(optionShit[curSelected] == 'freeplay')
				FlxTween.tween(window,{x: 572}, 0.3, {ease:FlxEase.expoInOut});
			else
				FlxTween.tween(window,{x: 600}, 0.3, {ease:FlxEase.expoInOut});
		}
		else
		{	
			if(optionShit[curSelected] == 'freeplay')
				window.x = 572;
			else
				window.x = 600;
		}
		window.animation.play('idle');
		window.scrollFactor.set();
		window.antialiasing = ClientPrefs.globalAntialiasing;
		add(window);
	}
}
