//
//  ViewController.m
//  BBCar
//
//  Created by ahua on 15/6/26.
//  Copyright (c) 2015年 ahua. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    //x轴方向的速度
    UIAccelerationValue _speedX;
    //y轴方向的速度
    UIAccelerationValue _speedY;
    

}

@end

@implementation ViewController
@synthesize upLabel;
@synthesize backLabel;
@synthesize leftLabel;
@synthesize rightLabel;
@synthesize stopLabel;
@synthesize welcomeLabel;
@synthesize xyzLabel;
@synthesize labeltag,mytextview,distance,acelerometer;
@synthesize lastDir;
@synthesize carURL;
@synthesize carState;





- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    labeltag=YES;
    acelerometer = [[NSMutableArray alloc]init];
    carURL = [NSURL URLWithString:@"http://192.168.31.201:5000/carServer/action"];
    
    CMMotionManager *motionManager = [[CMMotionManager alloc] init];
    if (!motionManager.accelerometerAvailable) {
        NSLog(@"没有加速计");
    }
    distance=0;
    motionManager.accelerometerUpdateInterval = 0.02; // 告诉manager，更新频率是100Hz
    
    [motionManager startDeviceMotionUpdates];
    //    [motionManager startAccelerometerUpdates];
    //    [motionManager startGyroUpdates];
    //    [motionManager startMagnetometerUpdates];
    
    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *latestAcc, NSError *error)
     {
         acelerometer[0] = [NSString stringWithFormat:@"%0.2f",latestAcc.acceleration.x];
         acelerometer[1] = [NSString stringWithFormat:@"%0.2f",latestAcc.acceleration.y];
         acelerometer[2] = [NSString stringWithFormat:@"%0.2f",latestAcc.acceleration.z*-1];
         double gravityX = motionManager.deviceMotion.gravity.x;
         double gravityY = motionManager.deviceMotion.gravity.y;
         double gravityZ = motionManager.deviceMotion.gravity.z;
         double zTheta = fabs(atan2(gravityZ,sqrtf(gravityX*gravityX+gravityY*gravityY))/M_PI*180.0);
         CMRotationRate rotationRate = motionManager.deviceMotion.rotationRate;
         double rotationX = fabs(rotationRate.x);
         double rotationY = fabs(rotationRate.y);
         double rotationZ = fabs(rotationRate.z);
         int currentDir = 0;
         
         CMAttitude *currentAttitude = motionManager.deviceMotion.attitude;
         
//         float yaw = roundf((float)(currentAttitude.yaw));
         //roll < 0 左倾，>0 右倾
         float roll = (float)(currentAttitude.roll);
         //pitch <0 前倾, >0 后倾
         float pitch = (float)(currentAttitude.pitch);
         
         
         NSMutableString *newText=[[NSMutableString alloc] initWithFormat:@"三轴: x: %@ y: %@ z: %@",acelerometer[0],acelerometer[1],acelerometer[2]];
         [newText appendFormat:@"\nroll=%0.4f,pitch=%0.4f",roll,pitch];
         xyzLabel.text=newText;
         
         
         if (ABS(roll*10) < 1.5 && ABS(pitch*10)<1.5) {
             //停止
             stopLabel.hidden = NO;
             upLabel.hidden = YES;
             backLabel.hidden = YES;
             leftLabel.hidden = YES;
             rightLabel.hidden = YES;
             currentDir = 0;
         } else {
             stopLabel.hidden = YES;
             if(ABS(roll) > ABS(pitch)) {
                 upLabel.hidden = YES;
                 backLabel.hidden = YES;
                 if (roll < 0) {
                     //左转
                     leftLabel.hidden = NO;
                     rightLabel.hidden = YES;
                     currentDir = 1;
                 } else {
                     //右转
                     leftLabel.hidden = YES;
                     rightLabel.hidden = NO;
                     currentDir = 2;
                 }
             } else {
                 leftLabel.hidden = YES;
                 rightLabel.hidden = YES;
                 if (pitch < 0) {
                     //前倾
                     upLabel.hidden = NO;
                     backLabel.hidden = YES;
                     currentDir = 4;
                 } else {
                     upLabel.hidden = YES;
                     backLabel.hidden = NO;
                     currentDir = 8;
                 }
             }
         }
         
         if (lastDir != currentDir) {
             lastDir = currentDir;
             //通知小车改变动作
             [self notifyCar:lastDir];
         }
         
         
         
//         if (latestAcc.acceleration.z*-1 >0.8 && zTheta <15 && rotationX <10   && labeltag) {
//             labely.text = [NSString stringWithFormat:@"X轴角速度：%0.2f",rotationX];
//             labelz.text = [NSString stringWithFormat:@"Z轴加速度：%0.2f",latestAcc.acceleration.z*-1];
//             labeltext.text = [NSString stringWithFormat:@"Z轴斜度：%0.2f",zTheta];
//             labeltag=NO;
//             
//             if ([acelerometer[2]floatValue]>1.6) {
//                 [self playsound:@"hit00.wav"];
//             }else if([acelerometer[2]floatValue]>1.3){
//                 [self playsound:@"vocalf03.wav"];
//             }else if([acelerometer[2]floatValue]>1.0){
//                 [self playsound:@"ok.wav"];
//             }else if([acelerometer[2]floatValue]>0.8){
//                 [self playsound:@"W00FIR01.wav"];
//             }
             
             NSMutableString * tempstr = [[NSMutableString alloc]init];
             [tempstr appendFormat:@"X轴加速度 = %@\n",acelerometer[0]];
             [tempstr appendFormat:@"Y轴加速度 = %@\n",acelerometer[1]];
             [tempstr appendFormat:@"Z轴加速度 = %@\n",acelerometer[2]];
             [tempstr appendFormat:@"Z轴倾斜角度 = %0.2f\n",zTheta];
             [tempstr appendFormat:@"x轴角速度 = %0.2f\n",rotationX];
             [tempstr appendFormat:@"y轴角速度 = %0.2f\n",rotationY];
             [tempstr appendFormat:@"z轴角速度 = %0.2f\n",rotationZ];
             mytextview.text = tempstr;
             
//         }else if (latestAcc.acceleration.z*-1 <0) {
//             //labeltext.text = @"";
//             labeltag=YES;
//         }else{
//             //labeltag=YES;
//         }
         
         //[self getcounts:motionManager];
         
     }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidUnload{
    CMMotionManager *motionManager = [[CMMotionManager alloc] init];
    [motionManager stopAccelerometerUpdates];
    [motionManager stopDeviceMotionUpdates];
    [motionManager stopGyroUpdates];
    [motionManager stopMagnetometerUpdates];
}


- (void)notifyCar:(int) action{
    
    //    2.创建请求对象
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:carURL];//默认为get请求
    request.timeoutInterval=5.0;//设置请求超时为5秒
    request.HTTPMethod=@"POST";//设置请求方法
    
    //设置请求体
    NSString *param=[NSString stringWithFormat:@"action=%d&stamp=%ld",action,timezone];
    NSLog(@"Action:%@", param);
    //把拼接后的字符串转换为data，设置请求体
    request.HTTPBody=[param dataUsingEncoding:NSUTF8StringEncoding];
    
    //    3.发送请求
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    dispatch_async(dispatch_queue_create("demo", DISPATCH_QUEUE_CONCURRENT), ^{
        [connection start];
    });
    
}




#pragma mark - NSURLConnectionDataDelegate代理方法
#pragma mark 接受到响应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // 准备工作
    // 按钮点击就会有网络请求,为了避免重复开辟空间
    if (!self.data) {
        self.data = [NSMutableData data];
    } else {
        [self.data setData:nil];
    }
}

#pragma mark 接收到数据,如果数据量大,例如视频,会被多次调用
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 拼接数据,二进制流的体现位置
    [self.data appendData:data];
}

#pragma mark 接收完成,做最终的处理工作
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // 最终处理
    NSString *str = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    if ([str  isEqual: @"OK"]) {
        carState = TRUE;
    }
    NSLog(@"%@ %@", str, [NSThread currentThread]);
}

#pragma mark 出错处理,网络的出错可能性非常高
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    carState = FALSE;
    NSLog(@"%@", error.localizedDescription);
}


- (IBAction)showMessage
{
    UIAlertView *helloWorldAlert = [[UIAlertView alloc]
                                    initWithTitle:@"My Dear,Jing" message:@"I Love You" delegate:nil cancelButtonTitle:@"I Love you ,too." otherButtonTitles:nil];
    
    [helloWorldAlert show];
    
    [self notifyCar:0];
    
    if (carState == YES) {
        welcomeLabel.text = @"CAR READY!!! :))))";
    } else {
        welcomeLabel.text= @"CAR OFFLINE!!! :((((";
    }
}
@end
