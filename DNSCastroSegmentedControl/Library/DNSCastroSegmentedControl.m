//
//  DNSCastroSegmentedControl.m
//  DNSCastroSegmentedControl
//
//  Created by Ellen Shapiro on 10/3/14.
//  Copyright (c) 2014 Designated Nerd Software. All rights reserved.
//

#import "DNSCastroSegmentedControl.h"

static CGFloat TopAndBottomPadding = 3;
static NSTimeInterval AnimationDuration = 0.1;

@interface DNSCastroSegmentedControl()
@property (nonatomic) UIView *selectionView;
@property (nonatomic) NSArray *sectionViews;
@property (nonatomic) CGPoint initialTouchPoint;
@property (nonatomic) NSLayoutConstraint *selectionLeftConstraint;
@property (nonatomic) NSInteger initialConstraintConstant;

@end

@implementation DNSCastroSegmentedControl

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.choices) {
        NSAssert(@"NO", @"Cannot setup with no choices set!");
    }
    
    if (self.choices && !self.sectionViews) {
        //Perform initial setup.
        [self setupKVO];
        [self setupSectionViews];
        [self setupSelectionView];
        [self roundAllTheThings];
        [self setSelectedIndex:self.selectedIndex animated:NO];
        [self snapToCurrentSection];
    }
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:[self boundsKeyPath]];
}

#pragma mark - Setup Helpers

- (void)setupKVO
{
    [self addObserver:self
           forKeyPath:[self boundsKeyPath]
              options:0
              context:NULL];
}

- (void)setupSectionViews
{
    NSMutableArray *sectionViews = [NSMutableArray arrayWithCapacity:self.choices.count];
    NSMutableString *autolayoutString = [NSMutableString stringWithString:@"H:|"];
    NSMutableDictionary *autolayoutViews = [NSMutableDictionary dictionary];
    
    for (NSInteger i = 0; i < self.choices.count; i++) {
        UIView *view = [self viewForChoice:self.choices[i]];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        
        //DEBUG
//        [self addDebugBorderOfColor:[UIColor greenColor] toView:view];
        
        [self addSubview:view];
        
        NSString *viewName = [NSString stringWithFormat:@"view%@", @(i)];
        
        //Pin width to percentage
        [self pinViewToWidth:view];
        
        //Pin to top and bottom
        [self pinViewToTopAndBottom:view withPadding:TopAndBottomPadding];
        
        //Add to autolayout string to allow pinning next to each other.
        [autolayoutString appendFormat:@"[%@]", viewName];
        [autolayoutViews addEntriesFromDictionary:@{ viewName : view }];
        [sectionViews addObject:view];
    }
    
    [autolayoutString appendString:@"|"];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:autolayoutString
                                                                 options:0
                                                                 metrics:nil
                                                                   views:autolayoutViews]];
    
    self.sectionViews = sectionViews;
}

- (void)setupSelectionView
{
    self.selectionView = [[UIView alloc] init];
    self.selectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (self.selectionViewColor) {
        [self addBorderOfColor:self.selectionViewColor toView:self.selectionView];
    } else {
        [self addBorderOfColor:self.tintColor toView:self.selectionView];
    }
        
    [self addSubview:self.selectionView];
    [self pinViewToWidth:self.selectionView];
    [self pinViewToTopAndBottom:self.selectionView withPadding:TopAndBottomPadding];
    
    self.selectionLeftConstraint = [NSLayoutConstraint constraintWithItem:self.selectionView
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeLeft
                                                               multiplier:1
                                                                 constant:0];
    [self addConstraint:self.selectionLeftConstraint];
}

- (void)roundAllTheThings
{
    CGFloat cornerRadius = (CGRectGetHeight(self.frame) / 2);
    self.layer.cornerRadius = cornerRadius;
    self.selectionView.layer.cornerRadius = cornerRadius - TopAndBottomPadding;
}

- (void)pinViewToWidth:(UIView *)view
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:[self sectionPercentage]
                                                      constant:0]];
}

- (void)pinViewToTopAndBottom:(UIView *)view withPadding:(CGFloat)padding
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:padding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:-padding]];
}

/**
 *  Creates the appropriate view for the given type of choice.
 *
 *  @param choice Either an NSString, an NSAttributedString, or a UIImage.
 *  @return The appropriate view to display such an item. 
 */
- (UIView *)viewForChoice:(id)choice
{
    if ([choice isKindOfClass:[NSString class]]) {
        UILabel *label = [[UILabel alloc] init];
        if ([choice isKindOfClass:[NSAttributedString class]]) {
            //Set attributed text
            label.attributedText = (NSAttributedString *)choice;
        } else {
            //Set regular text.
            label.text = (NSString *)choice;
            label.textAlignment = NSTextAlignmentCenter;
            if (self.labelFont) {
                label.font = self.labelFont;
            }
            
            if (self.choiceColor) {
                label.textColor = self.choiceColor;
            } else {
                label.textColor = self.tintColor;
            }
        }
        return label;
    } else if ([choice isKindOfClass:[UIImage class]]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:(UIImage *)choice];
        imageView.contentMode = UIViewContentModeCenter;
        if (self.choiceColor) {
            imageView.tintColor = self.choiceColor;
        } else {
            imageView.tintColor = self.tintColor;
        }
        
        return imageView;
    } else {
        NSAssert(NO, @"Unsupported choice type %@", NSStringFromClass([choice class]));
        return nil;
    }
}

#pragma mark - Measurements

- (CGFloat)sectionPercentage
{
    return (1.0 / self.choices.count);
}

- (CGFloat)pointsPerSection
{
    return CGRectGetWidth(self.frame) * [self sectionPercentage];
}

#pragma mark - KVO

- (NSString *)boundsKeyPath
{
    return NSStringFromSelector(@selector(bounds));
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:[self boundsKeyPath]]
        && object == self) {
        //The bounds of the view have changed - we've had a rotation.
        [self snapToCurrentSection];
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}


#pragma mark - Debug helpers

- (void)addDebugBorderOfColor:(UIColor *)color toView:(UIView *)view
{
#ifdef DEBUG
    [self addBorderOfColor:color toView:view];
#endif
}

- (void)addBorderOfColor:(UIColor *)color toView:(UIView *)view
{
    view.layer.borderWidth = 1;
    view.layer.borderColor = color.CGColor;
}

#pragma mark - Overridden setters

- (void)setSelectionViewColor:(UIColor *)selectionViewColor
{
    _selectionViewColor = selectionViewColor;
    
    if (self.selectionView) {
        //Update the border color
        [self addBorderOfColor:selectionViewColor toView:self.selectionView];
    }
}

#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    self.initialTouchPoint = [touch locationInView:self];
    self.initialConstraintConstant = self.selectionLeftConstraint.constant;
    
    CGFloat scaleXPercentage = (TopAndBottomPadding * 2) / (CGRectGetHeight(self.frame) - (TopAndBottomPadding * 2));
    
    [UIView animateWithDuration:AnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.selectionView.transform = CGAffineTransformMakeScale(1, (1 + scaleXPercentage));
                     }
                     completion:nil];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint currentTouch = [touch locationInView:self];
    CGFloat deltaX = currentTouch.x - self.initialTouchPoint.x;
    
    CGFloat calculatedConstant = self.initialConstraintConstant + deltaX;
    
    //Get the larger of 0 and the calculated constant.
    CGFloat constantVSMin = MAX(0, calculatedConstant);
    
    CGFloat maxX = CGRectGetWidth(self.frame) - CGRectGetWidth(self.selectionView.frame);
    
    //Get the smaller of the previous comparison and the calculated max X.
    CGFloat constantVSMax = MIN(constantVSMin, maxX);
    
    self.selectionLeftConstraint.constant = constantVSMax;
    
    //Figure out where we're at.
    CGFloat section = constantVSMax / [self pointsPerSection];
    NSInteger roundedSection = roundf(section);
    
    [self setSelectedIndex:roundedSection animated:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self touchesEndedOrCancelled];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self touchesEndedOrCancelled];
}

- (void)touchesEndedOrCancelled
{
    [UIView animateWithDuration:AnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.selectionView.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
    
    [UIView animateWithDuration:AnimationDuration * 2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self snapToCurrentSection];
                     }
                     completion:nil];
}

- (void)snapToCurrentSection
{
    self.selectionLeftConstraint.constant = self.selectedIndex * [self pointsPerSection];
    [self layoutIfNeeded];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated
{
    if (self.selectedIndex != selectedIndex
        || ! animated) {
        self.selectedIndex = selectedIndex;
        NSInteger duration = AnimationDuration * 2;
        if (!animated) {
            duration = 0;
        }
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             for (NSInteger i = 0; i < self.sectionViews.count; i++) {
                                 UIView *currentView = self.sectionViews[i];
                                 if (i == selectedIndex) {
                                     currentView.alpha = 1;
                                 } else {
                                     currentView.alpha = 0.5;
                                 }
                             }
                         }
                         completion:nil];
    }
}

@end
