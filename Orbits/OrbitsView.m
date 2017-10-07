//
//  OrbitsView.m
//  Orbits
//
//  Created by ajs on 28/7/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#import "OrbitsView.h"
#import "Body.h"
#import <math.h>
#import "BodyList.h"

#define NCOLOURS 8
#define MAX_SCALE 5
#define YEAR 6

@implementation OrbitsView

BodyList bodyList;
NSMutableArray *bodyImageViews;
UIImage *bodyImages[8];


NSArray *bodyColours;
CGFloat displayWidth[] = {16, 18, 20, 22, 24, 26, 40, 50};
CGGradientRef gradients[NCOLOURS];
CGColorSpaceRef colourSpace;

CAShapeLayer *trailLayers[NCOLOURS];
CAShapeLayer *projectedLayer;
UIBezierPath *trailPaths[NCOLOURS];

double Scale;
Vector ScreenCentre;  // Position of screen centre in world co-ordinates

double gameRadius;
double gameLimit;
CGRect gameRect;

CGPoint startTouch;
bool addInProgress;
NSValue *initialTouch;

Body newBody;
UIImageView *newBodyImage;

int nBodies[8];

int rgbValues[NCOLOURS][3] =
{
	{22, 35, 255},
	{236, 61, 145},
	{6, 197, 199},
	{63, 58, 171},
	{155, 61, 63},
	{174, 174, 174},
	{255, 178, 0},
	{255, 47, 0}
};

-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if(self) {
		displayLink = [CADisplayLink displayLinkWithTarget:self
												  selector:@selector(updatePositions)];
		displayLink.paused = YES;
		[displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
	
		bodyColours =
			[NSArray arrayWithObjects:
				 [UIColor colorWithRed:rgbValues[0][0]/255.0 green:rgbValues[0][1]/255.0 blue:rgbValues[0][2]/255.0 alpha:1],
				 [UIColor colorWithRed:rgbValues[1][0]/255.0 green:rgbValues[1][1]/255.0 blue:rgbValues[1][2]/255.0 alpha:1],
				 [UIColor colorWithRed:rgbValues[2][0]/255.0 green:rgbValues[2][1]/255.0 blue:rgbValues[2][2]/255.0 alpha:1],
				 [UIColor colorWithRed:rgbValues[3][0]/255.0 green:rgbValues[3][1]/255.0 blue:rgbValues[3][2]/255.0 alpha:1],
				 [UIColor colorWithRed:rgbValues[4][0]/255.0 green:rgbValues[4][1]/255.0 blue:rgbValues[4][2]/255.0 alpha:1],
				 [UIColor colorWithRed:rgbValues[5][0]/255.0 green:rgbValues[5][1]/255.0 blue:rgbValues[5][2]/255.0 alpha:1],
				 [UIColor colorWithRed:rgbValues[6][0]/255.0 green:rgbValues[6][1]/255.0 blue:rgbValues[6][2]/255.0 alpha:1],
				 [UIColor colorWithRed:rgbValues[7][0]/255.0 green:rgbValues[7][1]/255.0 blue:rgbValues[7][2]/255.0 alpha:1],
				 nil
			 ];
		[self makeShapeLayers];
		[self addGestureRecognisers];
		self.runType = NORMAL;
		[self loadImages];
		self.ovc.showTrails.on = NO;
		self.ovc.animationSpeed.value = 1.0;
		[self initView];
	}
	return self;
}

-(void) initView
{
    // Sets up data common to the normal and game modes, and then calls mode-specific methods
    Scale = 1.0;
    addInProgress = false;
    self.fixedCM = 1;
    lastTime = 0;
//    self.ovc.showTrails.on = NO;
//    self.ovc.animationSpeed.value = 1.0;
    
    clearBodyList(&bodyList);
    [self clearBodyImages];
    calcG(MSUN, 200, YEAR);
	memset(nBodies, 0, sizeof(nBodies));
	ScreenCentre = MakeVector(0, 0);
	if(self.runType == FIXED_SUN)
		[self addNewBody:makeBody(MakeVector(0,0), MakeVector(0,0), SUN)];
	self.ovc.bodyCount.text = [NSString stringWithFormat:@"%d", bodyList.nBodies];
}



-(void) makeShapeLayers
{
	int i;
	projectedLayer = [[CAShapeLayer alloc] init];
	projectedLayer.fillColor = [[UIColor clearColor] CGColor];
	projectedLayer.zPosition = -2;
	projectedLayer.strokeColor = [[UIColor whiteColor] CGColor];
	projectedLayer.lineWidth = 2;
	[self.layer addSublayer:projectedLayer];
	
	for(i = 0; i < NCOLOURS; i++) {
		trailLayers[i] = [[CAShapeLayer alloc] init];
		trailLayers[i].strokeColor = [bodyColours[i] CGColor];
		trailLayers[i].fillColor = [[UIColor clearColor] CGColor];
		trailLayers[i].lineWidth = 2;
		[self.layer addSublayer:trailLayers[i]];
		trailLayers[i].zPosition = -1;
		trailPaths[i] = [[UIBezierPath alloc] init];
	}
}

-(void)loadImages
{
	bodyImages[0] = [UIImage imageNamed:@"earth"];
	bodyImages[1] = [UIImage imageNamed:@"superearth"];
	bodyImages[2] = [UIImage imageNamed:@"icegiant"];
	bodyImages[3] = [UIImage imageNamed:@"gasgiant"];
	bodyImages[4] = [UIImage imageNamed:@"browndwarf"];
	bodyImages[5] = [UIImage imageNamed:@"dwarfstar"];
	bodyImages[6] = [UIImage imageNamed:@"sun"];
	bodyImages[7] = [UIImage imageNamed:@"giantstar"];
	bodyImageViews = [[NSMutableArray alloc] init];
}

-(void) addBodyImage:(Body)b
{
	UIImageView *iv = [[UIImageView alloc] initWithImage:bodyImages[b.bodyType]];
	[bodyImageViews addObject:iv];
	
    [self drawImage:iv forBody:&b];
	[self addSubview:iv];
	[self sendSubviewToBack:iv];
}

-(void)clearBodyImages
{
	int i;
	for(i = 0; i < [bodyImageViews count]; i++)
		[bodyImageViews[i] removeFromSuperview];
	[bodyImageViews removeAllObjects];
    newBodyImage = nil;
}
-(void)updatePositions
{
	int i, nsteps;
	double dt;
	if(lastTime == 0) {
		lastTime = displayLink.timestamp;
		return;
	}
	
	CFTimeInterval elapsed = displayLink.timestamp - lastTime;
	if(bodyList.nBodies <= 50)
		nsteps = 10;
	else if (bodyList.nBodies <= 100)
		nsteps = 2;
	else
		nsteps = 1;
	
	dt = (self.ovc.animationSpeed.value * elapsed) / nsteps;
	lastTime = displayLink.timestamp;
	for(i = 0; i < nsteps; i++)
		stepBodies(&bodyList, dt);
	updateTrails(&bodyList);
    [self checkBodyLimits];
	[self redrawBodies];
}

-(void)addGestureRecognisers
{
	UIPanGestureRecognizer *panRecognizer =
	[[UIPanGestureRecognizer alloc] initWithTarget:self
											action:@selector(pan:)];
	panRecognizer.delegate = self;
	
//	panRecognizer.cancelsTouchesInView = YES;
	panRecognizer.minimumNumberOfTouches = 2;
	panRecognizer.maximumNumberOfTouches = 2;
	[self addGestureRecognizer:panRecognizer];
	
	UIPinchGestureRecognizer *pinchRecognizer =
		[[UIPinchGestureRecognizer alloc] initWithTarget:self
											action:@selector(zoom:)];
	pinchRecognizer.delegate = self;
	[self addGestureRecognizer:pinchRecognizer];

}

- (void)redrawBodies
{
	int i;

	Body *b = bodyList.bodies;
	for(i = 0; i < NCOLOURS; i++)
		[trailPaths[i] removeAllPoints];
	
	for(i = 0; i < bodyList.nBodies; i++) {
		[self drawImage:(UIImageView *) bodyImageViews[i] forBody:b];
		if(self.ovc.showTrails.on)
			[self drawTrailsInPath:trailPaths[b->bodyType] forBody:b];
		b++;
	}
	for(i = 0; i < NCOLOURS; i++)
		trailLayers[i].path = trailPaths[i].CGPath;
}

-(void)drawProjectedPath:(CGPoint)translation
{
	int i;
	Vector path[2000];
	
	int nPoints = 100;
	
	path[0] = [self screenToWorld:startTouch];
	newBody.v  = ScaleVec(MakeVector(translation.x, -translation.y), 10.0);
	projectPath(&bodyList, newBody, path, nPoints, 0.005, self.fixedCM);
	
	UIBezierPath *projectedPath = [[UIBezierPath alloc] init];
	[projectedPath moveToPoint:[self worldToScreen:path[0]]];
	for(i = 1; i < nPoints; i++)
		[projectedPath addLineToPoint:[self worldToScreen:path[i]]];

	projectedLayer.path = [projectedPath CGPath];
	
	
}

-(void)addNewBody:(Body)b
{
	addBody(&bodyList, b, self.fixedCM);
	[self addBodyImage:b];
    nBodies[b.bodyType]++;
	self.ovc.bodyCount.text = [NSString stringWithFormat:@"%d", bodyList.nBodies];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//printf("Began\n");
	if(bodyList.nBodies == MAX_BODIES)
	   return;
   if(initialTouch != nil)
        return;
    if(addInProgress || touches.count != 1)
        return;
    UITouch *t = [touches anyObject];
    startTouch  = [t locationInView:self];
	Vector s = [self screenToWorld:startTouch];
	newBody = makeBody(s, MakeVector(0, 0), self.ovc.bodyTypes.selectedSegmentIndex);
	initialTouch = [NSValue valueWithNonretainedObject:t];
	addInProgress = true;
    if(self.runType == NORMAL)
        [self pause];
}

-(void)touchesEndedNormal:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *t = [touches anyObject];
	if(![[NSValue valueWithNonretainedObject:t] isEqualToValue:initialTouch])
		return;

	CGPoint endTouch  = [t locationInView:self];
	Vector s = [self screenToWorld:startTouch];
	Vector r = [self screenToWorld:endTouch];
	newBody.v = ScaleVec(SubVec(r, s), 10.0/Scale);
    [self addNewBody:newBody];
    [newBodyImage removeFromSuperview];
	newBodyImage = nil;
	projectedLayer.path = nil;
}

-(void)touchesEndedFixedSun:(NSSet *)touches withEvent:(UIEvent *)event
{
	Vector r = [self screenToWorld:startTouch];
	r = [self adjustPoint:r minRadius:35];
	newBody.r = r;
    newBody.v = AddVec(bodyList.bodies[0].v, circSpeed(SubVec(r, bodyList.bodies[0].r), MSUN));
    [self addNewBody:newBody];
	[newBodyImage removeFromSuperview];
	newBodyImage = nil;
	projectedLayer.path = nil;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//printf("Ended\n");

    if(!addInProgress)
        return;
	if(self.runType == NORMAL)
		[self touchesEndedNormal:touches withEvent:event];
	else
		[self touchesEndedFixedSun:touches withEvent:event];
	addInProgress = false;	
	initialTouch = nil;
	[self redrawBodies];
	[self resume];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//printf("Moved\n");
	if(touches.count != 1)
		return;
	if(initialTouch == nil)
		return;
	UITouch *t = [touches anyObject];
	if(![[NSValue valueWithNonretainedObject:t] isEqualToValue:initialTouch])
		return;
	CGPoint endTouch  = [t locationInView:self];
	CGPoint tr = CGPointMake(endTouch.x - startTouch.x, endTouch.y - startTouch.y);
	if((tr.x*tr.x + tr.y*tr.y) < 200)
		return;
	[self pause];
    if(newBodyImage==nil) {
        newBodyImage = [[UIImageView alloc] initWithImage:bodyImages[self.ovc.bodyTypes.selectedSegmentIndex]];
        [self drawImage:newBodyImage forBody:&newBody];
        [self addSubview:newBodyImage];
        [self sendSubviewToBack:newBodyImage];
    }
    
    //[self drawImage:newBodyImage forBody:&newBody];
	if(self.runType == NORMAL) {
		[self drawProjectedPath:CGPointMake(endTouch.x - startTouch.x, endTouch.y - startTouch.y)];
	}
	//[self redrawBodies];
}


-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	//printf("Cancelled\n");
	[self resume];
	[newBodyImage removeFromSuperview];
	newBodyImage = nil;
	projectedLayer.path = nil;
	addInProgress = false;
	initialTouch = nil;
}

- (void)pan:(UIPanGestureRecognizer *)gr{
	//printf("Pan\n");
	CGPoint tr = [gr translationInView:self];
	if (gr.state == UIGestureRecognizerStateChanged) {
		ScreenCentre.x -= (tr.x * Scale);
		ScreenCentre.y += (tr.y * Scale);
		[gr setTranslation:CGPointZero inView:self];
		[self redrawBodies];
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer: (UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

-(void)zoom:(UIPinchGestureRecognizer *)gr
{
	//printf("Zoom\n");
	if(addInProgress)
		return;
	if (gr.state == UIGestureRecognizerStateChanged) {
		Scale /= gr.scale;
		gr.scale = 1.0;
		if(Scale < 1)
			Scale = 1;
		if(Scale > MAX_SCALE)
		   Scale = MAX_SCALE;
	}
}

-(Vector)screenToWorld:(CGPoint) location
{
	Vector v;
	
	v.x = ScreenCentre.x +  Scale * (location.x - self.center.x);
	v.y = ScreenCentre.y -  Scale * (location.y - self.center.y);
	return v;
}

-(CGPoint)worldToScreen:(Vector) r
{
	double x;
	double y;
	
	x = self.center.x + (r.x - ScreenCentre.x)/Scale;
	y = self.center.y + (ScreenCentre.y - r.y) / Scale;
	return CGPointMake(x, y);
}

-(void)dealloc
{
	int i;
	for(i = 0; i < NCOLOURS; i++)
		CGGradientRelease(gradients[i]);

	CGColorSpaceRelease(colourSpace);
}

- (void)drawBody:(Body *)b inContext:(CGContextRef) context
{

	CGFloat w = displayWidth[b->bodyType] / Scale;
	if(w < 5.0)
		w = 5.0;
	CGFloat wby2 = w / 2.0;
	CGFloat wby4 = w / 4.0;
	CGPoint sr = [self worldToScreen:b->r];
	CGContextDrawRadialGradient(context, gradients[b->bodyType], CGPointMake(sr.x - wby4, sr.y + wby4), 0.0, sr, wby2, 0);
}

- (void)drawImage:(UIImageView *)iv forBody:(Body*) b
{
	
	CGFloat w = displayWidth[b->bodyType] / Scale;
	if(w < 5.0)
		w = 5.0;
	CGFloat wby2 = w / 2.0;
	CGPoint sr = [self worldToScreen:b->r];
	
	iv.frame = CGRectMake(sr.x - wby2, sr.y - wby2, w, w);
}

-(void)drawTrailsInPath:(UIBezierPath *)path forBody:(Body*)b
{
	int i;
	int tptr = b->trailptr - 1;
	if(tptr < 0)
		tptr += nelem(b->trail);
	int nPoints = 20;
	int step = 1;
	if(nPoints > nelem(b->trail))
		nPoints = nelem(b->trail);
	
	if(nPoints == 0)
		return;

	CGPoint sr = [self worldToScreen:b->r];
	
	[path moveToPoint:sr];
	for(i = 0; i < nPoints; i++) {
		sr = [self worldToScreen:b->trail[tptr]];
		tptr -= step;
		[path addLineToPoint:sr];
		if(tptr < 0)
			tptr += nelem(b->trail);
	}
}

-(void)pause
{
	displayLink.paused = YES;
}

-(void)resume
{
	lastTime = 0;
	displayLink.paused = NO;
}

- (void)lockCMChanged:(BOOL)state {
	self.fixedCM = state;
	if(state)
		resetVelocities(&bodyList);
}

-(NSString *) fmtInteger:(NSUInteger) i
  {
      NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
      [fmt setNumberStyle:NSNumberFormatterDecimalStyle]; // to get commas (or locale equivalent)
      [fmt setMaximumFractionDigits:0]; // to avoid any decimal
      return [fmt stringFromNumber:@(i)];
  }


-(void)checkBodyLimits
{
    // Try culling bodies too far from the screen centre
    int i;
    int nRemoved = 0;
    for(i = 0; i < bodyList.nBodies; i++) {
        Vector r = SubVec(bodyList.bodies[i].r, ScreenCentre);
        double rsq = (r.x * r.x) + (r.y * r.y);
        // Try 10 times 1000 points for starters
        if(rsq > 1e8) {
            removeBody(&bodyList, i);
            [bodyImageViews[i] removeFromSuperview];
            [bodyImageViews removeObjectAtIndex:i];
            nRemoved++;
        }
    }
    if(nRemoved > 0) {
//        resetVelocities(&bodyList);
        self.ovc.bodyCount.text = [NSString stringWithFormat:@"%d", bodyList.nBodies];
    }
}


-(Vector)adjustPoint:(Vector)p minRadius:(double) minr
{
	double r = sqrt((p.x * p.x) + (p.y * p.y));
	if(r >= minr)
		return p;
	if(r == 0)
		return MakeVector(minr, 0);

	return ScaleVec(p, minr/r);
}

@end
