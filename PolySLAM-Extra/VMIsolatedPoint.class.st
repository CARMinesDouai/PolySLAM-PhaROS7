"
An isolated point is - as the name implies - a single point with no length or volume. they can be used as a 'waypoint' in the map (e.g. the navigation goal, or the robots current position), or invlated (and thereby converted) into a closed polygon, if it represents an obstacle. isolated points have no winding order, and never intersect with lines by convention.
"
Class {
	#name : #VMIsolatedPoint,
	#superclass : #VMVerticesPolygon,
	#category : #'PolySLAM-Extra-Deprecated'
}

{ #category : #'instance creation' }
VMIsolatedPoint class >> fromPoint: point [ 
	"returns a new VMIsolatedPoint object with the vertex set."
	| vertex |
	vertex := VMGraphVertex point: point.
	^(self new)
		fromVertex: vertex;
		yourself.

]

{ #category : #'instance creation' }
VMIsolatedPoint class >> fromPoint: point id:  newId [
	"returns a new VMIsolatedPoint object with the vertex set."
	| vertex |
	
	vertex := VMGraphVertex point: point.
	vertex id: newId.
	
	^(self new)
		fromVertex: vertex;
		yourself.

]

{ #category : #'instance creation' }
VMIsolatedPoint class >> fromVertex: vertex [ 
	"returns a new VMIsolatedPoint object with the vertex set. vertex must be an VMGraphVertex instance."
	^(self new)
		fromVertex: vertex;
		yourself.

]

{ #category : #expanding }
VMIsolatedPoint >> expand: size [
	| t |
	t := self expand: size segCount: 6.
	^t.

]

{ #category : #expanding }
VMIsolatedPoint >> expand: size segCount: count [
	"creates a new polygons that approximates a circle of radius 'size' with 'count' vertices, and returns the new polygon."
	
	| a x y newVertices newPolygon point |
	
	count < 3 ifTrue: [
		self error: 'segment count must be 3 or greater but is ', count printString.
	].
	
	point := vertices first.
	
	newVertices := OrderedCollection new.
	
	0 to: (count - 1) do: [ :i |
		a := Float twoPi * i / count.
		x := point x + (size * (a sin)).
		y := point y + (size * (a cos)).
		
		newVertices add: ( VMGraphVertex point: (x @ y) ).
	].
	
	newPolygon := VMClosedPolygon fromOrderedVertices: newVertices.
	
	^newPolygon.
]

{ #category : #constructors }
VMIsolatedPoint >> fromOrderedVertices: aCollection [
	"for compatibility with the other polygon classes we store a single point in an OrderedCollection object"
	vertices := OrderedCollection new.
	vertices add: (aCollection first).
]

{ #category : #constructors }
VMIsolatedPoint >> fromPoint: point [
	"for compatibility with the other polygon classes we store a single point in an OrderedCollection object"
	vertices := OrderedCollection new.
	vertices add: point.
]

{ #category : #constructors }
VMIsolatedPoint >> fromVertex: vertex [
	"for compatibility with the other polygon classes we store a single vertex in an OrderedCollection object"
	vertices := OrderedCollection new.
	vertices add: vertex.
]

{ #category : #testing }
VMIsolatedPoint >> intersectsWithLine: lineSeg [
	^false.
]

{ #category : #accessing }
VMIsolatedPoint >> vertex [
	^vertices first.
]

{ #category : #setter }
VMIsolatedPoint >> vertex: v [
	vertices removeAll.
	vertices add: v.
]
