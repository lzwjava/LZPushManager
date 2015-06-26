# LZPushManager
LeanCloud Push Utils

```objc
#import <AVOSCloud/AVOSCloud.h>

static NSString *const kAVIMInstallationKeyUserId = @"userId";

@interface LZPushManager : NSObject

+ (LZPushManager *)manager;

// please call in application:didFinishLaunchingWithOptions:launchOptions
- (void)registerForRemoteNotification;

// please call in application:didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
- (void)saveInstallationWithDeviceToken:(NSData *)deviceToken;

// call when go in MainController , that is [AVUser currentUser] is available
- (void)saveCurrentUserIdToInstallation;

// push message
- (void)pushMessage:(NSString *)message userIds:(NSArray *)userIds block:(AVBooleanResultBlock)block;

// please call in applicationDidBecomeActive:application
- (void)cleanBadge;

@end
```