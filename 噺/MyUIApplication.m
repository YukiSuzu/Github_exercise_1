//
//  MyUIApplication.m
//  噺
//
//  Created by 鈴木 祐気 on 2014/06/21.
//  Copyright (c) 2014年 鈴木 祐気. All rights reserved.
//

#import "MyUIApplication.h"


@implementation MyUIApplication



-(BOOL)openURL:(NSURL *)url
{
    if(!url){
        return NO;
    }
    self.myOpenURL = url;
    AppDelegate *appDelegade = [[UIApplication sharedApplication]delegate];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    WebViewController *webViewController =
    [storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.openURL = self.myOpenURL;
    webViewController.title = @"Web View";
    [appDelegade.navigationController pushViewController:webViewController animated:YES];
    self.myOpenURL = nil;
    return YES;
}


@end
