Game Services Adobe Air Native Extension

*Aug 3, 2019 - V4.3.1*
* Added Android 64-bit support
* Removed **.os** property, use ```OverrideAir.os``` instead.

*Jun 17, 2019 - V4.3.0*
* Updated Games SDK and dependencies to be synced with GoogleSignIn ANE V2.0.0 make sure you are updating the dependency ANEs to the latest available versions.
* Removed deprecated properties *highSpenderProbability*, *churnProbability*, *spendProbability* and *totalSpendNext28Days* from **PlayerStats** class.
* Added property *snapshotId* to the **SnapshotMetadata** class.

*Apr 5, 2019 - V4.2.0*
* Added property ```Games.realtime.showWaitingRoomAutomatically```. You may set this property to false to hide the waiting room when players are connecting to the room.

*Nov 18, 2018 - V4.1.1*
* Works with OverrideAir ANE V5.6.1 or higher
* Works with ANELAB V1.1.26 or higher

*Sep 20, 2018 - V4.1.0*
* Updated to dependencies V15.0.1
* ANE still depends on GoogleSignIn ANE but notice that we have updated GoogleSignin ANE also to V1.3.0 and have removed AndroidSupport ANE and have replaced it with smaller ones.

*Mar 22, 2018 - V4.0.0*
* Updated to the latest SDK version. iOS support is removed by Google and AS3 usage has changed dramatically.
* Google Authentication now happens in the [GoogleSignin ANE](https://github.com/myflashlab/GoogleSignIn-ANE). You need to have that ANE installed first.
* [asDoc](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/googleGames/package-detail.html) packages have been changed.
* Start reading the [WIKI pages](https://github.com/myflashlab/GameServices-ANE/wiki) to get familiar with the new API.

*Dec 15, 2017 - V2.2.3*
* Optimized for [ANE-LAB software](https://github.com/myflashlab/ANE-LAB).

*Apr 26, 2017 - V2.2.1*
* Fixed issue https://github.com/myflashlab/GameServices-ANE/issues/14

*Mar 18, 2017 - V2.2.0*
* min iOS version to support this ANE is 8.0
* Updated SDK to 10.2.0 
* ```overrideAir.ane``` is now also necessary if you are building for iOS only
* Known issue, [conflict between gameServices and GoogleSignin](https://github.com/playgameservices/ios-basic-samples/issues/15)

*Nov 09, 2016 - V2.1.0*
* Optimized for Android manual permissions if you are targeting AIR SDK 24+

*Jun 05, 2016 - V2.0.0*
* Updated to Game Services V9.0.1
* All of the depenency ANEs must be updated to Google Play Services V9.0.1. (just replacing the new ANEs with your current ones is enough)
* New dpenendancy .ane is introduced. *googlePlayServices_authBase.ane* you should add this .ane to your project also. ```<extensionID>com.myflashlab.air.extensions.dependency.googlePlayServices.auth.base</extensionID>```


*May 14, 2016 - V1.0.0*
* beginning of the journey!