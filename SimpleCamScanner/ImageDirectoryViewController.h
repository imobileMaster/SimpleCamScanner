//
//  RootViewController.h
//  SimpleCamScanner
//
//  Created by iPhoneGang on 3/5/16.
//  Copyright © 2016 iPhone Max Developer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageDirectoryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *directoryTableView;
@property (strong, nonatomic) NSNumber *directoryNumber;
@property (strong, nonatomic) NSString *directoryPath;



@end
