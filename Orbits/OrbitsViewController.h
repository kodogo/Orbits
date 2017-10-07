//
//  OrbitsViewController.h
//  Orbits
//
//  Created by ajs on 15/8/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrbitsSettingsView.h"

enum RunTypes
{
	NORMAL,
	FIXED_SUN
};

@interface OrbitsViewController : UIViewController <UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *bodyTypes;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UISlider *animationSpeed;
@property (weak, nonatomic) IBOutlet OrbitsSettingsView *orbitsSettingsView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *runType;
@property (weak, nonatomic) IBOutlet UISwitch *showTrails;
@property (weak, nonatomic) IBOutlet UILabel *bodyCount;

- (IBAction)bodySelected:(UISegmentedControl *)sender;
- (IBAction)showSettings:(id)sender;
- (IBAction)animationSpeedChanged:(UISlider *)sender;
- (IBAction)runTypeChanged:(UISegmentedControl *)sender;
- (IBAction)showTrailsChanged:(UISwitch *)sender;
- (IBAction)resetBodies:(UIButton *)sender;
- (IBAction)showHelp:(UIButton *)sender;

-(void) pause;
-(void) resume;

@end
