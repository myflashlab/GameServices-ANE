package 
{
	import com.myflashlab.air.extensions.gameServices.google.multiplayer.Participant;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.StageOrientationEvent;
	import flash.events.StatusEvent;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.text.AntiAliasType;
	import flash.text.AutoCapitalize;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.events.InvokeEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import flash.data.EncryptedLocalStore;
	
	import com.doitflash.text.modules.MySprite;
	import com.doitflash.starling.utils.list.List;
	import com.doitflash.consts.Direction;
	import com.doitflash.consts.Orientation;
	import com.doitflash.consts.Easing;
	import com.doitflash.mobileProject.commonCpuSrc.DeviceInfo;
	
	import com.myflashlab.air.extensions.gameServices.GameServices;
	import com.myflashlab.air.extensions.gameServices.google.GamesStatusCodes;
	import com.myflashlab.air.extensions.gameServices.google.events.AuthEvents;
	import com.myflashlab.air.extensions.gameServices.google.events.EventEvents;
	import com.myflashlab.air.extensions.gameServices.google.gameEvents.GameEvent;
	import com.myflashlab.air.extensions.gameServices.google.player.PlayerLevel;
	
	
	import com.luaye.console.C;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 4/11/2016 10:24 AM
	 */
	public class EventsSample extends Sprite 
	{
		private const BTN_WIDTH:Number = 150;
		private const BTN_HEIGHT:Number = 60;
		private const BTN_SPACE:Number = 2;
		private var _txt:TextField;
		private var _body:Sprite;
		private var _list:List;
		private var _numRows:int = 1;
		
		public function EventsSample():void 
		{
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, handleActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleDeactivate);
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys);
			
			stage.addEventListener(Event.RESIZE, onResize);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			C.startOnStage(this, "`");
			C.commandLine = false;
			C.commandLineAllowed = false;
			C.x = 20;
			C.width = 250;
			C.height = 150;
			C.strongRef = true;
			C.visible = true;
			C.scaleX = C.scaleY = DeviceInfo.dpiScaleMultiplier;
			
			_txt = new TextField();
			_txt.autoSize = TextFieldAutoSize.LEFT;
			_txt.antiAliasType = AntiAliasType.ADVANCED;
			_txt.multiline = true;
			_txt.wordWrap = true;
			_txt.embedFonts = false;
			_txt.htmlText = "<font face='Arimo' color='#333333' size='20'><b>Game Services ANE V"+GameServices.VERSION+"</b>-\"Game Events\"</font>";
			_txt.scaleX = _txt.scaleY = DeviceInfo.dpiScaleMultiplier;
			this.addChild(_txt);
			
			_body = new Sprite();
			this.addChild(_body);
			
			_list = new List();
			_list.holder = _body;
			_list.itemsHolder = new Sprite();
			_list.orientation = Orientation.VERTICAL;
			_list.hDirection = Direction.LEFT_TO_RIGHT;
			_list.vDirection = Direction.TOP_TO_BOTTOM;
			_list.space = BTN_SPACE;
			
			// initialize the Game Services and wait for a successful init call before doing anything else
			GameServices.init(false); // set this to 'true' when you are building for production
			GameServices.google.auth.addEventListener(AuthEvents.INIT, onInit);
		}
		
		private function onInvoke(e:InvokeEvent):void
		{
			NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, onInvoke);
		}
		
		private function handleActivate(e:Event):void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
		}
		
		private function handleDeactivate(e:Event):void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
		}
		
		private function handleKeys(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.BACK)
            {
				e.preventDefault();
				NativeApplication.nativeApplication.exit();
            }
		}
		
		private function onResize(e:*=null):void
		{
			if (_txt)
			{
				_txt.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
				
				C.x = 0;
				C.y = _txt.y + _txt.height + 0;
				C.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
				C.height = 500 * (1 / DeviceInfo.dpiScaleMultiplier);
			}
			
			if (_list)
			{
				_numRows = Math.floor(stage.stageWidth / (BTN_WIDTH * DeviceInfo.dpiScaleMultiplier + BTN_SPACE));
				_list.row = _numRows;
				_list.itemArrange();
			}
			
			if (_body)
			{
				_body.y = stage.stageHeight - _body.height;
			}
		}
		
		private function onInit(e:AuthEvents):void
		{
			var result:String;
			
			switch (e.status) // status code indicating whether Game Services can run in your app or not. It can be one of following results:
			{
				case GameServices.SUCCESS:
					
					result = "GameServices.SUCCESS";
					onSuccessfullInit();
					onResize();
					
				break;
				case GameServices.SERVICE_MISSING:
					
					result = "GameServices.SERVICE_MISSING";
					
				break;
				case GameServices.SERVICE_UPDATING:
					
					result = "GameServices.SERVICE_UPDATING";
					
				break;
				case GameServices.SERVICE_VERSION_UPDATE_REQUIRED:
					
					result = "GameServices.SERVICE_VERSION_UPDATE_REQUIRED";
					
				break;
				case GameServices.SERVICE_DISABLED:
					
					result = "GameServices.SERVICE_DISABLED";
					
				break;
				case GameServices.SERVICE_INVALID:
					
					result = "GameServices.SERVICE_INVALID";
					
				break;
				default:
			}
			
			C.log("onInit result = " + result);
		}
		
		private function onSuccessfullInit():void
		{
			// add required listeners for the authentication process of the Game Services ANE
			GameServices.google.auth.addEventListener(AuthEvents.TRYING_SILENT_LOGIN, 		onSilentTry);
			GameServices.google.auth.addEventListener(AuthEvents.LOGIN, 					onLoginSuccess);
			GameServices.google.auth.addEventListener(AuthEvents.ERROR, 					onLoginError);
			
			GameServices.google.gameEvents.addEventListener(EventEvents.LOAD_RESULT, onGameEventsLoadResult);
			
			
			var btn00:MySprite = createBtn("login");
			btn00.addEventListener(MouseEvent.CLICK, login);
			_list.add(btn00);
			
			function login(e:MouseEvent):void
			{
				GameServices.google.auth.login();
			}
			
			// ----------------------------------------------------------------------
			
			var btn01:MySprite = createBtn("increment");
			btn01.addEventListener(MouseEvent.CLICK, increment);
			_list.add(btn01);
			
			function increment(e:MouseEvent):void
			{
				GameServices.google.gameEvents.increment("CgkI5Yi1zsAQEAIQCg", 7);
			}
			
			// ----------------------------------------------------------------------
			
			var btn02:MySprite = createBtn("load");
			btn02.addEventListener(MouseEvent.CLICK, load);
			_list.add(btn02);
			
			function load(e:MouseEvent):void
			{
				GameServices.google.gameEvents.load(true);
			}
			
			// ----------------------------------------------------------------------
			
			var btn03:MySprite = createBtn("load by ID");
			btn03.addEventListener(MouseEvent.CLICK, loadById);
			_list.add(btn03);
			
			function loadById(e:MouseEvent):void
			{
				GameServices.google.gameEvents.loadById("CgkI5Yi1zsAQEAIQCg", true);
			}
			
			// ----------------------------------------------------------------------
			
			
		}
		
		private function onSilentTry(e:AuthEvents):void
		{
			C.log("canDoSilentLogin = ", e.canDoSilentLogin);
			C.log("If silent try is \"false\", it means that you have to login the user yourself using the \"GameServices.login();\" method.");
			C.log("But if it's \"true\", it means that the user had signed in before and he will be signed in again silently shortly. and you have to wait for the \"AuthEvents.LOGIN\" event.");
			
			if (e.canDoSilentLogin)
			{
				C.log("connecting to Game Services, please wait...");
			}
		}
		
		private function onLoginSuccess(e:AuthEvents):void
		{
			C.log("------ onLoginSuccess");
			
			// some information about current logged in user.
			C.log("displayName = " + 				e.player.displayName);
			C.log("id = " + 						e.player.id);
			if (e.player.lastLevelUpTimestamp) // it will be null if the player has not leveled up yet!
			{
				C.log("lastLevelUpTimestamp = " + 	e.player.lastLevelUpTimestamp.toLocaleString());
			}
			C.log("title = " + 						e.player.title);
			C.log("xp = " + 						e.player.xp);
			
			var currLevel:PlayerLevel = e.player.currentLevel;
			C.log("currLevel.levelNumber = " + 		currLevel.levelNumber);
			C.log("currLevel.minXp = " + 			currLevel.minXp);
			C.log("currLevel.maxXp = " + 			currLevel.maxXp);
			
			var nextLevel:PlayerLevel = e.player.nextLevel;
			C.log("nextLevel.levelNumber = " + 		nextLevel.levelNumber);
			C.log("nextLevel.minXp = " + 			nextLevel.minXp);
			C.log("nextLevel.maxXp = " + 			nextLevel.maxXp);
			
			C.log("------");
		}
		
		private function onLoginError(e:AuthEvents):void
		{
			C.log("onLoginError: ", e.msg);
		}
		
// -----------------------------------------------------------------------------------------------------------------
		
		private function onGameEventsLoadResult(e:EventEvents):void
		{
			/**
			
				Possible status codes include:
				GamesStatusCodes.STATUS_OK 							if data was successfully loaded and is up-to-date. 
				GamesStatusCodes.STATUS_NETWORK_ERROR_NO_DATA 		if the device was unable to retrieve any data from the network and has no data cached locally.
				GamesStatusCodes.STATUS_NETWORK_ERROR_STALE_DATA 	if the device was unable to retrieve the latest data from the network, but has some data cached locally.
				GamesStatusCodes.STATUS_CLIENT_RECONNECT_REQUIRED 	if the client needs to reconnect to the service to access this data.
				GamesStatusCodes.STATUS_LICENSE_CHECK_FAILED 		if the game is not licensed to the user.
				GamesStatusCodes.STATUS_INTERNAL_ERROR 				if an unexpected error occurred in the service.
			
			*/
			C.log("--------- onGameEventsLoadResult status = " + e.status);
			
			var currEvent:GameEvent;
			for (var i:int = 0; i < e.gameEvents.length; i++) 
			{
				currEvent = e.gameEvents[i];
				C.log(" --------------------------- onGameEventsLoadResult");
				C.log("description = " + currEvent.description);
				C.log("eventId = " + currEvent.eventId);
				C.log("isVisible = " + currEvent.isVisible);
				C.log("name = " + currEvent.name);
				C.log("value = " + currEvent.value);
				C.log(" ");
			}
			
			C.log("---------");
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		private function createBtn($str:String):MySprite
		{
			var sp:MySprite = new MySprite();
			sp.addEventListener(MouseEvent.MOUSE_OVER,  onOver);
			sp.addEventListener(MouseEvent.MOUSE_OUT,  onOut);
			sp.addEventListener(MouseEvent.CLICK,  onOut);
			sp.bgAlpha = 1;
			sp.bgColor = 0xDFE4FF;
			sp.drawBg();
			sp.width = BTN_WIDTH * DeviceInfo.dpiScaleMultiplier;
			sp.height = BTN_HEIGHT * DeviceInfo.dpiScaleMultiplier;
			
			function onOver(e:MouseEvent):void
			{
				sp.bgAlpha = 1;
				sp.bgColor = 0xFFDB48;
				sp.drawBg();
			}
			
			function onOut(e:MouseEvent):void
			{
				sp.bgAlpha = 1;
				sp.bgColor = 0xDFE4FF;
				sp.drawBg();
			}
			
			var format:TextFormat = new TextFormat("Arimo", 16, 0x666666, null, null, null, null, null, TextFormatAlign.CENTER);
			
			var txt:TextField = new TextField();
			txt.autoSize = TextFieldAutoSize.LEFT;
			txt.antiAliasType = AntiAliasType.ADVANCED;
			txt.mouseEnabled = false;
			txt.multiline = true;
			txt.wordWrap = true;
			txt.scaleX = txt.scaleY = DeviceInfo.dpiScaleMultiplier;
			txt.width = sp.width * (1 / DeviceInfo.dpiScaleMultiplier);
			txt.defaultTextFormat = format;
			txt.text = $str;
			
			txt.y = sp.height - txt.height >> 1;
			sp.addChild(txt);
			
			return sp;
		}
	}
	
}