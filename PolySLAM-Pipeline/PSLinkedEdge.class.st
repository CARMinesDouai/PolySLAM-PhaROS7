Class {
	#name : #PSLinkedEdge,
	#superclass : #DoubleLink,
	#instVars : [
		'intersectionPoints',
		'chain',
		'visited',
		'id'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
PSLinkedEdge class >> from: pointA to:pointB type: type [
	|line|
	"the line is collapse to a point"
	"(pointA inrangeOf: pointB) ifTrue:[^nil]."
	line := self new.
	line value: (VMLineSegment from: pointA asPSVertex to: pointB asPSVertex type: type).
	(line value pointA vertexType: 0) segments removeAll; add: line.
	(line value pointB vertexType: 1) segments removeAll; add: line.
	^ line
]

{ #category : #'instance creation' }
PSLinkedEdge class >> from: pointA to:pointB type: type chain: c [
	|link|
	link := (self from: pointA to: pointB   type: type  ).
	link ifNil: [ ^ nil ].
	link chain: c.
	^ link
]

{ #category : #comparing }
PSLinkedEdge >> = anotherLink [
	^ self value = anotherLink value
]

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
	"|p|
	self value pointA y < self value pointB y
		ifTrue:[ p := (self value pointB) - (self value pointA) ]
		ifFalse:[ p := (self value pointA) - (self value pointB) ].
	^ p angle".
	^ self value angle
]

{ #category : #computing }
PSLinkedEdge >> angleWith: anotherLine [
	|alpha beta|
	"angle with other line, use this line as baseline, ignore the edge direction"
	alpha := (self upperVertex - self lowerVertex) angle.
	beta := (anotherLine upperVertex - anotherLine lowerVertex) angle.
	^ beta - alpha
]

{ #category : #computing }
PSLinkedEdge >> areaWith: aPoint [
	|farea|
	farea := [:a :b :c| (((b x) - ( a x )) * ( (c y) - (a y) ) ) - ( ( (c x) - (a x) )* ( ( b y) - (a y) ) )].
	^(farea value: self value pointA value: self value pointB value: aPoint) * 0.5.
]

{ #category : #converting }
PSLinkedEdge >> asPSLinkedEdge [
	^ self
]

{ #category : #converting }
PSLinkedEdge >> asPSVertices [
	|list|
	list := { PSVertex startOf: self. PSVertex endOf: self }.
	"self value pointA: list first; pointB: list second."
	^ list
]

{ #category : #converting }
PSLinkedEdge >> asRenderableElement [

	^ PSLinkedEdgeRenderer new model: self
]

{ #category : #printing }
PSLinkedEdge >> asString [
	^ self printString
]

{ #category : #accessing }
PSLinkedEdge >> bounds [
	^ self value bounds
]

{ #category : #computing }
PSLinkedEdge >> centerPoint [
	^(((self value pointA) + (self value pointB)) / 2)
]

{ #category : #accessing }
PSLinkedEdge >> chain [
	^ chain
]

{ #category : #accessing }
PSLinkedEdge >> chain: anObject [
	chain := anObject
]

{ #category : #computing }
PSLinkedEdge >> directionLine [
	^ VMLine pointA: 0@0 pointB: self directionVector 
]

{ #category : #computing }
PSLinkedEdge >> directionVector [
	|delta|
"	(self value pointA asPoint = self value pointB asPoint)
		ifTrue:[^ 0@0]."
	delta := self value pointB - self value pointA.
	"normalize it"
	delta := delta / ( ((delta x squared) + (delta y squared)) sqrt ).
	^ delta
]

{ #category : #computing }
PSLinkedEdge >> exteriorAngleWith: anotherLine [
	self shouldBeImplemented 
]

{ #category : #accessing }
PSLinkedEdge >> firstEdge [
	^ self
]

{ #category : #testing }
PSLinkedEdge >> hasCollinearIn: aCollection [
	aCollection do:[:e|
		(self isCollinearWith: e) ifTrue:[^ true]].
	^ false
]

{ #category : #testing }
PSLinkedEdge >> hasContactWith: anEdge [
	((self isPointInside: anEdge value pointA)  or: (self isPointInside: anEdge value pointB)) ifTrue: [ ^ true ].	
	^ ((anEdge isPointInside: self value pointA)  or: (anEdge  isPointInside: self value pointB)).
]

{ #category : #testing }
PSLinkedEdge >> hasId: anId [
	^ id = anId
]

{ #category : #accessing }
PSLinkedEdge >> id [
	^ id
]

{ #category : #accessing }
PSLinkedEdge >> id: anObject [
	id := anObject
]

{ #category : #initialization }
PSLinkedEdge >> initialize [
	super initialize.
	intersectionPoints := BTree order: 4.
	visited := false.
	"use for fast adjacent matrix accessing"
	id := 0
	
]

{ #category : #computing }
PSLinkedEdge >> interiorAngleWith: anotherLine [
		self shouldBeImplemented 
]

{ #category : #accessing }
PSLinkedEdge >> intersectionPoints [
	^ intersectionPoints
]

{ #category : #testing }
PSLinkedEdge >> isCollinearWith: aLine [
	^ ((self isCollinearWithPoint: aLine value pointA) & (self isCollinearWithPoint: aLine value pointB))
]

{ #category : #testing }
PSLinkedEdge >> isCollinearWithPoint: aPoint [
	|tolerance |
	"tolerance to 5mm"
	" 0.000001."
	tolerance := 0.0005.
	
	^ (self value distanceToPoint: aPoint) < tolerance 
	
	"v1 := self areaWith: aPoint.
	^ ((v1 abs) < tolerance)."
]

{ #category : #testing }
PSLinkedEdge >> isLineOnLeftSide: aLine [
	(self isCollinearWith: aLine ) ifTrue:[^ false].
	"test if a line is on my leftside based on my direction"
	(self isCollinearWithPoint: aLine value pointA) ifFalse:[
		(self value isPointOnRightSide: aLine value pointA) ifTrue:[^ false]].
	
	(self isCollinearWithPoint:  aLine value pointB) ifFalse:[
		(self value isPointOnRightSide: aLine value pointB) ifTrue:[^ false]].
	
	^ true
]

{ #category : #testing }
PSLinkedEdge >> isLineOnRightSide: aLine [
	(self isCollinearWith: aLine ) ifTrue:[^ false].
	"test if a line is on my leftside based on my direction"
	(self isCollinearWithPoint:  aLine value pointA) ifFalse:[
		(self value isPointOnLeftSide: aLine value pointA) ifTrue:[^ false]].
	
	(self isCollinearWithPoint:  aLine value pointB) ifFalse:[
		(self value isPointOnLeftSide: aLine value pointB) ifTrue:[^ false]].
	
	^ true
]

{ #category : #testing }
PSLinkedEdge >> isLineSegmentInside: anEdge [
	^ (self isPointInside: anEdge value pointA) and: (self isPointInside: anEdge value pointB)
]

{ #category : #testing }
PSLinkedEdge >> isPointInside: aPoint [
	(self isCollinearWithPoint: aPoint) ifFalse:[^false].
	^ ((aPoint dist: self value pointA) <= self length) and: ( (aPoint dist: self value pointB) <= self length )
]

{ #category : #accessing }
PSLinkedEdge >> lastEdge [
	^ self
]

{ #category : #accessing }
PSLinkedEdge >> length [
	^ self value length
]

{ #category : #accessing }
PSLinkedEdge >> lowerVertex [
	value pointA y = value pointB y ifTrue:[
		value pointA x < value pointB x
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

{ #category : #accessing }
PSLinkedEdge >> nextEdge [
	^ self nextLink
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

{ #category : #accessing }
PSLinkedEdge >> normal [
	^ self value normal 
]

{ #category : #accessing }
PSLinkedEdge >> previousEdge [
	^ self previousLink 
]

{ #category : #printing }
PSLinkedEdge >> printString [
	^ self value asString
]

{ #category : #accessing }
PSLinkedEdge >> project: anotherEdge [
	|v1 v2|
	v1 := self value projectionPoint: anotherEdge value pointA.
	v2 := self value projectionPoint: anotherEdge value pointB.
	^ PSLinkedEdge from: v1 to: v2 type: 3.
]

{ #category : #converting }
PSLinkedEdge >> reversed [
	^PSLinkedEdge from: self value pointB asPoint to: self value pointA asPoint  type: self value type
]

{ #category : #accessing }
PSLinkedEdge >> segments [
	 ^ { self }
]

{ #category : #accessing }
PSLinkedEdge >> upperVertex [
	value pointA y = value pointB y ifTrue:[
		value pointA x > value pointB x
			ifTrue:[ ^ PSVertex startOf: self  ]
			ifFalse:[^ PSVertex endOf: self]	
	].
	value pointA y > value pointB y 
		ifTrue:[ ^ PSVertex startOf: self.]
		ifFalse:[^ PSVertex endOf:self]
]

{ #category : #utils }
PSLinkedEdge >> vertexFarestOf: aPoint [
	((self value pointA dist: aPoint) > (self value pointB dist: aPoint))
		ifTrue:[^ self value pointA]
		ifFalse:[^ self value pointB]
]

{ #category : #utils }
PSLinkedEdge >> vertexNearestOf: aPoint [
	((self value pointA dist: aPoint) < (self value pointB dist: aPoint))
		ifTrue:[^ self value pointA]
		ifFalse:[^ self value pointB]
]

{ #category : #accessing }
PSLinkedEdge >> visited [
	^ visited
]

{ #category : #accessing }
PSLinkedEdge >> visited: anObject [
	visited := anObject
]
