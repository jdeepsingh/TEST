//
//  DataObjects.h
//  LoginRegisterDemoCode
//
//  Created by user on 2/24/14.
//  Copyright (c) 2014 sameer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LIALinkedInHttpClient.h"

@interface DataObjects : NSObject

@property(strong,nonatomic) LIALinkedInHttpClient * client;
@property(strong,nonatomic) NSString *accessTokenForLinkedIn;
@property (assign, nonatomic) BOOL isProfileViewVisible;
@property(strong,nonatomic) UIStoryboard *storyboard;

+(id)sharedDataObjects;
@end
