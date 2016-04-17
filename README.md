# Game Services ANE V0.0.1 (beta) for Android+iOS
Game Services Air native extension is supported on Android and iOS with 100% identical ActionScript API with a super easy interface so you can focus on your game logic and easily have access to all the cool features of this great library in your games.

**Current beta version works on Android only**

**Main Features:**
* Achievements
* Leaderboards
* Real-time Multiplayer
* Turn-based Multiplayer
* Game Events and Quests
* Saved Games (Game Snapshots)

# Demo .apk
you may like to see the ANE in action? [Download demo .apk](https://github.com/myflashlab/GameServices-ANE/tree/master/FD/dist)

**NOTICE**: the demo ANE works only after you hit the "OK" button in the dialog which opens. in your tests make sure that you are NOT calling other ANE methods prior to hitting the "OK" button.
[Download the ANE](https://github.com/myflashlab/GameServices-ANE/tree/master/FD/lib)

# Air Usage
```actionscript
import com.myflashlab.air.extensions.gameServices.GameServices;
import com.myflashlab.air.extensions.gameServices.google.events.AuthEvents;

// initialize the Game Services and wait for a successful init call before doing anything else
GameServices.init();
GameServices.google.auth.addEventListener(AuthEvents.INIT, onInit);

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
	
	trace("onInit result = " + result);
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
	
	// Do you stuff here after you are sure that Game Services is supported and can be used in your app.
	
}

private function onSilentTry(e:AuthEvents):void
{
	trace("canDoSilentLogin = ", e.canDoSilentLogin);
	trace("If silent try is \"false\", it means that you have to login the user yourself using the \"GameServices.login();\" method.");
	trace("But if it's \"true\", it means that the user had signed in before and he will be signed in again silently shortly. and you have to wait for the \"AuthEvents.LOGIN\" event.");
	
	if (e.canDoSilentLogin)
	{
		trace("connecting to Game Services, please wait...");
	}
	else
	{
		// You should always let users click the "login" button themselves! This is just a sample though and we are doing it programmatically
		GameServices.google.auth.login();
	}
}

private function onLoginSuccess(e:AuthEvents):void
{
	trace("onLoginSuccess");

	trace("appId = " + GameServices.google.auth.appId);
	trace("currentAccountName = " + GameServices.google.auth.currentAccountName);
	trace("sdkVariant = " + GameServices.google.auth.sdkVariant);
	
	GameServices.google.auth.registerInvitationListener();
	GameServices.google.auth.registerMatchUpdateListener();
	GameServices.google.auth.registerQuestUpdateListener();
	
	/*
		When you are logged in, you can use all the other APIs.
		Please refer to the tutorials section to know how you should 
		use other features of the Game Services ANE.
	*/
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
```

# Air .xml manifest
```xml
<!--
FOR ANDROID:
-->
<manifest android:installLocation="auto">
	
	<uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
	<uses-permission android:name="android.permission.GET_ACCOUNTS" />
	
	<application>
		
		<activity>
			<intent-filter>
				<action android:name="android.intent.action.MAIN" />
				<category android:name="android.intent.category.LAUNCHER" />
			</intent-filter>
			<intent-filter>
				<action android:name="android.intent.action.VIEW" />
				<category android:name="android.intent.category.BROWSABLE" />
				<category android:name="android.intent.category.DEFAULT" />
			</intent-filter>
		</activity>
		
		<meta-data android:name="com.google.android.gms.games.APP_ID" android:value="\ GOOGLE_GAMES_API_KEY_GOES_HERE" />
		<meta-data android:name="com.google.android.gms.version" android:value="@integer/google_play_services_version" />
		
	</application>
</manifest>
<!--
FOR iOS:
-->
		<!--iOS 7.0 or higher can support this ANE-->
		<key>MinimumOSVersion</key>
		<string>7.0</string>
		
		<key>com.google.android.gms.games.APP_ID</key>
		<string>567100130405-tu362slbd0dhh89e5906qbpuk6pracs3.apps.googleusercontent.com</string>
		 
		<key>CFBundleURLTypes</key>
		<array>
			<dict>
				<key>CFBundleTypeRole</key>
				<string>Editor</string>
				<key>CFBundleURLName</key>
				<string>myflashlabs_GPG_ane_clientID</string>
				<key>CFBundleURLSchemes</key>
				<array>
					<string>com.googleusercontent.apps.567100130405-tu362slbd0dhh89e5906qbpuk6pracs3</string>
				</array>
			</dict>
			<dict>
				<key>CFBundleTypeRole</key>
				<string>Editor</string>
				<key>CFBundleURLName</key>
				<string>com.doitflash.games.ex.realtime</string>
				<key>CFBundleURLSchemes</key>
				<array>
					<string>com.doitflash.games.ex.realtime</string>
				</array>
			</dict>
		</array>
			
		<key>UIStatusBarStyle</key>
		<string>UIStatusBarStyleBlackOpaque</string>
			
		<key>UIRequiresPersistentWiFi</key>
		<string>NO</string>
			
		<key>UIDeviceFamily</key>
		<array>
			<string>1</string>
			<string>2</string>
		</array>
<!--
Embedding the ANE:
-->
  <extensions>
	
	<!-- download the dependency ANEs from https://github.com/myflashlab/common-dependencies-ANE -->
	<extensionID>com.myflashlab.air.extensions.dependency.overrideAir</extensionID>
	<extensionID>com.myflashlab.air.extensions.dependency.androidSupport</extensionID>
    <extensionID>com.myflashlab.air.extensions.dependency.googlePlayServices.games</extensionID>
    <extensionID>com.myflashlab.air.extensions.dependency.googlePlayServices.drive</extensionID>
    <extensionID>com.myflashlab.air.extensions.dependency.googlePlayServices.plus</extensionID>
    <extensionID>com.myflashlab.air.extensions.dependency.googlePlayServices.base</extensionID>
    <extensionID>com.myflashlab.air.extensions.dependency.googlePlayServices.basement</extensionID>
	
    <extensionID>com.myflashlab.air.extensions.gameServices</extensionID>
	
  </extensions>
-->
```

# Requirements 
1. Android API 15 or higher
2. iOS SDK 7.0 or higher
3. Air SDK 19 or higher

# Commercial Version
http://www.myflashlabs.com/product/game-services-air-native-extension/

![Game Services ANE](http://www.myflashlabs.com/wp-content/uploads/2016/04/product_adobe-air-ane-extension-game-services-595x738.jpg)

# Tutorials
[How to embed ANEs into **FlashBuilder**, **FlashCC** and **FlashDevelop**](https://www.youtube.com/watch?v=Oubsb_3F3ec&list=PL_mmSjScdnxnSDTMYb1iDX4LemhIJrt1O)  
How to manage user authentication - coming soon  
How game achievements work - coming soon  
How leaderboards work - coming soon  
How to develop a real-time multiplayer game with Game Services - coming soon  
How to develop a turn-based multiplayer game with Game Services - coming soon  
How to save/load game data - coming soon  
How to manage game quests/events with Game Services - coming soon  

# Changelog
*Apr 17, 2016 - V0.0.1*
* (beta tests)Game Services works on Android only at the moment
