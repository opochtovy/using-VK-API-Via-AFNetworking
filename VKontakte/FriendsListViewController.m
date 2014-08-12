//
//  FriendsListViewController.m
//  VKontakte
//
//  Created by Oleg Pochtovy on 07.08.14.
//  Copyright (c) 2014 Oleg Pochtovy. All rights reserved.
//

// Class to view list of friends in social network VKontakte

#import "FriendsListViewController.h"
#import "ServerRequestManager.h"
#import "Friend.h"
#import "UIImageView+AFNetworking.h"

@interface FriendsListViewController ()

@property (strong, nonatomic) NSMutableArray *friendsArray; // array of objects (instances) Friend

@end

@implementation FriendsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.friendsArray = [NSMutableArray array];
    
    self.navigationController.toolbarHidden = YES;
    self.title = @"MY FRIENDS";
    
    [self getFriends]; // illustrates AFHTTPRequestOperationManager which uses NSURLConnection
}

- (void)getFriends {
    [[ServerRequestManager requestManager] getFriendsFromServerOnSuccess:^(NSArray *array) {
                                                                    [self.friendsArray addObjectsFromArray:array];
                                                                    [self.tableView reloadData];
                                                                }
                                                                onFailure:^(NSError *error, NSInteger statusCode) {
                                                                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Friends List From Your User Account"
                                                                                                                             message:[error localizedDescription]
                                                                                                                            delegate:nil
                                                                                                                   cancelButtonTitle:@"Ok"
                                                                                                                   otherButtonTitles:nil];
                                                                    [errorAlertView show];
                                                                }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friendsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"myCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    
    Friend *friendAtIndex = [self.friendsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", friendAtIndex.firstName, friendAtIndex.lastName];
    
    NSString *imageUrl = [NSString stringWithFormat:@"%@", friendAtIndex.photo];
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
    
    __weak UITableViewCell *weakCell = cell;
    
    [cell.imageView setImageWithURLRequest:request
                          placeholderImage:placeholderImage
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       // Both the success and failure blocks are optional, but if you do provide a success block, you must explicitly set the image property on the image view (or else it won’t be set). If you don’t provide a success block, the image will automatically be set for you.
                                       // When the cell is first created, its image view will display the placeholder image until the real image has finished downloading.
                                       weakCell.imageView.image = image;
                                       [weakCell setNeedsLayout];
                                       
                                   }
                                   failure:nil];
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
