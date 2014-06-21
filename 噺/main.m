//
//  main.m
//  噺
//
//  Created by 鈴木 祐気 on 2014/06/14.
//  Copyright (c) 2014年 鈴木 祐気. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "MyUIApplication.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc,argv,NSStringFromClass([MyUIApplication class]),//カスタムクラス名
                                 NSStringFromClass([AppDelegate class]));
    }
}
