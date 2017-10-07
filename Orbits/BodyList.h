//
//  BodyList.h
//  Orbits
//
//  Created by ajs on 1/8/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#ifndef Orbits_BodyList_h
#define Orbits_BodyList_h

#import "Body.h"

#define MSUN 330000

// Gravitational constant
extern double G;

void clearBodyList(BodyList *bl);
Body addBody(BodyList *bl, Body b, int fixedCM);
Body makeBody(Vector r, Vector v, int bodyType);
void removeBody(BodyList *bl, int n);

void calcG(double M, double r, double T);
Vector circSpeed(Vector r, double M);
void calcAcc(BodyList *bl);
void calcCM(BodyList *bl);
void stepBodies(BodyList *bl, double dt);
void multistepBodies(BodyList *bl, int n);
void projectPath(BodyList *bl, Body b, Vector *path, int n, double dt, int fixedCM);
void projectPathAll(BodyList *bl, Body b, Vector *path, int n, int fixedCM);
void resetVelocities(BodyList *bl);
void updateTrails(BodyList *bl);

#endif
