//
//  OrbitsView.h
//  Orbits
//
//  Created by ajs on 28/7/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrbitsViewController.h"


@interface OrbitsView : UIView  <UIGestureRecognizerDelegate>

{
	CADisplayLink *displayLink;
	CFTimeInterval lastTime;
}

@property OrbitsViewController *ovc;
@property int fixedCM;
@property int runType;

-(void) pause;
-(void) resume;

-(void) initView;

@end
