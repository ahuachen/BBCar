//
//  ViewController.h
//  BBCar
//
//  Created by ahua on 15/6/26.
//  Copyright (c) 2015年 ahua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>


@interface ViewController : UIViewController

@property (nonatomic , retain) IBOutlet UILabel *upLabel;
@property (nonatomic , retain) IBOutlet UILabel *backLabel;
@property (nonatomic , retain) IBOutlet UILabel *leftLabel;
@property (nonatomic , retain) IBOutlet UILabel *rightLabel;
@property (nonatomic , retain) IBOutlet UILabel *stopLabel;
@property (nonatomic , retain) IBOutlet UILabel *welcomeLabel;
@property (nonatomic , retain) IBOutlet UILabel *xyzLabel;
@property(nonatomic,retain)IBOutlet UITextView *mytextview;
@property(nonatomic)BOOL labeltag;
@property(nonatomic)float distance;
@property(nonatomic)int lastDir;
@property(nonatomic,retain)NSMutableArray * acelerometer;
@property(nonatomic,retain)NSURL *carURL;
@property(nonatomic)BOOL carState;
@property(nonatomic,retain)NSMutableData *data;

- (void)notifyCar:(int) action;

-(IBAction)showMessage;

@end

