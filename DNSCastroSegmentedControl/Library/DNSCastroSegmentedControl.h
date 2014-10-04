//
//  DNSCastroSegmentedControl.h
//  DNSCastroSegmentedControl
//
//  Created by Ellen Shapiro on 10/3/14.
//  Copyright (c) 2014 Designated Nerd Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DNSCastroSegmentedControl : UIControl

///An array of the choices for the user. Should be NSString/AttributedString or UIImage.
@property (nonatomic) NSArray *choices;

///The current selected index. Zero-indexed. 
@property (nonatomic) NSInteger selectedIndex;

///Will set a font to be used for all labels. If nil, the default system font will be used.
@property (nonatomic) UIFont *labelFont;

@end
