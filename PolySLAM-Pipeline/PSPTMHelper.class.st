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
					segs := Set new.
					self 	collectColinearEdgesAt: idx
							from: collection
							to: segs
							using: matrix
							exclude: visitedSet
							baseline: idx.
					"r withIndexDo: [:v :i| v = 1 ifTrue:[
							(visitedSet includes: i) ifFalse:[ visitedSet add:i. segs add: (collection at:i) ]]].
					segs add:(collection at: idx)."
					segs size > 1 ifTrue:[ self halt].
					colinearEdges add: ( (PSEdgeApproximator from: segs asOrderedCollection) approximate; yourself ).
					colinearEdges size  = 1 ifTrue:[colinearEdges asRenderableElement inspect].
				].
				visitedSet add: idx.
		].
		idx := idx + 1
	].

	^ { colinearEdges. otherEdges  } asOrderedCollection 
]

{ #category : #public }
PSPTMHelper >> collectColinearEdgesAt: idx from: collection to: segs using: matrix exclude: visitedSet baseline: base [
	|row prob|
	(visitedSet includes: idx) ifTrue:[^ self].
	visitedSet add: idx.
	segs add:(collection at:idx).
	row := matrix rowAt: idx.
	1 to: row size do:[:i|
		((row at: i) = 1) 
			ifTrue:[
				prob := PSInflateColinearProbability from: (collection at:base) and:(collection at:i).
				prob probability = 1 ifTrue:[ 
					self collectColinearEdgesAt: i
						from: collection
						to: segs
						using: matrix
						exclude: visitedSet  	
						baseline: base
				]
			]
	]
]

{ #category : #'as yet unclassified' }
PSPTMHelper >> filterPolygon: aPolygon threahold: th [
	
]

{ #category : #actions }
PSPTMHelper >> getInnerMostOf: list [
		|baseline point|
	baseline := list first.
	list do:[:line|
		point := line value pointB .
		"(line value pointA inrangeOf: baseline value pointA) ifTrue:[ point := line value pointB ]. "

		
		(baseline value isPointOnLeftSide: point)
					ifTrue:[ baseline := line ]
	].
	^ baseline
]

{ #category : #actions }
PSPTMHelper >> getOuterMostOf: list [
	|baseline point|
	baseline := list first.
	list do:[:line|
		point := line value pointB.
		"(line value pointA inrangeOf: baseline value pointA) ifTrue:[ point := line value pointB ]. "
		(baseline value isPointOnRightSide: point)
					ifTrue:[ baseline := line ]
	].
	^ baseline
]

{ #category : #public }
PSPTMHelper >> perform [
	| collection matrix idx   Q helper intersections  classifyResult |
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
	matrix := PSAdjacencyMatrix fromLines: collection probabilityHelper: PSInflateOverlapProbability.
	matrix := matrix binaryAdjacencyMatrix makeSymetric.
	classifyResult := self classify: collection using: matrix.
	collection  := OrderedCollection new.
	classifyResult first do:[:e|
		e approxChain linksDo: [:edge|
			"edge chain: polygonA."
			collection add: edge.
			"edge asPSVertices do:[:v| Q at: (PSVertexKeyY from:v) put: v ]"]].
	classifyResult second do:[:line|
		"line chain = polygonB ifTrue:["
				collection add: line.
				line asPSVertices do:[:v| Q at: (PSVertexKeyY from:v) put: v ]
		"]"	
	].
	helper := PSPolygonIntersectionHelper new.
	helper perform: Q.
	intersections := helper intersections. 
	(self surgery: classifyResult second) do:[:e| collection add: e].
	"reindex all lines"
	idx := 1.
	collection  do:[:e| e id: idx. idx := idx+1].
	matrix := PSAdjacencyMatrix fromLines: collection probabilityHelper: PSInflateLinkingProbability.
	collection asRenderableElement inspect.
	collection := self visit: collection using: matrix.
	"collection := collection select: [ :e| (e nextLink isNotNil) & (e previousLink isNotNil ) ]."
	"collection asRenderableElement inspect."
	{collection. intersections } asRenderableElement inspect.
]

{ #category : #public }
PSPTMHelper >> surgery: list [
	| lines|
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
		firstHalfLine length <= 0.05 ifTrue:[firstHalfLine := nil].
		secondHalfLine length <= 0.05 ifTrue: [ secondHalfLine := nil ].
		l1 := l2 := last2ndHalfLine.
		firstHalfLine
			ifNil: [firstHalfLine  := last2ndHalfLine previousLink.
					l1 := firstHalfLine].
		secondHalfLine
			ifNil:[secondHalfLine := last2ndHalfLine nextLink.
				l2 := secondHalfLine ].
			firstHalfLine ifNotNil: [ 
				collection add: firstHalfLine].
		last2ndHalfLine := secondHalfLine.
	].
	secondHalfLine ifNotNil: [  
		collection add: secondHalfLine].
	^ collection
]

{ #category : #public }
PSPTMHelper >> visit: collection using: matrix [
	|adjacents idx edge aNewCollection visited|
	idx := 1.
	visited := Set new.
	aNewCollection := OrderedCollection new.
	
	matrix rowsDo:[:row|
		(visited includes: idx)
			ifFalse:[
				aNewCollection add: (collection at:idx).
				row sum > 0
					ifTrue:[
						"collect all adjacent possible"
						adjacents := (row withIndexCollect:
							[:v :i| v = 1 ifTrue:[collection at:i] ifFalse:[nil]])
								select:[:e| e isNotNil ].
						"adjacents asRenderableElement inspect.
						self halt."
						edge := self voteForNextEdge: adjacents.
						adjacents do:[:e| e id = edge id  ifFalse:[ visited add: e id ]]].
				visited add: idx
			].
		idx  := idx + 1
	].

	^ aNewCollection
]

{ #category : #actions }
PSPTMHelper >> voteForFrontier: frontierList [
	^self getOuterMostOf: frontierList
]

{ #category : #actions }
PSPTMHelper >> voteForNextEdge: mutualExclusiveEdges [
	|l|
	mutualExclusiveEdges size = 0 ifTrue:[^nil].
	mutualExclusiveEdges size = 1 ifTrue:[^ mutualExclusiveEdges first].
"	mutualExclusiveEdges size >= 2 ifTrue:[mutualExclusiveEdges asRenderableElement inspect. self halt.]."
	"more than two, let vote for one"
	l := mutualExclusiveEdges select:[:e| e value isObstacle ].
	l isEmpty ifTrue:[ ^self voteForFrontier: mutualExclusiveEdges ].
	^ self voteForObstacle: l
]

{ #category : #actions }
PSPTMHelper >> voteForObstacle: obstacleList [
	^ self getInnerMostOf:  obstacleList
]
