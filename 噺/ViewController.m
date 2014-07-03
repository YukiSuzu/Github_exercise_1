//
//  ViewController.m
//  噺
//
//  Created by 鈴木 祐気 on 2014/06/14.
//  Copyright (c) 2014年 鈴木 祐気. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()


@property (weak, nonatomic) IBOutlet UILabel *accountDisplayLabel;
@property(nonatomic,strong) ACAccountStore *accountStore;
@property(nonatomic,copy) NSArray *twitterAccounts;
@property(nonatomic,copy) NSString *identifier;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   
    
     
    /*複数のアカウントから選択*/
    self.accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterType =
    [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:twitterType
                                               options:NULL
                                            completion:^(BOOL granted,NSError *error){
                                                if (granted) {//認証成功時
                                                    self.twitterAccounts = [self.accountStore accountsWithAccountType:twitterType];
                                                    if (self.twitterAccounts.count > 0) {//アカウントが1個以上あれば
                                                        ACAccount *account = self.twitterAccounts[1];//とりあえず先頭のアカウントをセット
                                                        self.identifier = self.identifier;//このidentifierを持ち回す
                                                        dispatch_sync(dispatch_get_main_queue(), ^{
                                                            self.accountDisplayLabel.text= account.username;//UI処理ｓはメインキュー
                                                        });
                                                    }else{
                                                        dispatch_sync(dispatch_get_main_queue(), ^{
                                                            self.accountDisplayLabel.text= @"アカウント無し";
                                                        });
                                                    }
                                                }else{//認証失敗時
                                                    NSLog(@"Account Error:%@",[error localizedDescription]);
                                                    dispatch_sync(dispatch_get_main_queue(), ^{
                                                        self.accountDisplayLabel.text= @"アカウント認証エラー";
                                                    });
                                                }
                                            }];
    
}







    
    


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
     
- (IBAction)tweet:(id)sender {
    //ボタンを押すとこの中が動く
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){//利用可能チェック
        NSString *serviceType = SLServiceTypeTwitter;
        SLComposeViewController *composeCtl =
        [SLComposeViewController composeViewControllerForServiceType:serviceType];
        [composeCtl setCompletionHandler:^(SLComposeViewControllerResult result){
            if(result==SLComposeViewControllerResultDone){
                //投稿成功時の処理
                NSLog(@"投稿成功!");
            }
        }];
        [self presentViewController:composeCtl animated:YES completion:nil];
    }
    
    
}
- (IBAction)setAccountAction:(id)sender {
    
    UIActionSheet *sheet =[[UIActionSheet alloc] init];
    sheet.delegate= self;
    
    sheet.title = @"選択してください";
    for (ACAccount *account in self.twitterAccounts) {//アカウント数だけ繰り返し(高速列挙)
        [sheet addButtonWithTitle:account.username];
    }
    [sheet addButtonWithTitle:@"キャンセル"];
    sheet.cancelButtonIndex = self.twitterAccounts.count;//アカウントの数が最後のボタンのindex
    [sheet showInView:self.view];
    
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.twitterAccounts.count > 0) {//アカウントがひとつ以上あれば
        if (buttonIndex != self.twitterAccounts.count) {//キャンセルボタンのindexでなければ
            ACAccount *account = self.twitterAccounts[buttonIndex];//ボタンのindexをアカウント
            self.identifier = account.identifier;//identifierをセット
            self.accountDisplayLabel.text = account.username;
            NSLog(@"Account Set! %@",account.username);//デバック用に表示
        }else{
            NSLog(@"Cancel!");//デバック用に表示
        }
    }
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"timeLineSegue"]){//segueのidを確認
        TimeLineTableViewController *timeLineVC = segue.destinationViewController;
        if ([timeLineVC isKindOfClass:[TimeLineTableViewController class]]) {
            timeLineVC.identifier = self.identifier;//アカウントidを持ち出す
        }
    }
}





@end
