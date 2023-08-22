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
	var curSelected:Int = 0;
	var curRow:Int = 1;

	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;

	var border:FlxSprite;
	var profiles:FlxTypedGroup<FlxSprite>;
	var bigProfile:FlxSprite;
	var bigHolder:FlxSprite;

	var nameText:FlxText;
	var descText:FlxText;
	var quoteText:FlxText;

	var blackOverlay:FlxSprite;
	var thanks:FlxText;
	var inThanks:Bool = false;

	var bigfatfuckingBALLS:Array<Int>;

	var offsetThing:Float = -75;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('credits/bg'));
		add(bg);
		bg.screenCenter();
		

		#if MODS_ALLOWED
		var path:String = 'modsList.txt';
		if(FileSystem.exists(path))
		{
			var leMods:Array<String> = CoolUtil.coolTextFile(path);
			for (i in 0...leMods.length)
			{
				if(leMods.length > 1 && leMods[0].length > 0) {
					var modSplit:Array<String> = leMods[i].split('|');
					if(!Paths.ignoreModFolders.contains(modSplit[0].toLowerCase()) && !modsAdded.contains(modSplit[0]))
					{
						if(modSplit[1] == '1')
							pushModCreditsToList(modSplit[0]);
						else
							modsAdded.push(modSplit[0]);
					}
				}
			}
		}

		var arrayOfFolders:Array<String> = Paths.getModDirectories();
		arrayOfFolders.push('');
		for (folder in arrayOfFolders)
		{
			pushModCreditsToList(folder);
		}
		#end

		var pisspoop:Array<Array<String>> = [ //Name - Portrait name - Description - Link - BG Color
			['DirectSpoogles',		'spoogles',			'Music, Layout, Story, Additional Art',		'https://twitter.com/directspoogles',	'0xffa566d9', 	"\"HUH, WAIT! I NEVER GOT TO SHOW YOU MY ELIMINAAAAAAAAAAAAaaaaa-\""],
			['SJ',					'sj',				'Art, Layout, Coding',						'https://iamsj.tumblr.com/',			'0xff323fcf', 	"\"Baby Park is the best Mario Kart track!\""],
			['OrangeLenny',			'lenny',			'Art, Additional Art',						'https://orangelenny.tumblr.com/',		'0xff05a867', 	"\"Next person to assume I'm annoying orange will be casted to be exploded immediately\""],
			['Zeno',				'zeno',				'Additional Art',							'https://twitter.com/__Zen0o__',		'0xfff21189', 	"\"Where's Towa?\""],
			['Zeph',				'zeph',				'Cutscenes, Layout, Story',					'https://zeph-phyr.tumblr.com/ ',		'0xff08ff52', 	"\"Goals! This sloth has no idea what's going on.\""],
			['GreenyToaster',		'greeny',			'Cutscene Music, Voice Actor for The Host',	'https://greenytoaster.newgrounds.com/','0xff59ffdb',	"\"They should've put me next to Zeno...\""],
			['Jax P.',				'jax',				'Voice Actor for One',						'https://twitter.com/crownjevvel',		'0xffff57db', 	"\"If you cant love yourself, how in the heck are you gonna take over the universe?\""],
			['Not_Ryan.jpeg',		'ryan',				'Voice Actor for The Director',				'https://twitter.com/not_ryanjpeg',		'0xffff2f24', 	"\"Not interested.\""]
		];

		//"You must be breaking every single fucking function in this project if you think we fucking"
		//FLIXEL VERSION 5.3.0:
		bigfatfuckingBALLS = [
			0xffa566d9,
			0xff323fcf,
			0xff05a867,
			0xfff21189,
			0xff08ff52,
			0xff59ffdb,
			0xffff57db,
			0xffff2f24
		];
		
		for(i in pisspoop){
			creditsStuff.push(i);
		}

		border = new FlxSprite(-50, -75).loadGraphic(Paths.image('credits/border'));
		border.scale.set(0.5, 0.5);
		add(border);

		profiles = new FlxTypedGroup<FlxSprite>();
		for (i in 0...creditsStuff.length)
			{
				var profile:FlxSprite = new FlxSprite(-50 + (i * 225), -75);
				profile.frames = Paths.getSparrowAtlas('credits/profiles');
				profile.animation.addByPrefix('spoogles', 'spoogles');
				profile.animation.addByPrefix('sj', 'sj');
				profile.animation.addByPrefix('lenny', 'lenny');
				profile.animation.addByPrefix('zeph', 'zeph');
				profile.animation.addByPrefix('zeno', 'zeno');
				profile.animation.addByPrefix('greeny', 'greeny');
				profile.animation.addByPrefix('jax', 'jax');
				profile.animation.addByPrefix('ryan', 'ryan');
				profile.ID = i;
				profile.animation.play(creditsStuff[i][1]);

				// its 1am and im too lazy to figure out how to not do this like this
				if (i >= 3 && i < 6)
					{
						profile.y += 230;
						profile.x -= 225 * 3;
					}
					
				else if (i >= 6)
					{
						
						profile.y += 230 * 2;
						switch (i)
						{
							case 6:
								profile.x = ((-100 + 255) / 2) + -50;
							case 7:
								profile.x = ((-100 + 255 * 3) / 2) + -50;
						}
					}
					

				profile.scale.set(0.5,0.5);
				profiles.add(profile);
				add(profile);

			}

		var bigBorder:FlxSprite = new FlxSprite(809 - 15, 36 - 15).loadGraphic(Paths.image('credits/border'));
		add(bigBorder);

		bigProfile = new FlxSprite(809, 36);
		bigProfile.frames = Paths.getSparrowAtlas('credits/profiles');
		bigProfile.animation.addByPrefix('spoogles', 'spoogles');
		bigProfile.animation.addByPrefix('sj', 'sj');
		bigProfile.animation.addByPrefix('lenny', 'lenny');
		bigProfile.animation.addByPrefix('zeph', 'zeph');
		bigProfile.animation.addByPrefix('zeno', 'zeno');
		bigProfile.animation.addByPrefix('greeny', 'greeny');
		bigProfile.animation.addByPrefix('jax', 'jax');
		bigProfile.animation.addByPrefix('ryan', 'ryan');
		add(bigProfile);

		bigHolder = new FlxSprite(773, 464).loadGraphic(Paths.image('credits/textholdy'));
		add(bigHolder);

		nameText = new FlxText(773, 470, bigHolder.width, '', 50);
		nameText.setFormat(Paths.font("GrilledCheese BTN Regular.ttf"), 50, FlxColor.BLACK, CENTER);
		add(nameText);

		descText = new FlxText(773, 540, bigHolder.width, '', 25);
		descText.setFormat(Paths.font("GrilledCheese BTN Regular.ttf"), 25, FlxColor.BLACK, CENTER);
		add(descText);
		
		quoteText = new FlxText(773, 595, bigHolder.width, '', 20);
		quoteText.setFormat(Paths.font("GrilledCheese BTN Regular.ttf"), 20, FlxColor.BLACK, CENTER);
		add(quoteText);

		var extraText:FlxText = new FlxText(773, 680, bigHolder.width, 'PRESS TAB TO VIEW ADDITIONAL CREDITS', 15);
		extraText.setFormat(Paths.font("GrilledCheese BTN Regular.ttf"), 15, FlxColor.WHITE, CENTER);
		add(extraText);

		blackOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackOverlay.alpha = 0;
		add(blackOverlay);

		thanks = new FlxText(10, 10, FlxG.width, "
		THE STRUGGLE FOR THE WORLD TEAM:

		Gema - Voice of Soda
		SachDash - Voice of Sacky
		That Channel Called Sistube - Voice of Bang Snaps
		Senroak - Voice of Star
		CrystalClear - Voice of LOLipop
		

		PSYCH ENGINE TEAM:

		Shadow Mario - Main Programmer
		River Oaken - Main Artist
		Shubs - Additional Programmer

		BB-Panzu - Ex-Programmer

		iFlicky - Composed Psync and Tea Time, Made Dialogue Sounds
		SqirraRNG - Crash Handler and Chart Editor Waveform
		EliteMasterEric	- Runtime Shader Support
		PolybiusProxy - MP4 Video Loader
		KadeDev - Chart Editor Help
		Keoiki - Note Splash Animations
		Nebula the Zorua - LUA JIT fork and Lua Reworks
		Smokey - Sprite Atlas Support


		FRIDAY NIGHT FUNKIN' TEAM:

		ninjamuffin99 - Programming
		Phantom Arcade - Animator
		evilsk8r - Artist
		Kawai Sprite - Musician
		", 15);
		thanks.setFormat(Paths.font("GrilledCheese BTN Regular.ttf"), 15, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		thanks.borderSize = 1;
		thanks.alpha = 0;
		add(thanks);


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

				var leftP = controls.UI_LEFT_P;
				var rightP = controls.UI_RIGHT_P;
				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (leftP)
				{
					if (!inThanks)
						changeSelection(-shiftMult);
				}
				if (rightP)
				{
					if (!inThanks)
						changeSelection(shiftMult);
				}
				if (upP)
					{
						if (!inThanks)
							changeSelectionBig(false);
					}
				if (downP)
				{
					if (!inThanks)
						changeSelectionBig(true);
				}
			}

			if (FlxG.keys.justPressed.TAB)
			{
				if (blackOverlay.alpha == 0)
					{
						blackOverlay.alpha = 0.75;
						inThanks = true;
						thanks.alpha = 1;
					}
				else
					{
						blackOverlay.alpha = 0;
						inThanks = false;
						thanks.alpha = 0;
					}
					
			}

			if(controls.ACCEPT && (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4)) {
				if (!inThanks)
					CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}
			if (controls.BACK)
			{
				if (!inThanks)
					{
						FlxG.sound.play(Paths.sound('cancelMenu'));
						MusicBeatState.switchState(new MainMenuState());
						quitting = true;
					}
				else
					{
						blackOverlay.alpha = 0;
						inThanks = false;
						thanks.alpha = 0;
					}
			}
		}
		
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		if (curSelected < 3)
			curRow = 1;
		else if (curSelected >= 3 && curSelected < 6)
			curRow = 2;
		else
			curRow = 3;

		bigProfile.animation.play(creditsStuff[curSelected][1]);
		bigHolder.color = bigfatfuckingBALLS[curSelected];
		nameText.text = creditsStuff[curSelected][0];
		descText.text = creditsStuff[curSelected][2];
		quoteText.text = creditsStuff[curSelected][5];
		profiles.forEach(function(spr:FlxSprite)
			{
				if (spr.ID == curSelected)
				{
					border.setPosition(spr.x - 15, spr.y - 16);
				}
			});
	}
	
	function changeSelectionBig(positive:Bool = true)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

			switch (curRow)
			{
				case 1 | 3:
					if (positive)
						curSelected += 3;
					else
						curSelected -= 3;
				case 2:
					if (curSelected == 3 || curSelected == 4)
						if (positive)
							curSelected += 3;
						else
							curSelected -= 3;
					else
						if (positive)
							curSelected += 2;
						else
							curSelected -= 3;

			}


			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;

			if (curSelected < 3)
				curRow = 1;
			else if (curSelected >= 3 && curSelected < 6)
				curRow = 2;
			else
				curRow = 3;
	
			bigProfile.animation.play(creditsStuff[curSelected][1]);
			bigHolder.color = bigfatfuckingBALLS[curSelected];
			nameText.text = creditsStuff[curSelected][0];
			descText.text = creditsStuff[curSelected][2];
			quoteText.text = creditsStuff[curSelected][5];
			profiles.forEach(function(spr:FlxSprite)
				{
					if (spr.ID == curSelected)
					{
						border.setPosition(spr.x - 15, spr.y - 16);
					}
				});
		}

	#if MODS_ALLOWED
	private var modsAdded:Array<String> = [];
	function pushModCreditsToList(folder:String)
	{
		if(modsAdded.contains(folder)) return;

		var creditsFile:String = null;
		if(folder != null && folder.trim().length > 0) creditsFile = Paths.mods(folder + '/data/credits.txt');
		else creditsFile = Paths.mods('data/credits.txt');

		if (FileSystem.exists(creditsFile))
		{
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for(i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if(arr.length >= 5) arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
		modsAdded.push(folder);
	}
	#end

	function getCurrentHolderColor() {
		var bgColor:String = creditsStuff[curSelected][4];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		trace(Std.parseInt(bgColor));
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}