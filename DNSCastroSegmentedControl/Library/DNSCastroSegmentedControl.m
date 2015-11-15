//
//  DNSCastroSegmentedControl.m
//  DNSCastroSegmentedControl
//
//  Created by Ellen Shapiro on 10/3/14.
//  Copyright (c) 2014 Designated Nerd Software. All rights reserved.
//

#import "DNSCastroSegmentedControl.h"

static CGFloat SelectionViewPadding = 3;
static NSTimeInterval AnimationDuration = 0.2;

static CGFloat SelectedAlpha = 1;
static CGFloat DeselectedAlpha = 0.4;

static CGFloat DefaultHeight = 40;

@interface DNSCastroSegmentedControl()
@property (nonatomic) UIView *selectionView;
@property (nonatomic) UIView *selectionBackgroundView;
@property (nonatomic) NSArray *sectionViews;
@property (nonatomic) CGPoint initialTouchPoint;
@property (nonatomic) NSLayoutConstraint *selectionLeftConstraint;
@property (nonatomic) NSInteger initialConstraintConstant;
@property (nonatomic) BOOL touchesInProgress;
@property (nonatomic) NSInteger valueAtStartOfTouches;

@end

@implementation DNSCastroSegmentedControl

#pragma mark - View Lifecycle

- (void)layoutSubviews
{
    //Make sure there are choices before moving forward. 
    NSAssert(self.choices, @"Cannot setup with no choices set!");
    
    [super layoutSubviews];
    
    if (self.choices && !self.sectionViews) {
        //Perform initial setup.
        [self setupSectionViews];
        [self setupSelectionView];
        [self setupSelectionBackgroundView];
        [self roundAllTheThings];
        [self setSelectedSegmentIndex:self.selectedSegmentIndex animated:NO];
    }
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    // Bounds change = chiclet placement needs to be updated.
    [self snapToCurrentSection:NO];
}

#pragma mark - Setup Helpers

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
//        [self setupDebugDotOfColor:[UIColor greenColor] forView:view];
        
        [self addSubview:view];
        
        NSString *viewName = [NSString stringWithFormat:@"view%@", @(i)];
        
        //Pin width to percentage
        [self pinViewToWidth:view withPadding:0];
        
        //Pin to top and bottom
        [self pinViewToTopAndBottom:view withPadding:SelectionViewPadding];
        
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
    [self pinViewToWidth:self.selectionView withPadding:SelectionViewPadding * 2];
    [self pinViewToTopAndBottom:self.selectionView withPadding:SelectionViewPadding];
    
    self.selectionLeftConstraint = [NSLayoutConstraint constraintWithItem:self.selectionView
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeLeft
                                                               multiplier:1
                                                                 constant:SelectionViewPadding];
    [self addConstraint:self.selectionLeftConstraint];
}

- (void)setupSelectionBackgroundView
{
    self.selectionBackgroundView = [[UIView alloc] init];
    self.selectionBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (self.selectionBackgroundColor) {
        self.selectionBackgroundView.backgroundColor = self.selectionBackgroundColor;
    } else {
        self.selectionBackgroundView.backgroundColor = [UIColor clearColor];
    }
    
    //Insert below the labels
    [self insertSubview:self.selectionBackgroundView belowSubview:[self.sectionViews firstObject]];
    
    //Pin in all directions to the chiclet.
    [self pinView:self.selectionBackgroundView
      toOtherView:self.selectionView
        attribute:NSLayoutAttributeRight];
    [self pinView:self.selectionBackgroundView
      toOtherView:self.selectionView
        attribute:NSLayoutAttributeLeft];
    [self pinView:self.selectionBackgroundView
      toOtherView:self.selectionView
        attribute:NSLayoutAttributeTop];
    [self pinView:self.selectionBackgroundView
      toOtherView:self.selectionView
        attribute:NSLayoutAttributeBottom];
}

- (void)roundAllTheThings
{
    CGFloat cornerRadius = self.cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.selectionView.layer.cornerRadius = cornerRadius - SelectionViewPadding;
    self.selectionBackgroundView.layer.cornerRadius = cornerRadius - SelectionViewPadding;
}

- (void)pinView:(UIView *)view1 toOtherView:(UIView *)view2 attribute:(NSLayoutAttribute)attribute
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view1
                                                     attribute:attribute
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view2
                                                     attribute:attribute
                                                    multiplier:1
                                                      constant:0]];
}

- (void)pinViewToWidth:(UIView *)view withPadding:(CGFloat)padding
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:[self sectionPercentage]
                                                      constant:-padding]];
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

- (CGSize)intrinsicContentSize
{
    /**
     *  NOTE: When using this in a storyboard, you have to select the view, go to
     *  the Size Inspector tab, and manually set a placeholder for the intrinsic
     *  content size that matches this height, and sets a desired width.
     */
    return CGSizeMake([self minimumWidthForChoices], DefaultHeight);
}

- (CGFloat)minimumWidthForChoices
{
    CGFloat greatestWidth = 0;
    for (id object in self.choices) {
        CGFloat currentWidth = 0;
        if ([object isKindOfClass:[UIImage class]]) {
            UIImage *image = (UIImage *)object;
            currentWidth = image.size.width;
        } else if ([object isKindOfClass:[NSAttributedString class]]) {
            NSAttributedString *attributedString = (NSAttributedString *)object;
            CGRect attributedBounding = [attributedString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, DefaultHeight)
                                                                       options:0
                                                                       context:NULL];
            currentWidth = CGRectGetWidth(attributedBounding);
        } else if ([object isKindOfClass:[NSString class]]) {
            NSString *string = (NSString *)object;
            CGRect bounding = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, DefaultHeight)
                                                   options:0
                                                attributes:@{ NSFontAttributeName : self.labelFont }
                                                   context:NULL];
            currentWidth = CGRectGetWidth(bounding);
        }
        
        if (currentWidth > greatestWidth) {
            greatestWidth = currentWidth;
        }
    }
    
    CGFloat singleChoiceWidth = greatestWidth + DefaultHeight / 2;
    CGFloat totalWidth = singleChoiceWidth * self.choices.count;
    
    return totalWidth;
}

- (CGFloat)sectionPercentage
{
    return (1.0 / self.choices.count);
}

- (CGFloat)pointsPerSection
{
    return CGRectGetWidth(self.frame) * [self sectionPercentage];
}

#pragma mark - Debug helpers

/**
 *  Adds a wee dot of the given color to the center of the given view which only
 *  shows up when DEBUG is enabled.
 *
 *  @param color The color for the dot.
 *  @param view  The view to add the debug dot to.
 */
- (void)setupDebugDotOfColor:(UIColor *)color forView:(UIView *)view
{
#ifdef DEBUG
    UIView *dot = [[UIView alloc] init];
    dot.translatesAutoresizingMaskIntoConstraints = NO;
    dot.backgroundColor = color;
    
    [view addSubview:dot];
    
    //Pin height/width
    CGFloat width = 3;
    [dot addConstraint:[NSLayoutConstraint constraintWithItem:dot
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:nil
                                                    attribute:0
                                                   multiplier:1
                                                     constant:width]];
    [dot addConstraint:[NSLayoutConstraint constraintWithItem:dot
                                                    attribute:NSLayoutAttributeWidth
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:nil
                                                    attribute:0
                                                   multiplier:1
                                                     constant:width]];
    
    
    //Pin to center.
    [view addConstraint:[NSLayoutConstraint constraintWithItem:dot
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:dot
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    
#endif
}

/**
 *  Adds a border of the given color to the given view, but only shows up if DEBUG 
 *  is enabled
 *
 *  @param color The color of the border for the view.
 *  @param view  The view to add the debug border to.
 */
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

#pragma mark - Overridden getters

- (UIFont *)labelFont
{
    if (_labelFont) {
        return _labelFont;
    } else {
        //Use the default system font.
        //TODO: Figure out how to get default current system font size.
        return [UIFont systemFontOfSize:17];
    }
}

- (CGFloat)cornerRadius
{
    if (_cornerRadius) {
        return _cornerRadius;
    } else {
        return (CGRectGetHeight(self.frame) / 2);
    }
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

- (void)setSelectionBackgroundColor:(UIColor *)selectionBackgroundColor
{
    _selectionBackgroundColor = selectionBackgroundColor;
    
    if (self.selectionBackgroundView) {
        self.selectionBackgroundView.backgroundColor = selectionBackgroundColor;
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    if (_selectedSegmentIndex != selectedSegmentIndex) {
        _selectedSegmentIndex = selectedSegmentIndex;
        if (!self.touchesInProgress) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}

#pragma mark - Animation helpers

- (void)animateSelectionViewUpIfNeeded:(BOOL)shorten
{
    if (self.touchesInProgress) {
        CGFloat scaleYPercentage = (SelectionViewPadding * 2) / (CGRectGetHeight(self.frame) - (SelectionViewPadding * 2));
        scaleYPercentage += 1;
        
        CGFloat scaleXPercentage = (SelectionViewPadding * 2) / ([self pointsPerSection]);
        scaleXPercentage += 1;
        
        CGFloat duration = AnimationDuration;
        if (shorten) {
            duration /= 2;
        }
        
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.selectionView.transform = CGAffineTransformMakeScale(scaleXPercentage, scaleYPercentage);
                             self.selectionBackgroundView.transform = CGAffineTransformMakeScale(scaleXPercentage, scaleYPercentage);
                             [self layoutIfNeeded];
                         }
                         completion:nil];
    }
}

#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    self.touchesInProgress = YES;
    self.valueAtStartOfTouches = self.selectedSegmentIndex;

    UITouch *touch = [touches anyObject];
    self.initialTouchPoint = [touch locationInView:self];
    self.initialConstraintConstant = self.selectionLeftConstraint.constant;
    
    //Figure out where we're at.
    CGFloat section = self.initialTouchPoint.x / [self pointsPerSection];
    NSInteger roundedSection = floorf(section);
    if (self.selectedSegmentIndex != roundedSection) {
        [self setSelectedSegmentIndex:roundedSection animated:YES];
        [UIView animateWithDuration:AnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self snapToCurrentSection:NO];
                         } completion:^(BOOL finished) {
                             self.initialConstraintConstant = self.selectionLeftConstraint.constant;
                         }];
        
        [self performSelector:@selector(animateSelectionViewUpIfNeeded:) withObject:@YES afterDelay:AnimationDuration / 2];
    } else {
        //Animate the selection view up
        [self animateSelectionViewUpIfNeeded:NO];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint currentTouch = [touch locationInView:self];
    CGFloat deltaX = currentTouch.x - self.initialTouchPoint.x;
    
    CGFloat calculatedConstant = self.initialConstraintConstant + deltaX;
    
    //Get the larger of 0 and the calculated constant.
    CGFloat constantVSMin = MAX((SelectionViewPadding), calculatedConstant);
    
    CGFloat maxX = CGRectGetWidth(self.frame) - CGRectGetWidth(self.selectionView.frame) + SelectionViewPadding;
    
    //Get the smaller of the previous comparison and the calculated max X.
    CGFloat constantVSMax = MIN(constantVSMin, maxX);
    
    self.selectionLeftConstraint.constant = constantVSMax;
        
    //Figure out where we're at.
    CGFloat section = constantVSMax / [self pointsPerSection];
    NSInteger roundedSection = roundf(section);
    
    [self setSelectedSegmentIndex:roundedSection animated:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self touchesEndedOrCancelled];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    //Reset the selected segment index to what it was initially.
    [self setSelectedSegmentIndex:self.valueAtStartOfTouches animated:YES];
    
    [self touchesEndedOrCancelled];
}

- (void)touchesEndedOrCancelled
{
    self.touchesInProgress = NO;
    
    //If the value has changed, send that action.
    if (self.valueAtStartOfTouches != self.selectedSegmentIndex) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    [UIView animateWithDuration:AnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.selectionView.transform = CGAffineTransformIdentity;
                         self.selectionBackgroundView.transform = CGAffineTransformIdentity;
                         //Calls LayoutIfNeeded - no need to call it seperately.
                         [self snapToCurrentSection:NO];
                     }
                     completion:nil];
}

#pragma mark - Animation movements

- (void)snapToCurrentSection:(BOOL)isEmbiggened;
{
    CGFloat fullMove = self.selectedSegmentIndex * [self pointsPerSection];
    
    if (!isEmbiggened) {
        fullMove += SelectionViewPadding;
    }
    
    self.selectionLeftConstraint.constant =  fullMove;
    [self layoutIfNeeded];
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex animated:(BOOL)animated
{
    NSInteger previousSelectedSegmentIndex = _selectedSegmentIndex;
    if (!animated) {
        self.selectedSegmentIndex = selectedSegmentIndex;
        for (NSInteger i = 0; i < self.sectionViews.count; i++) {
            UIView *currentView = self.sectionViews[i];
            if (i == selectedSegmentIndex) {
                currentView.alpha = SelectedAlpha;
            } else {
                currentView.alpha = DeselectedAlpha;
            }
        }
        
        [self snapToCurrentSection:NO];
        return;
    } //else, animate!
    
    if (self.selectedSegmentIndex != selectedSegmentIndex) {
        self.selectedSegmentIndex = selectedSegmentIndex;
        UIView *wasHighlighted = self.sectionViews[previousSelectedSegmentIndex];
        UIView *nowHighlighted = self.sectionViews[selectedSegmentIndex];
        [UIView animateWithDuration:AnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear //Crossfade
                         animations:^{
                             wasHighlighted.alpha = DeselectedAlpha;
                             nowHighlighted.alpha = SelectedAlpha;
                             
                             if (!self.touchesInProgress) {
                                 [self snapToCurrentSection:NO];
                             }
                         }
                         completion:nil];
    }
}

@end
