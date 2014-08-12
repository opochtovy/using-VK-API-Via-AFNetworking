//
//  Friend.h
//  VKontakte
//
//  Created by Oleg Pochtovy on 05.07.14.
//  Copyright (c) 2014 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Friend : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *photo;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *sex;

@property (nonatomic, strong) NSString *photoHash;
@property NSInteger photoServer;

//---! method to initialize friend object from dictionary
- (id)initWithDictionary:(NSDictionary *)dict;
- (id)initUserWithDictionary:(NSDictionary *)dict;
- (id)initUploadPhotoInfoWithDictionary:(NSDictionary *)dict;

//Factory Method
+ (Friend *)friendWithFirstName:(NSString *)firstName lastName:(NSString *)lastName;

@end
