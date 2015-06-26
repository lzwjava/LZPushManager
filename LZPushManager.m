//
//  LZPushManager.m
//
//  Created by lzw on 15/5/25.
//  Copyright (c) 2015年 lzw. All rights reserved.
//

#import "LZPushManager.h"

@implementation LZPushManager

+ (LZPushManager *)manager {
    static LZPushManager *pushManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pushManager = [[LZPushManager alloc] init];
    });
    return pushManager;
}

- (void)registerForRemoteNotification {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert |
                                                UIUserNotificationTypeBadge |
                                                UIUserNotificationTypeSound
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
    }
}

- (void)saveInstallationWithDeviceToken:(NSData *)deviceToken {
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveEventually:^(BOOL succeeded, NSError *error) {
        DLog(@"%@",error);
    }];
}

- (void)saveCurrentUserIdToInstallation {
    if ([AVUser currentUser] == nil ) {
        return;
    }
    AVInstallation *installation = [AVInstallation currentInstallation];
    if ([[installation objectForKey:kAVIMInstallationKeyUserId] isEqualToString:[AVUser currentUser].objectId] == NO) {
        [installation setObject:[AVUser currentUser].objectId forKey:kAVIMInstallationKeyUserId];
        [installation saveEventually:^(BOOL succeeded, NSError *error) {
            DLog(@"%@",error);
        }];
    }
}

- (void)pushMessage:(NSString *)message userIds:(NSArray *)userIds block:(AVBooleanResultBlock)block {
    AVQuery *query = [AVInstallation query];
    [query whereKey:kAVIMInstallationKeyUserId containedIn:userIds];
    AVPush *push = [[AVPush alloc] init];
    [push setQuery:query];
    [push setMessage:message];
    [push sendPushInBackgroundWithBlock:block];
}

- (void)cleanBadge {
    UIApplication *application = [UIApplication sharedApplication];
    NSInteger num = application.applicationIconBadgeNumber;
    if (num != 0) {
        AVInstallation *currentInstallation = [AVInstallation currentInstallation];
        [currentInstallation setBadge:0];
        [currentInstallation saveInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
            DLog(@"%@", error ? error : @"succeed");
        }];
        application.applicationIconBadgeNumber = 0;
    }
    [application cancelAllLocalNotifications];
}

@end
