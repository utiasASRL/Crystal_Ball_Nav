//
//
//		0==========================0
//		|    Local feature test    |
//		0==========================0
//
//		version 1.0 : 
//			> 
//
//---------------------------------------------------
//
//		Cloud source :
//		Define usefull Functions/Methods
//
//----------------------------------------------------
//
//		Hugues THOMAS - 10/02/2017
//


#include "points.h"


// Getters
// *******

PointXYZ max_point(const std::vector<PointXYZ>& points)
{
	// Initialize limits
	PointXYZ maxP(points[0]);

	// Loop over all points
	for (auto p : points)
	{
		if (p.x > maxP.x)
			maxP.x = p.x;

		if (p.y > maxP.y)
			maxP.y = p.y;

		if (p.z > maxP.z)
			maxP.z = p.z;
	}

	return maxP;
}


PointXYZ min_point(const std::vector<PointXYZ>& points)
{
	// Initialize limits
	PointXYZ minP(points[0]);

	// Loop over all points
	for (auto p : points)
	{
		if (p.x < minP.x)
			minP.x = p.x;

		if (p.y < minP.y)
			minP.y = p.y;

		if (p.z < minP.z)
			minP.z = p.z;
	}

	return minP;
}


PointXYZ max_point(const PointXYZ A, const PointXYZ B)
{
	// Initialize limits
	PointXYZ maxP(A);
	if (B.x > maxP.x)
		maxP.x = B.x;
	if (B.y > maxP.y)
		maxP.y = B.y;
	if (B.z > maxP.z)
		maxP.z = B.z;
	return maxP;
}

PointXYZ min_point(const PointXYZ A, const PointXYZ B)
{
	// Initialize limits
	PointXYZ maxP(A);
	if (B.x < maxP.x)
		maxP.x = B.x;
	if (B.y < maxP.y)
		maxP.y = B.y;
	if (B.z < maxP.z)
		maxP.z = B.z;
	return maxP;
	
	
}

