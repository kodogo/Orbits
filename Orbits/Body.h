//
//  Body.h
//  Orbits
//
//  Created by ajs on 29/7/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#include "Vector.h"

enum BodyTypes
{
	EARTH,
	SUPER_EARTH,
	ICE_GIANT,
	GIANT,
	BROWN_DWARF,
	DWARF_STAR,
	SUN,
	GIANT_STAR
};

struct Body
{
	Vector r;
	Vector v;
	Vector a;
	double mass;
	int bodyType;
	Vector trail[100];
	int trailptr;
};

typedef struct Body Body;

struct BodyList
{
	Body bodies[500];
	int nBodies;
	Body cMass;
	double totalMass;
};

typedef struct BodyList BodyList;

#define	nelem(x)	(sizeof(x)/sizeof((x)[0]))

#define MAX_BODIES 10
