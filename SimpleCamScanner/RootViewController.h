//
//  RootViewController.h
//  SimpleCamScanner
//
//  Created by iPhoneGang on 3/5/16.
//  Copyright © 2016 iPhone Max Developer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RootViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *imageTableView;
@property (nonatomic, strong) NSMutableArray *dataArray ;


@end
