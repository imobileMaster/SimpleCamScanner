//
//  RootViewController.m
//  SimpleCamScanner
//
//  Created by iPhoneGang on 3/5/16.
//  Copyright © 2016 iPhone Max Developer. All rights reserved.
//

#import "ImageDirectoryViewController.h"
#import "MSCMoreOptionTableViewCell.h"
//#import "AAPLCameraViewController.h"
#import "ImageScrollViewController.h"
#import "DocTableViewController.h"
#import "ViewController.h"

@interface ImageDirectoryViewController() <UITableViewDataSource, UITableViewDelegate, MSCMoreOptionTableViewCellDelegate>
{

}

@property (nonatomic, strong) IBOutlet UIBarButtonItem *selectButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *selectAllButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *emailButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *handleButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deselectButton;

@property (strong, nonatomic) NSMutableArray* arrFileName;
@property (strong, nonatomic) NSMutableArray* arrFileData;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UIToolbar *myToolbar;
@property (weak, nonatomic) IBOutlet UIButton *goToTop;

@end

@implementation ImageDirectoryViewController

@synthesize directoryTableView;
@synthesize directoryNumber;
@synthesize directoryPath;
@synthesize arrFileData;
@synthesize arrFileName;
@synthesize goToTop;


#pragma mark - UITableViewDelegate

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     This option is also selected in the storyboard. Usually it is better to configure a table view in a xib/storyboard, but we're redundantly configuring this in code to demonstrate how to do that.
     */
    self.directoryTableView.allowsMultipleSelectionDuringEditing = YES;
    
    self.dataArray = [NSMutableArray new];
    
    directoryTableView.dataSource = self;
    directoryTableView.delegate = self;
    
    [self preloadCellData];
    
    // make our view consistent
    [self updateButtonsToMatchTableState];
    
}

- (IBAction)deleteFiles:(id)sender {

    NSArray *selectedRows = [self.directoryTableView indexPathsForSelectedRows];
    BOOL deleteSpecificRows = selectedRows.count > 0;
    if (deleteSpecificRows)
    {
        NSMutableArray *indicesOfFiles = [[NSMutableArray alloc] init];
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            [indicesOfFiles addObject:arrFileName[selectionIndex.row]];
        }
        [self groupDelete:indicesOfFiles];
    }
}

- (void) groupDelete: (NSArray*) indicesOfFiles
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete"
                                                                   message:@"Confirm Delete"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [Utility deleteFiles:directoryPath :(long) directoryNumber :indicesOfFiles];
                                    [self preloadCellData];
                                   [self.directoryTableView reloadData];
                                    [self.directoryTableView setEditing:NO animated:YES];
                                   [self updateButtonsToMatchTableState];
                               }];
    
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)sendMail:(id)sender {
    
    NSArray *selectedRows = [self.directoryTableView indexPathsForSelectedRows];
    if (selectedRows.count == 1) {
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            DocTableViewController *docTableView = [[DocTableViewController alloc] init];
            docTableView.curDirPath = directoryPath;
            docTableView.fileName = arrFileName[selectionIndex.row];
            
            [self.navigationController pushViewController:docTableView animated:YES];
        }
    }
    else{
        BOOL deleteSpecificRows = selectedRows.count > 0;
        if (deleteSpecificRows)
        {
            NSMutableArray *indicesOfItemsToEmail = [NSMutableArray new];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                [indicesOfItemsToEmail addObject:[NSString stringWithFormat:@"%ld.jpg", selectionIndex.row]];
                [indicesOfItemsToEmail addObject:[NSString stringWithFormat:@"%ld.pdf", selectionIndex.row]];
            }
            
            NSArray *info = [Utility makeZipFileWithSpecific:directoryPath :indicesOfItemsToEmail];
            
            DocTableViewController *docTableView = [[DocTableViewController alloc] init];
            docTableView.curDirPath = info[0];
            docTableView.fileName = info[1];
            docTableView.fileName__ = info[2];
            docTableView.isZip = @"zip";
            
            [self.navigationController pushViewController:docTableView animated:YES];
        }
    }
   
}
- (IBAction)handleFiles:(id)sender {
    
    // Open a dialog with just an OK button.
//    NSString *actionTitle;
//    actionTitle = NSLocalizedString(@"merge project?", @"");
//    
//    NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel title for item removal action");
//    NSString *okTitle = NSLocalizedString(@"OK", @"OK title for item removal action");
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
//                                                             delegate:self
//                                                    cancelButtonTitle:cancelTitle
//                                               destructiveButtonTitle:okTitle
//                                                    otherButtonTitles:nil];
//    
//    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
//    
//    // Show from our table view (pops up in the middle of the table).
//    [actionSheet showInView:self.view];
}

- (void) viewWillAppear:(BOOL)animated
{
    [Utility setTakeType:2];
    [self preloadCellData];
    [Utility setCurrentDirectoryPath:directoryPath];
    [Utility setCurrentDirectory:[directoryNumber integerValue]];
    [directoryTableView reloadData];
}

- (void) preloadCellData
{
    arrFileName = [[NSMutableArray alloc] init];
    arrFileData = [[NSMutableArray alloc] init];
    NSFileManager *fManager = [NSFileManager defaultManager];
    NSString *item;
    NSArray *contents = [fManager contentsOfDirectoryAtPath:directoryPath error:nil];
    
    for (item in contents){
        if ([[item pathExtension] isEqualToString:@"jpg"]) {
            NSRange range = NSMakeRange (0, item.length-4);
            item = [item substringWithRange:range];
            [arrFileName addObject:item];
            NSString* filePath = [NSString stringWithFormat:@"%@/%@.jpg", directoryPath, item];
            
            
            NSData *fileData = [NSData dataWithContentsOfFile:filePath];
            [arrFileData addObject:fileData];
        }
    }

}
- (IBAction)goToTopView:(id)sender {

    [Utility setTakeType:2];

//    AAPLCameraViewController *aaCameraController = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
 ViewController *aaCameraController = [self.storyboard instantiateViewControllerWithIdentifier:@"IPFCameraView"];
    [self presentViewController:aaCameraController animated:YES completion:nil];
}

#pragma mark - Action methods

- (IBAction)selectAction:(id)sender
{
    [self.directoryTableView setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)cancelAction:(id)sender
{
    [self.directoryTableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
}

- (IBAction)DeselectAllAction:(id)sender {
    [arrFileName enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSMutableDictionary *dic, NSUInteger index, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        [self.directoryTableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    [self updateButtonsToMatchTableState];
}


- (IBAction)SelectAllAction:(id)sender
{
    [arrFileName enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSMutableDictionary *dic, NSUInteger index, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        //    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.directoryTableView selectRowAtIndexPath:indexPath
                                         animated:YES
                                   scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.directoryTableView didSelectRowAtIndexPath:indexPath];
    }];
    
    [self updateButtonsToMatchTableState];
    
}


#pragma mark - Updating button state

- (void)updateButtonsToMatchTableState
{
    if (self.directoryTableView.editing)
    {
       goToTop.hidden = YES;
        _myToolbar.hidden = NO;
     
        // Show the option to cancel the edit.
        self.navigationItem.rightBarButtonItem = self.cancelButton;
        
        NSArray *selectedRows = [self.directoryTableView indexPathsForSelectedRows];
        BOOL allItemsAreSelected = selectedRows.count == arrFileName.count;
        if (allItemsAreSelected) {
            self.navigationItem.leftBarButtonItem = self.deselectButton;
        }
        else{
            self.navigationItem.leftBarButtonItem = self.selectAllButton;
        }
        
        if (selectedRows.count > 0) {
            self.emailButton.enabled = YES;
       //     self.handleButton.enabled = YES;
            self.deleteButton.enabled = YES;
        }
        else
        {
            self.emailButton.enabled = NO;
       //     self.handleButton.enabled = NO;
            self.deleteButton.enabled = NO;
        }
    }
    else
    {
        goToTop.hidden = NO;
        _myToolbar.hidden = YES;
        // Not in editing mode.
        self.navigationItem.leftBarButtonItem = nil;
        
        // Show the edit button, but disable the edit button if there's nothing to edit.
        if (arrFileName.count > 0)
        {
            self.selectButton.enabled = YES;
        }
        else
        {
            self.selectButton.enabled = NO;
        }
        self.navigationItem.rightBarButtonItem = self.selectButton;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrFileName.count;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateButtonsToMatchTableState];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MSCMoreOptionImageViewCell";
    MSCMoreOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    
    [cell setConfigurationBlock:^(UIButton *deleteButton, UIButton *moreOptionButton, CGFloat *deleteButtonWitdh, CGFloat *moreOptionButtonWidth) {
       
        [moreOptionButton setTitle:nil forState:UIControlStateNormal];
        [moreOptionButton setImage:[UIImage imageNamed:@"Message.png"] forState:UIControlStateNormal];
        [moreOptionButton setImageEdgeInsets:UIEdgeInsetsMake(0.f, 20.f, 0.f, 20.f)];
        [moreOptionButton setBackgroundColor:[UIColor colorWithRed:58.0f/255.0f green:79.0f/255.0f blue:104.0f/255.0f alpha:1.0]];
       
        [deleteButton setTitle:nil forState:UIControlStateNormal];
        [deleteButton setImage:[UIImage imageNamed:@"Trash.png"] forState:UIControlStateNormal];
        [deleteButton setImageEdgeInsets:UIEdgeInsetsMake(0.f, 20.f, 0.f, 20.f)];
       [deleteButton setBackgroundColor:[UIColor colorWithRed:58.0f/255.0f green:79.0f/255.0f blue:104.0f/255.0f alpha:1.0]];
    }];
    
    cell.textLabel.text = arrFileName[indexPath.row];

    cell.imageView.image = [UIImage imageWithData:arrFileData[indexPath.row]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    cell.imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/3);
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView.visibleCells enumerateObjectsUsingBlock:^(MSCMoreOptionTableViewCell *cell, NSUInteger idx, BOOL *stop) {
            if ([[tableView indexPathForCell:cell] isEqual:indexPath]) {
                [cell hideDeleteConfirmation];
                NSString *myFileName = arrFileName[idx];
                [self createDeleteAlert: [myFileName lastPathComponent]];
            }
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.height/3;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.directoryTableView.editing)
    {
        [self updateButtonsToMatchTableState];
    }
    else {
      //  [tableView deselectRowAtIndexPath:indexPath animated:YES];
        ImageScrollViewController *imageScrollView = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageScrollView"];
        imageScrollView.imageData = arrFileData[indexPath.row];
        imageScrollView.imageFile = arrFileName[indexPath.row];
        imageScrollView.curDirPath = directoryPath;
        [Utility setCurrentFileName:arrFileName[indexPath.row]];
        
        [self.navigationController pushViewController:imageScrollView animated:YES];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MSCMoreOptionTableViewCellDelegate
////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView moreOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath {
    // Called when 'more' button is pushed.
    NSLog(@"MORE button pressed in row at: %@", indexPath.description);
    // Hide 'more'- and 'delete'-confirmation view
    [tableView.visibleCells enumerateObjectsUsingBlock:^(MSCMoreOptionTableViewCell *cell, NSUInteger idx, BOOL *stop) {
        if ([[tableView indexPathForCell:cell] isEqual:indexPath]) {
            [cell hideDeleteConfirmation];
            
            DocTableViewController *docTableView = [[DocTableViewController alloc] init];
            docTableView.curDirPath = directoryPath;
            docTableView.fileName = arrFileName[idx];
            
            [self.navigationController pushViewController:docTableView animated:YES];
        }
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"More";
}

- (void) createDeleteAlert: (NSString*) fileName
{
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete"
                                                                   message:@"Confirm Delete"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                 
                                   NSLog(@"OK action");
                                   [Utility deleteFileUnderDir: directoryPath :fileName];
                                   NSLog(@"end action");
                                   [self preloadCellData];
                                   [self.directoryTableView reloadData];
                                   [self.directoryTableView setEditing:NO animated:YES];
                                   [self updateButtonsToMatchTableState];
                               }];
    
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
