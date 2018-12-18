Class {
	#name : #VMLine,
	#superclass : #Object,
	#instVars : [
		'pointA',
		'pointB',
		'type',
		'angle'
	],
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #'as yet unclassified' }
VMLine class >> pointA: firstPoint pointB: secondPoint [
	^ self new
		pointA: firstPoint;
		pointB: secondPoint;
		type: VMLineType new;
		yourself
]

{ #category : #'as yet unclassified' }
VMLine class >> pointA: firstPoint pointB: secondPoint type: aLineType [
	^ self new
		pointA: firstPoint;
		pointB: secondPoint;
		type: aLineType;
		yourself
]

{ #category : #'as yet unclassified' }
VMLine class >> rendererClass [
	^VMLineRenderer
]

{ #category : #accessing }
VMLine >> angle [
	"angle in radians against 1@0 (x axis)"
	angle ifNil: [
		angle := (pointB - pointA) angle.
		angle < 0.0 ifTrue: [ angle := angle + Float twoPi. ].
	].

	^angle.

]

{ #category : #transforming }
VMLine >> applyTransform: aVMTFMatrix [
	pointA := pointA applyTransform: aVMTFMatrix.
	pointB := pointB applyTransform: aVMTFMatrix.
	angle := nil.
]

{ #category : #'rendering support' }
VMLine >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #converting }
VMLine >> asVMLine [
	^self
]

{ #category : #converting }
VMLine >> asVMLineSegment [
	^VMLineSegment pointA: self pointA pointB: self pointB type: type.
]

{ #category : #converting }
VMLine >> asVMRay [
	^VMRay pointA: self pointA pointB: self pointB.
]

{ #category : #accessing }
VMLine >> bounds [
	"since all boundaries are expected to be finit (withing the vector-map package) we simply
	return the bounds for the respective line segment instead, since that usually is the
	relevant part of the line"
	^VMRectangle point: pointA point: pointB.
]

{ #category : #copying }
VMLine >> copyAsVMLine [
	"creates a copy as a VMLine instance"
	^VMLine pointA: pointA pointB: pointB type: type.
]

{ #category : #accessing }
VMLine >> dX [
	^pointB x - pointA x
]

{ #category : #accessing }
VMLine >> dY [
	^pointB y - pointA y
]

{ #category : #accessing }
VMLine >> deltaAngle: aLine [
	"returns the delta angle between self and aLine. the value is in the range [-pi, pi].
	note: VMLineSegments are treated like lines"
	| angleA angleB angleD |
	
	angleA := self angle.
	angleB := aLine angle.
	angleD := angleB - angleA. "range: [-twoPi, twoPi]"
	
	(angleD > Float pi) ifTrue: [ ^ angleD - Float twoPi ].
	(angleD < Float pi negated) ifTrue: [ ^ angleD + Float twoPi ].
	
	^angleD

]

{ #category : #accessing }
VMLine >> direction [
	^pointB - pointA.

]

{ #category : #testing }
VMLine >> distanceToPoint: aPoint [
	"source: https://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
	(based on javascript code by Joshua)"
	| a b c d dot lengthSquared param xx yy dx dy |
	
	a := aPoint x - pointA x.
	b := aPoint y - pointA y.
	c := pointB x - pointA x.
	d := pointB y - pointA y.
	
	dot := (a * c) + (b * d).
	lengthSquared := (c * c) + (d * d).
	
	(lengthSquared ~= 0) ifTrue: [
		"param is the factor that creates the projection point from aPoint to the line. basically: projectionPoint := aPoint + (direction * param)"
		param := dot / lengthSquared.
	] ifFalse: [
		param := 0. "this means that pointA equals pointB, which doesn't make sense for a line. We treat it like a point here"
	].
	
	xx := pointA x + (param * c).
	yy := pointA y + (param * d).
	
	dx := aPoint x - xx.
	dy := aPoint y - yy.
	
	^(dx * dx + (dy * dy)) sqrt.


]

{ #category : #testing }
VMLine >> fuzzyPoint: aPoint ifOnLeftSideDo: leftBlock [
	^ self fuzzyPoint: aPoint ifOnLeftSideDo: leftBlock ifOnRightSideDo: [] ifOnLineDo: []

]

{ #category : #testing }
VMLine >> fuzzyPoint: aPoint ifOnLeftSideDo: leftBlock ifOnRightSideDo: rightBlock ifOnLineDo: lineBlock [
	"same as the non-fuzzy method, but points that are close to the line are considered to lie on the line.
	this hopefully deals with numeric issue that arise with float point arithmetic."
	| dist |
	
	dist := self asVMLine distanceToPoint: aPoint.
	"(dist < 0.0001) ifTrue: [ lineBlock value. ^self ]."
	(dist < 0.00000001) ifTrue: [ lineBlock value. ^self ].
	
	^self point: aPoint ifOnLeftSideDo: leftBlock ifOnRightSideDo: rightBlock ifOnLineDo: lineBlock
	

]

{ #category : #testing }
VMLine >> fuzzyPoint: aPoint ifOnRightSideDo: rightBlock [
	^ self fuzzyPoint: aPoint ifOnLeftSideDo: [] ifOnRightSideDo: rightBlock ifOnLineDo: []
]

{ #category : #testing }
VMLine >> ifIntersectsWith: aLine do: aBlock [
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
	| vectorV vectorW crossVW p ts tr t u |
	
	vectorV := self direction.
	vectorW := aLine direction.
	
	"compute the cross product of the vectors. if it is zero than the two lines are parallel"
	crossVW := vectorV crossProduct: vectorW.
	
	p := (pointB - aLine pointB).
	ts := p crossProduct: vectorW.
	tr := p crossProduct: vectorV.
	
	crossVW = 0 ifTrue: [ "the two lines are parallel."
		
		tr = 0 ifTrue: [ "the lines are colinear"
			"note: we simply return zero for the two construction factors, which in general does not construct the point."
			
			aBlock cull: pointA cull: 0 cull: 0.
			^true.
		] ifFalse: [ "parallel, but not colinear"
			^false.
		].
	
	] ifFalse: [ "the two lines are not parallel"
		
		t := 1.0 - (ts / crossVW). "the intersection point is at:  self pointA + (t * self direction)"
		u := 1.0 - (tr / crossVW). "the intersection point is at:  aLine pointA + (u * aLine direction)"
		
		aBlock cull: pointA + (t * vectorV) cull: t cull: u.
		
		^true.
	].
	




]

{ #category : #'vector operations' }
VMLine >> inverse [
	"inverts the direction of the line by switching the start and end points"
	| temp |
	temp := pointA.
	pointA := pointB.
	pointB := temp.
	
	angle := nil.
]

{ #category : #testing }
VMLine >> isCollinearWith: aLine [
	| selfLine tolerance |
	selfLine := self asVMLine.
	tolerance := 0.000001.
	
	^ ((selfLine distanceToPoint: aLine pointA) < tolerance) and: [(selfLine distanceToPoint: aLine pointB) < tolerance].
]

{ #category : #testing }
VMLine >> isPointOnLeftSide: aPoint [
	"see: https://math.stackexchange.com/questions/274712/calculate-on-which-side-of-a-straight-line-is-a-given-point-located
	
	note (1): 'left' and 'right' are not to be taking literaly, as sides flip when a directed line is inversed. furthermore, 
	flipping the y-axis also flips the sides (remember, that Athens for example has its y-axis pointed downwards)
	
	note (2): by convention, we consider points that lie exactly on the line as 'right of the line'"
	| vecAP vecAB d |
	
	vecAP := aPoint - pointA.  "vector from pointA to aPoint"
	vecAB := self direction.  "vector from pointA to pointB"
	
	d := vecAP x * vecAB y - ( vecAP y * vecAB x).
	
	^ d < 0
]

{ #category : #testing }
VMLine >> isPointOnRightSide: aPoint [
	"see: https://math.stackexchange.com/questions/274712/calculate-on-which-side-of-a-straight-line-is-a-given-point-located
	
	note (1): 'left' and 'right' are not to be taking literaly, as sides flip when a directed line is inversed. furthermore, 
	flipping the y-axis also flips the sides (remember, that Athens for example has its y-axis pointed downwards)
	
	note (2): by convention, we consider points that lie exactly on the line as 'right of the line'"
	^ (self isPointOnLeftSide: aPoint) not.
]

{ #category : #accessing }
VMLine >> length [
	^Float infinity.
]

{ #category : #transforming }
VMLine >> moveBy: aPoint [
	"answers a copy that has been moved by the amount specified via aPoint"
	^self species
		pointA: pointA + aPoint
		pointB: pointB + aPoint
		type: type
]

{ #category : #accessing }
VMLine >> normal [
	"returns the normal of the line, i.e. a vector that is perpendicular to the line.
	the normal is not normalized, i.e. the length of the vector typically is not 1.0.
	
	note, that the normal is pointing to the left, which by convention is traversable
	space when used as obstacle border/frontier"
	^self direction rightRotated.
]

{ #category : #testing }
VMLine >> point: aPoint ifOnLeftSideDo: leftBlock ifOnRightSideDo: rightBlock ifOnLineDo: lineBlock [
	"see: https://math.stackexchange.com/questions/274712/calculate-on-which-side-of-a-straight-line-is-a-given-point-located
	
	note (1): 'left' and 'right' are not to be taking literaly, as sides flip when a directed line is inversed. furthermore, 
	flipping the y-axis also flips the sides (remember, that Athens for example has its y-axis pointed downwards)
	
	note (2): unlike #isPointOnRightSide: this method considers points that lie on the line to be not on the right side
	
	note (3): the blocks are executed without any parameters"
	| vecAP vecAB d |
	
	vecAP := aPoint - pointA.  "vector from pointA to aPoint"
	vecAB := self direction.  "vector from pointA to pointB"
	
	d := vecAP x * vecAB y - ( vecAP y * vecAB x).
	
	(d < 0) ifTrue: [ leftBlock value. ^self ].
	(d > 0) ifTrue: [ rightBlock value. ^self ].
	
	lineBlock value.
	

]

{ #category : #accessing }
VMLine >> pointA [
	^pointA.
]

{ #category : #accessing }
VMLine >> pointA: point [
	pointA := point.
	angle := nil.
	
	pointB ifNotNil: [
		(self length < 0.000001) ifTrue: [ 1 halt. ].
	].

]

{ #category : #accessing }
VMLine >> pointB [
	^pointB.
]

{ #category : #accessing }
VMLine >> pointB: point [
	pointB := point.
	angle := nil.
	
	pointA ifNotNil: [
		(self length < 0.000001) ifTrue: [
			"Transcript show: 'warning: short line segment: ', self printString; cr."
			"1 halt."
		].
	].

]

{ #category : #printing }
VMLine >> printString [
	^self class name,
		' pointA: ',
		pointA printString,
		' pointB: ',
		pointB printString.
]

{ #category : #testing }
VMLine >> projectionPoint: aPoint [
	"returns the projection point for 'aPoint' and the line itself"
	| intersection newLine |
	newLine := VMLine pointA: aPoint pointB: aPoint + (self direction rightRotated).
	intersection := VMIntersection intersectLine: self withLine: newLine.
	
	^intersection intersectionPoint

]

{ #category : #transforming }
VMLine >> reversed [
	^self species pointA: pointB pointB: pointA type: type
]

{ #category : #testing }
VMLine >> squareDistanceToPoint: aPoint [
	"source: https://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
	(based on javascript code by Joshua)"
	| a b c d dot lengthSquared param xx yy dx dy |
	
	a := aPoint x - pointA x.
	b := aPoint y - pointA y.
	c := pointB x - pointA x.
	d := pointB y - pointA y.
	
	dot := (a * c) + (b * d).
	lengthSquared := (c * c) + (d * d).
	
	(lengthSquared ~= 0) ifTrue: [
		"param is the factor that creates the projection point from aPoint to the line. basically: projectionPoint := aPoint + (direction * param)"
		param := dot / lengthSquared.
	] ifFalse: [
		param := 0. "this means that pointA equals pointB, which doesn't make sense for a line. We treat it like a point here"
	].
	
	xx := pointA x + (param * c).
	yy := pointA y + (param * d).
	
	dx := aPoint x - xx.
	dy := aPoint y - yy.
	
	^dx * dx + (dy * dy).


]

{ #category : #transforming }
VMLine >> transform: aVMTFMatrix [
	"creates a copy of itself with the provided transformation applied to pointA/B"
	| mat |

	mat := aVMTFMatrix asVMTFMatrix.
	
	^self species
		pointA: (mat transformPoint: pointA)
		pointB: (mat transformPoint: pointB)
		type: type.

]

{ #category : #accessing }
VMLine >> type [
	^type.
]

{ #category : #accessing }
VMLine >> type: aNumberOrLineType [
	"current supported types:
		1: obstacle
		2: frontier
		3: sector"
	type := aNumberOrLineType asLineSegmentType.
]
