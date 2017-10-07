//
//  OrbitsSettingsView.m
//  Orbits
//
//  Created by ajs on 26/8/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#import "OrbitsSettingsView.h"

@implementation OrbitsSettingsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//[self hide];
}

-(void)hide
{
[UIView animateWithDuration: 0.5
					  delay: 0
					options: (UIViewAnimationOptionCurveEaseOut)
				 animations:^{
					 self.alpha = 0.0;
				 }
				 completion:^( BOOL finished) {
					 self.hidden = YES;
				 }
 ];
}
-(void)show
{
	self.hidden = NO;
	[UIView animateWithDuration: 0.5
						  delay: 0
						options: (UIViewAnimationOptionCurveEaseOut)
					 animations:^{
						 self.alpha = 1.0;
					 }
					 completion:^( BOOL finished) {
					 }
	 ];
}

@end
