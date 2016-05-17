# Google Game Services ANE V1.0.0 for Android+iOS
The Google Game Services Air native extension is supported on Android and iOS with 100% identical ActionScript API with a super easy interface so you can focus on your game logic and easily have access to all the cool features of this great library in your games.

**Main Features:**
* Achievements
* Leaderboards
* Real-time Multiplayer
* Game Events and Quests
* Cloud Game Saving (Game Snapshots)
* Google Games Services REST API

# asdoc
[find the latest asdoc for this ANE here.](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/gameServices/package-detail.html)

**NOTICE**: the demo ANE works only after you hit the "OK" button in the dialog which opens. in your tests make sure that you are NOT calling other ANE methods prior to hitting the "OK" button.
[Download the ANE](https://github.com/myflashlab/GameServices-ANE/tree/master/FD/lib)

# Air Usage
```actionscript
import com.myflashlab.air.extensions.gameServices.GameServices;
import com.myflashlab.air.extensions.gameServices.google.events.AuthEvents;
import com.myflashlab.air.extensions.gameServices.google.player.PlayerLevel;

// initialize the Game Services and wait for a successful init call before doing anything else
GameServices.init(false); // set this to 'true' when you are building for production
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
	
	// some information about current logged in user.
	trace("displayName = " + 				e.player.displayName);
	trace("id = " + 						e.player.id);
	if (e.player.lastLevelUpTimestamp) // it will be null if the player has not leveled up yet!
	{
		trace("lastLevelUpTimestamp = " + 	e.player.lastLevelUpTimestamp.toLocaleString());
	}
	trace("title = " + 						e.player.title);
	trace("xp = " + 						e.player.xp);
	
	var currLevel:PlayerLevel = e.player.currentLevel;
	trace("currLevel.levelNumber = " + 		currLevel.levelNumber);
	trace("currLevel.minXp = " + 			currLevel.minXp);
	trace("currLevel.maxXp = " + 			currLevel.maxXp);
	
	var nextLevel:PlayerLevel = e.player.nextLevel;
	trace("nextLevel.levelNumber = " + 		nextLevel.levelNumber);
	trace("nextLevel.minXp = " + 			nextLevel.minXp);
	trace("nextLevel.maxXp = " + 			nextLevel.maxXp);
	
	/*
		When you are logged in, you can use all the other APIs.
		Please refer to the tutorials section to know how you should 
		use other features of the Game Services ANE.
	*/
}

private function onLogout(e:AuthEvents):void
{
	trace("onLogout");
}

private function onLoginError(e:AuthEvents):void
{
	trace("onLoginError: ", e.msg);
}

private function onCanceled(e:AuthEvents):void
{
	trace("onCanceled: ", e.msg);
}

private function onSettingWinDismissed(e:AuthEvents):void
{
	trace("onSettingWinDismissed");
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
	
	<!-- required if you wish to receive the player email address or access token ID -->
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
		
		<!-- application ID which identifies your game settings in the Google Game Services console (NOTE: leave the initial '\ ' as it is) -->
		<meta-data android:name="com.google.android.gms.games.APP_ID" android:value="\ 000000000000" />
		<meta-data android:name="com.google.android.gms.version" android:value="@integer/google_play_services_version" />
		
	</application>
</manifest>
<!--
FOR iOS:
-->
	<InfoAdditions>
		<!--iOS 7.0 or higher can support this ANE-->
		<key>MinimumOSVersion</key>
		<string>7.0</string>
		
		<!- application ID which identifies your game settings in the Google Game Services console -->
		<key>com.google.android.gms.games.APP_ID</key>
		<string>000000000000-tu362slbd0dhh89e5906qbpuk6pracs3.apps.googleusercontent.com</string>
		 
		<key>CFBundleURLTypes</key>
		<array>
			<dict>
				<key>CFBundleTypeRole</key>
				<string>Editor</string>
				<key>CFBundleURLName</key>
				<string>myflashlabs_GPG_ane_clientID</string>
				<key>CFBundleURLSchemes</key>
				<array>
					<string>com.googleusercontent.apps.000000000000-tu362slbd0dhh89e5906qbpuk6pracs3</string>
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
		
		<key>UIBackgroundModes</key>
		<array>
			<string>fetch</string>
			<string>remote-notification</string>
		</array>
	</InfoAdditions>
	
	<requestedDisplayResolution>high</requestedDisplayResolution>
	
	<Entitlements>
		<key>keychain-access-groups</key>
		<array>
			<string>XXXXXXXXX.*</string>		
		</array>
		
		<key>get-task-allow</key>
		<!-- set to 'false' for adHoc or production builds -->
		<true/>
		
		<key>application-identifier</key>
		<string>XXXXXXXXX.com.doitflash.games.ex.realtime</string>
		
		<key>com.apple.developer.team-identifier</key>
		<string>XXXXXXXXX</string>
		
		<key>aps-environment</key>
		<!-- set to 'production' for adHoc or production builds -->
		<string>development</string> 
	<Entitlements>
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
	
	<!-- And finally embed the main gameServices ANE -->
    <extensionID>com.myflashlab.air.extensions.gameServices</extensionID>
	
  </extensions>
-->
```

# Requirements 
1. Android API 15 or higher
2. iOS SDK 7.0 or higher
3. Air SDK 20 or higher
4. This ANE is dependent on **androidSupport.ane**, **overrideAir.ane**, **googlePlayServices_base.ane**, **googlePlayServices_basement.ane**, **googlePlayServices_drive.ane**, **googlePlayServices_games.ane** and **googlePlayServices_plus.ane** You need to add these ANEs to your project too. [Download them from here:](https://github.com/myflashlab/common-dependencies-ANE)
5. To compile on iOS, you will need to add the GPG frameworks to your Air SDK.
  - download GPG_FRAMEWORKS.zip package from our github and extract them on your computer.
  - you will see some xxxxxx.framework files. just copy them as they are and go to your AdobeAir SDK.
  - when in your Air SDK, go to "\lib\aot\stub". here you will find all the iOS frameworks provided by Air SDK by default.
  - paste the GPG frameworks you had downloaded into this folder and you are ready to build your project.
6. On the iOS side, you also need to make sure you have included the resources at the top of you package. *next to the main .swf of your project*. [Check here for the resources](https://github.com/myflashlab/GameServices-ANE/tree/master/FD/bin) **GoogleSignIn.bundle** and **gpg.bundle**
7. When compiling on Android, make sure you are always compiling in debug or captive mode. shared mode won't work because in the extension we have overwritten some Adobe classes for the extension to work properly.

# Commercial Version
http://www.myflashlabs.com/product/game-services-air-native-extension/

![Game Services ANE](http://www.myflashlabs.com/wp-content/uploads/2016/04/product_adobe-air-ane-extension-game-services-1-595x738.jpg)

# Tutorials
[How to embed ANEs into **FlashBuilder**, **FlashCC** and **FlashDevelop**](https://www.youtube.com/watch?v=Oubsb_3F3ec&list=PL_mmSjScdnxnSDTMYb1iDX4LemhIJrt1O)  
[READ THE WIKI SECTION TO LEARN HOW TO SETUP THE GAME SERVICES AND ALSO TO KNOW HOW THINGS WORK WITH THIS ANE](https://github.com/myflashlab/GameServices-ANE/wiki)

# Changelog
*May 14, 2016 - V1.0.0*
* beginning of the journey!

*Apr 17, 2016 - V0.0.1*
* (beta tests)Game Services works on Android only at the moment
