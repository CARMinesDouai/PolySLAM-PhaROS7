"
This class computes intersections between lines (and derived classes). The class-side method #intersectLine:withLine: returns an instance, that can be used to determine the intersection point (if intersecting) and whether or not line-segments/rays do intersect.


Methods (class-side):
	intersectLine: <VMLine> withLine: <VMLine>
		returns an instance that can be used to determine whether the lines / line segments / eays do intersect.
		the first argument is referred to as 'lineA', the second argument as 'lineB'.


Methods (instance-side):
	ifIntersectsDo: <Block, 3 args> ifParallelDo: <Block, 0 args> ifCollinearDo: <Block, 2 args>
		does as the method name indicates. exectly one of the blocks is executed, meaning that if the lines are
		collinear, the prallel block will not be executed, beside the fact tha collinear lines are parallel too.
		intersec block arguments:
			1) intersection point
			2) factor 't'
			3) factor 'u'
		collinear block arguments:
			1) ray factors first
			2) ray factors second
	
	factorT
		returns factor 't' which determines the intersection point as: lineA pointA + (t * lineA direction).
		
	factorU
		returns factor 'u' which determines the intersection point as: lineB pointA + (t * lineB direction).
		
	rayFactors
		returns the ray factors, which can be used to determine wheather the ray would hit lineB if it were
		a line segment.
		lineB pointA = lineA pointA + (rayFactor first * lineA direction)
		lineB pointB = lineA pointA + (rayFactor second * lineA direction)
	
	isParallel
		returns true, if the lines ar parallel or collinear
	
	isCollinear
		returns true, if the lines are collinear
	
	intersectionPoint
		returns the intersection point (with the point type set to VMPointTypeIntersetion).
		this returns a point, even if the lines do not intersect. use 'isParallel' and 'isCollinear'
		to check for special conditions.

"
Class {
	#name : #VMIntersection,
	#superclass : #Object,
	#instVars : [
		'lineA',
		'lineB',
		't',
		'u',
		'ts',
		'tr',
		'vecA',
		'vecB',
		'crossAB'
	],
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #'as yet unclassified' }
VMIntersection class >> intersectLine: firstLine withLine: secondLine [
	^(self new)
		intersectLine: firstLine withLine: secondLine;
		yourself.
]

{ #category : #accessors }
VMIntersection >> factorT [
	^t.
]

{ #category : #accessors }
VMIntersection >> factorU [
	^u.
]

{ #category : #intersecting }
VMIntersection >> ifIntersectsDo: iBlock ifParallelDo: pBlock ifCollinearDo: cBlock [
	"note: if the lines are collinear, only 'cBlock' is executed, despite being parallel and intersecting too"
	
	self isCollinear ifTrue: [
		| factors |
		factors := self rayFactors.
		cBlock
			cull: factors first
			cull: factors second.
		^self.
	].
	
	self isParallel ifTrue: [
		pBlock value.
		^self.
	].
	
	iBlock
		cull: self intersectionPoint
		cull: t
		cull: u.
]

{ #category : #'as yet unclassified' }
VMIntersection >> initialize [
	t := 0.0.
	u := 0.0.

]

{ #category : #testing }
VMIntersection >> insideLineASegment [
	"returns true if the intersection point is inside the line segment defined by
	lineA pointA and lineA pointB"
	^t between: 0.0 and: 1.0.
]

{ #category : #testing }
VMIntersection >> insideLineBSegment [
	^u between: 0.0 and: 1.0.
]

{ #category : #intersecting }
VMIntersection >> intersectLine: firstLine withLine: secondLine [
	"computes if the two lines intersect, and returns a boolean according to the result.
	
	if the lines intersect,	aBlock is executed with three values:
		1) the intersection point
		2) construction factor 't', such that 'self pointA + (t * self direction)' creates the intersection point
		3) construction factor 'u', such that 'aLine pointA + (t * aLine direction)' creates the intersection point
	
	note: parallel lines intersect, if the distance between them is zero. in that case the block values are:
		1) self pointA
		2) 0.0
		3) 0.0
	"
	| temp |
	lineA := firstLine.
	lineB := secondLine.
	
	vecA := lineA direction.
	vecB := lineB direction.
	
	"compute the cross product of the vectors. if it is zero than the two lines are parallel"
	crossAB := vecA crossProduct: vecB.
	
	temp := (lineA pointB - lineB pointB).
	ts := temp crossProduct: vecB.
	tr := temp crossProduct: vecA.
	
	crossAB = 0 ifTrue: [ "the two lines are parallel."
		
		tr = 0 ifTrue: [ "the lines are collinear"
			"note: we simply return zero for the two construction factors, which in general does not construct the point."
			
			(vecA x > vecB y)
				ifTrue: []
				ifFalse: [].
			"aBlock value: pointA value: 0 value: 0."
			^true.
		] ifFalse: [ "parallel, but not colinear"
			^false.
		].
	
	] ifFalse: [ "the two lines are not parallel"
		
		t := 1.0 - (ts / crossAB). "the intersection point is at:  self pointA + (t * self direction)"
		u := 1.0 - (tr / crossAB). "the intersection point is at:  aLine pointA + (u * aLine direction)"
		
		^true.
	].
	




]

{ #category : #accessors }
VMIntersection >> intersectionPoint [
	| point |
	point := lineA pointA + (vecA * t).
	^point asVMPoint type: VMPointTypeIntersection new.
]

{ #category : #testing }
VMIntersection >> intersectsAsVectors [
	^ self strictInsideLineASegment and: [self strictInsideLineBSegment]
]

{ #category : #testing }
VMIntersection >> isCollinear [
	"note: this method does not compensate for inaccuracies that may stem from numerical errors"
	^(crossAB = 0)  and:  [ tr = 0 ].
]

{ #category : #testing }
VMIntersection >> isParallel [
	^crossAB = 0.
]

{ #category : #accessors }
VMIntersection >> rayFactors [
	"computes the factors to construct lineB pointA and lineB pointB from the collinear
	lineA, such that lineA pointA + (factor first * vecA) = lineB pointA, and
	lineA + (factor second * vecA) = lineB pointB.
	
	if the two lines are not collinear this function serves no purpose."
	
	| deltaAA deltaAB firstFactor secondFactor |
	
	deltaAA := lineB pointA - lineA pointA.
	deltaAB := lineB pointB - lineA pointA.
	
	(vecA x abs > vecB y abs) "this ensures that the component that we are using is not zero"
		ifTrue: [
			firstFactor := deltaAA x / vecA x.
			secondFactor := deltaAB x / vecA x.
		] ifFalse: [
			firstFactor := deltaAA y / vecA y.
			secondFactor := deltaAB y / vecA y.
		].
	
	^{ firstFactor. secondFactor }.

]

{ #category : #testing }
VMIntersection >> strictInsideLineASegment [
	"returns true if the intersection point is inside the line segment defined by
	lineA pointA and lineA pointB. this 'strict' version does not allow the
	intersection point to lie on a start/end point"
	^(t > 0) and: [t < 1.0].

]

{ #category : #testing }
VMIntersection >> strictInsideLineBSegment [
	^(u > 0.0) and: [u < 1.0].
]
