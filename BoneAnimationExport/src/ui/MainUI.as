package ui
{
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.NumericStepper;
	import com.bit101.components.PushButton;
	import com.bit101.components.ScrollPane;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.getQualifiedClassName;

	public class MainUI extends Sprite
	{
		private var swfPathLabel:Label;//swf地址
		private var swfPathInput:InputText;
		private var chooseFileBtn:PushButton;
		
		private var exportPathLabel:Label;//输出地址
		private var exportPathInput:InputText;
		private var chooseExportPathBtn:PushButton;
		
		private var exportScaleLabel:Label;
		private var exportScaleNumStep:NumericStepper;
		
		private var animationExportBtn:PushButton;
		
		private var exportStateLable:Label;
		
		private var animationPanel:ScrollPane;
		private var showX:Number = 0;
		private var showY:Number = 0;
		
		protected var tempContent:Sprite = new Sprite();
		
		public function MainUI()
		{
			swfPathLabel = new Label(this,17,12,"swf地址：");
			swfPathInput = new InputText(this,72,12);
			swfPathInput.enabled = false;
			chooseFileBtn = new PushButton(this,180,10,"选择文件swf",onSelectSwfBtn);
			
			exportPathLabel = new Label(this,12,36,"输出地址：");
			exportPathInput = new InputText(this,72,36);
			exportPathInput.enabled = false;
			chooseExportPathBtn = new PushButton(this,180,34,"选择输出路径",onSelectExportPathBtn);
			
			exportScaleLabel = new Label(this,12,60,"输出倍数：");
			exportScaleNumStep = new NumericStepper(this,72,60);
			exportScaleNumStep.minimum = 1;
			exportScaleNumStep.maximum = 10;
			exportScaleNumStep.value = 1;
			exportScaleNumStep.width = 60;
			
			animationExportBtn = new PushButton(this,12,84,"输出动画",onExportAnimationBtn);
			animationExportBtn.width = 100;
			
			exportStateLable = new Label(this,12,108,"等待输出");
			
			animationPanel = new ScrollPane(this,0,132);
			animationPanel.width = 800;
			animationPanel.height = 600 - 132;
			animationPanel.dragContent = false;
			animationPanel.autoHideScrollBar = true;
			addChild(animationPanel);
			
			tempContent.y = 800;
			addChild(tempContent);
		}
		
		private function onSelectSwfBtn(e:Event):void{
			var file:File = new File();
			file.browse([new FileFilter("Flash","*.swf")]);
			file.addEventListener(Event.SELECT,selectSwfOK);
		}
		private function selectSwfOK(e:Event):void{
			var file:File = e.target as File;
			file.removeEventListener(Event.SELECT,selectSwfOK);
			swfPathInput.text = file.url;
		}
		
		private function onSelectExportPathBtn(e:Event):void{
			var file:File = new File();
			file.browseForDirectory("输出路径");
			file.addEventListener(Event.SELECT,selectExportPathOK);
		}
		private function selectExportPathOK(e:Event):void{
			var file:File = e.target as File;
			file.removeEventListener(Event.SELECT,selectExportPathOK);
			exportPathInput.text = file.url + "/";
		}
		
		/**
		 * 点击了输出动画按钮 
		 * 
		 */		
		private function onExportAnimationBtn(e:MouseEvent):void{
			dispatchEvent(new Event("onExportAnimationBtn"));
		}
		
		/**
		 * swf地址
		 */		
		public function get swfPath():String{
			return swfPathInput.text;
		}
		
		/**
		 * 输入出地址
		 */		
		public function get exportPath():String{
			return exportPathInput.text;
		}
		
		/**
		 * 输出倍数
		 */		
		public function get exportScaleValue():int{
			return exportScaleNumStep.value;
		}
		
		/**
		 * 那对象添加到临时容器
		 * */
		public function addMcToTempContent(display:DisplayObject):void{
			while(tempContent.numChildren > 0){
				tempContent.removeChildAt(0);
			}
			tempContent.addChild(display);
		}
		
		/**
		 * 保留两位小数
		 */		
		public function formatNumber(_num:Number):Number{
			return Math.round(_num * (0 || 100)) / 100;
		}
		
		public function getName(rawAsset:Object):String
		{
			var matches:Array;
			var name:String;
			
			if (rawAsset is String || rawAsset is FileReference)
			{
				name = rawAsset is String ? rawAsset as String : (rawAsset as FileReference).name;
				name = name.replace(/%20/g, " "); // URLs use '%20' for spaces
				matches = /(.*[\\\/])?([\w\s\-]+)(\.[\w]{1,4})?/.exec(name);
				
				if (matches && matches.length == 4) return matches[2];
				else throw new ArgumentError("Could not extract name from String '" + rawAsset + "'");
			}
			else
			{
				name = getQualifiedClassName(rawAsset);
				throw new ArgumentError("Cannot extract names for objects of type '" + name + "'");
			}
		}
		
		public function addMovieClip(mc:DisplayObject):void{
			tempContent.addChild(mc);
			var rect:Rectangle = Util.getPivotAndMaxRect(mc);
			mc.x = rect.x + showX;
			mc.y = rect.y + showY;
			
			showX += rect.width;
			if(showX > 800){
				showX = rect.width;
				showY = animationPanel.content.height;
				mc.x = rect.x;
				mc.y = rect.y + showY;
			}
			animationPanel.content.addChild(mc);
			animationPanel.update();
		}
		
		public function clearMovies():void{
			if(animationPanel.content.numChildren > 0){
				animationPanel.content.removeChildren(0,animationPanel.content.numChildren-1);
			}
		}
	}
}