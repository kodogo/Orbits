//
//  OrbitsViewController.m
//  Orbits
//
//  Created by ajs on 15/8/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#import "OrbitsViewController.h"
#import "OrbitsHelpViewController.h"
#import "OrbitsView.h"
#import "BodyList.h"

#define TOOLBARHEIGHT 44
#define STATUSBARHEIGHT 20


@interface OrbitsViewController ()

@property OrbitsView *orbitsView;
@property NSArray *massTypes;
@property NSArray *massDescriptions;
@property (nonatomic, strong) UIPopoverController *settingsPopover;
@property OrbitsHelpViewController *ohvc;

@end

@implementation OrbitsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.orbitsView = (OrbitsView *) self.view;
    self.orbitsView.ovc = self;
	self.orbitsView.backgroundColor = [UIColor blackColor];
	[self initMassTypes];
	//[self.settingsButton setTitle:@"\u2699" forState:UIControlStateNormal];
	self.orbitsSettingsView.hidden = TRUE;
	self.orbitsSettingsView.backgroundColor = [UIColor clearColor];
    [self setupBodyTypes];
	self.ohvc = [[OrbitsHelpViewController alloc] init];
	
	[self resume];
}

-(void) viewWillAppear:(BOOL)animated
{
	[self resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initMassTypes
{
	self.massTypes = @[@"Earth", @"Super Earth", @"Ice giant", @"Gas giant",
					   @"Brown dwarf", @"Dwarf star", @"Sun", @"Giant star", @"Supergiant star"];
	
	self.massDescriptions = @[@"1 earth mass", @"5 earth masses", @"15 earth masses", @"300 earth masses",
							  @"5000 earth masses", @"30,000 earth masses", @"330,000 earth masses",
							  @"10 sun masses", @"100 sun masses"];
	
}

- (IBAction)bodySelected:(UISegmentedControl *)sender {
}

- (IBAction)showSettings:(id)sender {
	if(self.orbitsSettingsView.hidden)
		[self.orbitsSettingsView show];
	else
		[self.orbitsSettingsView hide];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(BOOL)prefersStatusBarHidden {
	return YES;
}

- (IBAction)animationSpeedChanged:(UISlider *)sender {
}

- (IBAction)runTypeChanged:(UISegmentedControl *)sender {
	self.orbitsView.runType = self.runType.selectedSegmentIndex;
    [self setupBodyTypes];
	[self.orbitsView initView];
}

- (IBAction)showTrailsChanged:(UISwitch *)sender {
}

- (IBAction)resetBodies:(UIButton *)sender {
	[self.orbitsView initView];
}

- (IBAction)showHelp:(UIButton *)sender {
	[self pause];
	[self presentViewController:self.ohvc animated:YES completion:nil];
	
}

-(void)pause
{
	[self.orbitsView pause];
}
	
-(void)resume
{
	[self.orbitsView resume];
}

/*
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
*/
-(void)setupBodyTypes
{
    NSUInteger nTypes;
    int i;
    NSArray *types = @[@"Earth", @"Super Earth", @"Ice giant", @"Gas giant", @"Brown dwarf",
                       @"Dwarf star", @"Sun", @"Giant star"];
    if(self.runType.selectedSegmentIndex == NORMAL)
       nTypes = [types count] - 1;
    else
        nTypes = [types count] - 2;
    [self.bodyTypes removeAllSegments];
    for(i = 0; i < nTypes; i++)
        [self.bodyTypes insertSegmentWithTitle:types[i] atIndex:i animated:NO];

	if(self.runType.selectedSegmentIndex == NORMAL)
		self.bodyTypes.selectedSegmentIndex = SUN;
	else
		self.bodyTypes.selectedSegmentIndex = EARTH;

}
@end
