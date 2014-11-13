//
//  ViewController.m
//  DNSCastroSegmentedControl
//
//  Created by Ellen Shapiro on 10/3/14.
//  Copyright (c) 2014 Designated Nerd Software. All rights reserved.
//

#import "ViewController.h"

#import "DNSCastroSegmentedControl.h"

@interface ViewController () <DNSCastroSegmentedControlDelegate>
@property (nonatomic, weak) IBOutlet DNSCastroSegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet DNSCastroSegmentedControl *stairsSegmentedControl;
@property (nonatomic) DNSCastroSegmentedControl *programmaticSegmentedControl;
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

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!self.programmaticSegmentedControl) {
        //Add the programmatic segmented control here so that widths are happy.
        self.programmaticSegmentedControl = [[DNSCastroSegmentedControl alloc] init];
        self.programmaticSegmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        self.programmaticSegmentedControl.backgroundColor = self.stairsSegmentedControl.backgroundColor;
        self.programmaticSegmentedControl.delegate = self;
        [self.view addSubview:self.programmaticSegmentedControl];
        
        //Pin to bottom of the stairs SC
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.programmaticSegmentedControl
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.stairsSegmentedControl
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:40]];
        
        //Pin to sides of stairs SC
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.programmaticSegmentedControl
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.stairsSegmentedControl
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1
                                                               constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.programmaticSegmentedControl
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.stairsSegmentedControl
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1
                                                               constant:0]];
        
        //Pin to height of stairs SC
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.programmaticSegmentedControl
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.stairsSegmentedControl
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1
                                                               constant:0]];
        
        self.programmaticSegmentedControl.choices = @[@"Programmatic", @"Springs/Struts", @"Autolayout"];
        self.programmaticSegmentedControl.labelFont = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:14];
        self.programmaticSegmentedControl.choiceColor = [UIColor orangeColor];
        self.programmaticSegmentedControl.selectedIndex = 1;
        
        //Uncomment to move automatically after a delay
//        [self performSelector:@selector(setProgrammaticIndex)
//                   withObject:nil
//                   afterDelay:2];
    }
}

- (void)setProgrammaticIndex
{
    [self.programmaticSegmentedControl setSelectedIndex:2 animated:YES];
}

#pragma mark - DNSCastroSegmentedControlDelegate

- (void)segmentedControl:(DNSCastroSegmentedControl *)control didChangeToSelectedIndex:(NSInteger)selectedIndex
{
    NSString *controlName = nil;
    if (control == self.segmentedControl) {
        controlName = @"First Segmented Control";
    } else if (control == self.stairsSegmentedControl) {
        controlName = @"Stairs Segmented Control";
    } else if (control == self.programmaticSegmentedControl) {
        controlName = @"Programmatic Segmented Control";
    }
    
    NSLog(@"Control %@ change to index %@", controlName, @(selectedIndex));
}

@end