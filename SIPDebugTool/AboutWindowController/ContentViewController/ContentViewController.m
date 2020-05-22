//
//  ContentViewController.m
//  UPHmonitor
//
//  Created by WeidongCao on 2020/4/26.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "ContentViewController.h"

@interface ContentViewController ()
@property (retain, nonatomic) NSMutableArray *peotrysArray;
@end

@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.peotrysArray = [NSMutableArray array];
    NSString *peotry1 = @"云想衣裳花想容，\r\n春风拂槛露华浓。\r\n若非群玉山头见，\r\n会向瑶台月下逢。\r\n";
    NSString *peotry2 = @"人生若只如初见，\r\n何事秋风悲画扇。\r\n等闲变却故人心，\r\n却道故人心易变。\r\n";
    NSString *peotry3 = @"劝君莫惜金缕衣，\r\n劝君惜取少年时。\r\n花开堪折直须折，\r\n莫待无花空折枝。\r\n";
    NSString *peotry4 = @"曾经沧海难为水，\r\n除却巫山不是云。\r\n取次花丛懒回顾，\r\n半缘修道半缘君。\r\n";
    NSString *peotry5 = @"行到水穷处，\r\n坐看云起时。\r\n偶然值林叟，\r\n谈笑无还期。\r\n";
    NSString *peotry6 = @"杨柳青青江水平，\r\n闻郎江上唱歌声。\r\n东边日出西边雨，\r\n道是无晴却有晴。\r\n";
    NSString *peotry7 = @"宣室求贤访逐臣，\r\n贾生才调更无伦。\r\n可怜夜半虚前席，\r\n不问苍生问鬼神。\r\n";
    NSString *peotry8 = @"月落乌啼霜满天，\r\n江枫渔火对愁眠。\r\n姑苏城外寒山寺，\r\n夜半钟声到客船。\r\n";
    NSString *peotry9 = @"人间四月芳菲尽，\r\n山寺桃花始盛开。\r\n长恨春归无觅处，\r\n不知转入此中来。\r\n";
    NSString *peotry10 = @"周公恐惧流言日，\r\n王莽谦恭未篡时。\r\n向使当初身便死，\r\n一生真伪复谁知？\r\n";
    [self.peotrysArray addObject:peotry1];
    [self.peotrysArray addObject:peotry2];
    [self.peotrysArray addObject:peotry3];
    [self.peotrysArray addObject:peotry4];
    [self.peotrysArray addObject:peotry5];
    [self.peotrysArray addObject:peotry6];
    [self.peotrysArray addObject:peotry7];
    [self.peotrysArray addObject:peotry8];
    [self.peotrysArray addObject:peotry9];
    [self.peotrysArray addObject:peotry10];
}
-(void)viewWillAppear{
    NSString *peotry = [self getTheLittlePeotry];
    [showPeotryField setStringValue:peotry];
}
-(NSString *)getTheLittlePeotry{
    //random [0,9]
    int y =0 +  (arc4random() % 10);
    return [self.peotrysArray objectAtIndex:y];
}
@end
