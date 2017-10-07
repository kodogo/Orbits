//
//  ViewController.h
//  Orbits
//
//  Created by ajs on 28/7/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *bodyTypes;

- (IBAction)bodySelected:(UISegmentedControl *)sender;

- (IBAction)resetBodies:(UIBarButtonItem *)sender;

@end

