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
@property (nonatomic, weak) IBOutlet UISegmentedControl *standardSegmentedControl;
@property (nonatomic, weak) IBOutlet DNSCastroSegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet DNSCastroSegmentedControl *stairsSegmentedControl;
@property (nonatomic, weak) IBOutlet DNSCastroSegmentedControl *autosizedSegmentedControl;
@property (nonatomic) DNSCastroSegmentedControl *programmaticSegmentedControl;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Make the standard segmented control more visible on the black bg. 
    self.standardSegmentedControl.tintColor = [UIColor whiteColor];
    
    //Setup the choices for the IBOutlet segmented controls.
    self.segmentedControl.choices = @[
                                      @"one",
                                      @"two",
                                      @"three",
                                      @"four",
                                      ];
    self.segmentedControl.labelFont = [UIFont fontWithName:@"AmericanTypewriter" size:17];
    self.segmentedControl.selectedSegmentIndex = 2;
    self.segmentedControl.choiceColor = [UIColor whiteColor];
    self.segmentedControl.selectionViewColor = [UIColor greenColor];
    
    self.stairsSegmentedControl.choices = @[
                                            [UIImage imageNamed:@"Down Stairs"],
                                            [UIImage imageNamed:@"With Bannister"],
                                            @"Elevator",
                                            ];
    self.stairsSegmentedControl.labelFont = [UIFont fontWithName:@"HoeflerText-Regular" size:15];
    self.stairsSegmentedControl.choiceColor = [UIColor yellowColor];
    self.stairsSegmentedControl.selectionViewColor = [UIColor redColor];
    
    //This control is only pinned to the center and will automatically size itself based on the length of the longest item.
    self.autosizedSegmentedControl.choices = @[
                                               @"Sizing",
                                               @"Is Cool",
                                               ];
    //Uncomment to see auto-sizing.
//    self.autosizedSegmentedControl.choices = @[
//                                                @"Automatic Sizing",
//                                                @"Is Cool"
//                                               ];
    
    self.autosizedSegmentedControl.choiceColor = [UIColor greenColor];
    self.autosizedSegmentedControl.selectionViewColor = [UIColor greenColor];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!self.programmaticSegmentedControl) {
        //Add the programmatic segmented control here so that widths are happy.
        self.programmaticSegmentedControl = [[DNSCastroSegmentedControl alloc] init];
        self.programmaticSegmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        self.programmaticSegmentedControl.backgroundColor = self.stairsSegmentedControl.backgroundColor;
        [self.view addSubview:self.programmaticSegmentedControl];
        
        //Pin to bottom of the autosized SC
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.programmaticSegmentedControl
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.autosizedSegmentedControl
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
        
        //NOTE: Height does not need to be pinned due to intrinsic content size.
        self.programmaticSegmentedControl.choices = @[@"Programmatic", @"Springs/Struts", @"Autolayout"];
        self.programmaticSegmentedControl.labelFont = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:14];
        self.programmaticSegmentedControl.choiceColor = [UIColor orangeColor];
        self.programmaticSegmentedControl.selectedSegmentIndex = 1;
        
        [self.programmaticSegmentedControl addTarget:self
                                              action:@selector(customSegmentedControlChanged:)
                                    forControlEvents:UIControlEventValueChanged];
        
        //Uncomment to move automatically after a delay
//        [self performSelector:@selector(setProgrammaticIndex)
//                   withObject:nil
//                   afterDelay:2];
    }
}

- (void)setProgrammaticIndex
{
    [self.programmaticSegmentedControl setSelectedSegmentIndex:2 animated:YES];
}

- (IBAction)standardSegmentedControlChanged:(UISegmentedControl *)sender
{
    NSLog(@"Standard segmented control changed to index %@", @(sender.selectedSegmentIndex));
}

- (IBAction)customSegmentedControlChanged:(DNSCastroSegmentedControl *)sender
{
    NSString *controlName = nil;
    if (sender == self.segmentedControl) {
        controlName = @"First Segmented Control";
    } else if (sender == self.stairsSegmentedControl) {
        controlName = @"Stairs Segmented Control";
    } else if (sender == self.programmaticSegmentedControl) {
        controlName = @"Programmatic Segmented Control";
    } else if (sender == self.autosizedSegmentedControl) {
        controlName = @"Auto-sized Segmented Control";
    }
    
    NSLog(@"Control %@ changed to index %@", controlName, @(sender.selectedSegmentIndex));
}

@end