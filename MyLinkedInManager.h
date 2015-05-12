//
//  MyLinkedInManager.h
//  Netceeds
//
//  Created by kuldeep on 4/16/15.
//  Copyright (c) 2015 kuldeep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LIALinkedInApplication.h"
#import "LIALinkedInHttpClient.h"


@interface MyLinkedInManager : NSObject

@property(strong,nonatomic)void (^loginCompleted)(id complete);

+ (id)sharedManager;


-(void)login;

- (LIALinkedInHttpClient *)client ;

-(void)sharetoLinkedIn:(NSString *)title desc:(NSString *)description path:(NSString *)submitted_url imagePath:(NSString *)submitted_image_url postString:(NSString *)comment;
@end
