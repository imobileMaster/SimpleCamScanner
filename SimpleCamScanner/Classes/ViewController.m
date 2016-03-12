//
//  ViewController.m
//  IPDFCameraViewController
//
//  Created by Maximilian Mackh on 11/01/15.
//  Copyright (c) 2015 Maximilian Mackh. All rights reserved.
//

#import "ViewController.h"

#import "IPDFCameraViewController.h"
#import "MAImagePickerControllerAdjustViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet IPDFCameraViewController *cameraViewController;
@property (weak, nonatomic) IBOutlet UIImageView *focusIndicator;
- (IBAction)focusGesture:(id)sender;

- (IBAction)captureButton:(id)sender;

@end

@implementation ViewController

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.cameraViewController setupCameraView];
    [self.cameraViewController setEnableBorderDetection:YES];
    [self updateTitleLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.cameraViewController start];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark CameraVC Actions

- (IBAction)focusGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint location = [sender locationInView:self.cameraViewController];
        
        [self focusIndicatorAnimateToPoint:location];
        
        [self.cameraViewController focusAtPoint:location completionHandler:^
         {
             [self focusIndicatorAnimateToPoint:location];
         }];
    }
}

- (void)focusIndicatorAnimateToPoint:(CGPoint)targetPoint
{
    [self.focusIndicator setCenter:targetPoint];
    self.focusIndicator.alpha = 0.0;
    self.focusIndicator.hidden = NO;
    
    [UIView animateWithDuration:0.4 animations:^
    {
         self.focusIndicator.alpha = 1.0;
    }
    completion:^(BOOL finished)
    {
         [UIView animateWithDuration:0.4 animations:^
         {
             self.focusIndicator.alpha = 0.0;
         }];
     }];
}

- (IBAction)borderDetectToggle:(id)sender
{
//    BOOL enable = !self.cameraViewController.isBorderDetectionEnabled;
//    [self changeButton:sender targetTitle:(enable) ? @"CROP On" : @"CROP Off" toStateEnabled:enable];
//    self.cameraViewController.enableBorderDetection = enable;
//    [self updateTitleLabel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)filterToggle:(id)sender
{
    [self.cameraViewController setCameraViewType:(self.cameraViewController.cameraViewType == IPDFCameraViewTypeBlackAndWhite) ? IPDFCameraViewTypeNormal : IPDFCameraViewTypeBlackAndWhite];
    [self updateTitleLabel];
}

- (IBAction)torchToggle:(id)sender
{
    BOOL enable = !self.cameraViewController.isTorchEnabled;
    [self changeButton:sender targetTitle:(enable) ? @"FLASH On" : @"FLASH Off" toStateEnabled:enable];
    self.cameraViewController.enableTorch = enable;
}

- (void)updateTitleLabel
{
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    animation.duration = 0.35;
    [self.titleLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    NSString *filterMode = (self.cameraViewController.cameraViewType == IPDFCameraViewTypeBlackAndWhite) ? @"TEXT FILTER" : @"COLOR FILTER";
    self.titleLabel.text = filterMode;//[filterMode stringByAppendingFormat:@" | %@",(self.cameraViewController.isBorderDetectionEnabled)?@"AUTOCROP On":@"AUTOCROP Off"];
}

- (void)changeButton:(UIButton *)button targetTitle:(NSString *)title toStateEnabled:(BOOL)enabled
{
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:(enabled) ? [UIColor colorWithRed:1 green:0.81 blue:0 alpha:1] : [UIColor whiteColor] forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark CameraVC Capture Image

- (IBAction)captureButton:(id)sender
{
//    __weak typeof(self) weakSelf = self;
    
    [self.cameraViewController captureImageWithCompletionHander:^(NSString *imageFilePath)
    {
        MAImagePickerControllerAdjustViewController *adjustViewController = [[MAImagePickerControllerAdjustViewController alloc] init];
        adjustViewController.sourceImage = [UIImage imageWithContentsOfFile:imageFilePath];
        adjustViewController.image = self.cameraViewController.soureImg;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:adjustViewController];
        
        [self showViewController:navigationController sender:nil];
        
//        UIImageView *captureImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imageFilePath]];
//        captureImageView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
//        captureImageView.frame = CGRectOffset(weakSelf.view.bounds, 0, -weakSelf.view.bounds.size.height);
//        captureImageView.alpha = 1.0;
//        captureImageView.contentMode = UIViewContentModeScaleAspectFit;
//        captureImageView.userInteractionEnabled = YES;
//        [weakSelf.view addSubview:captureImageView];
//        
//        UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(dismissPreview:)];
//        [captureImageView addGestureRecognizer:dismissTap];
//        
//        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.7 options:UIViewAnimationOptionAllowUserInteraction animations:^
//        {
//            captureImageView.frame = weakSelf.view.bounds;
//        } completion:nil];
    }];
}

- (UIImage*) detectEdge: (UIImage*) _adjustedImage
{
    CIImage *myImage = [CIImage imageWithData:UIImagePNGRepresentation(_adjustedImage)];
    
    //   NSLog(@"%f, %f", _adjustedImage.size.width, _adjustedImage.size.height);
    
    NSDictionary *options = @{CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio: @(1.0)};
    CIDetector *rectangleDetector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:options];
    
    NSArray *rectangleFeatures = [rectangleDetector featuresInImage:myImage];
    
    for (CIRectangleFeature *rectangleFeature in rectangleFeatures) {
        CGPoint topLeft = rectangleFeature.topLeft;
        CGPoint topRight = rectangleFeature.topRight;
        CGPoint bottomLeft = rectangleFeature.bottomLeft;
        CGPoint bottomRight = rectangleFeature.bottomRight;
        
        //       NSLog(@"%f, %f  %f, %f  %f, %f %f, %f\n\n", topLeft.x, topLeft.y, topRight.x, topRight.y, bottomLeft.x, bottomLeft.y, bottomRight.x, bottomRight.y);
        //        [adjustRect topLeftCornerToCGPoint:topLeft];
        //        [adjustRect topRightCornerToCGPoint:topRight];
        //        [adjustRect bottomRightCornerToCGPoint:bottomRight];
        //        [adjustRect bottomLeftCornerToCGPoint:bottomLeft];
        
        CIImage *detecteCIImage = [self drawHighlightOverlayForPoints:myImage :topLeft :topRight :bottomLeft :bottomRight];
        return [[UIImage alloc] initWithCIImage:detecteCIImage];
    }
    
    return  nil;
}

- (CIImage*) drawHighlightOverlayForPoints: (CIImage*) image : (CGPoint) topLeft :  (CGPoint) topRight :  (CGPoint)  bottomLeft :  (CGPoint) bottomRight
{
    CIImage* overlay = [CIImage imageWithColor:[CIColor colorWithRed:1.0 green:0 blue:0 alpha:0.5]];
    
    NSDictionary *param = @{@"inputExtent": [CIVector vectorWithCGRect:[image extent]],                       @"inputTopLeft": [CIVector vectorWithCGPoint:topLeft],                                    @"inputTopRight": [CIVector vectorWithCGPoint:topRight],                                       @"inputBottomLeft": [CIVector vectorWithCGPoint: bottomLeft],                                      @"inputBottomRight": [CIVector vectorWithCGPoint: bottomRight]};
    overlay = [overlay imageByCroppingToRect:[image extent]];
    overlay = [overlay imageByApplyingFilter:@"CIPerspectiveTransformWithExtent" withInputParameters:param];
    
    NSLog(@"param %@\n", param);
    
    NSLog(@"%f, %f", overlay.extent.size.width, overlay.extent.size.height);
    
    return [overlay imageByCompositingOverImage:image];
}

- (void)dismissPreview:(UITapGestureRecognizer *)dismissTap
{
    [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionAllowUserInteraction animations:^
    {
        dismissTap.view.frame = CGRectOffset(self.view.bounds, 0, self.view.bounds.size.height);
    }
    completion:^(BOOL finished)
    {
        [dismissTap.view removeFromSuperview];
    }];
}

@end
