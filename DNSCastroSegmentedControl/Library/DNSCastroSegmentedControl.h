//
//  DNSCastroSegmentedControl.h
//  DNSCastroSegmentedControl
//
//  Created by Ellen Shapiro on 10/3/14.
//  Copyright (c) 2014 Designated Nerd Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DNSCastroSegmentedControl : UIControl

@property (nonatomic) NSArray *choices;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) UIFont *font;

@end
