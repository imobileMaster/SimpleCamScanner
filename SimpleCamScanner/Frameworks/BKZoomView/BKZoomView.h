//
//  BKZoomView.h
//  BKZoomView
//


#import <UIKit/UIKit.h>

@interface BKZoomView : UIView

/*
 * Sets the scale on how far you want to zoom in to.
 */
- (void)setZoomScale:(CGFloat)scale;

/*
 * Enables/disables dragging of the zoom view.
 */
- (void)setDragingEnabled:(BOOL)enabled;

- (void) setZoomPoint: (CGPoint) point;
@end



