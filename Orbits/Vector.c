//
//  Vector.c
//  Orbits
//
//  Created by ajs on 28/7/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#include "Vector.h"

void ClearVector(Vector *v)
{
	v->x = 0;
	v->y = 0;
}

Vector MakeVector(double x, double y)
{
	Vector v;
	v.x = x;
	v.y = y;
	return v;
}

Vector AddVec(Vector a, Vector b)
{
	Vector v;
	v.x = a.x + b.x;
	v.y = a.y + b.y;
	return v;
}

Vector SubVec(Vector a, Vector b)
{
	Vector v;
	v.x = a.x - b.x;
	v.y = a.y - b.y;
	return v;
}

Vector ScaleVec(Vector v, double s)
{
	Vector sv;
	sv.x = v.x * s;
	sv.y = v.y * s;
	return sv;
}
