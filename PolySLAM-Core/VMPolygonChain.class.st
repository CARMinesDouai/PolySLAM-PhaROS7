"
This class is similar to a closed polygon, but the start and end vertices are not connected. As a direct consequence, it has no 'inside/outside', no winding order, and is usually inflated (and therby converted into a closed polygon) when used in the map.
"
Class {
	#name : #VMPolygonChain,
	#superclass : #VMVerticesPolygon,
	#category : #'PolySLAM-Core-kernel'
}

{ #category : #expanding }
VMPolygonChain >> createExpandEndCap: newVertices expand: size [
	| u v w |
	
	u := ((vertices at: (vertices size-1)) point) - (vertices last).
	v := size * u normal.
	w := size negated * (u normalized).
	newVertices add: (VMGraphVertex point: ( vertices last point + w + v )).
	newVertices add: (VMGraphVertex point: ( vertices last point + w - v )).

	

]

{ #category : #expanding }
VMPolygonChain >> createExpandStartCap: newVertices expand: size [
	| u v w |
	
	"set u to be the vector that points from the first vertex to the second vertex"
	u := ((vertices at: 2) point) - (vertices first point).
	v := size * (u normal).
	w := size negated * (u normalized).
	
	newVertices add: (VMGraphVertex point: ( vertices first point + w + v )).
	newVertices add: (VMGraphVertex point: ( vertices first point + w - v )).

]

{ #category : #expanding }
VMPolygonChain >> expand: size [
	| newVertices ret temp |
	
	newVertices := OrderedCollection new.
	temp := OrderedCollection new.
	
	" ----------
	create the expandet vertices for the start vertex
	---------- "
	self createExpandStartCap: newVertices expand: size.
	
	" ----------
	compute the vertices between the start and end vertices
	---------- "
	2 to: (vertices size - 1) do: [ :i |
		|	p				"the current point in the line segment chain that we are processing"
			left right	"th e left and right (prev & next) neighbors of the point"
			expandVectror				"vector in which direction we expand from p, already set to the correct size"
		|
		
		p := vertices at: i.
		left := vertices at: (i-1).
		right := vertices at: (i+1).

		expandVectror := self getExpandVectorPrev: (p point - (left point)) next: (right point - (p point)) expand: size.
		newVertices add: (VMGraphVertex point: (p + expandVectror)).
		temp add: (VMGraphVertex point: (p - expandVectror)).
	].
	
	" ----------
	create the expandet vertices for the end vertex
	----------"
	self createExpandEndCap: newVertices expand: size.
	
	" ----------
	add the remaining (already computed) vertices that lead back from the end vertex to the start vertex
	----------"
	temp reverseDo: [ :q |
		newVertices add: q.
	].
	
	ret := VMClosedPolygon fromOrderedVertices: newVertices.
	^ret.
	





]

{ #category : #constructor }
VMPolygonChain >> fromOrderedPoints: collection [
	"takes an ordered collection of Point objects as parameter and builds the polygon chain from them"
	
	| prevIndex nextIndex vertex |
	
	vertices := OrderedCollection new.
		
	prevIndex := [ :i |
		(i-1) < 1 ifTrue: [
			^collection size.
		] ifFalse: [
			^(i-1).
		].
	].
	
	nextIndex := [ :i |
		(i+1) > (collection size) ifTrue: [
			^1.
		] ifFalse: [
			^(i+1).
		].
	].
	
	"error check: collection must not be empty"
	collection ifEmpty: [
		Transcript show: 'empty collection - cannot create polygon'; cr.
		^self.
	].
	
	minX := collection first x.
	maxX := collection first x.
	minY := collection first y.
	maxY := collection first y.
	
	"error checking: we need at least two points ot create a polygon chain."
	collection size < 2 ifTrue: [
		Transcript show: 'not enough points to create a polygon chain (size=', (collection size)printString, ')'; cr.
		^self.
	].
	
	"update min/max values, create VMGraphVertex objects and add them to the internal collection"
	collection do: [ :p |
		minX > (p x) ifTrue: [ minX := (p x). ].
		maxX < (p x) ifTrue: [ maxX := (p x). ].
		minY > (p y) ifTrue: [ minY := (p y). ].
		maxY < (p y) ifTrue: [ maxY := (p y). ].
		
		vertex := VMGraphVertex point: p.
		
		vertices add: vertex.
	].
	
	"connect vertices, in case that they are used outside of this polygon too."
	1 to: ((vertices size) - 1) do: [ :i |
		(vertices at: i) addNeighbor: (vertices at: (i+1)).
		(vertices at: (i+1)) addNeighbor: (vertices at: i).
	].
	
	self markVertices.
	




]

{ #category : #constructor }
VMPolygonChain >> fromOrderedVertices: collection [
	"takes an ordered collection of VMGraphVertex instances as parameter and builds the polygon chain from them"
	
	| prevIndex nextIndex |
	
	vertices := OrderedCollection new.
		
	prevIndex := [ :i |
		(i-1) < 1 ifTrue: [
			^collection size.
		] ifFalse: [
			^(i-1).
		].
	].
	
	nextIndex := [ :i |
		(i+1) > (collection size) ifTrue: [
			^1.
		] ifFalse: [
			^(i+1).
		].
	].
	
	"error check: collection must not be empty"
	collection ifEmpty: [
		Transcript show: 'empty collection - cannot create polygon'; cr.
		^self.
	].
	
	minX := collection first x.
	maxX := collection first x.
	minY := collection first y.
	maxY := collection first y.
	
	"error checking: we need at least two points ot create a polygon chain."
	collection size < 2 ifTrue: [
		Transcript show: 'not enough points to create a polygon chain (size=', (collection size)printString, ')'; cr.
		^self.
	].
	
	"update min/max values, create VMGraphVertex objects and add them to the internal collection"
	collection do: [ :p |
		minX > (p x) ifTrue: [ minX := (p x). ].
		maxX < (p x) ifTrue: [ maxX := (p x). ].
		minY > (p y) ifTrue: [ minY := (p y). ].
		maxY < (p y) ifTrue: [ maxY := (p y). ].
		
		vertices add: p.
	].
	
	"connect vertices, in case that they are used outside of this polygon too."
	1 to: ((vertices size) - 1) do: [ :i |
		(vertices at: i) addNeighbor: (vertices at: (i+1)).
		(vertices at: (i+1)) addNeighbor: (vertices at: i).
	].
	
	self markVertices.
	




]

{ #category : #testing }
VMPolygonChain >> intersectsWithLine: lineSeg [
	"returns true if the provided line segment intersects with this polygon, and false otherwise."
	
	vertices doWithIndex: [ :v :i |
		| line |
		
		(i < vertices size) ifTrue: [
			line := VMLineSegment from: v to: (vertices at: (i + 1)).
		
			(lineSeg intersectsWith: line) ifTrue: [ ^true. ].
		].
	].
	
	^false.
]
