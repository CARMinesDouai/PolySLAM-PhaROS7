Class {
	#name : #DoublyConnectedEdgeList,
	#superclass : #DoubleLinkedList,
	#instVars : [
		'bounds',
		'peak',
		'type'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #adding }
DoublyConnectedEdgeList >> add: anEdge [
	bounds := bounds encompass: anEdge value pointA.
	bounds := bounds encompass: anEdge value pointB.
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
	^super add: anEdge
]

{ #category : #intersection }
DoublyConnectedEdgeList >> addLine: l to: L ifIntersectWith: line [
|intersection p v key|
intersection := VMIntersection intersectLine: line withLine: l value.
			intersection insideLineBSegment ifTrue:[
				v := PSVertex new.
				p := intersection intersectionPoint.
				v setX: p x setY: p y.
				v vertexType: -1.
				v segments add: l.
				key := PSVertexKeyX from:v.
				L at:key put: l. 	
		] 
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
	^ self asVMPolygon asRenderableElement 
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

{ #category : #intersection }
DoublyConnectedEdgeList >> calculateIntersectionOn: L 	except: blackList do: aBlock [
	|lastline vertex|
	L isEmpty ifTrue: [ ^self ].
	lastline := nil.
	L do: [ :e|
		lastline
			ifNotNil: [
				lastline chain = e chain ifFalse:[
				(blackList includes:{lastline. e}) ifFalse:[
					"Transcript show: 'Intersection of ', lastline value asString, ' and ', e value asString; cr."
					vertex := PSVertex intersectionOf: lastline  and: e.
					blackList add: {lastline.e}.
					blackList add: {e. lastline}.
					vertex ifNotNil: [
						lastline addIntersectionPoint: vertex.
						e addIntersectionPoint: vertex.
						aBlock value: vertex].
				]
			]].
		lastline := e
	]
	
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

{ #category : #initialization }
DoublyConnectedEdgeList >> initialize [
	super initialize.
	bounds := VMRectangle point: 0@0 point: 0@0.
]

{ #category : #intersection }
DoublyConnectedEdgeList >> intersectWith: anotherPolygon [
	^ self intersectWith: anotherPolygon thenDo: nil
]

{ #category : #intersection }
DoublyConnectedEdgeList >> intersectWith: anotherPolygon thenDo: aBlock [
|C Q L intersections vertex lut blackList  key D1 D2|
Q := BTree order: 4.
C := OrderedCollection new.
lut := Dictionary new.
intersections := OrderedCollection new.
blackList := Set new.
"push all events to Q, a B-Tree, each event coresponding to a vertex of the two polygon"
D1 := self asDoublyConnectedEdgeListDo:[:line| line asPSVertices do:[:v| Q at: (PSVertexKeyY from:v) put: v ]].
D2 := anotherPolygon asDoublyConnectedEdgeListDo:[:line| line asPSVertices do:[:v| Q at: (PSVertexKeyY from:v) put: v ]].
D2 close.
D1 close.
"D1 firstLink previousLink asPSVertices do:[:v|Q at: (PSVertexKeyY from:v) put: v ].
D2 firstLink previousLink asPSVertices do:[:v|Q at: (PSVertexKeyY from:v) put: v ]."
"Q inspect.
self halt."
"get first, calculate intersection"
[ Q isEmpty ] whileFalse: [ 
	vertex := Q root first.
	key := Q root firstKey.
	Q removeKey: key.
	"sweep line event at vertex"
	L := self sweepEventAt: vertex on:C lut: lut.
	"find intersection points"
	self calculateIntersectionOn: L except: blackList do: [:e|
				Q at:(PSVertexKeyY from:e) put: e.
				intersections add:e	
	]
].
aBlock ifNotNil: [ ^ aBlock value: intersections value: D1 value: D2 ].
^intersections
]

{ #category : #testing }
DoublyConnectedEdgeList >> isCCW [
	|prv area|
	prv := self peak segments first previousLink value.
	area := self peak segments first areaWith: prv pointA.
	
	^area > 0
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

{ #category : #private }
DoublyConnectedEdgeList >> mergeWith: anotherPolygon [
	|   D p l|
	D := OrderedCollection new.
	self intersectWith: anotherPolygon thenDo:[:intersections :D1 :D2|
		p := PSVertex startOf: D1 lastLink.
		"
		D add: (self polygonalChainAt: p atIntersectionPointDo: [:e| (intersections includes:e) ifTrue:[ intersections remove:e]])."
		"{D. intersections} asRenderableElement inspect."
		[intersections size >= 2 ] whileTrue: [
			p := intersections first.
			D add: (self polygonalChainAt: p atIntersectionPointDo:[:e|
					l := intersections select:[:i| i inrangeOf: e ].		
					l do:[:i| intersections remove:i ].
				]).
		"intersections inspect.
		D inspect.
		self halt."
		].
	].
	^ D
]

{ #category : #enumerating }
DoublyConnectedEdgeList >> nextPointAndLinkOf: pointA and: aLink do: aBlock [
	|    pointB  link intersection|
		link := aLink.
		pointB := link nextIntersectionOf: pointA.
		intersection  := nil.
		((pointB isEndPoint) & (pointB vertexType >= 0))
			"pointB is an endpoint"
			ifTrue:[
				link := link nextLink]
			"pointB is an intersection"
			ifFalse:[
				"event at intersection point here"
				intersection := pointB.
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

{ #category : #accessing }
DoublyConnectedEdgeList >> polygonalChainAt: point atIntersectionPointDo: aBlock [
	| link  D pointA pointB type|
	D := DoublyConnectedEdgeList new.
	"D asRenderableElement inspect."
	pointA := point.
	link := pointA getPivotLine.
	point isEndPoint ifTrue:[
		self nextPointAndLinkOf: point and: link  do: [ :p :intersection :l|
			pointA := p.
			link := l.
		] 
	].
	aBlock value: pointA.
	[
		type := link value type.
		self nextPointAndLinkOf: pointA and: link  do:[:p :intersection :l|
			pointB := p.
			link := l.
			intersection ifNotNil: [ aBlock value: intersection ].
		].
		D add: ((VMLineSegment from: pointA asPoint to: pointB asPoint type: type) asPSLinkedEdge chain:D; yourself).
		"self halt."
		pointA := pointB.
		pointA inrangeOf: point
		"(pointA asPoint) = (point asPoint )"
	] whileFalse: [  ].
	D close.
	^D
]

{ #category : #intersection }
DoublyConnectedEdgeList >> sweepEventAt: vertex on:C lut: lut [
	|line L|
	line := vertex segments first.
	"tmpline := VMLineSegment from: 2.0@6.0 to:1.0@5.0." 
	L := BTree order: 4.
	vertex vertexType >= 0 
		ifTrue:[
			(C includes: line)
				ifFalse:[ 
					C add: line.
					L at: (PSVertexKeyX from:vertex) put: line] 
				ifTrue: [ C remove: line]]
		ifFalse:[
			vertex isEndPoint
				ifTrue: [
					vertex segments do: [ :l|
					L at: (PSVertexKeyX from:( l asPSLinkedEdge lowerVertex )) put:l ]]
				ifFalse:[
					self switchLinesAndAddTo:L at: vertex]
			].
	line := VMLine pointA: 0@(vertex  y) pointB: vertex. 
	C do:[:l|
				(vertex segments includes: l)
					ifFalse: [ 
						self addLine: l to: L ifIntersectWith: line]].
	"((vertex asPoint)  = (10@5)) ifTrue:[
		{ C. L } inspect.
		self halt.
	]."
	^L 
]

{ #category : #intersection }
DoublyConnectedEdgeList >> switchLinesAndAddTo:L at: vertex [
|segA segB lwxA lwxB|
segA := vertex segments first.
segB := vertex segments second.

"(vertex asPoint) = (10@5) ifTrue: [ self error:'fuuuuuk' ]."

lwxA := segA value pointA y < segA value pointB y ifTrue: [ segA value pointA x ] ifFalse: [ segA value pointB x ]. 
lwxB := segB value pointA y < segB value pointB y ifTrue: [ segB value pointA x ] ifFalse: [ segB value pointB x ]. 
lwxA  < lwxB
	ifTrue:[
		L at:(PSVertexKeyX from: (PSVertex new setX: vertex  x setY: 1; vertexType: vertex vertexType; yourself )) put: segA.
		L at:(PSVertexKeyX from: (PSVertex new setX: vertex  x setY: 0; vertexType: vertex vertexType; yourself )) put: segB.
	]
	ifFalse:[
		L at:(PSVertexKeyX from: (PSVertex new setX: vertex  x setY: 0; vertexType: vertex vertexType; yourself )) put: segA.
		L at:(PSVertexKeyX from: (PSVertex new setX: vertex  x setY: 1; vertexType: vertex vertexType; yourself )) put: segB.	
	].

"(vertex asPoint) = (10@5) ifTrue: [L inspect. self error:'fuuuuuk' ]."
]

{ #category : #accessing }
DoublyConnectedEdgeList >> type [
	^ type
]
