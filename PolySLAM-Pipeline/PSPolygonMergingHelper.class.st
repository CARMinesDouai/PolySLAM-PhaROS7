Class {
	#name : #PSPolygonMergingHelper,
	#superclass : #PSPolygonOperationHelper,
	#instVars : [
		'isReversal',
		'helper',
		'chains'

	],
	#category : #'PolySLAM-Pipeline-Algo'
}


{ #category : #'instance creation' }
PSPolygonMergingHelper class >> from: a and:b helperClass: aClass [
	|o|
	o := self from: a and: b.
	o helper: aClass new.
	^ o
]


{ #category : #'as yet unclassified' }
PSPolygonMergingHelper class >> merge: pA with:pB [
	^ self new polygonA: pA; polygonB: pB; yourself.
]

{ #category : #actions }
PSPolygonMergingHelper >> adjacentVectorFrom: matrix and: collection [
	|adjacentVector collinearIds mutualExclusiveIds i unvisitedIds edge edges connectedIds|
	i := 1.
	connectedIds := Set new.
	adjacentVector := PMVector zeros: collection size.
	unvisitedIds := (1 to: collection size) asOrderedCollection.
	[unvisitedIds isEmpty] whileFalse: [
		collinearIds := Set new.
		mutualExclusiveIds := Set new.
		i := unvisitedIds removeFirst.
		self select: collinearIds and: mutualExclusiveIds of: i from: matrix.
		edges := (collinearIds collect: [:e| collection at: e  ]) asOrderedCollection.
		"edge := self approximateEdgeFrom: edges removeFirst to: edges."
		"edges  do: [ :e| |ml|
			ml := Set new.
			self select: Set new and: ml  of: e id  from: matrix.
			ml do:[:eid| mutualExclusiveIds add: eid].
		]."
		"avoid looping between the two lists"
		mutualExclusiveIds := mutualExclusiveIds select:[:e| |v|
			v := true.
			collinearIds do:[:c| (matrix at:e at:c) ~= 0 ifTrue:[ v:= false] ].
			v 
		].
		edges := mutualExclusiveIds collect:[:e| collection at:e].
		"i = 81 ifTrue:[self halt]."
		"self halt."
		edge := nil.
		edge ifNil: [ 
			"mutualExclusiveIds add: edge"
			edge := self voteForNextEdge: edges asOrderedCollection.
			"unvisitedIds remove: edge id ifAbsent:[]."
			edges do:[:e|
				"unvisitedIds remove: e id ifAbsent:[]"
				e id ~= edge id 
					ifTrue:[
					unvisitedIds remove: e id ifAbsent:[]]
			] 
		].
		"another stuff here"
		edge
			ifNil: ["adjacentVector at:i put: 0"]
			ifNotNil: [
				(collinearIds collect:[:idx| collection at: idx]) do:[:e|
					e value pointB: edge value pointA.
					e nextLink: edge.
					unvisitedIds remove: e id ifAbsent:[].
					matrix at: e id at: edge id put: 1.
				].
				adjacentVector at: i put: edge id.
				connectedIds add:i.
			].
	].
	"adjacentVector inspect."
	"adjacentVector withIndexDo:[:j :k| j = 0 ifFalse:[ {collection at:k. collection at:j} asRenderableElement inspect. self halt. ] ]."
	(connectedIds collect:[:e| collection at: e ]) asOrderedCollection asRenderableElement inspect.
	"self halt."
	"(collection select:[:e| (adjacentVector at: e id) ~= 0 ]) 	asRenderableElement inspect.
		self halt."
	^ adjacentVector

]

{ #category : #actions }
PSPolygonMergingHelper >> approximateEdgeFrom: pivot to: colinearEdges [
	|list  pointB dvector vector  nextLink|
	list := colinearEdges select:[:e| e value isObstacle ].
	list isEmpty ifTrue:[ list := colinearEdges ].
	dvector := pivot directionVector.
	pointB := pivot value pointB.
	nextLink := pivot nextLink.
	list do:[:l|
		"vector := l value pointA - pointA.
		(dvector dotProduct: vector) < 0 ifTrue:[
			pointA := l value pointA]."
		vector := l value pointB - pointB.
		(dvector dotProduct: vector) > 0 ifTrue:[
			pointB := l value pointB.
			nextLink  := l nextLink ].
	].
	"if the resulting line is actually the current line
	return nothing"
	nextLink = pivot nextLink ifTrue:[^ nil].
	"modify the line"
	"represent all collinear edge by this edge"
	"pivot value pointB: pointB.
	pivot nextLink: nextLink.
	list do:[:l| 
		l value pointB:pointB.
		l nextLink: nextLink
	]."
	^ nextLink 
	
]


{ #category : #accessing }
PSPolygonMergingHelper >> chains [
	^ chains
]

{ #category : #actions }
PSPolygonMergingHelper >> findNextEdgeOn: row in: aCollection from: pivot [
	|list colinearEdges mutualExclusiveEdges edge|
	list := OrderedCollection new.
	"select all linked edge"
	1 to: row size do:[ :i| |e| e := row at:i. e ~= 0 ifTrue:[ list add: e ->(aCollection at:i). "row at:i put: 0" ] ].
	list size = 0 ifTrue:[^ 0].
	list size = 1 ifTrue:[ "row at: (list first value id) put: 1. ^ self" ^ list first value id ].
	colinearEdges := list select:[:e| e key = -1] thenCollect:[:e| e value].
	mutualExclusiveEdges := list select:[:e| e key = 1] thenCollect:[:e| e value].
	"edge := self approximateEdgeFrom: pivot to: colinearEdges."
	"colinearEdges := colinearEdges select:[:e| (e directionVector dotProduct: pivot directionVector) > 0 ]."
	mutualExclusiveEdges add: pivot nextLink.
	colinearEdges do: [: l|
		mutualExclusiveEdges add: l nextLink
	].
	edge := self voteForNextEdge: mutualExclusiveEdges asOrderedCollection.
	"colinearEdges size > 0 ifTrue:[
		{ pivot. colinearEdges  } asRenderableElement inspect.	
	]."
	edge ifNil: [ ^ 0 ].
	"colinearEdges size > 0 ifTrue:[
	{ pivot. edge } asRenderableElement inspect.
	{ mutualExclusiveEdges asRenderableElement inspect }.
	self halt
	]."
	pivot value pointB: edge value pointA.
	"pivot nextLink: edge.
	colinearEdges do: [: l|
		l value pointB: edge value pointA.
		l nextLink: edge
	]."

	^ edge id "row at: edge id put: 1".
	
]

{ #category : #actions }
PSPolygonMergingHelper >> getInnerMostOf: list [
		|baseline point|
	baseline := list first.
	list do:[:line|
		point := line centerPoint .
		"(line value pointA inrangeOf: baseline value pointA) ifTrue:[ point := line value pointB ]. "

		
		(baseline value isPointOnLeftSide: point)
					ifTrue:[ baseline := line ]
	].
	^ baseline
]

{ #category : #actions }
PSPolygonMergingHelper >> getOuterMostOf: list [
	|baseline point|
	baseline := list first.
	list do:[:line|
		point := line centerPoint.
		"(line value pointA inrangeOf: baseline value pointA) ifTrue:[ point := line value pointB ]. "
		(baseline value isPointOnRightSide: point)
					ifTrue:[ baseline := line ]
	].
	^ baseline
]

{ #category : #accessing }
PSPolygonMergingHelper >> helper [
	^ helper
]

{ #category : #accessing }
PSPolygonMergingHelper >> helper: anObject [
	helper := anObject
]


{ #category : #initialization }
PSPolygonMergingHelper >> initialize [
	super initialize.
	isReversal := false.
	helper := PSPolygonDecompositionHelper new.
]

{ #category : #actions }
PSPolygonMergingHelper >> partition: collection basedOn: adjacentVector [ 
	|unvisitedNodes  D line visistedNodes|
	unvisitedNodes := (1 to: collection size) asOrderedCollection.
	chains := OrderedCollection new.
	[ unvisitedNodes isEmpty ] whileFalse: [ 
		D := DoublyConnectedEdgeList new.
		visistedNodes := OrderedCollection new.
		line := collection at: unvisitedNodes removeFirst.
		[ ((visistedNodes includes: line id) not) & (line visited not) ] whileTrue: [ 
			visistedNodes add: line id.
			unvisitedNodes remove: line id ifAbsent:[].
			D add: (PSLinkedEdge from: line value pointA asPoint to: line value pointB asPoint  type: line value type  chain: D  ).
			line visited: true.
			line := line nextLink.
		].
		(visistedNodes includes: line id) ifTrue:[ 
			D relinkAllFrom: line.
			chains add: D.
		]
	].
]

{ #category : #actions }
PSPolygonMergingHelper >> partition: collection startAt: peak [
	|unvisitedNodes D line visistedNodes|
	unvisitedNodes := (1 to: collection size) asOrderedCollection.
	chains := OrderedCollection new.
	line := nil.
	[ unvisitedNodes isEmpty ] whileFalse: [ 
		D := DoublyConnectedEdgeList new.
		visistedNodes := OrderedCollection new.
		line ifNil: [ line := peak ]
			ifNotNil: [ line := collection at: unvisitedNodes removeFirst ].
		[ ((visistedNodes includes: line id) not) & (line visited not) ] whileTrue: [ 
			visistedNodes add: line id.
			unvisitedNodes remove: line id ifAbsent:[].
			D add: (PSLinkedEdge from: line value pointA asPoint to: line value pointB asPoint  type: line value type  chain: D  ).
			line visited: true.
			line := line nextLink.
		].
		(visistedNodes includes: line id) ifTrue:[ 
			"line inspect."
			"self halt."
			D relinkAllFrom: line.
			chains add: D.
		] .
	].
	^ chains
]

{ #category : #public }
PSPolygonMergingHelper >> perform [
	|collection matrix idx adjacentVector peak peakf|
	helper polygonA: polygonA.
	helper polygonB: polygonB.
	helper perform.
	((polygonA isNil ) | (polygonB isNil )) ifTrue:[^self error: 'Please set the two input polygons'].
	" first calculate the intersetion point"
	((polygonA isCCW) & (polygonB isCCW ) ) ifTrue:[isReversal := false].
	"now create the adjacent matrix"
	idx := 1.
	collection := OrderedCollection new.
	peak := nil.
	peakf := [:anEdge| 
		peak
			ifNil:[ peak := anEdge ]
			ifNotNil: [
				( (anEdge value pointA y) > (peak value pointA y) ) ifTrue:[
					peak := anEdge]].
	].
	polygonA linksDo:[:e| e id:idx. collection add:e. peakf value:e. idx := idx +1].
	polygonB linksDo:[:e| e id:idx. collection add:e. peakf value:e. idx := idx +1].
	matrix := PSAdjacencyMatrix fromLines: collection probabilityHelper: PSLinkingProbability.
	"automatic thresholding of this matrix"
	matrix inspect.
	matrix := matrix trinaryAdjacencyMatrix makeSymetric.
	"1 to: matrix numberOfRows do:[:j||list|

		list := OrderedCollection new.
		 self select: list and: {  } asOrderedCollection  of:j  from: matrix.
		list size >= 2 ifTrue:[
			(list collect:[:e| collection at:e]) asRenderableElement inspect.
			self halt.
		]
	]."
	
	"since we know that each edge will have exactly one next linking edge
	therefore, we need to find the only edge that is actually linked to that edge"
	"^ self visit: collection baseOn: matrix."
	adjacentVector := self adjacentVectorFrom: matrix and: collection.

	"(adjacentVector withIndexCollect: [ :e :j| { collection at:e. collection at: j } ]) asRenderableElement inspect"	
	"now find all the chain using the adjacentVector"
	"adjacentVector inspect. self halt."
	"adjacentVector withIndexDo: [ :e :i| { collection at:e. collection at:i } asRenderableElement inspect. self halt ]."
	"(collection select:[:e| (adjacentVector at: e id) ~= 0 ]) asRenderableElement inspect."

	self partition: (collection select:[:e| (adjacentVector at: e id) ~= 0 ]) startAt: peak

	
]

{ #category : #actions }
PSPolygonMergingHelper >> select: collinearIds and: mutualExclusiveIds of: rowId from: matrix [
	|row|
	row := matrix rowAt: rowId.
	collinearIds add: rowId.
	row withIndexDo:[:e :i|
		e = 1 ifTrue:[ 
			(((collinearIds includes: i) not) "&( (matrix at: i at: rowId) = 0 )") ifTrue:[
				"avoid looping itself"
				mutualExclusiveIds add: i ]].
		e = -1 ifTrue:[(collinearIds includes: i) ifFalse:[
			"collinearIds add:i."
			self select: collinearIds and: mutualExclusiveIds of: i from: matrix		
		] ]	
	].
]

{ #category : #actions }
PSPolygonMergingHelper >> visit: collection baseOn: matrix [
	|unvisitedNodes chains D line visistedNodes collinearIds mutualExclusiveIds edges edge|

	unvisitedNodes := (1 to: collection size) asOrderedCollection.
	chains := OrderedCollection new.
	[ unvisitedNodes isEmpty ] whileFalse: [ 
		D := DoublyConnectedEdgeList new.
		visistedNodes := OrderedCollection new.
		line := collection at: unvisitedNodes removeFirst.
		[ ((visistedNodes includes: line id) not) & (line visited not) ] whileTrue: [ 
			visistedNodes add: line id.
			unvisitedNodes remove: line id ifAbsent:[].
			collinearIds := Set new.
			mutualExclusiveIds := Set new.
			self select: collinearIds and: mutualExclusiveIds of: line id from: matrix.
			"find it"
			
			edges := (collinearIds collect:[:e| collection at: e]) asOrderedCollection.
			edge := self approximateEdgeFrom: edges removeFirst to: edges. 
			edge ifNil: [ 
				edges := mutualExclusiveIds collect:[:e| collection at:e].
				edge := self voteForNextEdge: edges asOrderedCollection.
			].
			
			(collinearIds collect:[:idx| collection at: idx]) do:[:e|
					e value pointB: edge value pointA.
					e nextLink: edge.
					"unvisitedNodes remove: e id ifAbsent:[].
					visistedNodes add: e id."
				].
			
			
			line value pointB: edge value pointA.
			D add: (PSLinkedEdge from: line value pointA asPoint to: line value pointB asPoint  type: line value type  chain: D  ).
			line visited: true.
			line := edge.

		].
		(visistedNodes includes: line id) ifTrue:[
			D relinkAllFrom: line.
			chains add: D.
		].
	].
	^ chains
]

{ #category : #actions }
PSPolygonMergingHelper >> voteForFrontier: frontierList [
	isReversal
		ifTrue: [
			^self getInnerMostOf: frontierList 
		]
		ifFalse:[
			^ self getOuterMostOf: frontierList 
		].
]

{ #category : #actions }
PSPolygonMergingHelper >> voteForNextEdge: mutualExclusiveEdges [
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
PSPolygonMergingHelper >> voteForObstacle: obstacleList [
	isReversal 
		ifTrue:[
			^ self getOuterMostOf:  obstacleList
		]
		ifFalse:[
			^ self getInnerMostOf:  obstacleList
		]
]
