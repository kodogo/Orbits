//
//  OrbitsSettingsViewController.h
//  Orbits
//
//  Created by ajs on 23/08/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrbitsViewController.h"

@interface OrbitsSettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *lockCM;
@property (weak, nonatomic) IBOutlet UISlider *trailLength;
@property (weak, nonatomic) IBOutlet UISlider *animationSpeed;

@property OrbitsViewController *ovc;

- (IBAction)lockCMChanged:(UISwitch*)sender;
- (IBAction)trailLengthChanged:(id)sender;
- (IBAction)animationSpeedChanged:(id)sender;

@end
