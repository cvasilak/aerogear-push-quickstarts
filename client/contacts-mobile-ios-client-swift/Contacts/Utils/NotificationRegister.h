/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#ifndef Contacts_Notification_h
#define Contacts_Notification_h

#import <UIKit/UIKit.h>

/* 
 * This is workaround for avoiding runtime exception when callind new API
 * not available in iOS 7 from Swift. In particular using #ifdef macros it will
 * avoid 'dyld: Symbol not found: _OBJC_CLASS_$_UIUserNotificationSettings' exception.
 * That is because the Obj-C compiler  properly weak-links symbols that are only available
 * on later versions than the deployment target. In contrast Swift (at this stage) complains
 * and crashes
 */
@interface NotificationRegister: NSObject

+(void)registerForRemoteNofications:(UIApplication *)application;

@end

#endif
