package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:Array<FlxText> = [];
	private var grpDesc:Array<FlxText> = [];
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var descText:Array<FlxText>;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var offsetThing:Float = -75;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		FlxG.sound.playMusic(Paths.music('Ragtime_Original_extreme'), 1);

		var happyBoo:FlxSprite = new FlxSprite();
		happyBoo.frames = Paths.getSparrowAtlas('credits/CreditsBoo1');
		happyBoo.animation.addByPrefix('idle', 'Portrait instance0', 24, true);
		happyBoo.scale.set(2.8,2.8);
		happyBoo.animation.play('idle');
		happyBoo.scrollFactor.set();
		happyBoo.updateHitbox();
		happyBoo.screenCenter();
		happyBoo.x += 330;
		add(happyBoo);


		persistentUpdate = true;

		var pisspoop:Array<Array<String>> = [ //Name - Description - Link
			['DIRECTOR'],
			['SaltedSporks',					'Singer, Musician, Artist, Animator',										'https://twitter.com/saltedsporks'],
			[''],
			['Programmers'],
			['Corrun',							'All of StoryMode songs, Most Mooncode songs, Most menus, and much more',					'https://twitter.com/Corrun_UT'],
			['Penguinsmh',						'Initial Boo Stage Demo + Tricky or Treat Demo Programmer',								'https://gamebanana.com/members/1949284'],
			['snowy~.',							'Implemented StickyBM Collab + Co-Directed Stumble Station',									'https://twitter.com/neuroxrd'],
			['ArfieCat',						'Reprogrammed Boo Stage',																'https://www.youtube.com/channel/UC5N7B8YvFDkw8KfiZZWRuNA'],
			['Gazozoz',							'UI Programmer: (Main Menu Overhaul and MoonCode Implementation)',						'https://twitter.com/Gazozoz_'],
			[''],
			['Voice Actors'],
			['Richard ballOOnhead Wroblewski',	"'SILENCE!' Guy",																		'https://www.facebook.com/OfficialRichardWroblewski/'],
			["Audiospawn's Sudzy Bubbles",		'Biggs',																				'https://www.youtube.com/user/werewolfyman'],
			['Cougar MacDowall VA',				'Buggs and Heart',																		'https://www.youtube.com/c/CougarmacdowallVa'],
			['Melissa MekRose',					'Daisy Bell (Singer + VA)',																			'https://www.youtube.com/channel/UCI3HhUCIXgqSSTPuRAoILJg'],
			['StickyBM',						'Arson Ifrit',																			'https://www.youtube.com/c/StickyBM'],
			['Redenvi',							'Luna Mond (Main Voice)',																'https://twitter.com/Doc_Glowstick'],
			['Rebecca Doodles',					'Luna Mond (Blood Moon Ver)',															'https://www.youtube.com/rebecca_doodles'],
			[''],
			['Musician'],
			['Mr_MusicGuy',						"Composed 'Brunch' (Pause Music)",														'https://mrmusicguy.bandcamp.com/'],
			["TMOCAD",							"Composed 'Ragtime' (End Credits Music)",												'https://soundcloud.com/tmocad'],
			[''],
			['Artists'],
			['KGBepis',							"BG Artist: Spweeked Stages + Cameos (Tricks)",															'https://twitter.com/KGBepis'],
			["Ito",								'BG Artist: Vibing Week + Deadly Colors',												'https://twitter.com/ItoSaihara_'],
			["Ghospel",							'Loading Screen art',																	'https://twitter.com/Ghospel_ghost'],
			['Tunaki',							"Concept artist: Treats Background, Earth's Sister building background",				'https://twitter.com/tunakihere'],
			['DamiNation',						'BF Promo art + Loading Screens + Cameos (Tricks)',									'https://twitter.com/DamiNation2020'],
			['Miss Beepy',						'Cameos (Tricks)',									'https://twitter.com/MissBeepy'],
			['Rabbit’s Foot',					'Main menu Window Art',																	'https://twitter.com/Kakosa_sama'],
			['BunMuffin',						'StoryMode Spweeked Art',																'https://linktr.ee/bun.muffin'],
			['@Mena_Mochii',					'StoryMode Winter Week Art',																'https://www.instagram.com/mena_mochii/'],
			['YoitsCro',						'Concept Pose Artist: Skeletons (Treat)',										'https://twitter.com/yoitscro'],
			['Ceres',							'Boo Witch Art + StoryMode Golden Days Art',																		'https://twitter.com/ceresmane'],
			[''],
			['Animators'],
			['Spyrodile',						"Cutscene Animator + Storyboard artist + Sprite animator: Skeleton Band (Treats Stage)", 'https://twitter.com/Spyrodile'],
			['OminousArtist',					"End Cutscene Animator",																	'https://twitter.com/OminousArtist'],
			['Ms.Unoriginal',					"End Cutscene Animator",																	'https://twitter.com/Unoriginalspaz'],
			['@NoBrain_Cells',					"End Cutscene Animator",																	'https://www.instagram.com/nobrain_cells/'],
			['Zoning Out',						"End Cutscene Animator (3d modeler)",															'https://twitter.com/Zoe_ning_Out'],
			['Raffi',							"Caramel Sprites",														'https://twitter.com/rafaisnotsoshom'],
			['OhSoVanilla',						"Deadly Colors (Biggs)",												'https://twitter.com/OhSoVanilla64'],
			['Bibi',							"Deadly Colors (Buggs BG Bounce + Biggs Midevent) + Tricky Cutscene Animatic",	'https://twitter.com/robotonin'],
			['Ascenti4',						"Stumble Station Stage (Boo) + Loading Screen Art",					'https://twitter.com/Ascenti4'],			

			[''],
			['Charters'],
			['10ju',							"Satellite Picnic, Poignant Comfort, Stumble Station,Meteorite Waltz,Earth’s Sister,Caramel,Treats",	'https://twitter.com/10juxd'],
			['Wilde',							"Boo, Heart Of Gold",																	'https://www.youtube.com/channel/UCRkIodLXQb50MuMLIcDdGQQ'],
			['SnowyBraviary',					"Ghost Picnic, Deadly Colors,Tricky or Treat",																			'https://twitter.com/SnowyBraviary'],
			['Iro',								"Trick, A Skeleton's Passion, It’s Okay",												'https://gamebanana.com/members/1949279'],
			[''],
			['Special Thanks'],
			['Saruky',							"Co-Directed Satellite Picnic",															'https://www.youtube.com/c/Saruky'],
			['Tsuraran',						"Co-Directed Caramel",																	'https://www.youtube.com/c/Tsuraran/'],
			['Tossler',							"Artistic Altitude Tossler Sprites + Tossler Chromatic",								'https://www.youtube.com/c/Tossler'],

			['UniqueGeese',						"Narrator for Caramel",																	'https://www.youtube.com/c/UniqueGeese'],
			['Kai_Lol',							"Programmer for Demo",																	'https://twitter.com/huskgold/'],
			['FidbroS',							"Html5 Porter for Demo + Beta Tester",													'https://twitter.com/FidbroS'],
			['Banbuds',							"Tricky Chromatics",																	'https://twitter.com/Banbuds'],
			['MaliciousBunny',					"Support",																				'https://twitter.com/BunnyMalicious'],
			['Sr Pelo',							"Oggabooga video",																		'https://youtu.be/zQu_Xi6aoFo?t=598'],
			['M1 Aether',						"Video pausing, skipping, scrolling",													'https://twitter.com/M1_Aether'],
			['EEYM',							"That wiki man",																		'https://twitter.com/EEYM5'],
			[''],
			['Psych Team'],
			['Shadow Mario',					'Main Programmer of Psych Engine',														'https://twitter.com/Shadow_Mario_'],
			['RiverOaken',						'Main Artist/Animator of Psych Engine',													'https://twitter.com/RiverOaken'],
			['shubs',							'Additional Programmer of Psych Engine',												'https://twitter.com/yoshubs'],
			['bb-panzu',						'Ex-Programmer of Psych Engine',														'https://twitter.com/bbsub3'],
			[''],
			['Engine Helpers'],
			['iFlicky',							'Composer of Psync and Tea Time\nMade the Dialogue Sounds',								'https://twitter.com/flicky_i'],
			['SqirraRNG',						'Crash Handler and Base code for\nChart Editor\'s Waveform',							'https://twitter.com/gedehari'],
			['PolybiusProxy',					'.MP4 Video Loader Library (hxCodec)',													'https://twitter.com/polybiusproxy'],
			['KadeDev',							'Fixed some cool stuff on Chart Editor\nand other PRs',									'https://twitter.com/kade0912'],
			['Keoiki',							'Note Splash Animations',																'https://twitter.com/Keoiki_'],
			['Nebula the Zorua',				'LUA JIT Fork and some Lua reworks',													'https://twitter.com/Nebula_Zorua'],
			['Smokey',							'Sprite Atlas Support',																	'https://twitter.com/Smokey_5_'],
			[''],
			["Funkin' Crew"],
			['ninjamuffin99',					"Programmer of Friday Night Funkin'",													'https://twitter.com/ninja_muffin99'],
			['PhantomArcade',					"Animator of Friday Night Funkin'",														'https://twitter.com/PhantomArcade3K'],
			['evilsk8r',						"Artist of Friday Night Funkin'",														'https://twitter.com/evilsk8r'],
			['kawaisprite',						"Composer of Friday Night Funkin'",														'https://twitter.com/kawaisprite']
		];
		
		for(i in pisspoop){
			creditsStuff.push(i);
		}
	
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:FlxText = new FlxText(FlxG.width * 0.15, 60 + 100 * i, FlxG.width * 0.5, creditsStuff[i][0], 32, true);
			var descText:FlxText = new FlxText(FlxG.width * 0.15 - 2, 110 + 100 * i, FlxG.width * 0.4, '', 32, true);
			if (isSelectable) {
				optionText.setFormat(Paths.font("times new roman.ttf"), 40, FlxColor.YELLOW, LEFT);

				descText = new FlxText(FlxG.width * 0.15 - 2, 105 + 100 * i, FlxG.width * 0.4, creditsStuff[i][1], 32, true);
				descText.setFormat(Paths.font("times new roman.ttf"), 24, FlxColor.YELLOW, LEFT);
			} else if (creditsStuff[i][0] != '') {
				optionText.text = "[" + optionText.text.toUpperCase() + "]";
				optionText.setFormat(Paths.font("times new roman.ttf"), 50, FlxColor.YELLOW, LEFT);
				optionText.x += -70;
			}
			add(optionText);
			grpOptions.push(optionText);
			add(descText);
			grpDesc.push(descText);

			if(isSelectable) {
				var random = Std.random(7);
				var iconName:String = null;
				switch (random)
				{
					case 0: iconName = "blue";
					case 1: iconName = "green";
					case 2: iconName = "orange";
					case 3: iconName = "pink";
					case 4: iconName = "purple";
					case 5: iconName = "red";
					case 6: iconName = "yellow";
				}

				switch (creditsStuff[i][0].toLowerCase())
				{
					case 'corrun': iconName = "corrun";
					case "audiospawn's sudzy bubbles": iconName = "biggs";
					case 'cougar macdowall va': iconName = "buggs";
					case 'stickybm': iconName = "arson";
					case 'redenvi': iconName = "luna";
					case 'rebecca doodles': iconName = "lunaBlood";
					case 'melissa mekrose': iconName = "daisy";
				}

				var icon:AttachedSprite = new AttachedSprite('credits/' + iconName);
				icon.scale.set(0.7, 0.7);
				icon.sprTracker = optionText;
				icon.xAdd = optionText.x - 350;
				icon.yAdd = -40;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				Paths.currentModDirectory = '';

				if(curSelected == -1) curSelected = i;
			}
		}

		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;
				
				if (curSelected != 1 && allowToMove && upP)
				{
					changeSelection(-1);
					holdTime = 0;
				}
				if (curSelected < creditsStuff.length - 1 && allowToMove && downP)
				{
					changeSelection(1);
					holdTime = 0;
				}
				/*
				if(allowToMove && (controls.UI_DOWN || controls.UI_UP))
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
				*/
				
			}

			if(controls.ACCEPT && (creditsStuff[curSelected][2] == null || creditsStuff[curSelected][2].length > 4)) {
				CoolUtil.browserLoad(creditsStuff[curSelected][2]);
			}
			if (controls.BACK)
			{
				FlxG.sound.playMusic(Paths.music('HungryMenuMusic'), 0.7);
				FlxG.sound.music.time = 9150;
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchAnimatedState(new MainMenuState());
				quitting = true;
			}
		}
		super.update(elapsed);
	}

	var allowToMove = true;
	function changeSelection(change:Int = 0)
	{
		allowToMove = false;
		var count:Int = 0;

		grpOptions[curSelected].setFormat(Paths.font("times new roman.ttf"), 40, FlxColor.YELLOW, LEFT);  
		grpDesc[curSelected].setFormat(Paths.font("times new roman.ttf"), 24, FlxColor.YELLOW, LEFT);

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
			{
				curSelected = 0;
			}
			if (curSelected >= creditsStuff.length)
			{
				curSelected = creditsStuff.length - 1;
			}
			count ++;
		} while(unselectableCheck(curSelected));

		for (i in 0...grpOptions.length)
		{
			FlxTween.tween(grpOptions[i], {y: grpOptions[i].y + ((-100 * count) * change)}, 0.2);
		}

		for (i in 0...grpDesc.length)
		{
			FlxTween.tween(grpDesc[i], {y: grpDesc[i].y + ((-100 * count) * change)}, 0.2);
		}

		new FlxTimer().start(0.2, function(tmr:FlxTimer) 
		{
			allowToMove = true;
		});

		grpOptions[curSelected].setFormat(Paths.font("times new roman.ttf"), 40, FlxColor.CYAN, LEFT);  
		grpDesc[curSelected].setFormat(Paths.font("times new roman.ttf"), 24, FlxColor.CYAN, LEFT);
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}