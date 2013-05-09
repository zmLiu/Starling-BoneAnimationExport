package
{
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import lzm.starling.STLStarup;
	
	public class Test extends STLStarup
	{
		public function Test()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.color = 0x999999;
			stage.frameRate = 60;
			
			initStarling(MainTest,true);
		}
	}
}