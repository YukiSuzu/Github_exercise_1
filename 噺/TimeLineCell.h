//
//  TimeLineCell.h
//  噺
//
//  Created by 鈴木 祐気 on 2014/06/14.
//  Copyright (c) 2014年 鈴木 祐気. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLineCell : UITableViewCell



@property(nonatomic,strong) UILabel *tweetTextLabel;
@property(nonatomic,strong) UILabel *nameLabel;
@property(nonatomic,strong) UIImageView *profileImageView;

@property(nonatomic) float tweetTextLabelHeight;



@end
