package
{
	import lzm.starling.STLConstant;
	import lzm.starling.STLMainClass;
	import lzm.starling.display.ainmation.bone.BoneAnimation;
	import lzm.starling.display.ainmation.bone.BoneAnimationFactory;
	import lzm.starling.gestures.TapGestures;
	
	import starling.display.Quad;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.AssetManager;
	import starling.utils.HAlign;
	
	public class MainTest extends STLMainClass
	{
		private var asset:AssetManager;
		private var boneAnimationFactory:BoneAnimationFactory;
		private var animations:Array;
		private var index:int = 0;
		private var text:TextField;
		
		public function MainTest()
		{
			asset = new AssetManager(STLConstant.scale,STLConstant.useMipMaps);
			asset.enqueue("asset/movies.json");
			asset.enqueue("asset/export.png");
			asset.enqueue("asset/export.xml");
			asset.loadQueue(function(ratio:Number):void{
				if(ratio == 1){
					boneAnimationFactory = new BoneAnimationFactory(asset.getOther("movies"),asset);
					
					
					test1();
//					test2();
					
				}
			});
		}
		
		private function test1():void{
			STLConstant.nativeStage.frameRate = 60;
			
			animations = [];
			
			var labbels:Array = ["stomp","walk","headSmack","dead"];
			
			var tempX:int = 56;
			for (var i:int = 0; i < labbels.length; i++) {
				var animation:BoneAnimation = boneAnimationFactory.createAnimation("Tain",60);
				animation.x = 120 * i + tempX;
				animation.y = 200;
				animation.goToMovie(labbels[i]);
				animation.play();
				addChild(animation);
				animations.push(animation);
			}
			
			addEventListener(Event.ENTER_FRAME,function(e:EnterFrameEvent):void{
				for each (var animation:BoneAnimation in animations) {
					animation.update();
				}
			});
		}
		
		private function test2():void{
			STLConstant.nativeStage.frameRate = 30;
			
			text = new TextField(100,16,"");
			text.hAlign = HAlign.LEFT;
			text.color = 0xffffff;


			var quad:Quad = new Quad(STLConstant.StageWidth,STLConstant.StageHeight,0x333333);
			addChild(quad);
			new TapGestures(quad,function():void{
				createAnimation();
			});
			
			animations = [];

			createAnimation();
			
			addEventListener(Event.ENTER_FRAME,function(e:EnterFrameEvent):void{
				for each (var animation:BoneAnimation in animations) {
					animation.update();
				}
			});
		}
		
		private function createAnimation():void{
			var animation:BoneAnimation;
			for (var i:int = 0; i < 20; i++) {
				animation = boneAnimationFactory.createAnimation("Sworder2",60);
				animation.touchable = false;
				animation.y = 40 + index * 15;
				animation.x = 15 + i * 25;
				addChild(animation);
				animation.goToMovie("attack");
				animation.play();
				
				animations.push(animation);
			}
			index++;
			
			text.text = (index * 20) + "";
			addChild(text);
		}
	}
}