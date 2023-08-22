package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import flixel.group.FlxSpriteGroup;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flash.system.System; // Or nme.system.System if you're using NME
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end
import flixel.system.ui.FlxSoundTray;
import lime.app.Application;
import openfl.Assets;
import openfl.utils.Assets as OpenFlAssets;

#if VIDEOS_ALLOWED
import vlc.MP4Handler;
#end

using StringTools;
class EasterEggState extends MusicBeatState
{
	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		super.create();

		startVideo('CARAMELLDANSEN');
	}

	public function startVideo(name:String)
		{
			#if VIDEOS_ALLOWED
	
			var filepath:String = Paths.video(name);
			var video:MP4Handler = new MP4Handler();
			video.playVideo(filepath);
			video.finishCallback = function()
			{
				System.exit(0);
				return;
			}
			#else
			FlxG.log.warn('Platform not supported!');
			System.exit(0);
			return;
			#end
		}
}
