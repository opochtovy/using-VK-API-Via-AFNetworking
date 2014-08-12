//
//  VKontakteLoginDialog.h
//  VKontakte
//
//  Created by Oleg Pochtovy on 18.07.14.
//  Copyright (c) 2014 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VKontakteLoginDialogDelegate

- (void)accessTokenFound:(NSString *)accessToken;
- (void)closeTapped;

@end

@interface VKontakteLoginDialog : UIViewController <UIWebViewDelegate> {}

@property (retain) IBOutlet UIWebView *webView;
@property (copy) NSString *apiKey;
@property (copy) NSString *requestedPermissions;
@property (nonatomic, weak) id <VKontakteLoginDialogDelegate> delegate;

- (id)initWithAppId:(NSString *)apiKey
requestedPermissions:(NSString *)requestedPermissions
           delegate:(id <VKontakteLoginDialogDelegate>)delegate;
- (IBAction)closeTapped:(id)sender;
- (void)login;
- (void)logout;

-(void)checkForAccessToken:(NSString *)urlString;

@end
