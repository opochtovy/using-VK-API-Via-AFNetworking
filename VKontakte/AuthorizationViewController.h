//
//  AuthorizationViewController.h
//  VKontakte
//
//  Created by Oleg Pochtovy on 18.07.14.
//  Copyright (c) 2014 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKontakteLoginDialog.h"

typedef enum {
    LoginStateStartup,
    LoginStateLoggingIn,
    LoginStateLoggedIn,
    LoginStateLoggedOut
} LoginState;

@interface AuthorizationViewController : UIViewController <VKontakteLoginDialogDelegate> {
    LoginState _loginState;
}

@property (retain) IBOutlet UILabel *loginStatusLabel;
@property (retain) IBOutlet UIButton *loginButton;
@property (retain) IBOutlet UIButton *logoutButton;

@property (retain) IBOutlet UIButton *rateButton;
@property (retain) IBOutlet UITextView *textView;
@property (retain) IBOutlet UIImageView *imageView;
@property (retain) IBOutlet UISegmentedControl *segControl;
@property (retain) IBOutlet UIWebView *webView;
@property (copy) NSString *accessToken;

- (IBAction)logoutButtonTapped:(id)sender;

- (IBAction)rateTapped:(id)sender;

@end
