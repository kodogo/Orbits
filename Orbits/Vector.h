//
//  Vector.h
//  Orbits
//
//  Created by ajs on 28/7/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#ifndef __Orbits__Vector__
#define __Orbits__Vector__

struct Vector
{
	double x;
	double y;
};

typedef struct Vector Vector;

Vector MakeVector(double x, double y);

void ClearVector(Vector *v);
Vector AddVec(Vector a, Vector b);
Vector SubVec(Vector a, Vector b);
Vector ScaleVec(Vector v, double s);

#endif /* defined(__Orbits__Vector__) */
