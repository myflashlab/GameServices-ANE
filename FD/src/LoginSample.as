package 
{
	import com.doitflash.consts.Direction;
	import com.doitflash.consts.Orientation;
	import com.doitflash.mobileProject.commonCpuSrc.DeviceInfo;
	import com.doitflash.starling.utils.list.List;
	import com.doitflash.text.modules.MySprite;
	
	import com.luaye.console.C;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import com.myflashlab.air.extensions.gameServices.GameServices;
	import com.myflashlab.air.extensions.gameServices.google.events.AuthEvents;
	
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 2/29/2016 8:34 AM
	 */
	public class LoginSample extends Sprite 
	{
		private const BTN_WIDTH:Number = 150;
		private const BTN_HEIGHT:Number = 60;
		private const BTN_SPACE:Number = 2;
		private var _txt:TextField;
		private var _body:Sprite;
		private var _list:List;
		private var _numRows:int = 1;
		
		public function LoginSample():void 
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
			_txt.htmlText = "<font face='Arimo' color='#333333' size='20'><b>Game Services ANE V"+GameServices.VERSION+"</b>-\"Authentication Sample\"</font>";
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
			GameServices.init();
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
				C.height = 300 * (1 / DeviceInfo.dpiScaleMultiplier);
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
			GameServices.google.auth.addEventListener(AuthEvents.LOGOUT, 					onLogout);
			GameServices.google.auth.addEventListener(AuthEvents.ERROR, 					onLoginError);
			GameServices.google.auth.addEventListener(AuthEvents.CANCELED, 					onCanceled);
			GameServices.google.auth.addEventListener(AuthEvents.SETTING_WINDOW_DISMISSED, 	onSettingWinDismissed);
			
			var btn0:MySprite = createBtn("login");
			btn0.addEventListener(MouseEvent.CLICK, login);
			_list.add(btn0);
			
			function login(e:MouseEvent):void
			{
				GameServices.google.auth.login();
			}
			
			var btn1:MySprite = createBtn("logout");
			btn1.addEventListener(MouseEvent.CLICK, logout);
			_list.add(btn1);
			
			function logout(e:MouseEvent):void
			{
				GameServices.google.auth.logout();
			}
			
			var btn2:MySprite = createBtn("check login state");
			btn2.addEventListener(MouseEvent.CLICK, checkLoginState);
			_list.add(btn2);
			
			function checkLoginState(e:MouseEvent):void
			{
				C.log("isLogin? " + GameServices.google.auth.isLogin);
			}
			
			var btn3:MySprite = createBtn("show Native Window Settings");
			btn3.addEventListener(MouseEvent.CLICK, showNativeWindowSettings);
			_list.add(btn3);
			
			function showNativeWindowSettings(e:MouseEvent):void
			{
				if (GameServices.google.auth.isLogin)
				{
					GameServices.google.auth.showNativeWindowSettings();
				}
				else
				{
					C.log("\n you need to login first!");
				}
			}
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
			C.log("onLoginSuccess");
			
			trace("appId = " + GameServices.google.auth.appId);
			trace("currentAccountName = " + GameServices.google.auth.currentAccountName);
			trace("sdkVariant = " + GameServices.google.auth.sdkVariant);
			
			GameServices.google.auth.registerInvitationListener();
			GameServices.google.auth.registerMatchUpdateListener();
			GameServices.google.auth.registerQuestUpdateListener();
		}
		
		private function onLogout(e:AuthEvents):void
		{
			C.log("onLogout");
		}
		
		private function onLoginError(e:AuthEvents):void
		{
			C.log("onLoginError: ", e.msg);
		}
		
		private function onCanceled(e:AuthEvents):void
		{
			C.log("onCanceled: ", e.msg);
		}
		
		private function onSettingWinDismissed(e:AuthEvents):void
		{
			C.log("onSettingWinDismissed");
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