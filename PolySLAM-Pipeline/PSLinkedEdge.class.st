Class {
	#name : #PSLinkedEdge,
	#superclass : #DoubleLink,
	#instVars : [
		'intersectionPoints',
		'chain'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #adding }
PSLinkedEdge >> addIntersectionPoint: vertex [
	|d|
	d := (self value pointA dist:vertex).
	(self value pointA inrangeOf: vertex) ifTrue:[d := d + 1e-6 ].
	(self value pointB inrangeOf: vertex) ifTrue:[d := d - 1e-6].
	
	intersectionPoints at: d put: vertex.
	
]

{ #category : #accessing }
PSLinkedEdge >> angle [
	|p|
	self value pointA y < self value pointB y
		ifTrue:[ p := (self value pointB) - (self value pointA) ]
		ifFalse:[ p := (self value pointA) - (self value pointB) ].
	^ p angle
]

{ #category : #converting }
PSLinkedEdge >> asPSLinkedEdge [
	^ self
]

{ #category : #converting }
PSLinkedEdge >> asPSVertices [
	^ { PSVertex startOf: self. PSVertex endOf: self }
]

{ #category : #converting }
PSLinkedEdge >> asRenderableElement [
	^ self value asRenderableElement 
]

{ #category : #printing }
PSLinkedEdge >> asString [
	^ self printString
]

{ #category : #accessing }
PSLinkedEdge >> bounds [
	^ self value bounds
]

{ #category : #accessing }
PSLinkedEdge >> chain [
	^ chain
]

{ #category : #accessing }
PSLinkedEdge >> chain: anObject [
	chain := anObject
]

{ #category : #initialization }
PSLinkedEdge >> initialize [
	super initialize.
	intersectionPoints := BTree order: 4.
	
]

{ #category : #testing }
PSLinkedEdge >> isCollinearWith: aLine [
	^ ((self isCollinearWithPoint: aLine value pointA) & (self isCollinearWithPoint: aLine value pointB))
]

{ #category : #testing }
PSLinkedEdge >> isCollinearWithPoint: aPoint [
	|tolerance farea v1 |
	"tolerance to 5mm"
	tolerance := 0.0005.
	farea := [:a :b :c| (((b x) - ( a x )) * ( (c y) - (a y) ) ) - ( ( (c x) - (a x) )* ( ( b y) - (a y) ) )].
	v1 := farea value: self value pointA value: self value pointB value: aPoint.
	^ ((v1 abs) < tolerance) .
]

{ #category : #accessing }
PSLinkedEdge >> lowerVertex [
	value pointA y = value pointB y ifTrue:[
		value pointA x < value pointA
			ifTrue:[ ^ PSVertex startOf: self  ]
			ifFalse:[^ PSVertex endOf: self]	
	].
	value pointA y < value pointB y 
		ifTrue:[ ^ PSVertex startOf: self.]
		ifFalse:[^ PSVertex endOf:self]
]

{ #category : #printing }
PSLinkedEdge >> name [
	^ self asString
]

{ #category : #adding }
PSLinkedEdge >> nearestIntersectionPoint [
	intersectionPoints isEmpty ifTrue: [ ^nil ].
	^intersectionPoints first
]

{ #category : #adding }
PSLinkedEdge >> nextIntersectionOf: vertex [
	"find the next intersection point from a vertex"
	|d|
	d := self value pointA dist: vertex.
	((vertex vertexType = -1)&(vertex isEndPoint) ) ifTrue:[
		(self value pointA inrangeOf: vertex) ifTrue:[d := d + 1e-6 ].
		(self value pointB inrangeOf: vertex) ifTrue:[^ self value pointB].
	].
	intersectionPoints from:d keysAndValuesDo: [ :k :v| k = d ifFalse:[^ v]].
	^ self value pointB 
]

{ #category : #printing }
PSLinkedEdge >> printString [
	^ self value asString
]
