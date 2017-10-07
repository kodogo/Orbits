//
//  BodyList.c
//  Orbits
//
//  Created by ajs on 1/8/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#include <stdio.h>
#include <math.h>
#include <time.h>
#include <string.h>
#include "Body.h"

#define EASING 1

double G;

static double BodyMasses[] = {1, 5, 15, 300, 5000, 30000, 330000, 3300000};
void calcCM(BodyList *bl);

void LogBody(Body *b)
{
//	printf("x, y:\t%.10f\t%.10f\tvx, vy:\t%.10f\t%.10f\tax, ay:\t%.10f\t%.10f\t\n", b->r.x, b->r.y, b->v.x, b->v.y, b->a.x, b->a.y);
	
}

void calcG(double M, double r, double T)
{
	// Calculates the gravitational constant so that a circular orbit of radius r
	// around a body of mass M has a period of T seconds.
	// M is measured in multiples of the earth's mass, and r is measured in points
	// (ie screen co-ordinate units)
	G = (pow(r, 3) * 4.0 * M_PI * M_PI) / (M * T * T);
}

void clearBodyList(BodyList *bl)
{
	bl->nBodies = 0;
	memset(bl->bodies, 0, sizeof(bl->bodies));
}

void calcAcc(BodyList *bl)
{
	// Sets up the acceleration for each body for Verlet integration, given the set of initial
	// positions and velocities
	
	int i;
	int j;
	Vector r;
	double k;
	double rsq;
	Body *bi, *bj;
	
	Body *b = bl->bodies;
	int n = bl->nBodies;
	for(i = 0; i < n; i++) {
		ClearVector(&(b->a));
		b++;
	}
	
	bi = bl->bodies;
	for(i = 0; i < n - 1; i++) {
		bj = bi + 1;
		for(j = i+1; j < n; j++) {
			r = SubVec(bj->r, bi->r);
			rsq = (r.x * r.x) + (r.y * r.y);
			k = G / pow(rsq + EASING, 1.5);
			bi->a = AddVec(bi->a, ScaleVec(r, k * bj->mass));
			bj->a = SubVec(bj->a, ScaleVec(r, k * bi->mass));
			bj++;
		}
		bi++;
	}
}

void calcCM(BodyList *bl)
{
	// Calculate the centre of mass position of the bodies
	if(bl->nBodies == 0) {
		memset(&bl->cMass, 0, sizeof(Body));
		return;
	}
	
	double xsum = 0;
	double ysum = 0;
	double xdotsum = 0;
	double ydotsum = 0;
	bl->totalMass = 0.0;
	Body *b;
	Body *bend;
	int n = bl->nBodies;
	bend = bl->bodies + n;
	for(b = bl->bodies; b < bl->bodies + n; b++) {
		bl->totalMass += b->mass;
		xsum += (b->mass * b->r.x);
		ysum += (b->mass * b->r.y);
		xdotsum += (b->mass * b->v.x);
		ydotsum += (b->mass * b->v.y);
	}
	bl->cMass.r.x = xsum/bl->totalMass;
	bl->cMass.r.y = ysum/bl->totalMass;
	bl->cMass.v.x = xdotsum/bl->totalMass;
	bl->cMass.v.y = ydotsum/bl->totalMass;
}

void nail(BodyList *bl)
{
	// Calculate the centre of mass position of the bodies
	if(bl->nBodies == 0)
		return;
	Vector r = bl->bodies[0].r;
	Body *b;
	int n = bl->nBodies;
	for(b = bl->bodies; b < bl->bodies + n; b++) {
		b->r = SubVec(b->r, r);
	}
}


Body makeBody(Vector r, Vector v, int bodyType)
{
	Body b;
	int i;
	memset(&b, 0, sizeof(Body));
	b.r = r;
	b.v = v;
	b.mass = BodyMasses[bodyType];
	b.bodyType = bodyType;
	b.trailptr = 0;
	for(i = 0; i < nelem(b.trail); i++)
		b.trail[i] = r;
	return b;
}

void resetVelocities(BodyList *bl)
{
	Body *bp;
	calcCM(bl);
	for(bp = bl->bodies; bp < bl->bodies + bl->nBodies; bp++)
		bp->v = SubVec(bp->v, bl->cMass.v);
	bl->cMass.v = MakeVector(0,0);
	
}

Body addBody(BodyList *bl, Body b, int fixedCM)
{
	if(bl->nBodies == MAX_BODIES)
		return b;
	bl->bodies[bl->nBodies++] = b;
	if(fixedCM) {
		resetVelocities(bl);
	}
	calcAcc(bl);
	return b;
}

void removeBody(BodyList *bl, int n)
{
	bl->nBodies--;
	memmove(bl->bodies+n, bl->bodies+n+1, sizeof(Body) * (bl->nBodies - n));
}


void stepBodies(BodyList *bl, double dt)
{
	// For the current list of bodies and value of G, advances the position of each
	// body for the specified time interval
	
	// Assume that the velocities and accelerations at the current position are known
	if(dt == 0)
		return;
//	printf("%.6f milliseconds\n", dt*1000.0);
	int n = bl->nBodies;
	Body *b;
	for(b = bl->bodies; b < bl->bodies + n; b++) {
		b->v = AddVec(b->v, ScaleVec(b->a, 0.5 * dt));
		b->r = AddVec(b->r, ScaleVec(b->v, dt));
	}
	// Now that all of the positions are updated, calculate the accelerations
	calcAcc(bl);
	
	// And update the velocities for the second half step of the current interval
	for(b = bl->bodies; b < bl->bodies + n; b++) {
		b->v = AddVec(b->v, ScaleVec(b->a, 0.5 * dt));
	}
}

void updateTrails(BodyList *bl)
{
	Body *bp;
	for(bp = bl->bodies; bp < bl->bodies + bl->nBodies; bp++) {
		bp->trail[bp->trailptr] = bp->r;
		bp->trailptr = (bp->trailptr + 1) % nelem(bp->trail);
	}
		
}

void multistepBodies(BodyList *bl, int n)
{
	// Just here for timing purposes
	
	bl->nBodies = n;
	for(int i = 0; i < 100; i++)
	 stepBodies(bl, 0.01);
	
	
}

Vector calcAccCM(BodyList *bl, double mass, Vector pos)
{
	// Calculates the acceleration at position pos assuming all other masses fixed
	Vector a = MakeVector(0, 0);
	Vector r;
	double rsq;
	double amod;
	Body *b;
	
	for(b = bl->bodies; b < bl->bodies + bl->nBodies; b++) {
		r = SubVec(pos, b->r);
		rsq = (r.x * r.x) + (r.y * r.y);
		amod = (G * (b->mass)) / pow(rsq + EASING, 1.5);
		a = SubVec(a, ScaleVec(r, amod));
	}
	return a;
}

void projectPath(BodyList *bl, Body b, Vector *path, int n, double dt, int fixedCM)
{
	// Projects the path of an object with the specified velocity assuming all other masses fixed
	// Just uses the centre of mass fixed at its current position
	int i;
	if(fixedCM && bl->nBodies == 0) {
		for(i = 1; i < n; i++)
			path[i] = path[0];
		return;
	}
	Vector a;
	Vector v = b.v;

	int oind = 1;
	a = calcAccCM(bl, b.mass, path[0]);
	Vector r = path[0];
	for(i = 0; i < n; i++) {
		v = AddVec(v, ScaleVec(a, 0.5 * dt));
		r = AddVec(r, ScaleVec(v, dt));
		path[oind++] = r;
		a = calcAccCM(bl, b.mass, r);
		v = AddVec(v, ScaleVec(a, 0.5 * dt));
	}
}

Vector circSpeed(Vector r, double M)
 {
	Vector v;
	double modr, modv;
	modr = sqrt((r.x * r.x) + (r.y * r.y));
	modv = sqrt(G * M / modr);
	
	v.x = -r.y * modv/modr;
	v.y = r.x * modv/modr;
	return v;
 }


/*
void projectPathAll(BodyList *bl, Vector *path, int n, int fixedCM)
{
	// Projects the path of a new body.
	// Time steps of 0.01 seconds are used at this point

	int i, ind;
	BodyList pbl = *bl;
	
	Body *bp = pbl.bodies + pbl.nBodies - 1;
	path[0] = bp->r;
	ind = 0;
	for(i = 0; i < n/10; i++) {
		stepBodies(&pbl, 0.1);
		if(i % 1 == 0)
			path[ind++] =  bp->r;
	}
}
*/
