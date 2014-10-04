//
//  DNSCastroSegmentedControl.m
//  DNSCastroSegmentedControl
//
//  Created by Ellen Shapiro on 10/3/14.
//  Copyright (c) 2014 Designated Nerd Software. All rights reserved.
//

#import "DNSCastroSegmentedControl.h"

static CGFloat TopAndBottomPadding = 2;
static NSTimeInterval AnimationDuration = 0.1;

@interface DNSCastroSegmentedControl()
@property (nonatomic) UIView *selectionView;
@property (nonatomic) NSArray *sectionViews;
@property (nonatomic) CGPoint initialTouchPoint;
@property (nonatomic) NSLayoutConstraint *selectionLeftConstraint;
@property (nonatomic) NSInteger initialConstraintConstant;
@property (nonatomic) UIView *backgroundView;

@end

@implementation DNSCastroSegmentedControl

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.choices && !self.sectionViews) {
        [self setupBackgroundView];
        [self setupSectionViews];
        [self setupSelectionView];
        [self roundAllTheThings];
    }
    
    //TODO: Handle rotation.
}

#pragma mark - Setup Helpers

- (void)setupBackgroundView
{
    [self addDebugBorderOfColor:[UIColor blueColor] toView:self];
    
    UIColor *backgroundColor = self.backgroundColor;
    [super setBackgroundColor:[UIColor clearColor]];
    
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundView.backgroundColor = backgroundColor;
    
    [self addSubview:self.backgroundView];

    NSDictionary *bindings = NSDictionaryOfVariableBindings(_backgroundView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(padding)-[_backgroundView]-(padding)-|"
                                                                options:0
                                                                 metrics:@{ @"padding" : @(TopAndBottomPadding) } views:bindings]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:bindings]];
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
        [self addDebugBorderOfColor:[UIColor greenColor] toView:view];
        
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
    
    self.selectionView.layer.borderColor = [UIColor redColor].CGColor;
    self.selectionView.layer.borderWidth = 1;
    
    self.selectionView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    
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
    CGFloat cornerRadius = (CGRectGetHeight(self.frame) / 2) - TopAndBottomPadding;
    self.backgroundView.layer.cornerRadius = cornerRadius;
    self.selectionView.layer.cornerRadius = cornerRadius;
}

- (void)pinViewToWidth:(UIView *)view
{
    CGFloat percent = (1.0 / self.choices.count);
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:percent
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
        }
        return label;
    } else if ([choice isKindOfClass:[UIImage class]]) {
        return [[UIImageView alloc] initWithImage:(UIImage *)choice];
    } else {
        NSAssert(NO, @"Unsupported choice type %@", NSStringFromClass([choice class]));
        return nil;
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

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if (self.backgroundView) {
        self.backgroundView.backgroundColor = backgroundColor;
    } else {
        [super setBackgroundColor:backgroundColor];
    }
}

#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    self.initialTouchPoint = [touch locationInView:self];
    self.initialConstraintConstant = self.selectionLeftConstraint.constant;
    
    CGFloat scaleXPercentage = (TopAndBottomPadding * 2) / CGRectGetHeight(self.backgroundView.frame);
    
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
    
    //TODO: Calculate highlighting.
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
    NSLog(@"ENDED OR CANCELLED");
    
    //TODO: Calculate where to release.
    
    
    [UIView animateWithDuration:AnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.selectionView.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
}

@end
