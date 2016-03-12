//
//  Utility.m
//  AVCam
//
//  Created by iPhoneGang on 3/5/16.
//
//

#import "Utility.h"
#import "PDFImageConverter.h"
#import "Objective-Zip.h"

@implementation Utility

+ (void) initWithKey: (NSString*) key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *array = [[defaults arrayForKey:key] mutableCopy];
    
    if (!array) {
        [defaults setObject:array forKey:key];
        [defaults synchronize];
        
        NSLog(@"dir initialise");
    }
}



+(NSString*) getCurrentTime
{
    // get current local time
    NSDate* sourceDate = [NSDate date];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* currentDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter2 setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    NSString *strDate = [dateFormatter2 stringFromDate:currentDate];
    
    return strDate;
}

+(void) addDirectoryNumber: (NSInteger) newDirNumber
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *array = [[defaults arrayForKey:@"dirArray"] mutableCopy];
    NSNumber *myNum = [NSNumber numberWithLong:newDirNumber];
    
        
    NSString *strDate = [Utility getCurrentTime];
    NSString *dirName = [NSString stringWithFormat:@"Project %li", (long)newDirNumber];
    
    NSDictionary *dic = @{@"num": myNum, @"date": strDate, @"name": dirName};
    if (!array) {
        array = [NSMutableArray arrayWithObjects:dic, nil];
    }
    else{
        [array addObject:dic];
    }
   
    [defaults setObject:array forKey:@"dirArray"];
    [defaults synchronize];
}

+ (void) deleteDirectoryNumber: (NSInteger)dirNumber
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
     NSMutableArray *array = [[defaults arrayForKey:@"dirArray"] mutableCopy];
    
    if (!array) {
        return;
    }
    [array enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSMutableDictionary *dic, NSUInteger index, BOOL *stop) {
        if (dirNumber == [[dic valueForKey:@"num"] integerValue]) {
            [array removeObjectAtIndex:index];
        }
    }];
    
    [defaults setObject:array forKey:@"dirArray"];
    [defaults synchronize];

}

+ (void) deleteDirectoryName: (NSString*)dirName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *array = [[defaults arrayForKey:@"dirArray"] mutableCopy];
    
    if (!array) {
        return;
    }
    [array enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSMutableDictionary *dic, NSUInteger index, BOOL *stop) {
        NSString* temp = [dic valueForKey:@"name"];
        if ([dirName isEqualToString: temp]) {
            [array removeObjectAtIndex:index];
        }
    }];
    
    [defaults setObject:array forKey:@"dirArray"];
    [defaults synchronize];
    
}

+ (void) deleteAllFileUnderDir: (NSString*) dirName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        NSString *item;
        NSFileManager *sharedFM = [NSFileManager defaultManager];
        NSArray *paths = [sharedFM URLsForDirectory:NSLibraryDirectory
                                          inDomains:NSUserDomainMask];
        
        NSURL *directoryPath;
        if ([paths count] > 0) {
            NSURL *libraryPath = paths[0];
            directoryPath = [libraryPath
                             URLByAppendingPathComponent:dirName];
        }
        NSArray *contents = [sharedFM contentsOfDirectoryAtPath:[directoryPath path] error:nil];
        
        for (item in contents){
           
                NSString* filePath = [NSString stringWithFormat:@"%@/%@", [directoryPath path], item];
                                NSError* error;
                BOOL success =[sharedFM copyItemAtPath:filePath toPath:filePath error:&error];
                if (!success) {
                    NSLog(@"%@", error);
                }
        }
 
    
    [defaults setObject:nil forKey:dirName];
    [defaults synchronize];
}

+ (void) deleteFileUnderDir: (NSString*) dirName : (NSString*) fileName
{
    NSFileManager *sharedFM = [NSFileManager defaultManager];
    NSArray *paths = [sharedFM URLsForDirectory:NSLibraryDirectory
                                      inDomains:NSUserDomainMask];
    
    NSURL *directoryPath;
    if ([paths count] > 0) {
        NSURL *libraryPath = paths[0];
        directoryPath = [libraryPath
                         URLByAppendingPathComponent:[dirName lastPathComponent] ];

        NSString* filePath = [NSString stringWithFormat:@"%@/%@.jpg", [directoryPath path], fileName];
    
        NSString* filePath1 = [NSString stringWithFormat:@"%@/%@.pdf", [directoryPath path], fileName];
            
        NSError* error;
        BOOL success =[sharedFM removeItemAtPath:filePath error:&error];
        success =[sharedFM removeItemAtPath:filePath1 error:&error];
        if (!success) {
            NSLog(@"%@", error);
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSMutableArray *array = [[defaults arrayForKey:[dirName lastPathComponent]] mutableCopy];
        
        if (!array) {
            return;
        }
        [array enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSMutableDictionary *dic, NSUInteger index, BOOL *stop) {
            long temp = [[dic valueForKey:@"num"] intValue];
            if ([fileName intValue] ==  temp) {
                [array removeObjectAtIndex:index];
            }
        }];
        
        [defaults setObject:array forKey:[dirName lastPathComponent]];
        [defaults synchronize];


    }
}

+ (NSMutableArray*) getDirectoryList{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *array = [[defaults arrayForKey:@"dirArray"] mutableCopy];
    return array;
}

+(NSInteger) getCurrentDirectoryNumber
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger curDir = [defaults integerForKey:@"curDirNum"];
    
    return curDir;
}

+(void) setCurrentDirectoryNumber: (NSInteger) curDirNum
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:curDirNum forKey:@"curDirNum"];
    
    [defaults synchronize];
}

+ (void) saveTempData: (NSData*) tempData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:tempData forKey:@"tempData"];
    
    [defaults synchronize];
}

+ (NSData*) getTempData: (NSData*) tempData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *data = [defaults dataForKey:@"tempData"];
    
    return data;
}

+ (NSData*) savePDFFile: (NSData*) imageData : (NSString*) filePath : (NSString*) dirName
{
    NSData *pdfData = [PDFImageConverter convertImageToPDF: [UIImage imageWithData:imageData]                               withHorizontalResolution: 300 verticalResolution: 300];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@.pdf", filePath, dirName];
    
    NSLog(@"after: %@\n\n", path);
    
    [pdfData writeToFile:path atomically:YES];

    return pdfData;
}

+ (NSString*) createDirectoryPath
{
    NSString* dirName;
    NSFileManager *sharedFM = [NSFileManager defaultManager];
    NSArray *paths = [sharedFM URLsForDirectory:NSLibraryDirectory
                                      inDomains:NSUserDomainMask];
    
    NSURL *templatesPath;
    if ([paths count] > 0) {
        NSURL *libraryPath = paths[0];
        NSInteger dirNumber = [Utility getAvailableNumberWithKey:@"dirArray"];
        dirName = [NSString stringWithFormat:@"Project %li", (long)dirNumber];
        
        templatesPath = [libraryPath
                         URLByAppendingPathComponent:dirName];
        
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:templatesPath
                                                withIntermediateDirectories:YES
                                                                 attributes:nil
                                                                      error:&error];
        
        NSLog(@"@@@@@@@@@@@@@@@@@@after %@", [templatesPath path]);
        if (success) {
            [Utility setCurrentDirectoryPath:[templatesPath path]];
            [Utility setCurrentDirectoryNumber:dirNumber];
            [Utility setCurrentDirectory:dirNumber];
            return [templatesPath path];
        }
        else
            return nil;
    }
    
    return nil;
}

+ (void) setCurrentDirectory: (NSInteger) dirNumber
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *str = [NSString stringWithFormat:@"Project %li", (long)dirNumber];
    
    [defaults setObject:str forKey:@"curDir"];
    
    [defaults synchronize];
}

+ (NSString*) getCurrentDirectory
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* curDir = [defaults objectForKey:@"curDir"];
    return curDir;
}

+ (void) setCurrentDirectoryPath: (NSString*) dirPath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:dirPath forKey:@"curDirPath"];
    
    [defaults synchronize];
}

+ (NSString*) getCurrentDirectoryPath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* curDirPath = [defaults objectForKey:@"curDirPath"];
    return curDirPath;
}

+(NSString*) getCurrentDirectoryPathFromNumber: (NSInteger) dirNumber
{
    NSFileManager *sharedFM = [NSFileManager defaultManager];
    NSArray *paths = [sharedFM URLsForDirectory:NSLibraryDirectory
                                      inDomains:NSUserDomainMask];
    NSString *curDirPath = nil;
    
    NSString* dirName = [[[Utility getDirectoryList] objectAtIndex:dirNumber] objectForKey:@"name"];

    if ([paths count] > 0) {
        NSURL *libraryPath = paths[0];
        
        curDirPath = [[libraryPath
                         URLByAppendingPathComponent:dirName] path];

    }
    
    return curDirPath;
}

+ (NSInteger) getAvailableNumberWithKey: (NSString*) key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *array = [[defaults arrayForKey:key] mutableCopy];
    
    if (!array || array.count == 0) {
        if ([key isEqualToString:@"dirArray"]) {
            [Utility addDirectoryNumber: 1];
        }
        else
        {
    //        [Utility addFileNumberUnderDir:key :1];
        }
        return 1;
    }
    
    NSArray *sorted = [array sortedArrayUsingComparator:^NSComparisonResult(NSMutableDictionary *obj1, NSMutableDictionary *obj2) {
        
        if ([[obj1 valueForKey:@"num"] integerValue] > [[obj2 valueForKey:@"num"] integerValue]) return NSOrderedDescending;
        else return NSOrderedAscending;
    }];
    
    NSLog(@"%@", sorted);
    
    NSInteger dirNumber = array.count+1;
    NSInteger i;
    for (i = 1; i <= array.count; i++) {
        if (![key isEqualToString:@"dirArray"])
        {
            NSString* item = [sorted[i-1] valueForKey:@"filePath"];
            if ([item rangeOfString:@"jpg"].location != NSNotFound)
                if (i != [[sorted[i-1] valueForKey:@"num"] integerValue]) {
                dirNumber = i;
                break;
            }
        }
        else if (i != [[sorted[i-1] valueForKey:@"num"] integerValue]) {
            dirNumber = i;
            break;
        }
    }
    
    if ([key isEqualToString:@"dirArray"]) {
        [Utility addDirectoryNumber: dirNumber];

    }
    return dirNumber;
}

// File name
+ (NSString*) createFileNameUnderDir: (NSString*) dirName
{
    NSString *fileName;
    
    NSInteger fileNumber = [Utility getAvailableNumberWithKey:dirName];
    fileName = [NSString stringWithFormat:@"%li", (long)fileNumber];
    
    [Utility addFileNumberUnderDir:dirName : fileNumber];
    return fileName;
}

+ (void) setCurrentFilePath: (NSString*) curFilePath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:curFilePath forKey:@"curFile"];
    
    [defaults synchronize];
}

+ (NSString*) getCurrentFilePath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* curFilePath = [defaults objectForKey:@"curFile"];
    return curFilePath;
}

+(void) addFileNumberUnderDir: (NSString*) dirName : (NSInteger) newFileNumber
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *array = [[defaults arrayForKey:dirName] mutableCopy];
    
    
    NSNumber *myNum = [NSNumber numberWithInteger:newFileNumber];
    
    
    NSString *strDate = [Utility getCurrentTime];
    
    NSFileManager *sharedFM = [NSFileManager defaultManager];
    NSArray *paths = [sharedFM URLsForDirectory:NSLibraryDirectory
                                      inDomains:NSUserDomainMask];
    
    NSURL *templatesPath;
    if ([paths count] > 0) {
        NSURL *libraryPath = paths[0];
        
        templatesPath = [libraryPath
                         URLByAppendingPathComponent:dirName];
        
    }
    NSString *filePath = [NSString stringWithFormat:@"%@/%li.jpg", [templatesPath path], (long)newFileNumber];
  
    
    NSDictionary *dic = @{@"num": myNum, @"date": strDate, @"filePath": filePath};
    
    if (!array) {
        array = [[NSMutableArray alloc] init];
    }
    
    [array addObject:dic];
    
    
    [defaults setObject:array forKey:dirName];
    [defaults synchronize];
 
    
    [Utility setCurrentFileNameUnderDir:dirName :newFileNumber];
}

+ (NSString*) getCurrentFileNameUnderDir: (NSString*) dirName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger fileNumber = [defaults integerForKey:@"curFileName"];
    
    return [NSString stringWithFormat:@"%li", (long)fileNumber];
}

+ (void) setCurrentFileNameUnderDir: (NSString*) dirName : (NSInteger) fileNumber
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
 
    [defaults setInteger:fileNumber forKey:@"curFileName"];
    [defaults synchronize];
}

+ (NSArray*) getFileListUnderDir: (NSString*) dirName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *array = [[defaults arrayForKey:dirName] mutableCopy];
    if (!array) {
        [defaults setObject:nil forKey:dirName];
        [defaults synchronize];
        
        NSLog(@"file list initialise");
    }
    
    return  array;
}

+ (void) setTakeType: (NSInteger) type
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:type  forKey:@"takeType"];
    [defaults synchronize];
}

+ (NSInteger) getTakeType
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger type = [defaults integerForKey:@"takeType"];
    
    return type;
}

+ (void) setCurrentFileName: (NSString*) fileName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:fileName forKey:@"curFile"];
    [defaults synchronize];
}

+ (NSString*) getCurrentFileName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *fileName = [defaults objectForKey:@"curFile"];
    
    return fileName;
}

+ (void) mergeDirectoryWithNewDir: (NSString*) newDir : (NSMutableIndexSet *)indicesOfDirs
{
    NSInteger fileNumber = 0;
    for (NSInteger i = 0; i < indicesOfDirs.count; i++) {
        NSString *dirName = [NSString stringWithString:[[Utility getDirectoryList][i] objectForKey:@"name"]];
        
        NSString *item;
        NSFileManager *sharedFM = [NSFileManager defaultManager];
        NSArray *paths = [sharedFM URLsForDirectory:NSLibraryDirectory
                                          inDomains:NSUserDomainMask];
        
        NSURL *directoryPath;
        if ([paths count] > 0) {
            NSURL *libraryPath = paths[0];
            directoryPath = [libraryPath
                             URLByAppendingPathComponent:dirName];
        }
        NSArray *contents = [sharedFM contentsOfDirectoryAtPath:[directoryPath path] error:nil];
        
        for (item in contents){
                fileNumber++;
                NSString* filePath = [NSString stringWithFormat:@"%@/%@", [directoryPath path], item];
                NSLog(@"path %@", filePath);
                NSString* toFilePath = [NSString stringWithFormat:@"%@/%@", newDir, item];
                
                NSError* error;
                BOOL success =[sharedFM copyItemAtPath:filePath toPath:toFilePath error:&error];
                if (!success) {
                    NSLog(@"%@", error);
                }
        }
    }
}

+ (void) mergeDirectory: (NSMutableIndexSet*) indicesOfDirs
{
    NSString* newDir = [Utility createDirectoryPath];
    NSInteger fileNumber = 0;
    for (NSInteger i = 0; i < indicesOfDirs.count; i++) {
        NSString *dirName = [NSString stringWithString:[[Utility getDirectoryList][i] objectForKey:@"name"]];
        
        NSString *item;
        NSFileManager *sharedFM = [NSFileManager defaultManager];
        NSArray *paths = [sharedFM URLsForDirectory:NSLibraryDirectory
                                          inDomains:NSUserDomainMask];
        
        NSURL *directoryPath;
        if ([paths count] > 0) {
            NSURL *libraryPath = paths[0];
            directoryPath = [libraryPath
                             URLByAppendingPathComponent:dirName];
        }
        NSArray *contents = [sharedFM contentsOfDirectoryAtPath:[directoryPath path] error:nil];
        
        for (item in contents){
            NSRange range = NSMakeRange (item.length-4, item.length-1);
            NSString* ext = [item substringWithRange:range];
        //    if ([ext isEqualToString:@".jpg"]) {
                fileNumber++;
                NSString* filePath = [NSString stringWithFormat:@"%@/%@", [directoryPath path], item];
                NSLog(@"path %@", filePath);
                NSString* toFilePath = [NSString stringWithFormat:@"%@/%ld.jpg", newDir, (long)fileNumber];
                
                NSError* error;
                BOOL success =[sharedFM copyItemAtPath:filePath toPath:toFilePath error:&error];
                if (!success) {
                    NSLog(@"%@", error);
                }
                [Utility addFileNumberUnderDir:dirName : fileNumber];
        //    }
        }
    }
}

+ (void) deleteDirectorys: (NSMutableIndexSet*) indicesOfDirs
{
    for (NSInteger i = 0; i < indicesOfDirs.count; i++) {
        NSString *dirName = [NSString stringWithString:[[Utility getDirectoryList][i] objectForKey:@"name"]];
        [Utility deleteAllFileUnderDir:dirName];
        [Utility deleteDirectoryName:dirName];
    }
}

+ (void) deleteFiles: (NSString*) dirPath : (NSInteger) dirNumber : (NSArray*) indicesOfFiles
{
    NSFileManager *sharedFM = [NSFileManager defaultManager];
    NSString *item;
    NSString* dirName = [dirPath lastPathComponent];
    
    for (NSInteger i = 0; i < indicesOfFiles.count; i++) {
        
        for (item in indicesOfFiles){
            
             NSString* filePath1 = [NSString stringWithFormat:@"%@/%@.jpg",dirPath, item];
             NSString* filePath2 = [NSString stringWithFormat:@"%@/%@.pdf",dirPath, item];
            NSError* error;
            BOOL success =[sharedFM removeItemAtPath:filePath1 error:&error];
            success =[sharedFM removeItemAtPath:filePath2 error:&error];
            if (!success) {
                NSLog(@"%@", error);
            }
            
            // rearrange available filename
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            NSMutableArray *array = [[defaults arrayForKey:dirName] mutableCopy];
            
            if (!array || array.count == 0) {
                return;
            }
            [array enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSMutableDictionary *dic, NSUInteger index, BOOL *stop) {
                long temp = [[dic valueForKey:@"num"] intValue];
                if ([item intValue] ==  temp) {
                    [array removeObjectAtIndex:index];
                }
            }];
            
            [defaults setObject:array forKey:dirName];
            [defaults synchronize];

        }
    }
}

+ (NSArray*) makeZipFile:(NSString *)dirPath
{
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:Nil];
    NSString* zipName = [dirPath lastPathComponent];
    
    NSString* pdfZipName = [NSString stringWithFormat:@"%@_pdf", zipName];
    NSString* jpgZipName = [NSString stringWithFormat:@"%@_jpg", zipName];
    
    NSString *dirName;
    
    //ZIP Dir Create
    NSFileManager *sharedFM = [NSFileManager defaultManager];
    NSArray *paths = [sharedFM URLsForDirectory:NSLibraryDirectory
                                      inDomains:NSUserDomainMask];
    
    NSURL *templatesPath;
    if ([paths count] > 0) {
        NSURL *libraryPath = paths[0];
        dirName = [NSString stringWithFormat:@"ZIP FOLDER"];
        
        templatesPath = [libraryPath
                         URLByAppendingPathComponent:dirName];
        
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:templatesPath
                                                withIntermediateDirectories:YES
                                                                 attributes:nil
                                                                      error:&error];
        if (!success)
            NSLog(@"zip folder create error");
    }
   
    NSString *zipDirPath = [templatesPath path];
    NSString *pdfZipfilePath= [NSString stringWithFormat:@"%@/%@.zip", zipDirPath, pdfZipName];
    NSString *jpgZipfilePath= [NSString stringWithFormat:@"%@/%@.zip", zipDirPath, jpgZipName];
    
       
    OZZipFile *pdfZipFile= [[OZZipFile alloc] initWithFileName:pdfZipfilePath mode:OZZipFileModeCreate];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
         if ([filename rangeOfString:@"pdf"].location != NSNotFound) {
             NSString * filePath_iter = [NSString stringWithFormat:@"%@/%@", dirPath, filename];
             NSData *output = [NSData dataWithContentsOfFile:filePath_iter];
             
             OZZipWriteStream *stream= [pdfZipFile writeFileInZipWithName:filename fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:OZZipCompressionLevelBest];
            [stream writeData:output];
             
             [stream finishedWriting];
         }
        
    }];
    
    OZZipFile *jpgZipFile= [[OZZipFile alloc] initWithFileName:jpgZipfilePath mode:OZZipFileModeCreate];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        if ([filename rangeOfString:@"jpg"].location != NSNotFound) {
            NSString * filePath_iter = [NSString stringWithFormat:@"%@/%@", dirPath, filename];
            NSData *output = [NSData dataWithContentsOfFile:filePath_iter];
            
            OZZipWriteStream *stream= [jpgZipFile writeFileInZipWithName:filename fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:OZZipCompressionLevelBest];
            
            [stream writeData:output];
            
            [stream finishedWriting];
        }
    }];
    
    NSArray* arr =  [NSArray arrayWithObjects:zipDirPath, pdfZipName, jpgZipName, nil];
    
    return arr;
}

+ (NSArray*) makeZipFileWithSpecific:(NSString *)dirPath : (NSArray*) indicesOfItemsToEmail
{
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:Nil];
    NSString* zipName = [dirPath lastPathComponent];
    
    NSString* pdfZipName = [NSString stringWithFormat:@"%@_pdf", zipName];
    NSString* jpgZipName = [NSString stringWithFormat:@"%@_jpg", zipName];
    
    NSString *dirName;
    
    //ZIP Dir Create
    NSFileManager *sharedFM = [NSFileManager defaultManager];
    NSArray *paths = [sharedFM URLsForDirectory:NSLibraryDirectory
                                      inDomains:NSUserDomainMask];
    
    NSURL *templatesPath;
    if ([paths count] > 0) {
        NSURL *libraryPath = paths[0];
        dirName = [NSString stringWithFormat:@"ZIP FOLDER"];
        
        templatesPath = [libraryPath
                         URLByAppendingPathComponent:dirName];
        
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:templatesPath
                                                withIntermediateDirectories:YES
                                                                 attributes:nil
                                                                      error:&error];
        if (!success)
            NSLog(@"zip folder create error");
    }
    
    NSString *zipDirPath = [templatesPath path];
    NSString *pdfZipfilePath= [NSString stringWithFormat:@"%@/%@.zip", zipDirPath, pdfZipName];
    NSString *jpgZipfilePath= [NSString stringWithFormat:@"%@/%@.zip", zipDirPath, jpgZipName];
    
    
    OZZipFile *pdfZipFile= [[OZZipFile alloc] initWithFileName:pdfZipfilePath mode:OZZipFileModeCreate];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        if ([filename rangeOfString:@"pdf"].location != NSNotFound && [indicesOfItemsToEmail containsObject:filename]) {
            NSString * filePath_iter = [NSString stringWithFormat:@"%@/%@", dirPath, filename];
            NSData *output = [NSData dataWithContentsOfFile:filePath_iter];
            
            OZZipWriteStream *stream= [pdfZipFile writeFileInZipWithName:filename fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:OZZipCompressionLevelBest];
            [stream writeData:output];
            
            [stream finishedWriting];
        }
        
    }];
    
    OZZipFile *jpgZipFile= [[OZZipFile alloc] initWithFileName:jpgZipfilePath mode:OZZipFileModeCreate];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        if ([filename rangeOfString:@"jpg"].location != NSNotFound && [indicesOfItemsToEmail containsObject:filename]) {
            NSString * filePath_iter = [NSString stringWithFormat:@"%@/%@", dirPath, filename];
            NSData *output = [NSData dataWithContentsOfFile:filePath_iter];
            
            OZZipWriteStream *stream= [jpgZipFile writeFileInZipWithName:filename fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:OZZipCompressionLevelBest];
            
            [stream writeData:output];
            
            [stream finishedWriting];
        }
    }];
    
    NSArray* arr =  [NSArray arrayWithObjects:zipDirPath, pdfZipName, jpgZipName, nil];
    
    return arr;
}

- (void) copyFileToClipboard: (NSString*) fileUrl
{
    NSData *myData = [NSData dataWithContentsOfFile:fileUrl];
    [[UIPasteboard generalPasteboard] setData:myData forPasteboardType:@"yourUTI"];
}

- (void) pastFileFromClipboard: (NSString*) fileUrl
{
    NSData *moreData = [[UIPasteboard generalPasteboard]dataForPasteboardType:@"yourUTI"];
    [moreData writeToFile:fileUrl atomically:YES];
}


@end
