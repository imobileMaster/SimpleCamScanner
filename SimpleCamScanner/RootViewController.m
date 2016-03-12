//
//  RootViewController.m
//  SimpleCamScanner
//
//  Created by iPhoneGang on 3/5/16.
//  Copyright © 2016 iPhone Max Developer. All rights reserved.
//

#import "RootViewController.h"
#import "MSCMoreOptionTableViewCell.h"
//#import "AAPLCameraViewController.h"
#import "ImageDirectoryViewController.h"
#import "DocTableViewController.h"
#import "ViewController.h"

@interface RootViewController() <UITableViewDataSource, UITableViewDelegate, MSCMoreOptionTableViewCellDelegate, UIActionSheetDelegate>
{

}

@property (nonatomic, strong) IBOutlet UIBarButtonItem *selectButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *selectAllButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *DeselectAllButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mergeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *emailButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

@property (weak, nonatomic) IBOutlet UIToolbar *myToolbar;
@property (weak, nonatomic) IBOutlet UIButton *goToTop;

@end

@implementation RootViewController

@synthesize imageTableView;
@synthesize goToTop;

#pragma mark - UITableViewDelegate

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     This option is also selected in the storyboard. Usually it is better to configure a table view in a xib/storyboard, but we're redundantly configuring this in code to demonstrate how to do that.
     */
    self.imageTableView.allowsMultipleSelectionDuringEditing = YES;
    
    // populate the data array with some example objects
    self.dataArray = [NSMutableArray new];
    NSString *itemFormatString = NSLocalizedString(@"Project %d", @"Format string for item");
    for (unsigned int itemNumber = 1; itemNumber <= 1; itemNumber++)
    {
        NSString *itemName = [NSString stringWithFormat:itemFormatString, itemNumber];
        itemName = @"Project 01";
        [self.dataArray addObject:itemName];
    }
    
    imageTableView.dataSource = self;
    imageTableView.delegate = self;
    
    // make our view consistent
    [self updateButtonsToMatchTableState];
 
}

- (void) viewWillAppear:(BOOL)animated
{
    [Utility setTakeType:1];
    [imageTableView reloadData];
    [self updateButtonsToMatchTableState];
}

- (IBAction)deleteDirectory:(id)sender
{

    NSArray *selectedRows = [self.imageTableView indexPathsForSelectedRows];
    BOOL deleteSpecificRows = selectedRows.count > 0;
    if (deleteSpecificRows)
    {
        NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            [indicesOfItemsToDelete addIndex:selectionIndex.row];
        }
        [self groupDelete:indicesOfItemsToDelete];
    }

}

- (void) groupDelete: (NSMutableIndexSet*) indicesOfDirs
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
                                   [Utility deleteDirectorys:indicesOfDirs];
                                   [self.imageTableView reloadData];
                                   [self.imageTableView setEditing:NO animated:YES];
                                    [self updateButtonsToMatchTableState];
                               }];
    
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) __sendEmail: (NSInteger) idx
{
    DocTableViewController *docTableView = [[DocTableViewController alloc] init];
    NSFileManager *sharedFM = [NSFileManager defaultManager];
    NSArray *paths = [sharedFM URLsForDirectory:NSLibraryDirectory
                                      inDomains:NSUserDomainMask];
    
    NSURL *directoryPath;
    NSString* dirName = [[Utility getDirectoryList][idx] objectForKey:@"name"];
    if ([paths count] > 0) {
        NSURL *libraryPath = paths[0];
        directoryPath = [libraryPath
                         URLByAppendingPathComponent:dirName ];
    }
    
    NSArray *info =  [Utility makeZipFile:[directoryPath path]];
    
    docTableView.curDirPath = info[0];
    docTableView.fileName = info[1];
    docTableView.fileName__ = info[2];
    docTableView.isZip = @"zip";
    
    [self.navigationController pushViewController:docTableView animated:YES];
}


- (IBAction)sendEmail:(id)sender {

    NSArray *selectedRows = [self.imageTableView indexPathsForSelectedRows];
    
    if (selectedRows.count == 1) {
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            [self __sendEmail: selectionIndex.row];
        }
    }
    else {
        NSString* dirName;
        NSFileManager *sharedFM = [NSFileManager defaultManager];
        NSArray *paths = [sharedFM URLsForDirectory:NSLibraryDirectory
                                          inDomains:NSUserDomainMask];
        
        NSURL *newDir;
        if ([paths count] > 0) {
            NSURL *libraryPath = paths[0];
            dirName = [NSString stringWithFormat:@"newDir"];
            
            newDir = [libraryPath
                      URLByAppendingPathComponent:dirName];
            
            if ([sharedFM fileExistsAtPath:[newDir path]]) {
                [Utility deleteAllFileUnderDir:[newDir path]];
                [sharedFM removeItemAtPath:[newDir path] error:nil];
            }
            
            NSError *error = nil;
            BOOL success = [sharedFM createDirectoryAtURL:newDir
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
            if (!success)
                NSLog(@"temp folder create error");
        }
        
        
        BOOL deleteSpecificRows = selectedRows.count > 0;
        if (deleteSpecificRows)
        {
            NSMutableIndexSet *indicesOfItemsToEmail = [NSMutableIndexSet new];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                [indicesOfItemsToEmail addIndex:selectionIndex.row];
            }
            [Utility mergeDirectoryWithNewDir:[newDir path] :indicesOfItemsToEmail];
            
            NSArray *info =  [Utility makeZipFile:[newDir path]];
            
            DocTableViewController *docTableView = [[DocTableViewController alloc] init];
            docTableView.curDirPath = info[0];
            docTableView.fileName = info[1];
            docTableView.fileName__ = info[2];
            docTableView.isZip = @"zip";
            
            [self.navigationController pushViewController:docTableView animated:YES];
        }
    }
}
- (IBAction)MergeDirectory:(id)sender {
    
    // Open a dialog with just an OK button.
    NSString *actionTitle;
     actionTitle = NSLocalizedString(@"merge project?", @"");
    
    NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel title for item removal action");
    NSString *okTitle = NSLocalizedString(@"OK", @"OK title for item removal action");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
                                                             delegate:self
                                                    cancelButtonTitle:cancelTitle
                                               destructiveButtonTitle:okTitle
                                                    otherButtonTitles:nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    
    // Show from our table view (pops up in the middle of the table).
    [actionSheet showInView:self.view];
}
- (IBAction)goToTopView:(id)sender {

//    AAPLCameraViewController *aaCameraController = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    ViewController *aaCameraController = [self.storyboard instantiateViewControllerWithIdentifier:@"IPFCameraView"];
    [self presentViewController:aaCameraController animated:YES completion:nil];
}

#pragma mark - Action methods

- (IBAction)selectAction:(id)sender
{
    [self.imageTableView setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)cancelAction:(id)sender
{
    [self.imageTableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // The user tapped one of the OK/Cancel buttons.
    if (buttonIndex == 0)
    {
        // Delete what the user selected.
        NSArray *selectedRows = [self.imageTableView indexPathsForSelectedRows];
        BOOL deleteSpecificRows = selectedRows.count > 0;
        if (deleteSpecificRows)
        {
            // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
            NSMutableIndexSet *indicesOfItemsToMerge = [NSMutableIndexSet new];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                [indicesOfItemsToMerge addIndex:selectionIndex.row];
                
                
            }
            
            [Utility mergeDirectory:indicesOfItemsToMerge];
            
            // Tell the tableView that we deleted the objects
            [self.imageTableView reloadData];
        }
        else
        {
            // Tell the tableView that we deleted the objects.
            // Because we are deleting all the rows, just reload the current table section
            [self.imageTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        // Exit editing mode after the deletion.
        [self.imageTableView setEditing:NO animated:YES];
        [self updateButtonsToMatchTableState];
    }
}

- (IBAction)DeselectAllAction:(id)sender {
    [[Utility getDirectoryList] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSMutableDictionary *dic, NSUInteger index, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        [self.imageTableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    [self updateButtonsToMatchTableState];

}


- (IBAction)SelectAllAction:(id)sender
{
    [[Utility getDirectoryList] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSMutableDictionary *dic, NSUInteger index, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        //    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.imageTableView selectRowAtIndexPath:indexPath
                                             animated:YES
                                       scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.imageTableView didSelectRowAtIndexPath:indexPath];
    }];
    
    [self updateButtonsToMatchTableState];
}


#pragma mark - Updating button state

- (void)updateButtonsToMatchTableState
{
    if (self.imageTableView.editing)
    {
        goToTop.hidden = YES;
        _myToolbar.hidden = NO;
        
        // Show the option to cancel the edit.
        self.navigationItem.rightBarButtonItem = self.cancelButton;
        
      //  [self updateDeleteButtonTitle];
        
        NSArray *selectedRows = [self.imageTableView indexPathsForSelectedRows];
        BOOL allItemsAreSelected = selectedRows.count == [Utility getDirectoryList].count;
      
        if (allItemsAreSelected) {
            self.navigationItem.leftBarButtonItem = self.DeselectAllButton;
        }
        else{
            self.navigationItem.leftBarButtonItem = self.selectAllButton;
        }
        if (selectedRows.count > 0) {
            self.emailButton.enabled = YES;
            self.mergeButton.enabled = YES;
            self.deleteButton.enabled = YES;
        }
        else
        {
            self.emailButton.enabled = NO;
            self.mergeButton.enabled = NO;
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
        if ([Utility getDirectoryList].count > 0)
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

- (void)updateDeleteButtonTitle
{
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.imageTableView indexPathsForSelectedRows];
    
    BOOL allItemsAreSelected = selectedRows.count == self.dataArray.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
    {
        self.selectAllButton.title = NSLocalizedString(@"Select All", @"");
    }
    else
    {
        NSString *titleFormatString =
        NSLocalizedString(@"Select (%d)", @"Title for select button with placeholder for number");
        self.selectAllButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [Utility getDirectoryList].count;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateButtonsToMatchTableState];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure a cell to show the corresponding string from the array.
    //   static NSString *kCellID = @"cellID";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    //	cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
        static NSString *identifier = @"MSCMoreOptionTableViewCell";
    MSCMoreOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    
    [cell setConfigurationBlock:^(UIButton *deleteButton, UIButton *moreOptionButton, CGFloat *deleteButtonWitdh, CGFloat *moreOptionButtonWidth) {
       
       
        
        [moreOptionButton setTitle:nil forState:UIControlStateNormal];
        [moreOptionButton setImage:[UIImage imageNamed:@"Message.png"] forState:UIControlStateNormal];
        [moreOptionButton setImageEdgeInsets:UIEdgeInsetsMake(0.f, 20.f, 0.f, 20.f)];
        [moreOptionButton setBackgroundColor:[UIColor colorWithRed:58.0f/255.0f green:79.0f/255.0f blue:104.0f/255.0f alpha:1.0]];
        // Set a trash icon as 'delete' button content on every fourth row
        ////      if (indexPath.row % 4 == 0) {
        [deleteButton setTitle:nil forState:UIControlStateNormal];
        [deleteButton setImage:[UIImage imageNamed:@"Trash.png"] forState:UIControlStateNormal];
        [deleteButton setImageEdgeInsets:UIEdgeInsetsMake(0.f, 20.f, 0.f, 20.f)];
        [deleteButton setBackgroundColor:[UIColor colorWithRed:58.0f/255.0f green:79.0f/255.0f blue:104.0f/255.0f alpha:1.0]];
       
    }];
    
    NSString *strText = [[[Utility getDirectoryList] objectAtIndex:indexPath.row] objectForKey:@"name"];
    NSString* subtitle = [[[Utility getDirectoryList] objectAtIndex:indexPath.row] objectForKey:@"date"];
    subtitle = [NSString stringWithFormat:@"%@  %ld", subtitle, (long)[Utility getFileListUnderDir:strText].count];
    
    NSMutableAttributedString* attri = [[NSMutableAttributedString alloc] initWithString:subtitle];
    
    NSUInteger len = subtitle.length;
    NSUInteger sublen = [NSString stringWithFormat:@"%ld", (long)[Utility getFileListUnderDir:strText].count].length;
    [attri addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(len-sublen, sublen)];
    [attri addAttribute:NSFontAttributeName value: [UIFont systemFontOfSize:15] range:NSMakeRange(len-sublen, sublen)];
    cell.textLabel.text = strText;
    cell.detailTextLabel.attributedText = attri;
    
    NSFileManager *fManager = [NSFileManager defaultManager];
    NSArray *paths = [fManager URLsForDirectory:NSLibraryDirectory
                                      inDomains:NSUserDomainMask];
    
    NSURL *templatesPath;
    if ([paths count] > 0) {
        NSURL *libraryPath = paths[0];
        
        templatesPath = [libraryPath
                         URLByAppendingPathComponent:strText];
    }
    NSString *item;
    NSArray *contents = [fManager contentsOfDirectoryAtPath:[templatesPath path] error:nil];
    
   
    NSString* filePath;
    for (item in contents){
        if ([[item pathExtension] isEqualToString:@"jpg"]) {
          
            filePath = [NSString stringWithFormat:@"%@/%@", [templatesPath path], item];
            break;
        }
    }

    UIImage *image = [UIImage imageNamed:filePath];
    if (!image) {
        image = [UIImage imageNamed:@"test.png"];
    }
    cell.imageView.image = image;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Called when 'delete' button is pushed.
        NSLog(@"DELETE button pressed in row at: %@", indexPath.description);
        // Hide 'more'- and 'delete'-confirmation view
        [tableView.visibleCells enumerateObjectsUsingBlock:^(MSCMoreOptionTableViewCell *cell, NSUInteger idx, BOOL *stop) {
            if ([[tableView indexPathForCell:cell] isEqual:indexPath]) {
                [cell hideDeleteConfirmation];
                [self createDeleteAlert: idx];
            }
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0f;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.imageTableView.editing)
    {
        [self updateButtonsToMatchTableState];
    }
    else {
        ImageDirectoryViewController *imageDirectoryView = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageDirectoryView"];
        
        goToTop.hidden = YES;
        
        NSNumber* dirNumber = [[[Utility getDirectoryList] objectAtIndex:indexPath.row] objectForKey:@"num"];
        [Utility setCurrentDirectory: [dirNumber integerValue]];
        imageDirectoryView.directoryNumber = dirNumber;
        
        imageDirectoryView.directoryPath = [Utility getCurrentDirectoryPathFromNumber: indexPath.row];
        [self.navigationController pushViewController:imageDirectoryView animated:YES];
        //        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MSCMoreOptionTableViewCellDelegate
////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView moreOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath {
   
    [tableView.visibleCells enumerateObjectsUsingBlock:^(MSCMoreOptionTableViewCell *cell, NSUInteger idx, BOOL *stop) {
        if ([[tableView indexPathForCell:cell] isEqual:indexPath]) {
            [cell hideDeleteConfirmation];
            [self __sendEmail: idx];
        }
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"More";
}

- (void) createDeleteAlert: (NSInteger) dirNumber
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
                                   [Utility deleteAllFileUnderDir: [[[Utility getDirectoryList] objectAtIndex:dirNumber] objectForKey:@"name"]];
                                   
                                   NSNumber* _dirNumber = [[[Utility getDirectoryList] objectAtIndex:dirNumber] objectForKey:@"num"];
                                   
                                   [Utility deleteDirectoryNumber:[_dirNumber integerValue]];
                                   [self.imageTableView reloadData];
                                   [self.imageTableView setEditing:NO animated:YES];
                                   [self updateButtonsToMatchTableState];
                               }];
    
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}


@end
