//
//  Friend.m
//  VKontakte
//
//  Created by Oleg Pochtovy on 05.07.14.
//  Copyright (c) 2014 Oleg Pochtovy. All rights reserved.
//

#import "Friend.h"

@implementation Friend

#pragma mark - Factory Method
+ (Friend *)friendWithFirstName:(NSString *)firstName lastName:(NSString *)lastName
{
    Friend *newFriend = [[self alloc] init];
    
    newFriend.firstName = firstName;
    newFriend.lastName = lastName;
    
    //Return the fully instantiated Friend object.
    return newFriend;
}

//---! method to initialize friend object from dictionary
- (id)initWithDictionary:(NSDictionary *)dict {
    
	if (self = [super init]) {
		
        self.userId = dict[@"user_id"]; // it's just different way to call "objectForKey"
        self.firstName = dict[@"first_name"];
        self.lastName = dict[@"last_name"];
        self.photo = dict[@"photo_50"];
        self.city = dict[@"city"];
        self.country = dict[@"country"];
        self.sex = dict[@"sex"];
		
	}
	
	return self;
}

- (id)initUserWithDictionary:(NSDictionary *)dict {
    
	if (self = [super init]) {
		
        self.userId = dict[@"uid"]; // it's just different way to call "objectForKey"
        self.firstName = dict[@"first_name"];
        self.lastName = dict[@"last_name"];
        self.photo = dict[@"photo_50"];
        self.city = dict[@"city"];
        self.country = dict[@"country"];
        self.sex = dict[@"sex"];
		
	}
	
	return self;
}

- (id)initUploadPhotoInfoWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
		
        self.photoHash = dict[@"hash"];
        self.photo = dict[@"photo"];
        self.photoServer = [dict[@"server"] integerValue];
		
	}
	
	return self;
}

@end
