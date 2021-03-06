Class {
	#name : #DoublyConnectedEdgeList,
	#superclass : #DoubleLinkedList,
	#instVars : [
		'bounds',
		'peak',
		'type',
		'size'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
DoublyConnectedEdgeList class >> fromPoints: pointCollection withTypes: typeCollection [
	^(self new)
		fromPoints: pointCollection withTypes: typeCollection;
		yourself
]

{ #category : #adding }
DoublyConnectedEdgeList >> add: anEdge [
	anEdge ifNil: [ ^self ].
	super add: anEdge 
]

{ #category : #adding }
DoublyConnectedEdgeList >> addFirst: anEdge [
	self preProcess:anEdge.
	super addFirst: anEdge.
	head chain: self
]

{ #category : #adding }
DoublyConnectedEdgeList >> addLast: anEdge [
	self preProcess:anEdge.
	super addLast: anEdge.
	tail chain: self
]


{ #category : #enumerating }
DoublyConnectedEdgeList >> allButFirstDo:aBLock [
	|i|
	i := 0.
	self do:[:e|
		i = 0 
			ifFalse: [
				aBLock value:e
			].
		i := i+1
	].
	^ i
]

{ #category : #accessing }
DoublyConnectedEdgeList >> area [
	"see: https://en.wikipedia.org/wiki/Shoelace_formula"
	| sum |
	
	sum := 0.
	self linksDo:[:edge|
		sum := sum + ((edge value pointA x) * ( (edge value pointB y) - ( edge previousLink value pointA y ) ))	
	].
	
	^0.5 * sum
]

{ #category : #converting }
DoublyConnectedEdgeList >> asDoublyConnectedEdgeList [
	^ self
	
]

{ #category : #converting }
DoublyConnectedEdgeList >> asDoublyConnectedEdgeListDo: ablock [
	ablock ifNotNil: [ 
		self linksDo: [ :l| ablock value:l ]	
	].
	^self
	
]

{ #category : #converting }
DoublyConnectedEdgeList >> asRenderableElement [
	^ VMPolygon rendererClass new model: self
]

{ #category : #converting }
DoublyConnectedEdgeList >> asVMPolygon [
	|p|
	p := VMPolygon new.
	self do:[:edge|
		p add: edge	
	].
	^p
]

{ #category : #accessing }
DoublyConnectedEdgeList >> bounds [
	^bounds

]


{ #category : #merging }
DoublyConnectedEdgeList >> close [
	"|link|"
	head ifNil: [ ^self ].
	head previousLink ifNotNil: [ ^self ].
	tail nextLink ifNotNil: [ ^self ].
	"link := (VMLineSegment from: tail value pointB to: head value pointA  type: (VMLineType fromInteger: 2)) asPSLinkedEdge. 
	link previousLink: tail.
	link nextLink: head."
	head previousLink: tail.
	tail nextLink: head.	

]


{ #category : #'instance creation' }
DoublyConnectedEdgeList >> fromPoints: aCollectionOfPoints withTypes: aCollectionOfTypes [
	self ifEmpty: [self removeAll].
	aCollectionOfPoints doWithIndex: [ :point :index |
		self add: (
			VMLineSegment
				pointA: point
				pointB: (aCollectionOfPoints atWrap: index+1)
				type: (aCollectionOfTypes at: index)
		) asPSLinkedEdge
	].
]

{ #category : #testing }
DoublyConnectedEdgeList >> ifEmpty:aBlock [
	self isEmpty ifTrue:[
		aBlock value	
	]
]

{ #category : #initialization }
DoublyConnectedEdgeList >> initialize [
	super initialize.
	size := 0.
]


{ #category : #testing }
DoublyConnectedEdgeList >> isCCW [
	|prv area|
	prv := self peak segments first previousLink value.
	prv ifNil: [ prv := tail value ].
	area := self peak segments first areaWith: prv pointA.
	
	^area > 0
]

{ #category : #testing }
DoublyConnectedEdgeList >> isCW [
	^ self isCCW not
]

{ #category : #testing }
DoublyConnectedEdgeList >> isFrontier [
	^ self type = 2
]

{ #category : #testing }
DoublyConnectedEdgeList >> isObstacle [
	^ self type = 1
]

{ #category : #testing }
DoublyConnectedEdgeList >> isPolygon [
	head previousLink ifNil:[^false].
	^head nextLink ~= tail
]

{ #category : #testing }
DoublyConnectedEdgeList >> isSelfIntersecting [
	"TODO: assume the polygon is not
	self intersecting, should use sweep line to
	find if there is any intersection in the polygon"
	^ false
]

{ #category : #enumerating }
DoublyConnectedEdgeList >> linksDo: block [
	"Execute block for each of the links that I hold internally."
	
	| current |
	head ifNil: [^ self].
	current := head.
	[ 
		block value: current.
		current := current nextLink.
		current isNil or: current = head 
	] whileFalse: [ ]
]

{ #category : #merging }
DoublyConnectedEdgeList >> mergeWith: anotherPolygon [
	|   D p l link|
	D := OrderedCollection new.
	self intersectWith: anotherPolygon thenDo:[:intersections :D1 :D2|
		link := self firstLink.
		[ p := link nearestIntersectionPoint.
			p ifNil: [ link := link nextLink ].
			(p isNil) & (link ~= D2 firstLink)  ] whileTrue.
		[intersections size >= 2 ] whileTrue: [
			D add: (self polygonalChainAt: p atIntersectionPointDo:[:e|
					l := intersections select:[:i| i inrangeOf: e ].		
					l do:[:i| intersections remove:i ].
				]).
			intersections isEmpty ifFalse:[
			p := intersections first.
			]
		"{D. intersections} asRenderableElement inspect."
		"self halt."
		].
	].
	^ D
]

{ #category : #merging }
DoublyConnectedEdgeList >> nextPointAndLinkOf: pointA and: aLink do: aBlock [
	|    pointB  link intersection|
		link := aLink.
		pointB := link nextIntersectionOf: pointA.
		intersection := pointB.
		((pointB isEndPoint) & (pointB vertexType >= 0))
			"pointB is an endpoint"
			ifTrue:[
				link := link nextLink]
			"pointB is an intersection"
			ifFalse:[
				"event at intersection point here"
				link := pointB getPivotLine.
				((pointB isEndPoint) & (pointB inrangeOf: pointA)) "pointB asPoint = pointA asPoint"
					ifTrue:[
						"a dirty hack"
						pointB := link nextIntersectionOf: pointB.
						"find a new link"
						pointB vertexType >= 0
							ifTrue: [link := link nextLink]
							ifFalse:[link := pointB getPivotLine]
						]
			].
		aBlock value: pointB value: intersection value: link.
]

{ #category : #accessing }
DoublyConnectedEdgeList >> peak [
	^peak
]

{ #category : #merging }
DoublyConnectedEdgeList >> polygonalChainAt: point [ 
	^ self polygonalChainAt: point atIntersectionPointDo: nil
]

{ #category : #merging }
DoublyConnectedEdgeList >> polygonalChainAt: point atIntersectionPointDo: aBlock [
	| link  D pointA pointB ltype visisted|
	D := DoublyConnectedEdgeList new.
	visisted := Set new.
	pointA := point.
	link := pointA getPivotLine.
	aBlock value: pointA.
	point isEndPoint ifTrue:[
		self nextPointAndLinkOf: point and: link  do: [ :p :intersection :l|
			D add: ((VMLineSegment from: pointA asPoint to: p asPoint type: link value type) asPSLinkedEdgeOf:D).
			pointA := p.
			link := l.
		] 
	].
	[
		ltype := link value type.
		self nextPointAndLinkOf: pointA and: link  do:[:p :intersection :l|
			pointB := p.
			link := l.
			intersection isIntersection
				ifTrue: [ aBlock value: intersection]
				"ifFalse:[ visisted add:p ]".
		].
		D add: ((VMLineSegment from: pointA asPoint to: pointB asPoint type: ltype) asPSLinkedEdgeOf:D).
		"D size = 3 ifTrue:[D asRenderableElement inspect]."
		"self halt."
		visisted add: pointA.
		pointA := pointB.
		(pointA inrangeOf: point)" | (visisted includes: pointA)"
		"(pointA asPoint) = (point asPoint )"
	] whileFalse: [  ].
	D close.
	^D
]

{ #category : #private }
DoublyConnectedEdgeList >> postProcess:anEdge [
	size := size - 1.
]

{ #category : #private }
DoublyConnectedEdgeList >> preProcess:anEdge [
	bounds
		ifNil:[
			bounds := VMRectangle point: anEdge value pointA point: anEdge value pointB.
		]
		ifNotNil:[
			bounds := bounds encompass: anEdge value pointA.
			bounds := bounds encompass: anEdge value pointB.
		].
	peak
		ifNil:[ peak := PSVertex startOf: anEdge ]
		ifNotNil: [
			( (anEdge value pointA y) > (peak y) ) ifTrue:[
				peak := PSVertex startOf: anEdge]].
	"type"
	type
		ifNil:[type := anEdge value type asInteger]
		ifNotNil: [ ((type ~= 4) & (type ~= anEdge value type asInteger))
				ifTrue:[type := 4] ].
	size := size + 1.
]


{ #category : #relink }

DoublyConnectedEdgeList >> relinkAll [
	^ self relinkAllFrom: nil
]


{ #category : #relink }

DoublyConnectedEdgeList >> relinkAllFrom: aLink [
	|link|
	link := aLink.
	link ifNil: [link := head nextLink previousLink ].
	link ifNil: [ ^ self ].
	head := link.
	size := 0.
	[
		size := size + 1.
		link := link nextLink.
		link = head
	] whileFalse.
	tail := link previousLink.
]


{ #category : #removing }
DoublyConnectedEdgeList >> removeAll [
	size := 0.
	bounds := nil.
	peak := nil.
	type := nil.
	super removeAll
]

{ #category : #removing }
DoublyConnectedEdgeList >> removeFirst [
	self postProcess: head.
	^super removeFirst
]

{ #category : #removing }
DoublyConnectedEdgeList >> removeLast [
	self postProcess: tail.
	^super removeLast
]

{ #category : #removing }
DoublyConnectedEdgeList >> removeLink:aLink [
	self postProcess: aLink.
	^super removeLink: aLink
]

{ #category : #accessing }
DoublyConnectedEdgeList >> size [
	^ size
]

{ #category : #accessing }
DoublyConnectedEdgeList >> type [
	^ type
]
