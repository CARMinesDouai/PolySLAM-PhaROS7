Class {
	#name : #PSPolygonIntersectionHelper,
	#superclass : #PSPolygonOperationHelper,
	#instVars : [
		'intersections'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #adding }
PSPolygonIntersectionHelper >> addLine: l to: L ifIntersectWith: line [
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

{ #category : #intersection }
PSPolygonIntersectionHelper >> calculateIntersectionOn: L 	except: blackList do: aBlock [
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

{ #category : #initialization }
PSPolygonIntersectionHelper >> initialize [
	super initialize.
	intersections := OrderedCollection new.
]

{ #category : #accessing }
PSPolygonIntersectionHelper >> intersections [
	^ intersections
]

{ #category : #public }
PSPolygonIntersectionHelper >> perform [
|Q|
Q := BTree order: 4.
"push all events to Q, a B-Tree, each event coresponding to a vertex of the two polygon"
self polygonA asDoublyConnectedEdgeListDo:[:line| line asPSVertices do:[:v| Q at: (PSVertexKeyY from:v) put: v ]].
self polygonB asDoublyConnectedEdgeListDo:[:line| line asPSVertices do:[:v| Q at: (PSVertexKeyY from:v) put: v ]].
self polygonA close.
self polygonB close.

self perform: Q
]

{ #category : #public }
PSPolygonIntersectionHelper >> perform: Q [
|C L vertex lut blackList  key|
C := OrderedCollection new.
lut := Dictionary new.
intersections := OrderedCollection new.
blackList := Set new.
"push all events to Q, a B-Tree, each event coresponding to a vertex of the two polygon"
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
	
]

{ #category : #accessing }
PSPolygonIntersectionHelper >> sweepEventAt: vertex on:C lut: lut [
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
PSPolygonIntersectionHelper >> switchLinesAndAddTo1:L at: vertex [
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
PSPolygonIntersectionHelper >> switchLinesAndAddTo:L at: vertex [
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
