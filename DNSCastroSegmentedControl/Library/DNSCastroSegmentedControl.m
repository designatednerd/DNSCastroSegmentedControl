//
//  DNSCastroSegmentedControl.m
//  DNSCastroSegmentedControl
//
//  Created by Ellen Shapiro on 10/3/14.
//  Copyright (c) 2014 Designated Nerd Software. All rights reserved.
//

#import "DNSCastroSegmentedControl.h"

static CGFloat TopAndBottomPadding = 2;

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
    
    if (self.choices && !self.sectionViews) {
        [self setupSectionViews];
        [self setupSelectionView];
        [self roundAllTheThings];
    }
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
        view.layer.borderColor = [UIColor greenColor].CGColor;
        view.layer.borderWidth = 1;
        
        [self addSubview:view];
        
        NSString *viewName = [NSString stringWithFormat:@"view%@", @(i)];
        
        //Pin width to percentage
        [self pinViewToWidth:view];
        
        //Pin to top and bottom
        [self pinViewToTopAndBottom:view];
        
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
    [self pinViewToTopAndBottom:self.selectionView];
    
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
    self.selectionView.layer.cornerRadius = cornerRadius + TopAndBottomPadding;
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

- (void)pinViewToTopAndBottom:(UIView *)view
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:-TopAndBottomPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:TopAndBottomPadding]];
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
            if (self.font) {
                label.font = self.font;
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

#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    self.initialTouchPoint = [touch locationInView:self];
    self.initialConstraintConstant = self.selectionLeftConstraint.constant;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint currentTouch = [touch locationInView:self];
    CGFloat deltaX = currentTouch.x - self.initialTouchPoint.x;
    
    CGFloat calculatedConstant = self.initialConstraintConstant + deltaX;
    CGFloat constantVSMin = MAX(0, calculatedConstant);
    
    CGFloat maxX = CGRectGetWidth(self.frame) - CGRectGetWidth(self.selectionView.frame);
    CGFloat constantVSMax = MIN(constantVSMin, maxX);
    
    self.selectionLeftConstraint.constant = constantVSMax;    
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
}

@end
