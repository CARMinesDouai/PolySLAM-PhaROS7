"
peak := nil.
	peakf := [:anEdge| 
		peak
			ifNil:[ peak := anEdge ]
			ifNotNil: [
				( (anEdge value pointA y) > (peak value pointA y) ) ifTrue:[peak := anEdge]].
	].
"
Class {
	#name : #PSPTMHelper,
	#superclass : #PSPolygonOperationHelper,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #public }
PSPTMHelper >> classify: collection using: matrix [
	|visitedSet colinearEdges otherEdges idx segs|
	visitedSet := Set new.
	colinearEdges := OrderedCollection new.
	otherEdges := OrderedCollection new.
	idx := 1.
	
	matrix rowsDo:[:r|
		(visitedSet includes: idx) ifFalse:[
			(r sum = 0)
				ifTrue:[
					otherEdges add:(collection at:idx)
				]
				ifFalse:[
					"collect all colinear"
					segs := OrderedCollection new.
					self 	collectColinearEdgesAt: idx
							from: collection
							to: segs
							using: matrix
							exclude: visitedSet.
					colinearEdges add: ( (PSEdgeApproximator from: segs) approximate; yourself ).
				].
				visitedSet add: idx.
		].
		idx := idx + 1
	].

	^ { colinearEdges. otherEdges  } asOrderedCollection 
]

{ #category : #public }
PSPTMHelper >> collectColinearEdgesAt: idx from: collection to: segs using: matrix exclude: visitedSet [
	|row|
	(visitedSet includes: idx) ifTrue:[^ self].
	visitedSet add: idx.
	segs add:(collection at:idx).
	
	row := matrix rowAt: idx.
	1 to: row size do:[:i|
		(row at: i) = 1
			ifTrue:[
				self collectColinearEdgesAt: i
					from: collection
					to: segs
					using: matrix
					exclude: visitedSet  	
			]
	]
]

{ #category : #public }
PSPTMHelper >> perform [
	| collection matrix idx   cocollection Q helper intersections  classifyResult lines|
	((polygonA isNil ) | (polygonB isNil )) ifTrue:[^self error: 'Please set the two input polygons'].
	" first calculate the intersetion point"
	"now create the adjacent matrix"
	Q := BTree order: 4.
	idx := 1.
	collection := OrderedCollection new.
	polygonA linksDo:[:e|
		e id:idx.
		collection add:e.
		idx := idx +1.
		"e asPSVertices do:[:v| Q at: (PSVertexKeyY from:v) put: v ]"].
	polygonB linksDo:[:e| e id:idx. collection add:e. idx := idx +1.].
	matrix := PSAdjacencyMatrix fromLines: collection probabilityHelper: PSInflateColinearProbability.
	matrix := matrix binaryAdjacencyMatrix makeSymetric.
	classifyResult := self classify: collection using: matrix.
	cocollection := classifyResult first.
	classifyResult second do:[:line|
		"line chain = polygonB ifTrue:["
			line asPSVertices do:[:v| Q at: (PSVertexKeyY from:v) put: v ]
		"]"	
	].
	helper := PSPolygonIntersectionHelper new.
	helper perform: Q.
	intersections := helper intersections. 
	lines := self surgery: classifyResult second.
	"reindex all lines"
	
	"collection asRenderableElement inspect."
	{cocollection collect:[:e| e approxChain] . lines. intersections } asRenderableElement inspect.
]

{ #category : #public }
PSPTMHelper >> surgery: list [
	|helper lines|
	helper := PSPolygonDecompositionHelper new.
	lines := OrderedCollection new.
	list do:[: segment|
		(self surgerySegment: segment) do:[:e| lines add: e] 	
	].
	^ lines
]

{ #category : #public }
PSPTMHelper >> surgerySegment: l [
	|vertex collection firstHalfLine secondHalfLine last2ndHalfLine v1 v2 l1 l2|
	collection := OrderedCollection new.
	last2ndHalfLine := l.
	l intersectionPoints ifEmpty: [ collection add: l. ^ collection ].
	
	[ l intersectionPoints isEmpty ] whileFalse: [
		vertex := l intersectionPoints root first.
		l intersectionPoints removeKey: (l intersectionPoints root firstKey).
		"surgery at vertex"
		v1 := vertex asPoint asPSVertex.
		v2 := vertex asPoint asPSVertex.
		firstHalfLine  := (PSLinkedEdge from: last2ndHalfLine value pointA to: v1  type: last2ndHalfLine value type  chain: last2ndHalfLine chain).
		secondHalfLine := (PSLinkedEdge from: v2 to: last2ndHalfLine value pointB  type: last2ndHalfLine value type  chain: last2ndHalfLine chain).
		l1 := l2 := last2ndHalfLine.
		firstHalfLine
			ifNil: [firstHalfLine  := last2ndHalfLine previousLink.
					l1 := firstHalfLine].
		secondHalfLine
			ifNil:[secondHalfLine := last2ndHalfLine nextLink.
				l2 := secondHalfLine ].
		collection add: firstHalfLine.
		last2ndHalfLine := secondHalfLine.
	].
	collection add: secondHalfLine.
	^ collection
]
