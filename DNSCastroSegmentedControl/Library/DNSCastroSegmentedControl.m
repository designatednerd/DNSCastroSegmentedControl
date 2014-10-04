//
//  DNSCastroSegmentedControl.m
//  DNSCastroSegmentedControl
//
//  Created by Ellen Shapiro on 10/3/14.
//  Copyright (c) 2014 Designated Nerd Software. All rights reserved.
//

#import "DNSCastroSegmentedControl.h"

@interface DNSCastroSegmentedControl()
@property (nonatomic) UIView *selectionView;
@property (nonatomic) NSArray *sectionViews;
@property (nonatomic) UITouch *initialTouch;

@end

@implementation DNSCastroSegmentedControl

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.choices && !self.sectionViews) {
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
            
            [autolayoutString appendFormat:@"[%@]", viewName];
            NSDictionary *currentView = @{ viewName : view };
            [autolayoutViews addEntriesFromDictionary:currentView];
            [sectionViews addObject:view];
            
            //Pin top and bottom
            NSString *visualFormat = [NSString stringWithFormat:@"V:|[%@]|", viewName];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visualFormat options:0 metrics:nil views:currentView]];
        }
        
        [autolayoutString appendString:@"|"];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:autolayoutString
                                                                     options:0
                                                                     metrics:nil
                                                                       views:autolayoutViews]];
        
        self.sectionViews = sectionViews;
        
    }
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
    self.initialTouch = [touches anyObject];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
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
