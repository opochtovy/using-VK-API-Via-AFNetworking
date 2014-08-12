//
//  AuthorizationViewController.m
//  VKontakte
//
//  Created by Oleg Pochtovy on 18.07.14.
//  Copyright (c) 2014 Oleg Pochtovy. All rights reserved.
//

#import "AuthorizationViewController.h"
#import "ServerRequestManager.h"
#import "Friend.h"
#import "UIImageView+AFNetworking.h"

@interface AuthorizationViewController ()
@property (strong, nonatomic) NSMutableArray *userInfoArray;
@property (strong, nonatomic) NSMutableArray *uploadPhotoInfoArray;
@end

@implementation AuthorizationViewController

@synthesize loginStatusLabel = _loginStatusLabel;
@synthesize loginButton = _loginButton;
@synthesize logoutButton = _logoutButton;
@synthesize rateButton = _rateButton;

@synthesize textView = _textView;
@synthesize imageView = _imageView;
@synthesize segControl = _segControl;
@synthesize webView = _webView;
@synthesize accessToken = _accessToken;

- (void)dealloc {
    self.loginStatusLabel = nil;
    self.loginButton = nil;
    self.logoutButton = nil;
    self.rateButton = nil;
    
    self.textView = nil;
    self.imageView = nil;
    self.segControl = nil;
    self.webView = nil;
    self.accessToken = nil;
}

- (void)refresh {
    if (_loginState == LoginStateStartup || _loginState == LoginStateLoggedOut) {
        _loginStatusLabel.text = @"Not connected to VK";
        [_loginButton setTitle:@"Login" forState:UIControlStateNormal];
        _loginButton.hidden = NO;
        _logoutButton.hidden = YES;
        _rateButton.hidden = YES;
    } else if (_loginState == LoginStateLoggingIn) {
        _loginStatusLabel.text = @"Connecting to VK...";
        _loginButton.hidden = YES;
        _logoutButton.hidden = YES;
        _rateButton.hidden = YES;
    } else if (_loginState == LoginStateLoggedIn) {
        _loginStatusLabel.text = @"Connected to VK";
        [_loginButton setTitle:@"Logout" forState:UIControlStateNormal];
        _loginButton.hidden = YES;
        _logoutButton.hidden = NO;
        _rateButton.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self refresh];
}

- (IBAction)logoutButtonTapped:(id)sender {
    
    _loginState = LoginStateLoggedOut;
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie* cookie in
         [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [cookies deleteCookie:cookie];
    }
    [self refresh];
    
    _textView.text = [NSString stringWithFormat:@" "];
    [_imageView setImage:[UIImage imageNamed:@"maltese.jpg"]];
}

// we go to a ViewController VKontakteLoginDialog after pressing the LOGIN button
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"authorization"]) {;
        _loginState = LoginStateLoggingIn;
        VKontakteLoginDialog *vk = (VKontakteLoginDialog *)segue.destinationViewController;
        vk.delegate = self;
        [[self navigationController] pushViewController:vk animated:YES];
    }
}

#pragma mark - VKontakteLoginDialog Delegate methods

- (void)accessTokenFound:(NSString *)accessToken {
    _loginState = LoginStateLoggedIn;
    
    self.accessToken = accessToken;
    [self getUserInfo];
    [self dismissViewControllerAnimated:YES completion:nil]; // here we return from ViewController VKontakteLoginDialog to ViewController AuthorizationViewController
    [self refresh];
}

- (void)closeTapped {
    [self dismissViewControllerAnimated:YES completion:nil]; // the key point to close the current VC (return from ViewController VKontakteLoginDialog to ViewController AuthorizationViewController skipping authorization)
    _loginState = LoginStateLoggedOut;
    
    // next we delete all cookies
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie* cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [cookies deleteCookie:cookie];
    }
    
    [self refresh];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userInfoArray = [NSMutableArray array];
    self.uploadPhotoInfoArray = [NSMutableArray array];
    
    _rateButton.hidden = YES;
}

// this is a callback for when we receive the data back from VK.com
- (void)getUserInfo {
    [[ServerRequestManager requestManager] getUserInfoOnSuccess:^(NSArray *array) {
        
       [self.userInfoArray addObjectsFromArray:array];
        
        // first we convert the string we got back from the server into Objective-C objects using the JSON parser.
        NSString *likesString;
        Friend *userInfoObject = [self.userInfoArray objectAtIndex:0];
        NSString *userSex = [NSString stringWithFormat:@"%@", userInfoObject.sex];
        if ([userSex compare:@"1"] == 0) {
            [_imageView setImage:[UIImage imageNamed:@"depp.jpg"]];
            likesString = @"dudes";
        } else if ([userSex compare:@"2"] == 0) {
            [_imageView setImage:[UIImage imageNamed:@"angelina.jpg"]];
            likesString = @"babes";
        } else {
            [_imageView setImage:[UIImage imageNamed:@"maltese.jpg"]];
            likesString = @"puppies";
        }
       
        NSString *username;
        NSString *firstName = [NSString stringWithFormat:@"%@", userInfoObject.firstName];
        NSString *lastName = [NSString stringWithFormat:@"%@", userInfoObject.lastName];
        if (firstName && lastName) {
            username = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        } else {
            username = @"mysterious user";
        }
        
        _textView.text = [NSString stringWithFormat:@"Hi %@!  I noticed you like %@, so tell me if you think this pic is hot or not!", username, likesString];
        
        [self refresh];
    }
                                                      onFailure:^(NSError *error, NSInteger statusCode) {
                                                          UIAlertView *getUserInfoErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Error Getting User Info"
                                                                                                                              message:[error localizedDescription]
                                                                                                                             delegate:nil
                                                                                                                    cancelButtonTitle:@"Ok"
                                                                                                                    otherButtonTitles:nil];
                                                          [getUserInfoErrorAlertView show];
                                                                }];
    
}

- (void)rateTapped:(id)sender {
    ServerRequestManager *aManager = [ServerRequestManager requestManager];
    aManager.accessToken = _accessToken;
    
    NSString *likeString;
    NSString *filePath = nil;
    
    if (_imageView.image == [UIImage imageNamed:@"angelina.jpg"]) {
        filePath = [[NSBundle mainBundle] pathForResource:@"angelina" ofType:@"jpg"];
        likeString = @"babe";
    } else if (_imageView.image == [UIImage imageNamed:@"depp.jpg"]) {
        filePath = [[NSBundle mainBundle] pathForResource:@"depp" ofType:@"jpg"];
        likeString = @"dude";
    } else if (_imageView.image == [UIImage imageNamed:@"maltese.jpg"]) {
        filePath = [[NSBundle mainBundle] pathForResource:@"maltese" ofType:@"jpg"];
        likeString = @"puppy";
    }
    if (filePath == nil) return;
    
    NSString *adjectiveString;
    if (_segControl.selectedSegmentIndex == 0) {
        adjectiveString = @"cute";
    } else {
        adjectiveString = @"ugly";
    }
    
    NSString *message = [NSString stringWithFormat:@"I think this is a %@ %@!", adjectiveString, likeString];
    // next we give the values of filePath and message to class ServerRequestManager before posting the chosed photo on the wall
    aManager.filePath = filePath;
    aManager.message = message;
    
    [aManager uploadPhotoOnTheWallOnSuccess:^(NSString *string) {
        
    }
                       onFailure:^(NSError *error, NSInteger statusCode) {
                           UIAlertView *uploadPhotoErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Error Uploading Photo on the Wall"
                                                                                               message:[error localizedDescription]
                                                                                              delegate:nil
                                                                                     cancelButtonTitle:@"Ok"
                                                                                     otherButtonTitles:nil];
                           [uploadPhotoErrorAlertView show];
                       }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
