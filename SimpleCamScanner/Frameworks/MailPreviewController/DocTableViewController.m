//
//  DocTableViewController.m
//  AVCam
//
//  Created by iPhoneGang on 3/4/16.
//
//

#import "DocTableViewController.h"
#import <MessageUI/MessageUI.h>

@interface DocTableViewController () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property(strong, nonatomic) UITableView *tableView;

@end

@implementation DocTableViewController

@synthesize tableView;
@synthesize fileName;
@synthesize fileName__;
@synthesize curDirPath;
@synthesize isZip;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
       [self.navigationController setHidesBarsOnTap:NO];
    // Do any additional setup after loading the view.
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    [tableView setShowsVerticalScrollIndicator:NO];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
   
    [self.view addSubview:tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Initializing each section with a set of rows
    return 2;
}

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSString *fileURLString;
    NSString *labelStr;
    NSString *myFileName = fileName;
    
    if (indexPath.row == 0)
    {
        fileURLString = [NSString stringWithFormat:@"%@/%@.pdf", curDirPath, myFileName];
        if ([isZip isEqualToString:@"zip"])
        {
            fileURLString = [NSString stringWithFormat:@"%@/%@.zip", curDirPath, myFileName];
        }
        labelStr = @"PDF file";
    }
    else if(indexPath.row == 1)
    {
        if ([isZip isEqualToString:@"zip"])
        {
            myFileName = fileName__;
            fileURLString = [NSString stringWithFormat:@"%@/%@.zip", curDirPath, myFileName];
        }
        else{
            fileURLString = [NSString stringWithFormat:@"%@/%@.jpg", curDirPath, myFileName];
        }
        
        labelStr = @"JPEG file";
    }
    else
    {
        return nil;
    }
    
    NSLog(@"after: %@\n\n", fileURLString);
    
    NSError* error;
    NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURLString error: &error];
    NSNumber *fileSize = [fileDictionary objectForKey:NSFileSize];
    NSString *fileSizeStr = [NSByteCountFormatter stringFromByteCount:[fileSize longLongValue]                                                               countStyle:NSByteCountFormatterCountStyleFile];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", labelStr, fileSizeStr];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return 100.0f;
    }
    
    return 0.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0){
        return 100.0f;
    }
    
    return 0.0f;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        if ([MFMailComposeViewController canSendMail])
        {
            NSString *emailTitle = @"Scanned image";
            NSString *messageBody = @"";
            NSArray *toRecipents = [NSArray arrayWithObject:@"SimpleCamScanner@mobile.com"];
    
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setToRecipients:toRecipents];
    
            NSString* mimeType;
            NSString* extension;
   
            if (indexPath.row == 0) {
                mimeType = @"application/pdf";
                extension = @"pdf";
                if ([isZip isEqualToString:@"zip"])
                {
                    mimeType = @"application/zip";
                    extension = @"zip";
                }
            }
            else {
                mimeType = @"image/jpeg";
                extension = @"jpg";
                if ([isZip isEqualToString:@"zip"])
                {
                    mimeType = @"application/zip";
                    extension = @"zip";
                    fileName = fileName__;
                }
            }
            
            NSString* filePath = [NSString stringWithFormat:@"%@/%@.%@", curDirPath, fileName, extension];
            NSData *fileData = [NSData dataWithContentsOfFile:filePath];
            
            [mc addAttachmentData:fileData mimeType:mimeType fileName:fileName];
    
            // Present mail view controller on screen
            [self presentViewController:mc animated:YES completion:NULL];
    
        }
        else{
            NSLog(@"cannot send email");
        }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
