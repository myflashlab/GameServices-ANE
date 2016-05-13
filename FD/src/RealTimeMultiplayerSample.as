package 
{
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
	import com.myflashlab.air.extensions.gameServices.google.events.RealTimeEvents;
	import com.myflashlab.air.extensions.gameServices.google.events.InvitationsEvents;
	import com.myflashlab.air.extensions.gameServices.google.multiplayer.realTime.Room;
	import com.myflashlab.air.extensions.gameServices.google.multiplayer.InvitationUIResult;
	import com.myflashlab.air.extensions.gameServices.google.multiplayer.Participant;
	import com.myflashlab.air.extensions.gameServices.google.multiplayer.realTime.RoomStatusUpdatedData;
	import com.myflashlab.air.extensions.gameServices.google.multiplayer.realTime.MessageSentResult;
	import com.myflashlab.air.extensions.gameServices.google.multiplayer.realTime.Message;
	import com.myflashlab.air.extensions.gameServices.google.multiplayer.invitation.Invitation;
	import com.myflashlab.air.extensions.gameServices.google.player.PlayerLevel;
	
	import com.luaye.console.C;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 2/29/2016 8:34 AM
	 */
	public class RealTimeMultiplayerSample extends Sprite 
	{
		private const BTN_WIDTH:Number = 150;
		private const BTN_HEIGHT:Number = 60;
		private const BTN_SPACE:Number = 2;
		private var _txt:TextField;
		private var _body:Sprite;
		private var _list:List;
		private var _numRows:int = 1;
		
		private var _room:Room;
		private var _otherParticipantId:String;
		
		public function RealTimeMultiplayerSample():void 
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
			_txt.htmlText = "<font face='Arimo' color='#333333' size='20'><b>Game Services ANE V"+GameServices.VERSION+"</b>-\"Real-Time Multiplayer\"</font>";
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
			
			GameServices.google.multiplayerRealTime.addEventListener(RealTimeEvents.ROOM_CREATED, onRoomCreation);
			GameServices.google.multiplayerRealTime.addEventListener(RealTimeEvents.ROOM_LEFT, onRoomLeft);
			GameServices.google.multiplayerRealTime.addEventListener(RealTimeEvents.ROOM_JOINED, onRoomJoined);
			GameServices.google.multiplayerRealTime.addEventListener(RealTimeEvents.ROOM_CONNECTED, onRoomConnected);
			GameServices.google.multiplayerRealTime.addEventListener(RealTimeEvents.WAITING_ROOM_RESULT, onWaitingRoomResult);
			GameServices.google.multiplayerRealTime.addEventListener(RealTimeEvents.INVITING_PLAYERS_RESULT, onInvitingPlayersResult);
			GameServices.google.multiplayerRealTime.addEventListener(RealTimeEvents.ROOM_STATUS_UPDATED, onRoomStatusUpdated);
			
			GameServices.google.invitations.addEventListener(InvitationsEvents.RECEIVED, onInvitationReceived);
			GameServices.google.invitations.addEventListener(InvitationsEvents.REMOVED, onInvitationRemoved);
			GameServices.google.invitations.addEventListener(InvitationsEvents.WINDOW_DISMISSED, onInvitationWindowDismissed);
			GameServices.google.invitations.addEventListener(InvitationsEvents.LOAD_RESULT, onInvitationsLoadResult);
			
			GameServices.google.multiplayerRealTime.addEventListener(RealTimeEvents.MESSAGE_SENT, onMessageSent);
			GameServices.google.multiplayerRealTime.addEventListener(RealTimeEvents.MESSAGE_RECEIVED, onMessageReceived);
			
			
			var btn00:MySprite = createBtn("login");
			btn00.addEventListener(MouseEvent.CLICK, login);
			_list.add(btn00);
			
			function login(e:MouseEvent):void
			{
				GameServices.google.auth.login();
			}
			
			// ----------------------------------------------------------------------
			
			var btn01:MySprite = createBtn("createRoom");
			btn01.addEventListener(MouseEvent.CLICK, createRoom);
			_list.add(btn01);
			
			function createRoom(e:MouseEvent):void
			{
				// listen to RealTimeEvents.ROOM_CREATED for the results
				GameServices.google.multiplayerRealTime.createRoom(1, 2, 0, -1, null);
				
				C.log("wait for ANE to create the room...");
			}
			
			var btn0111:MySprite = createBtn("leaveRoom");
			btn0111.addEventListener(MouseEvent.CLICK, leaveRoom);
			_list.add(btn0111);
			
			function leaveRoom(e:MouseEvent):void
			{
				GameServices.google.multiplayerRealTime.leave(_room);
			}
			
			// ----------------------------------------------------------------------
			
			var btn02:MySprite = createBtn("invite players window");
			btn02.addEventListener(MouseEvent.CLICK, invitePlayersWindow);
			_list.add(btn02);
			
			function invitePlayersWindow(e:MouseEvent):void
			{
				GameServices.google.multiplayerRealTime.showNativeWindowInvitePlayers(1, 3, 0, -1);
			}
			
			// ----------------------------------------------------------------------
			
			var btn03:MySprite = createBtn("invitation inbox window");
			btn03.addEventListener(MouseEvent.CLICK, invitationInboxWindow);
			_list.add(btn03);
			
			function invitationInboxWindow(e:MouseEvent):void
			{
				GameServices.google.invitations.showNativeWindow();
			}
			
			// ----------------------------------------------------------------------
			
			var btn04:MySprite = createBtn("load invitations");
			btn04.addEventListener(MouseEvent.CLICK, loadInvitations);
			_list.add(btn04);
			
			function loadInvitations(e:MouseEvent):void
			{
				GameServices.google.invitations.load(GameServices.SORT_ORDER_SOCIAL_AGGREGATION);
			}
			
			// ----------------------------------------------------------------------
			
			var btn05:MySprite = createBtn("send reliable message");
			btn05.addEventListener(MouseEvent.CLICK, sendReliableMessage);
			_list.add(btn05);
			
			function sendReliableMessage(e:MouseEvent):void
			{
				var token:int = GameServices.google.multiplayerRealTime.sendReliableMessage("my reliable data random number = "+Math.random(), _room.roomId, _otherParticipantId);
				C.log("send message with token: " + token);
			}
			
			// ----------------------------------------------------------------------
			
			var btn06:MySprite = createBtn("send unreliable message");
			btn06.addEventListener(MouseEvent.CLICK, sendUnreliableMessage);
			_list.add(btn06);
			
			function sendUnreliableMessage(e:MouseEvent):void
			{
				var state:int = GameServices.google.multiplayerRealTime.sendUnreliableMessage("unreliable data random number = " + Math.random(), _room.roomId, []);
				
				if (state == GamesStatusCodes.STATUS_OK)
				{
					
				}
				else
				{
					C.log("send unreliable message with state: " + state);
				}
				
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
			C.log("-------------- onLoginSuccess");
			
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
			
			C.log("--------------");
		}
		
		private function onLoginError(e:AuthEvents):void
		{
			C.log("onLoginError: ", e.msg);
		}
		
// -----------------------------------------------------------------------------------------------------------------
		
		private function onRoomCreation(e:RealTimeEvents):void
		{
			if (e.status != GamesStatusCodes.STATUS_OK)
			{
				C.log("room creation failed with status: " + e.status);
			}
			else
			{
				C.log("------------ room creation was successfull");
				var room:Room = e.room;
				
				// save a reference to the room so we can leave it if necessary
				_room = e.room;
				
				C.log("-----------------------------");
				C.log("roomId = " + room.roomId);
				C.log("variant = " + room.variant);
				C.log("max_automatch_players = " + room.max_automatch_players);
				C.log("min_automatch_players = " + room.min_automatch_players);
				C.log("exclusive_bit_mask = " + room.exclusive_bit_mask);
				C.log("autoMatchWaitEstimateSeconds = " + room.autoMatchWaitEstimateSeconds);
				C.log("creationTimestamp = " + room.creationTimestamp.toLocaleString());
				C.log("participantIds = " + room.participantIds);
				C.log(" ");
				
				var currParticipant:Participant;
				for (var i:int = 0; i < room.participantIds.length; i++) 
				{
					currParticipant = room.getParticipant(room.participantIds[i]);
					C.log("--------------------------------- currParticipant");
					C.log("displayName = " + currParticipant.displayName);
					C.log("isConnectedToRoom = " + currParticipant.isConnectedToRoom);
					C.log("participantId = " + currParticipant.participantId);
					C.log("status = " + currParticipant.status);
					C.log(" ");
				}
				
				C.log("------------");
			}
		}
		
		private function onWaitingRoomResult(e:RealTimeEvents):void
		{
			switch (e.waitingRoomResult) 
			{
				case GameServices.WAITING_ROOM_RESULT_OK:
					
					C.log("onWaitingRoomResult = OK");
					
				break;
				case GameServices.WAITING_ROOM_RESULT_DISMISSED:
					
					C.log("onWaitingRoomResult = DISMISSED");
					
				break;
				case GameServices.WAITING_ROOM_RESULT_CANCELED:
					
					C.log("onWaitingRoomResult = CANCELED");
					
				break;
				case GameServices.WAITING_ROOM_RESULT_LEFT:
					
					C.log("onWaitingRoomResult = LEFT");
					
				break;
				case GameServices.WAITING_ROOM_RESULT_INVALID_ROOM:
					
					C.log("onWaitingRoomResult = INVALID_ROOM");
					
					// room is null and you are already out of the room
					
				break;
				default:
			}
		}
		
		private function onRoomLeft(e:RealTimeEvents):void
		{
			C.log("onRoomLeft status = " + e.status);
			C.log("onRoomLeft roomId = " + e.roomId);
		}
		
		private function onRoomJoined(e:RealTimeEvents):void
		{
			if (e.status != GamesStatusCodes.STATUS_OK)
			{
				C.log("Joining room failed with status: " + e.status);
			}
			else
			{
				C.log("----------- Joining room was successfull");
				
				// save a reference to the room so we can leave it if necessary
				_room = e.room;
				
				C.log("-----------------------------");
				C.log("roomId = " + _room.roomId);
				C.log("variant = " + _room.variant);
				C.log("max_automatch_players = " + _room.max_automatch_players);
				C.log("min_automatch_players = " + _room.min_automatch_players);
				C.log("exclusive_bit_mask = " + _room.exclusive_bit_mask);
				C.log("autoMatchWaitEstimateSeconds = " + _room.autoMatchWaitEstimateSeconds);
				C.log("creationTimestamp = " + _room.creationTimestamp.toLocaleString());
				C.log("participantIds = " + _room.participantIds);
				C.log(" ");
				
				C.log("-----------");
			}
		}
		
		private function onRoomConnected(e:RealTimeEvents):void
		{
			if (e.status != GamesStatusCodes.STATUS_OK)
			{
				C.log("Connecting to the room failed with status: " + e.status);
			}
			else
			{
				C.log("Connecting to the room was successfull");
				
				// save a reference to the room so we can leave it if necessary
				_room = e.room;
				
				C.log("-----------------------------");
				C.log("roomId = " + _room.roomId);
				C.log("variant = " + _room.variant);
				C.log("max_automatch_players = " + _room.max_automatch_players);
				C.log("min_automatch_players = " + _room.min_automatch_players);
				C.log("exclusive_bit_mask = " + _room.exclusive_bit_mask);
				C.log("autoMatchWaitEstimateSeconds = " + _room.autoMatchWaitEstimateSeconds);
				C.log("creationTimestamp = " + _room.creationTimestamp.toLocaleString());
				C.log("participantIds = " + _room.participantIds);
				C.log(" ");
				
				var currParticipant:Participant;
				for (var i:int = 0; i < _room.participantIds.length; i++) 
				{
					currParticipant = _room.getParticipant(_room.participantIds[i]);
					C.log("--------------------------------- currParticipant");
					C.log("displayName = " + currParticipant.displayName);
					C.log("isConnectedToRoom = " + currParticipant.isConnectedToRoom);
					C.log("participantId = " + currParticipant.participantId);
					C.log("status = " + currParticipant.status);
					C.log(" ");
				}
				
				C.log("-----------");
			}
		}
		
		private function onInvitingPlayersResult(e:RealTimeEvents):void
		{
			if (e.invitationResult == GameServices.INVITING_PLAYERS_RESULT_OK)
			{
				C.log("invitation window OK");
			}
			else if (e.invitationResult == GameServices.INVITING_PLAYERS_RESULT_CANCELED)
			{
				C.log("invitation window canceled");	
			}
		}
		
		private function onRoomStatusUpdated(e:RealTimeEvents):void
		{
			var data:RoomStatusUpdatedData = e.roomUpdateData;
			
			C.log("------------------------------- onRoomStatusUpdated");
			C.log("event = " + data.event);
			C.log("participantIds = " + data.participantIds);
			
			if (data.room)
			{
				C.log("\t ----------------------------- onRoomStatusUpdated > ROOM");
				C.log("\t roomId = " + data.room.roomId);
				C.log("\t variant = " + data.room.variant);
				C.log("\t max_automatch_players = " + data.room.max_automatch_players);
				C.log("\t min_automatch_players = " + data.room.min_automatch_players);
				C.log("\t exclusive_bit_mask = " + data.room.exclusive_bit_mask);
				C.log("\t autoMatchWaitEstimateSeconds = " + data.room.autoMatchWaitEstimateSeconds);
				C.log("\t creationTimestamp = " + data.room.creationTimestamp.toLocaleString());
				C.log("\t participantIds = " + data.room.participantIds);
				C.log(" ");
			}
			C.log("----------------");
			
			if (data.event == RoomStatusUpdatedData.EVENT_ON_PEER_JOINED)
			{
				_otherParticipantId = data.participantIds[0];
			}
		}
		
		private function onInvitationReceived(e:InvitationsEvents):void
		{
			var invitation:Invitation = e.invitation;
			
			C.log("----------------------- InvitationsEvents.RECEIVED")
			C.log("creationTimestamp = " + invitation.creationTimestamp.toLocaleString());
			C.log("invitationId = " + invitation.invitationId);
			C.log("invitationType = " + invitation.invitationType);
			C.log("inviter.displayName = " + invitation.inviter.displayName);
			C.log("inviter.participantId = " + invitation.inviter.participantId);
			C.log("inviter.isConnectedToRoom = " + invitation.inviter.isConnectedToRoom);
			C.log("inviter.status = " + invitation.inviter.status);
			C.log(" ");
			C.log("-----------");
			
			// when you get the invitation id, you can join the game like below:
			C.log("we just received an invitation! so the player can now click a button and join the game...");
			GameServices.google.multiplayerRealTime.joinRoom(invitation.invitationId);
		}
		
		private function onInvitationRemoved(e:InvitationsEvents):void
		{
			C.log("on Invitation Removed > id = " + e.invitationId);
		}
		
		private function onInvitationWindowDismissed(e:InvitationsEvents):void
		{
			C.log("on Invitation Window Dismissed");
		}
		
		private function onInvitationsLoadResult(e:InvitationsEvents):void
		{
			// use the GamesStatusCodes class to see what each status code means
			C.log("-------------- on Invitations Load Result status = " + e.status);
			C.log("on Invitations Load Result data.length = ", e.invitations.length);
			
			var invitation:Invitation;
			for (var i:int = 0; i < e.invitations.length; i++) 
			{
				invitation = e.invitations[i];
				C.log("\t creationTimestamp =", invitation.creationTimestamp.toLocaleString());
				C.log("\t invitationId =", invitation.invitationId);
				C.log("\t invitationType =", invitation.invitationType);
				C.log("\t inviter.displayName =", invitation.inviter.displayName);
				C.log("\t inviter.isConnectedToRoom =", invitation.inviter.isConnectedToRoom);
				C.log("\t inviter.participantId =", invitation.inviter.participantId);
				C.log("\t inviter.status =", invitation.inviter.status);
				C.log(" ");
				C.log("--------------");
			}
		}
		
		private function onMessageSent(e:RealTimeEvents):void
		{
			var result:MessageSentResult = e.messageSentResult;
			
			C.log("onMessageSent");
			C.log("----------- onMessageSent ------------------");
			C.log("status = " + result.status);
			C.log("tokenId = " + result.tokenId);
			C.log("recipientParticipantId = " + result.recipientParticipantId);
			C.log(" ");
		}
		
		private function onMessageReceived(e:RealTimeEvents):void
		{
			var msg:Message = e.message;
			
			C.log("onMessageReceived");
			C.log("----------- onMessageReceived ------------------");
			C.log("isReliable = " + msg.isReliable);
			C.log("senderParticipantId = " + msg.senderParticipantId);
			C.log("messageData = " + msg.messageData);
			C.log(" ");
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