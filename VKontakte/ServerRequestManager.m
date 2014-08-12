//
//  ServerRequestManager.m
//  TestVKontakte
//
//  Created by Admin on 04.07.14.
//  Copyright (c) 2014 Oleg Pochtovy. All rights reserved.
//

// class to operate with methods of VK.com API server

#import "ServerRequestManager.h"
#import "Friend.h"

@interface ServerRequestManager ()

@end

@implementation ServerRequestManager

@synthesize friends = _friends;
@synthesize accessToken = _accessToken;
@synthesize filePath = _filePath;
@synthesize message = _message;

+ (ServerRequestManager *) requestManager {
    
    //Declare a static instance variable
    static ServerRequestManager *manager = nil;
    
    //Create a token that facilitates only creating this item once.
    static dispatch_once_t onceToken;
    
    //Use Grand Central Dispatch to create a single instance and do any initial setup only once.
    dispatch_once(&onceToken, ^{
        manager = [[ServerRequestManager alloc] init];
    });
    
    //Returns the shared instance variable.
    return manager;
}

// method to get friends list of specified user account (without autherization)
- (void) getFriendsFromServerOnSuccess:(void(^)(NSArray *array)) success
                             onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
#warning INSERT YOUR OWN (OR ANY) USER_ID HERE
                                @"USER_ID",  @"user_id",
                                @"name",       @"order",
                                @"photo_50, city, country, sex",   @"fields",
                                nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:@"https://api.vk.com/method/friends.get"
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSArray *theFriends = [responseObject objectForKey:@"response"];
             NSMutableArray *friendObjects = [[NSMutableArray alloc] init];
             for (NSDictionary *dict in theFriends) {
                 Friend *f = [[Friend alloc] initWithDictionary:dict];
                 [friendObjects addObject:f];
             }
             
             if (success) {
                 success(friendObjects);
             }
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             UIAlertView *getFriendListErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Error Getting Friends List"
                                                                                 message:[error localizedDescription]
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"Ok"
                                                                       otherButtonTitles:nil];
             [getFriendListErrorAlertView show];
         }];
}

// this is a call to get the user’s VK profile information
- (void)getUserInfoOnSuccess:(void (^)(NSArray *))success
                   onFailure:(void (^)(NSError *, NSInteger))failure {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                
                                @"124397841",  @"user_ids",
                                //@"name",       @"order",
                                //@(count),      @"count",
                                //@(offset),     @"offset",
                                @"photo_50, city, country, sex",   @"fields",
                                // @"nom",        @"name_case",
                                
                                nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:@"https://api.vk.com/method/users.get"
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSArray *userInfo = [responseObject objectForKey:@"response"];
             NSMutableArray *userInfoObjects = [[NSMutableArray alloc] init];
             for (NSDictionary *dict in userInfo) {
                 Friend *f = [[Friend alloc] initUserWithDictionary:dict];
                 [userInfoObjects addObject:f];
             }
             
             if (success) {
                 success(userInfoObjects);
             }
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             UIAlertView *getProfileInfoErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Error Getting User's VK Profile Information"
                                                                                   message:[error localizedDescription]
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"Ok"
                                                                         otherButtonTitles:nil];
             [getProfileInfoErrorAlertView show];
         }];
    
}

// method to upload photo on the wall of the authorized user (after autherization)
- (void)uploadPhotoOnTheWallOnSuccess:(void(^)(NSString *string)) success
                                  onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure
{
    // first method of the VK.com api server - thanks to the method photos.getWallUploadServer the application finds the http-address to download the picture on the wall of the current user
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.vk.com/method/photos.getWallUploadServer?access_token=%@", [_accessToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [manager GET:urlString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSDictionary *photoUrlInfo = [responseObject objectForKey:@"response"];
             NSString *photoUrl = [photoUrlInfo objectForKey:@"upload_url"];
             
             // second method of the VK.com api server - the application generates a POST-request to the received address
             
             NSString *filePath = _filePath;
             NSURL *filePathUrl = [NSURL fileURLWithPath:filePath]; // !
             
             AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
             manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"]; // !!
             
             [manager POST:photoUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                 [formData appendPartWithFileURL:filePathUrl name:@"photo" error:nil]; // !!!
             } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
                 NSDictionary *dict = responseObject;
                 Friend *uploadPhotoInfoObject = [[Friend alloc] initUploadPhotoInfoWithDictionary:dict];
                 
                 // third method of the VK.com api server - thanks to the method photos.saveWallPhoto application transmits the data to server (server, photo, hash and optional user_id and group_id) and receives data about the uploaded photo
                 
                 NSString *photoHash = [NSString stringWithFormat:@"%@", uploadPhotoInfoObject.photoHash];
                 NSString *photo = [NSString stringWithFormat:@"%@", uploadPhotoInfoObject.photo];
                 NSString *photoServer = [NSString stringWithFormat:@"%li", (long)uploadPhotoInfoObject.photoServer];
                 
                 NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                             photo,  @"photo",
                                             photoServer,   @"server",
                                             photoHash,   @"hash",
                                             nil];
                 
                 AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                 
                 NSString *urlString = [NSString stringWithFormat:@"https://api.vk.com/method/photos.saveWallPhoto?access_token=%@", [_accessToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                 
                 [manager GET:urlString
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          
                          NSArray *photoInfoArray = [responseObject objectForKey:@"response"];
                          NSDictionary *photoInfo = [photoInfoArray objectAtIndex:0];
                          NSString *photoId = [photoInfo objectForKey:@"id"];
                          
                          // fourth method of the VK.com api server - after successful downloading of the pictures we will post it on the wall, using the method wall.post and specifying a photo id selected in parameter "attachments"
                          
                          NSString *message = _message;
                          
                          NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      photoId,  @"attachments",
                                                      message,  @"message",
                                                      nil];
                          
                          AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                          
                          NSString *urlString = [NSString stringWithFormat:@"https://api.vk.com/method/wall.post?access_token=%@", [_accessToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                          [manager GET:urlString
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   
                                   // we just pop up a dialog here to let the user know when we’re done
                                   UIAlertView *av = [[UIAlertView alloc]
                                                       initWithTitle:@"Sucessfully posted to wall!"
                                                       message:@"Check out your VK account to see!"
                                                       delegate:nil 
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                                   [av show];
                                   
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   UIAlertView *fourthMethodErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Error Posting a Message on the Wall"
                                                                                            message:[error localizedDescription]
                                                                                           delegate:nil
                                                                                  cancelButtonTitle:@"Ok"
                                                                                  otherButtonTitles:nil];
                                   [fourthMethodErrorAlertView show];
                               }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          UIAlertView *thirdMethodErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Error Transmiting the Data to Server"
                                                                                               message:[error localizedDescription]
                                                                                              delegate:nil
                                                                                     cancelButtonTitle:@"Ok"
                                                                                     otherButtonTitles:nil];
                          [thirdMethodErrorAlertView show];
                      }];
                 
                 
             }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       UIAlertView *secondMethodErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Error Generating a POST-request to the Received Address"
                                                                                           message:[error localizedDescription]
                                                                                          delegate:nil
                                                                                 cancelButtonTitle:@"Ok"
                                                                                 otherButtonTitles:nil];
                       [secondMethodErrorAlertView show];
                   }];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             UIAlertView *firstMethodErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Error Finding the HTTP-address to Download the Picture on the Wall of the Current User"
                                                                                  message:[error localizedDescription]
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"Ok"
                                                                        otherButtonTitles:nil];
             [firstMethodErrorAlertView show];
         }];
}

@end
