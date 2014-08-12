//
//  VKontakteLoginDialog.m
//  VKontakte
//
//  Created by Oleg Pochtovy on 18.07.14.
//  Copyright (c) 2014 Oleg Pochtovy. All rights reserved.
//

// To use this application you have to create a new API in your VK.com account first:

// 1. To get started with your VK.com App, open the VK.com App Console located at http://vk.com/editapp?act=create&site=1
// 2. Sign in if you have a VK.com account, but if not, just create a free VK.com account.
// 3. Choose the Create App option. You’ll be presented with a question:
// 3.1. What type of app do you want to create? - Standalone application
// 4. Then you'll get a verification code to your phone number -> you just need to write it
// 5. On the page "Settings" you’ll see the App key (App ID). You need only App ID to put right here below:

#warning INSERT YOUR App ID HERE

#define APIKEY @"Your App ID"

#define PERMISSIONS @"friends,video,offline,wall,photos"
#define REDIRECTURLSTRING @"https://oauth.vk.com/blank.html"
#define DISPLAY @"page"
#define API_VERSION @"5.23"

#import "VKontakteLoginDialog.h"

@interface VKontakteLoginDialog ()

@end

@implementation VKontakteLoginDialog

@synthesize webView = _webView;
@synthesize apiKey = _apiKey;
@synthesize requestedPermissions = _requestedPermissions;
@synthesize delegate = _delegate;

- (id)initWithAppId:(NSString *)apiKey requestedPermissions:(NSString *)requestedPermissions delegate:(id <VKontakteLoginDialogDelegate>)delegate {
    if (self = [super init]) {
        self.apiKey = apiKey;
        self.requestedPermissions = requestedPermissions;
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc {
    self.webView = nil;
    self.apiKey = nil;
    self.requestedPermissions = nil;
}

- (void)login {
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    
    NSString *vkAuthFormatString = @"https://oauth.vk.com/authorize?client_id=%@&scope=%@&redirect_uri=%@&display=%@&v=%@&response_type=token";
    NSString *urlString = [NSString stringWithFormat:vkAuthFormatString, APIKEY, PERMISSIONS, REDIRECTURLSTRING, DISPLAY, API_VERSION];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

-(void)logout {
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie* cookie in
         [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [cookies deleteCookie:cookie];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *urlString = request.URL.absoluteString;
    
    [self checkForAccessToken:urlString];
    
    return TRUE;
}

-(void)checkForAccessToken:(NSString *)urlString {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"access_token=(.*)&e"
                                  options:0 error:&error];
    if (regex != nil) {
        NSTextCheckingResult *firstMatch =
        [regex firstMatchInString:urlString
                          options:0 range:NSMakeRange(0, [urlString length])];
        if (firstMatch) {
            NSRange accessTokenRange = [firstMatch rangeAtIndex:1];
            NSString *accessToken = [urlString substringWithRange:accessTokenRange];
            accessToken = [accessToken
                           stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [_delegate accessTokenFound:accessToken];
        }
    }
}

- (IBAction)closeTapped:(id)sender {
    [_delegate closeTapped];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self login];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
