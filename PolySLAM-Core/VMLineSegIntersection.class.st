Class {
	#name : #VMLineSegIntersection,
	#superclass : #Object,
	#instVars : [
		't',
		'u',
		'intersectionPoint',
		'intersectionPoint2',
		'crossVW'
	],
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #'as yet unclassified' }
VMLineSegIntersection >> computeIntersection: lineSegA with: lineSegB [
	"computes if this line segement intersects with the provided line segement"
	| vectorV vectorW p ts tr epsilon |
	
	epsilon := 0.0001.
	vectorV := ((lineSegA pointB x) - (lineSegA pointA x)) @ ((lineSegA pointB y) - (lineSegA pointA y)).
	vectorW := ((lineSegB pointB x) - (lineSegB pointA x)) @ ((lineSegB pointB y) - (lineSegB pointA y)).
	
	"compute the cross product of the vectors. if it is zero than the two lines are parallel"
	crossVW := vectorV crossProduct: vectorW.
	p := lineSegA pointA - (lineSegB pointA).
	ts := p crossProduct: vectorW.
	tr := p crossProduct: vectorV.
	
	crossVW = 0
		ifTrue: [
			"the two lines are parallel.
			
			Note: we return False here no matter whether the lines intersect or not, because the edges of the visibility graph should be able to run along the walls"
			
			tr = 0
			ifTrue: [
				"the lines are colinear - we need to check the segments overlap
				 note: in a virtual map this case should never happen, because such lines would be merged."
				^false.
			]
			ifFalse: [
				"the lines are not identical, hence the line segments cannot overlap"
				^false.
			].
		]
		ifFalse: [
			"the two lines are not parallel"
			
			t := -1 *ts / crossVW . "the intersection point is at:  pointA + t*vectorV "
			u := -1 * tr / crossVW . "the intersection point is at:  (line pointA) + u*vectorW "
			
			"now we check for the special case, where both lines share a common start/end point. for numerical reasons, we accept a tolerance of epsilon.
			this check will prevent connected line segments to be considered as interesecting with each other.
			((( t abs ) < epsilon) | ((t-1) abs < epsilon) ) ifTrue: [
				((( u abs ) < epsilon) | ((u-1) abs < epsilon) ) ifTrue: [
					^false.
				].
			].
			"
			intersectionPoint := lineSegA pointA + (t * vectorV).
			intersectionPoint2 := lineSegB pointA + (u * vectorW).
			
			"todo: incoperate epsilon in these conditions"
			((0.0 <= t) & (t <= 1.0)) ifTrue: [
				((0.0 <= u) & (u <= 1.0)) ifTrue: [
					^ true.
				].
			].
			
			^false.
		].
	
	self error: 'undefined behavior'.
	^true.
	




]

{ #category : #accessing }
VMLineSegIntersection >> crossVW [
	^crossVW.
]

{ #category : #accessing }
VMLineSegIntersection >> intersectionPoint [
	^intersectionPoint.
]

{ #category : #accessing }
VMLineSegIntersection >> intersectionPoint2 [
	^intersectionPoint2.
]

{ #category : #accessing }
VMLineSegIntersection >> t [
	^t.
]

{ #category : #accessing }
VMLineSegIntersection >> u [
	^u.
]
