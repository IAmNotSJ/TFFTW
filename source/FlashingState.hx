package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	var warning:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('flashingBG'));
		add(bg);

		warning = new FlxText(0, 200, FlxG.width,
			"Warning!",
			48);
		warning.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warning.borderSize = 2;
		add(warning);

		warnText = new FlxText(0, 350, FlxG.width,
			"This Mod contains some scenes of minor flashing lights.
			You've been warned!






			Press any button to continue.",
			32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warnText.borderSize = 2;
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (FlxG.keys.justPressed.ANY) {
				leftState = true;
				FlxG.save.data.flashingShown = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						MusicBeatState.switchState(new TitleState());
					}
				});
				FlxTween.tween(warning, {alpha: 0}, 1, {});
			}
		}
		super.update(elapsed);
	}
}
