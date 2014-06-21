//
//  WebViewController.h
//  噺
//
//  Created by 鈴木 祐気 on 2014/06/21.
//  Copyright (c) 2014年 鈴木 祐気. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic,strong) NSURL *openURL;

@end
