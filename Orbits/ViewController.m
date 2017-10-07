//
//  ViewController.m
//  Orbits
//
//  Created by ajs on 28/7/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#import "ViewController.h"
#import "OrbitsView.h"
#import "BodyList.h"

#define TOOLBARHEIGHT 44
#define STATUSBARHEIGHT 20

@interface ViewController ()

@property(strong, nonatomic) OrbitsView *orbitsView;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	float cHeight = self.view.bounds.size.height - (STATUSBARHEIGHT + TOOLBARHEIGHT);
	float cWidth = self.view.bounds.size.width;
	
	self.orbitsView = [[OrbitsView alloc] initWithFrame:CGRectMake(0, STATUSBARHEIGHT, cWidth, cHeight)];
	self.orbitsView.backgroundColor = [UIColor blackColor];
	[self.view addSubview:self.orbitsView];
	[self initBodies];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	
	CGRect f;
	
	f.size.height = size.height - (STATUSBARHEIGHT + TOOLBARHEIGHT);
	f.size.width = size.width;
	f.origin.x = 0.0;
	f.origin.y = STATUSBARHEIGHT;
	
	[self.orbitsView setFrame:f];
	[self.orbitsView setNeedsDisplay];
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void) initBodies
{
	calcG(MSUN, 150, 5);
	initBodyList();
	
	Vector earthPos = MakeVector(150, 0);
	addBody(MakeVector(0, 0), MakeVector(0, 0), SUN);
	addBody(earthPos, circSpeed(earthPos, MSUN), EARTH);
	calcAcc();
}

- (IBAction)bodySelected:(UISegmentedControl *)sender {
	self.orbitsView.newBodyType = sender.selectedSegmentIndex;
}

- (IBAction)resetBodies:(UIBarButtonItem *)sender {
	[self initBodies];
}

@end
