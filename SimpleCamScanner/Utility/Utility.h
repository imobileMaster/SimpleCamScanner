//
//  Utility.h
//  AVCam
//
//  Created by iPhoneGang on 3/5/16.
//
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+ (void) initWithKey: (NSString*) key;
+(void) addDirectoryNumber: (NSInteger) newDirNumber;
+ (void) deleteDirectoryNumber: (NSInteger)dirNumber;
+ (void) deleteDirectoryName: (NSString*)dirName;
+ (void) deleteFileUnderDir: (NSString*) dirName : (NSString*) fileName;
+ (void) deleteFiles: (NSString*) dirPath : (NSInteger) dirNumber : (NSArray*) indicesOfFiles;
+ (void) deleteAllFileUnderDir: (NSString*) dirName;
+ (void) saveTempData: (NSData*) tempData;
+ (NSData*) getTempData: (NSData*) tempData;
+ (NSData*) savePDFFile: (NSData*) imageData : (NSString*) filePath : (NSString*) dirName;

+(NSInteger) getCurrentDirectoryNumber;
+(void) setCurrentDirectoryNumber: (NSInteger) curDirNum;
+ (NSString*) getCurrentDirectoryPath;
+(NSString*) getCurrentDirectoryPathFromNumber: (NSInteger) dirNumber;
+ (void) setCurrentDirectoryPath: (NSString*) dirName;
+ (NSString*) createDirectoryPath;
+ (void) setCurrentDirectory: (NSInteger) dirNumber;
+ (NSString*) getCurrentDirectory;
+ (NSInteger) getAvailableNumberWithKey: (NSString*) key;
+ (NSString*) getCurrentTime;
+ (NSMutableArray*) getDirectoryList;

+ (void) addFileNumberUnderDir: (NSString*) dirName : (NSInteger) newFileNumber;
+ (NSArray*) getFileListUnderDir: (NSString*) dirName;
+ (NSString*) createFileNameUnderDir: (NSString*) dirName;
+ (NSString*) getCurrentFileNameUnderDir: (NSString*) dirName;
+ (void) setCurrentFileNameUnderDir: (NSString*) dirName : (NSInteger) fileNumber;
+ (void) setCurrentFilePath: (NSString*) curFilePath;
+ (NSString*) getCurrentFilePath;
+ (void) setCurrentFileNumber: (NSInteger) fineNumber;
+ (NSInteger) getCurrentFileNumber;

+ (void) setCurrentFileName: (NSString*) fileName;
+ (NSString*) getCurrentFileName;

/***
* 1: Take a photo in new Folder
* 2: Take a photo in existing Folder
* 3: Retake a photo
***/
+ (void) setTakeType: (NSInteger) type;
+ (NSInteger) getTakeType;

+ (void) mergeDirectory: (NSMutableIndexSet*) indicesOfDirs;
+ (void) deleteDirectorys: (NSMutableIndexSet*) indicesOfDirs;

// zip file making
+ (void) mergeDirectoryWithNewDir: (NSString*) newDir : (NSMutableIndexSet *)indicesOfDirs;
+ (NSArray*) makeZipFile:(NSString *)dirPath;
+ (NSArray*) makeZipFileWithSpecific:(NSString *)dirPath : (NSArray*) indicesOfItemsToEmail;

// clipboard
- (void) copyFileToClipboard: (NSString*) fileUrl;
- (void) pastFileFromClipboard: (NSString*) fileUrl;
@end

