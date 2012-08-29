//
//  ViewController.h
//  SNReachabilityTest
//
//  Created by sonson on 2012/08/29.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNReachablityChecker;

@interface ViewController : UIViewController

@property (nonatomic, strong) SNReachablityChecker *wifiChecker;

@end
