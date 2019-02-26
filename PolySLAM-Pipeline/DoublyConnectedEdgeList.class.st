Class {
	#name : #DoublyConnectedEdgeList,
	#superclass : #DoubleLinkedList,
	#category : #'PolySLAM-Pipeline-Algo'
}

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
	| rectangle |
	self isEmpty ifTrue: [ ^nil ].
	
	rectangle := VMRectangle point: 0@0 point: 0@0.
	
	self do:[:edge|
		rectangle := rectangle encompass: edge pointA.
		rectangle := rectangle encompass: edge pointB.	
	].
	
	^rectangle

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
		[intersections isEmpty ] whileFalse: [
			p := intersections first.
			D add: (self polygonalChainAt: p atIntersectionPointDo:[:e|
					l := intersections select:[:i| i asPoint = e asPoint].		
					l do:[:i| intersections remove:i ]]).
		].
	].
	^ D
]

{ #category : #merging }
DoublyConnectedEdgeList >> polygonalChainAt: point [ 
	^ self polygonalChainAt: point atIntersectionPointDo: nil
]

{ #category : #accessing }
DoublyConnectedEdgeList >> polygonalChainAt: point atIntersectionPointDo: aBlock [
	| link  D pointA pointB type|
	D := DoublyConnectedEdgeList new.
	"D := OrderedCollection new.
	D asRenderableElement inspect."
	link := point getPivotLine.
	pointA := point.
	[
		pointB := link nextIntersectionOf: pointA.
		type := link value type.
		((pointB isEndPoint) & (pointB vertexType >= 0))
			"pointB is an endpoint"
			ifTrue:[
				link := link nextLink]
			"pointB is an intersection"
			ifFalse:[
				"event at intersection point here"
				aBlock ifNotNil: [ aBlock value: pointB ].
				link := pointB getPivotLine.
				((pointB isEndPoint) & (pointB asPoint = pointA asPoint))
					ifTrue:[
						"a dirty hack"
						pointB := link nextIntersectionOf: pointB + 1e-6.
						"find a new link"
						pointB vertexType >= 0
							ifTrue: [link := link nextLink]
							ifFalse:[link := pointB getPivotLine]
						]
			].
			D add: ((VMLineSegment from: pointA to: pointB type: type) asPSLinkedEdge chain:D; yourself).
			"{pointA. pointB} inspect."
			"self halt."
			pointA := pointB.
		pointA asPoint = point asPoint
	] whileFalse: [  ].
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
