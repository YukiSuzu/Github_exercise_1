//
//  TimeLineTableViewController.m
//  噺
//
//  Created by 鈴木 祐気 on 2014/06/14.
//  Copyright (c) 2014年 鈴木 祐気. All rights reserved.
//

#import "TimeLineTableViewController.h"

@interface TimeLineTableViewController ()

@property(nonatomic) dispatch_queue_t mainQueue;
@property(nonatomic) dispatch_queue_t imageQueue;
@property(nonatomic,copy) NSString *httpErrorMessage;
@property(nonatomic,copy) NSArray *timeLineData;

@end

@implementation TimeLineTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.mainQueue = dispatch_get_main_queue();
    self.imageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
    
    //iOS6以降のカスタムセルの再利用のパターン
    [self.tableView registerClass:[TimeLineCell class] forCellReuseIdentifier:@"TimeLineCell"];
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccount *account = [accountStore accountWithIdentifier:self.identifier];
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];//タイムラインURLの取得
    
    NSDictionary *params = @{@"count": @"100",@"trim_user":@"0",@"include_entities":@"0"};
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
    
    request.account = account;

    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;//インジゲータON
    
    [request performRequestWithHandler:^(NSData *responseData
                                         ,NSHTTPURLResponse *urlResponse,
                                         NSError *error){
        if (responseData) {
            self.httpErrorMessage = nil;
            if(urlResponse.statusCode >= 200 && urlResponse.statusCode < 300){//200番代は成功
                NSError *jsonError;
                self.timeLineData = //複数件のNSDictionaryが返される
                [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                if(self.timeLineData){
                    NSLog(@"TimeLine Response:%@ ¥n",self.timeLineData);
                    dispatch_async(dispatch_get_main_queue(), ^{//UI処理はメインキューで
                        [self.tableView reloadData];//テーブルビュー書き換え
                    });
                }else{//JSONシリアライズエラー発生時
                    NSLog(@"JSON Error:%@",[jsonError localizedDescription]);
                }
            }else{//HTTPエラー発生時
                self.httpErrorMessage =
                [NSString stringWithFormat:@"The response statuscode is %d",urlResponse.statusCode];
                NSLog(@"HTTP Error:@%",self.httpErrorMessage);
                dispatch_async(dispatch_get_main_queue(), ^{//UI処理はメインキューで
                    [self.tableView reloadData];//テーブルビュー書き換え
                });
            }
        }else{//リクエスト送信エラー発生時
            NSLog(@"ERROR:An ERror occurred while requesting:%@",[error localizedDescription]);
            //リクエスト送信時の送信エラーメッセージを画面に表示する領域がない。今後の課題。
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIApplication *application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = NO;//インジゲータOFF
        });
    }];
}

                       


-(NSAttributedString *)labelAttributing:(NSString *)labelString//ラベルの文字を属性付きに変換
{
    //ラベル文字列
    NSString *text = (labelString == nil)? @"":labelString;//三項演算子のサンプルとして普通のif文で可
    
    //フォントを指定
    UIFont *font = [UIFont fontWithName:@"HiraKakuProN-W3" size:13];
    
    //カスタムLineHeightを指定
    CGFloat customLineHeight = 19.5f;
    
    //パラグラフスタイルにLineHeightをセット
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.minimumLineHeight = customLineHeight;
    paragraphStyle.maximumLineHeight = customLineHeight;
    
    //属性としてパラグラフスタイルとフォントをセット
    NSDictionary *attributes = @{NSParagraphStyleAttributeName:paragraphStyle,
                                 NSFontAttributeName:font};
    
    //NSA
    NSMutableAttributedString *attributedText =[[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    
    return attributedText;
}


-(CGFloat)labelHeight:(NSAttributedString *)attributedText //属性付きテキストからラベルの高さを求める
{
    //ラベルの高さ計算
    CGFloat aHeight = [attributedText boundingRectWithSize:CGSizeMake(257,MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    return aHeight;
}









- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (!self.timeLineData) {//レスポンス取得前はtimeLineDataがない
        return 1;
    }else{
        return [self.timeLineData count];
    }
}



///////////////////////////////ここから考えろ


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //iOS6以降のカスタムセル再利用のパターン
    TimeLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeLineCell"
                                                         forIndexPath:indexPath];
    
    // Configure the cell...
    //NSString *status;
    if (self.httpErrorMessage) {//このif文は超重要
        cell.tweetTextLabel.text = @"HTTP Error!";
        cell.tweetTextLabelHeight = 24.0;
    } else if (!self.timeLineData) {//レスポンス取得前はtimeLineDataがない
        cell.tweetTextLabel.text = @"Loading...";
        cell.tweetTextLabelHeight = 24.0;
    } else {
        NSString *tweetText = self.timeLineData[indexPath.row][@"text"];
        NSAttributedString *attributedTweetText = [self labelAttributing:tweetText];
        
        cell.tweetTextLabel.attributedText = attributedTweetText;
        cell.nameLabel.text = self.timeLineData[indexPath.row][@"user"][@"screen_name"];
        cell.profileImageView.image = [UIImage imageNamed:@"blank.png"];
        cell.tweetTextLabelHeight = [self labelHeight:attributedTweetText];
        
       // UIApplication *application = [UIApplication sharedApplication];
        //application.networkActivityIndicatorVisible = YES;
        
        dispatch_async(self.imageQueue, ^{
            NSString *url;
            NSDictionary *tweetDictionary = [self.timeLineData objectAtIndex:indexPath.row];
            
            if ([[tweetDictionary allKeys] containsObject:@"retweeted_status"]) {
                // リツイートの場合はretweeted_statusキー項目が存在する
                url = tweetDictionary[@"retweeted_status"][@"user"][@"profile_image_url"];
            } else {
                url = tweetDictionary[@"user"][@"profile_image_url"];
            }
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            dispatch_async(self.mainQueue, ^{
                UIApplication *application = [UIApplication sharedApplication];
                application.networkActivityIndicatorVisible = NO;
                UIImage *image = [[UIImage alloc] initWithData:data];
                cell.profileImageView.image = image;
                [cell setNeedsLayout];
            });
        });
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *tweetText = self.timeLineData[indexPath.row][@"text"];
    NSAttributedString *attributedTweetText = [self labelAttributing:tweetText];
    CGFloat tweetTextLabelHeight = [self labelHeight:attributedTweetText];
    return  tweetTextLabelHeight+35;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimeLineCell *cell = (TimeLineCell *)[tableView cellForRowAtIndexPath:indexPath];
    DetailViewController *detailViewController =
         [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    
    detailViewController.text = cell.tweetTextLabel.text;
    detailViewController.name = cell.nameLabel.text;
    detailViewController.image = cell.profileImageView.image;
    detailViewController.identifier = self.identifier;
    detailViewController.idStr = self.timeLineData[indexPath.row][@"id_str"];
    [self.navigationController pushViewController:detailViewController animated:YES];
}


/*
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
