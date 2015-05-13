//
//  MyLinkedInManager.m
//  Netceeds
//
//  Created by kuldeep on 4/16/15.
//  Copyright (c) 2015 kuldeep. All rights reserved.
//

#import "MyLinkedInManager.h"
#import "DataObjects.h"
#define REDIRECTURL @"Paste here REDIRECTURL"
#define CLIENTID @"Paste here CLIENTID"
#define CLIENTSECRET @"Paste here CLIENTSECRET"

@implementation MyLinkedInManager

static MyLinkedInManager *myLinkedInManager = nil;

+ (id)sharedManager{
    
    if (!myLinkedInManager) {
        
        myLinkedInManager = [[MyLinkedInManager alloc]init];
    }
    return myLinkedInManager;
}

-(void)login
{
    [self.client getAuthorizationCode:^(NSString *code) {
        [self.client getAccessToken:code success:^(NSDictionary *accessTokenData) {
           
            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
            NSLog(@"accessToken ========== %@",accessToken);
            self.loginCompleted(accessToken);
            [[DataObjects sharedDataObjects] setAccessTokenForLinkedIn:accessToken];
        }                   failure:^(NSError *error) {
           
            NSLog(@"Quering accessToken failed %@", error);
            UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"LogIn Failed!!" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
            return;
        }];
    }                      cancel:^{
       
        NSLog(@"Authorization was cancelled by user");
        UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"LogIn Failed!!" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;
    }                     failure:^(NSError *error) {
        
        NSLog(@"Authorization failed %@", error);
        UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"LogIn Failed!!" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;
    }];
}


-(void)sharetoLinkedIn:(NSString *)title desc:(NSString *)description path:(NSString *)submitted_url imagePath:(NSString *)submitted_image_url postString:(NSString *)comment
{
    NSString *stringRequest = [NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~/shares?oauth2_access_token=%@&format=json",[[DataObjects sharedDataObjects] accessTokenForLinkedIn]] ;
    
    NSDictionary *param = @{
                            @"content":@{
                                    @"title":title,
                                    @"description":description,
                                    @"submitted-url":submitted_url,
                                    @"submitted-image-url":submitted_image_url
                                    },
                            @"comment": comment,
                            @"visibility": @{
                                    @"code": @"anyone"
                                    }
                            };
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringRequest]];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:param options:0 error:nil]];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:@{@"Content-Type":@"application/json",
                                      @"x-li-format":@"json"
                                      
                                      }];
    
    AFHTTPRequestOperation *op = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"result: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.responseString class] == [NSDictionary class]) {
                //[Utility showAlert:@"LinkedIn" mess:[(NSDictionary *)operation.responseString objectForKey:@"message"]];
            
            NSLog(@"error: %@", [(NSDictionary *)operation.responseString objectForKey:@"message"]);
        }
        NSLog(@"error: %@", error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
}

- (void)requestMeWithToken:(NSString *)accessToken {
    [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~:(id,first-name,last-name,picture-url,email-address)?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSLog(@"current user %@", result);
        NSString *name = [[result objectForKey:@"firstName"] stringByAppendingString:[result objectForKey:@"lastName"]];
        NSString *emailID = [result objectForKey:@"emailAddress"];
        NSString *idName = [result objectForKey:@"id"];
        NSString *picture = [result objectForKey:@"pictureUrl"];
        NSDictionary *userDict=@{@"username":name,
                                 @"email":emailID,
                                 @"user_id":idName,@"picture":picture,
                                 @"login":@"linkedin"
                                 };
        NSLog(@"%@",userDict);
    }        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to fetch current user %@", error);
        UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"Error" message:@"Somthing went wrong please try again. !!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;
    }];
}

- (LIALinkedInHttpClient *)client {
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:REDIRECTURL                                                                                           clientId:CLIENTID
                                                                                clientSecret:CLIENTSECRET
                                                                                       state:@"DCEEFWF45453sdffef424"
                                                                               grantedAccess:@[@"w_share"]];
    return [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
}


@end
