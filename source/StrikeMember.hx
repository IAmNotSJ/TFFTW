package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class StrikeMember extends FlxSprite
{
    var daMember:Int;
	var isPissed:Bool = true;
	public function new(x:Float, y:Float, member:Int)
        {
            super(x, y);
    
            daMember = member;
            // strike deez nuts in yo face LMAAAAAAAAAAAAAAAAAAAAAAO
            switch (member)
            {
                case 2:
                    frames = Paths.getSparrowAtlas('ONE/TWO');
                    animation.addByPrefix('idle', 'TWO0');
                    animation.addByPrefix('fire', 'TWO fire', 24, false);
                case 3:
                    frames = Paths.getSparrowAtlas('ONE/THREE');
                    animation.addByPrefix('idle', 'THREE0');
                    animation.addByPrefix('fire', 'THREE fire', 24, false);
                case 4:
                    frames = Paths.getSparrowAtlas('ONE/FOUR');
                    animation.addByPrefix('idle', 'FOUR0');
                    animation.addByPrefix('fire', 'FOUR fire', 24, false);
                case 5:
                    frames = Paths.getSparrowAtlas('ONE/FIVE');
                    animation.addByPrefix('idle', 'FIVE0');
                    animation.addByPrefix('fire', 'FIVE fire', 24, false);
                case 6:
                    frames = Paths.getSparrowAtlas('ONE/SIX');
                    animation.addByPrefix('idle', 'SIX0');
    
            }
            frames = Paths.getSparrowAtlas('ONE/bgFreaks');

            playAnim('idle');
        }

	var danced:Bool = false;

    public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
		{
			animation.play(AnimName, Force, Reversed, Frame);

            if (AnimName != 'idle')
            {
                switch (daMember)
                {
                    case 2:
                        offset.set(33,10);
                    case 3:
                        offset.set(887,7);
                    case 4:
                        offset.set(74,224);
                    case 5:
                        offset.set(853,195);
                }
            }
            else
                offset.set(0,0);
            
			
		}

	public function dance():Void
	{
        playAnim('idle', true);
	}
}
