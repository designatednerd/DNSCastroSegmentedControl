//
//  ViewController.m
//  DNSCastroSegmentedControl
//
//  Created by Ellen Shapiro on 10/3/14.
//  Copyright (c) 2014 Designated Nerd Software. All rights reserved.
//

#import "ViewController.h"

#import "DNSCastroSegmentedControl.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet DNSCastroSegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet DNSCastroSegmentedControl *stairsSegmentedControl;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.segmentedControl.choices = @[@"one", @"two", @"three", @"four"];
    self.segmentedControl.labelFont = [UIFont fontWithName:@"AmericanTypewriter" size:17];
    self.segmentedControl.selectedIndex = 2;
    self.segmentedControl.tintColor = [UIColor orangeColor];
    self.segmentedControl.choiceColor = [UIColor whiteColor];
    self.segmentedControl.selectionViewColor = [UIColor greenColor];
    
    self.stairsSegmentedControl.choices = @[
                                            [UIImage imageNamed:@"Down Stairs"],
                                            [UIImage imageNamed:@"With Bannister"],
                                            @"Elevator",
                                            ];
    self.stairsSegmentedControl.labelFont = [UIFont fontWithName:@"HoeflerText-Regular" size:15];
    self.stairsSegmentedControl.tintColor = [UIColor whiteColor];
    self.stairsSegmentedControl.choiceColor = [UIColor yellowColor];
    self.stairsSegmentedControl.selectionViewColor = [UIColor redColor];
}

@end