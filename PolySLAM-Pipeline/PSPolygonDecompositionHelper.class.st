Class {
	#name : #PSPolygonDecompositionHelper,
	#superclass : #PSPolygonOperationHelper,
	#instVars : [
		'helper',
		'vertices'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
PSPolygonDecompositionHelper class >> from: a and:b helperClass: aClass [
	|o|
	o := self from: a and: b.
	o helper: aClass new.
	^ o
]

{ #category : #public }
PSPolygonDecompositionHelper >> components [
	|vs|
	vertices ifNil: [ self perform ].
	vs := OrderedCollection new.
	vertices keysAndValuesDo: [ :k :v|
		self relinkEdges: v asOrderedCollection.
		v do:[:e| vs add: e]].
		
	^ self decomposedPolygonsFrom:  vs.
]

{ #category : #decomposing }
PSPolygonDecompositionHelper >> decomposedPolygonsFrom: vx [
|D edge startEdge chains|
chains := OrderedCollection new.
"chains asRenderableElement inspect."
[ vx isEmpty ] whileFalse:[
	startEdge := vx first segments first.
	D := DoublyConnectedEdgeList new.
	chains add:D.
	"D asRenderableElement inspect."
	edge := startEdge.
	[
		D add: ((PSLinkedEdge from: edge value pointA asPoint to: edge value pointB asPoint  type: edge value type ) chain:D; yourself).
		(vx includes: edge value pointA) ifTrue:[ vx remove: edge value pointA ].
		(vx includes: edge value pointB) ifTrue:[ vx remove: edge value pointB ].
		edge  := edge nextLink.
		"self halt."
		edge = startEdge.
	] whileFalse:[].
	D close.
].
^ chains
]

{ #category : #accessing }
PSPolygonDecompositionHelper >> helper [
	^ helper
]

{ #category : #accessing }
PSPolygonDecompositionHelper >> helper: anObject [
	helper := anObject
]

{ #category : #initialization }
PSPolygonDecompositionHelper >> initialize [
	super initialize.
	helper := PSProbabilistPolygonIntersectionHelper new.
]

{ #category : #public }
PSPolygonDecompositionHelper >> perform [
	| list|
	helper polygonA: self polygonA.
	helper polygonB: self polygonB.
	helper perform.
	list := Set new.
	vertices := Dictionary new.
	helper intersections do:[:vx|
		vertices at: vx asPoint put: Set new.
		vx segments do:[:l | list add: l] ].
	list do:[:line| (self surgeryLine: line) do:[:vx|
		(vertices at: vx key) add: vx value
	]].
	self polygonA relinkAll.
	self polygonB relinkAll.
		
]

{ #category : #decomposing }
PSPolygonDecompositionHelper >> relinkEdges: aList [
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

{ #category : #decomposing }
PSPolygonDecompositionHelper >> surgeryLine: l [
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

{ #category : #accessing }
PSPolygonDecompositionHelper >> vertices [
	^ vertices
]
