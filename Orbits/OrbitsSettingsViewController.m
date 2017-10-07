//
//  OrbitsSettingsViewController.m
//  Orbits
//
//  Created by ajs on 23/08/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#import "OrbitsSettingsViewController.h"

@interface OrbitsSettingsViewController ()

@end

@implementation OrbitsSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.ovc.animationSpeed = round(self.animationSpeed.value);
	self.ovc.trailLength = self.trailLength.value;
	[self.ovc lockCMChanged:self.lockCM.on];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)lockCMChanged:(UISwitch*)sender {
	[self.ovc lockCMChanged:sender.on];
}
- (IBAction)trailLengthChanged:(UISlider*)sender {
	self.ovc.trailLength = round(sender.value);
	//printf("Trail length %f\n",sender.value );
}
- (IBAction)animationSpeedChanged:(UISlider*)sender {
	self.ovc.animationSpeed = sender.value;
	//printf("Animation speed %f\n",sender.value );
}

@end
