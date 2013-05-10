package
{
	import lzm.starling.STLConstant;
	import lzm.starling.STLMainClass;
	import lzm.starling.display.ainmation.bone.BoneAnimation;
	import lzm.starling.display.ainmation.bone.BoneAnimationFactory;
	import lzm.starling.gestures.TapGestures;
	
	import starling.display.Quad;
	import starling.text.TextField;
	import starling.utils.AssetManager;
	import starling.utils.HAlign;
	
	public class MainTest extends STLMainClass
	{
		private var asset:AssetManager;
		private var boneAnimationFactory:BoneAnimationFactory;
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
					
					text = new TextField(100,16,"");
					text.hAlign = HAlign.LEFT;
					text.color = 0xffffff;
					
					var animation:BoneAnimation = boneAnimationFactory.createAnimation("Tain",60);
					animation.x = animation.y = 200;
//					animation.goToMovie("walk");
					animation.play();
					addChild(animation);
					
					
//					var quad:Quad = new Quad(STLConstant.StageWidth,STLConstant.StageHeight,0x333333);
//					addChild(quad);
//					new TapGestures(quad,function():void{
//						createAnimation();
//					});
//					
//					createAnimation();
				}
			});
		}
		
		private function createAnimation():void{
			var animation:BoneAnimation;
			for (var i:int = 0; i < 20; i++) {
				animation = boneAnimationFactory.createAnimation("Tain",60);
				animation.touchable = false;
				animation.y = 40 + index * 15;
				animation.x = 15 + i * 25;
				addChild(animation);
//				animation.goToMovie("walk");
				animation.play();
			}
			index++;
			
			text.text = (index * 20) + "";
			addChild(text);
		}
	}
}