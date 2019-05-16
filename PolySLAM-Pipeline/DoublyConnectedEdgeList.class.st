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

{ #category : #intersection }
DoublyConnectedEdgeList >> calculateIntersectionOn: L 	except: blackList do: aBlock [
	|lastline vertex|
	L isEmpty ifTrue: [ ^self ].
	lastline := nil.
	L do: [:e|
		lastline
			ifNotNil: [
				lastline chain = e chain ifFalse:[
				(blackList includes:{lastline. e}) ifFalse:[
					"Transcript show: 'Intersection of ', lastline value asString, ' and ', e value asString; cr."
					vertex := PSVertex intersectionOf: lastline  and: e.
					blackList add: {lastline.e};add: {e. lastline}.
					vertex ifNotNil: [
						lastline addIntersectionPoint: vertex.
						e addIntersectionPoint: vertex.
						aBlock value: vertex ].
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

{ #category : #decomposing }
DoublyConnectedEdgeList >> decomposeAfterIntersectWith: anotherPolygon [
	| list vertices  vs|
	vertices := Dictionary new.
	self intersectWith: anotherPolygon thenDo:[:intersections :D1 :D2|
		list := Set new.
		intersections do:[:vx|
			(vx segments first isCollinearWith: vx segments last) ifTrue: [
				self halt	
			].
			vertices at: vx asPoint put: Set new.
			vx segments do:[:l | list add: l] ].
		list do:[:line| (self surgeryLine: line) do:[:vx|
			(vertices at: vx key) add: vx value]].
	
		vs := OrderedCollection new.
		vertices keysAndValuesDo: [ :k :v|
			self relinkEdges: v asOrderedCollection.
			v do:[:e| vs add: e]].
		
		^ self decomposedPolygonsFrom:  vs.
	].
]

{ #category : #decomposing }
DoublyConnectedEdgeList >> decomposedPolygonsFrom: vertices [
|D edge startEdge chains|
chains := OrderedCollection new.
"chains asRenderableElement inspect."
[ vertices isEmpty ] whileFalse:[
	startEdge := vertices first segments first.
	D := DoublyConnectedEdgeList new.
	chains add:D.
	"D asRenderableElement inspect."
	edge := startEdge.
	[
		D add: ((PSLinkedEdge from: edge value pointA asPoint to: edge value pointB asPoint  type: edge value type ) chain:D; yourself).
		(vertices includes: edge value pointA) ifTrue:[ vertices remove: edge value pointA ].
		(vertices includes: edge value pointB) ifTrue:[ vertices remove: edge value pointB ].
		edge  := edge nextLink.
		"self halt."
		edge = startEdge.
	] whileFalse:[].
	D close.
].
^ chains
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

{ #category : #'as yet unclassified' }
DoublyConnectedEdgeList >> relinkAll [
	^ self relinkAllFrom: nil
]

{ #category : #'as yet unclassified' }
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

{ #category : #decomposing }
DoublyConnectedEdgeList >> relinkEdges: aList [
	|e1 e2 e3 e4|
	e1 := (aList  first) segments first.
	e3 := (aList  second) segments first.
	e2 := e1 nextLink.
	e4 := e3 nextLink.
	
	e1 nextLink: e4.
	e4 previousLink: e1.
	
	e3 nextLink: e2.
	e2 previousLink: e3.
	
	"aList add: e2 value pointA.
	aList add: e4 value pointA."
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

{ #category : #decomposing }
DoublyConnectedEdgeList >> surgeryAtIntersectionWith: anotherPolygon [
	| list|
	self intersectWith: anotherPolygon thenDo:[:intersections :D1 :D2|
		list := Set new.
		intersections do:[:vx|
			vx segments do:[:l | list add: l] ].
		list do:[:line| (self surgeryLine: line)].
		self relinkAll.
		D2 relinkAll.
		^ D2
	].
]

{ #category : #decomposing }
DoublyConnectedEdgeList >> surgeryLine: l [
	|vertex collection firstHalfLine secondHalfLine last2ndHalfLine v1 v2 l1 l2|
	collection := OrderedCollection new.
	last2ndHalfLine := l.
	[ l intersectionPoints isEmpty ] whileFalse: [ 
		vertex := l intersectionPoints root first.
		l intersectionPoints removeKey: (l intersectionPoints root firstKey).
		"surgery at vertex"
		v1 := vertex asPoint asPSVertex.
		v2 := vertex asPoint asPSVertex.
		firstHalfLine  := (PSLinkedEdge from: last2ndHalfLine value pointA to: v1  type: last2ndHalfLine value type  chain: last2ndHalfLine chain).
		secondHalfLine := (PSLinkedEdge from: v2 to: last2ndHalfLine value pointB  type: last2ndHalfLine value type  chain: last2ndHalfLine chain).
		"special cases"
		"(secondHalfLine value pointB inrangeOf: vertex ) ifTrue"
		l1 := l2 := last2ndHalfLine.
		firstHalfLine
			ifNil: [firstHalfLine  := last2ndHalfLine previousLink.
					l1 := firstHalfLine].
		secondHalfLine
			ifNil:[secondHalfLine := last2ndHalfLine nextLink.
				l2 := secondHalfLine ].
		"(firstHalfLine  value pointA inrangeOf: vertex) ifTrue:"
		"linking them"
		firstHalfLine nextLink: secondHalfLine.
		firstHalfLine previousLink: l1 previousLink.
		l1 previousLink nextLink: firstHalfLine.
		secondHalfLine previousLink: firstHalfLine.
		secondHalfLine nextLink: l2 nextLink.
		l2 nextLink previousLink: secondHalfLine.
		collection add: (vertex asPoint -> firstHalfLine value pointB).
		last2ndHalfLine := secondHalfLine.
	].

	^ collection
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
					"C add: l."
					L at: (PSVertexKeyX from:(l asPSLinkedEdge lowerVertex)) put:l ]]
				ifFalse:[
					self switchLinesAndAddTo:L at: vertex]].
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
DoublyConnectedEdgeList >> switchLinesAndAddTo1:L at: vertex [
|segA segB  vA vB|
segA := vertex segments first.
segB := vertex segments second.
vA := vertex asPoint asPSVertex.
vA segments add: segA.

vB := vertex asPoint asPSVertex.
vB segments add: segB.

L at: (PSVertexKeyX from: vA) put: segA.
L at: (PSVertexKeyX  from: vB) put: segB.
]

{ #category : #intersection }
DoublyConnectedEdgeList >> switchLinesAndAddTo:L at: vertex [
|segA segB  vA vB|
segA := vertex segments first.
segB := vertex segments second.
vA := vertex asPoint asPSVertex.
vA segments add: segA.

vB := vertex asPoint asPSVertex.
vB segments add: segB.

L at: (PSVertexKeyX from: vA) put: segA.
L at: (PSVertexKeyX  from: vB) put: segB.
]

{ #category : #accessing }
DoublyConnectedEdgeList >> type [
	^ type
]
