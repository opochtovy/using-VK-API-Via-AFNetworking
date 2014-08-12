//
//  ServerRequestManager.h
//  TestVKontakte
//
//  Created by Admin on 04.07.14.
//  Copyright (c) 2014 Oleg Pochtovy. All rights reserved.
//

// class to operate with methods of VK.com API server

#import <Foundation/Foundation.h>
#import "AuthorizationViewController.h"

#import "AFURLRequestSerialization.h"

@interface ServerRequestManager : NSObject
@property (nonatomic, strong) NSArray *friends; // array of instances Friend
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *message;

+ (ServerRequestManager *) requestManager;

- (void) getFriendsFromServerOnSuccess:(void(^)(NSArray *array)) success
                              onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;
- (void)getUserInfoOnSuccess:(void(^)(NSArray *array)) success
                   onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)uploadPhotoOnTheWallOnSuccess:(void(^)(NSString *string)) success
                 onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

@end
