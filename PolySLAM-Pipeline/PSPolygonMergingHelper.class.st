Class {
	#name : #PSPolygonMergingHelper,
	#superclass : #Object,
	#instVars : [
		'polygonA',
		'polygonB',
		'isReversal'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'as yet unclassified' }
PSPolygonMergingHelper class >> merge: pA with:pB [
	^ self new polygonA: pA; polygonB: pB; yourself.
]

{ #category : #actions }
PSPolygonMergingHelper >> adjacentVectorFrom: matrix and: collection [
	|adjacentVector collinearIds mutualExclusiveIds i unvisitedIds edge edges|
	i := 1.
	adjacentVector := PMVector zeros: collection size.
	unvisitedIds := (1 to: collection size) asOrderedCollection. 
	
	[unvisitedIds isEmpty] whileFalse: [ 
		collinearIds := Set new.	
		mutualExclusiveIds := Set new.
		i := unvisitedIds removeFirst.
		self select: collinearIds and: mutualExclusiveIds of: i from: matrix.
		edges := (collinearIds collect: [:e| collection at: e  ]) asOrderedCollection. 
		edge := self approximateEdgeFrom: edges removeFirst to: edges.
		edges := mutualExclusiveIds collect:[:e| collection at:e].
		edge ifNil: [ 
			"mutualExclusiveIds add: edge"
			edge := self voteForNextEdge: edges asOrderedCollection.
			edges do:[:e|
				e id ~= edge id 
					ifTrue:[
					unvisitedIds remove: e id ifAbsent:[]]
			] 
		].
		"another stuff here"
		edge
			ifNil: [adjacentVector at:i put: 0]
			ifNotNil: [
				(collinearIds collect:[:idx| collection at: idx]) do:[:e|
					e value pointB: edge value pointA.
					e nextLink: edge.
					"adjacentVector at: e id put: edge id."
					unvisitedIds remove: e id ifAbsent:[].
				].
				adjacentVector at: i put: edge id.
				
			].
	].
	adjacentVector inspect.
	(collection select:[:e| (adjacentVector at: e id) ~= 0 ]) asRenderableElement inspect.
	self halt.
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
		point := line value pointA.
		(line value pointA inrangeOf: baseline value pointA) ifTrue:[ point := line value pointB ]. 
		
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
		point := line value pointA.
		(line value pointA inrangeOf: baseline value pointA) ifTrue:[ point := line value pointB ]. 
		
		(baseline value isPointOnRightSide: point)
					ifTrue:[ baseline := line ]
	].
	^ baseline
]

{ #category : #initialization }
PSPolygonMergingHelper >> initialize [
	super initialize.
	isReversal := false.
]

{ #category : #actions }
PSPolygonMergingHelper >> merge [
	|D1 D2 collection matrix idx adjacentVector|
	((polygonA isNil ) | (polygonB isNil )) ifTrue:[^self error: 'Please set the two input polygons'].
	" first calculate the intersetion point"
	D1 := polygonA asDoublyConnectedEdgeList.
	D2 := D1 surgeryAtIntersectionWith: polygonB.
	((D1 isCCW) & (D2 isCCW ) ) ifTrue:[isReversal := false].
	"now create the adjacent matrix"
	idx := 1.
	collection := OrderedCollection new.
	D1 linksDo:[:e| e id:idx. collection add:e. idx := idx +1].
	D2 linksDo:[:e| e id:idx. collection add:e. idx := idx +1].
	matrix := PSAdjacencyMatrix fromLines: collection.
	"automatic thresholding of this matrix"
	"matrix th inspect."
	matrix := matrix trinaryAdjacencyMatrix.
	"since we know that each edge will have exactly one next linking edge
	therefore, we need to find the only edge that is actually linked to that edge"
	"(PSLinkingProbability from: (collection at: 26) and: (collection at: 57)) probability inspect. 
	{ collection at: 26. collection at:27. collection at:28. collection at: 57 } asRenderableElement inspect. self halt."
	adjacentVector := self adjacentVectorFrom: matrix and: collection.
	"(adjacentVector withIndexCollect: [ :e :j| { collection at:e. collection at: j } ]) asRenderableElement inspect"	
	"now find all the chain using the adjacentVector"
	"adjacentVector inspect. self halt."
	"adjacentVector withIndexDo: [ :e :i| { collection at:e. collection at:i } asRenderableElement inspect. self halt ]."
	adjacentVector inspect.
	^self partition: collection basedOn: adjacentVector 
	
]

{ #category : #actions }
PSPolygonMergingHelper >> partition: collection basedOn: adjacentVector [ 
	|unvisitedNodes chains D line visistedNodes|
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
			line := line nextLink. "collection at: (adjacentVector at: line id)."
		].
		(visistedNodes includes: line id) ifTrue:[
			D relinkAllFrom: line.
			chains add: D.
		].
	].
	^ chains
]

{ #category : #accessing }
PSPolygonMergingHelper >> polygonA [
	^ polygonA
]

{ #category : #accessing }
PSPolygonMergingHelper >> polygonA: anObject [
	polygonA := anObject .
]

{ #category : #accessing }
PSPolygonMergingHelper >> polygonB [
	^ polygonB
]

{ #category : #accessing }
PSPolygonMergingHelper >> polygonB: anObject [
	polygonB := anObject.
]

{ #category : #actions }
PSPolygonMergingHelper >> select: collinearIds and: mutualExclusiveIds of: rowId from: matrix [
	|row|
	row := matrix rowAt: rowId.
	collinearIds add: rowId.
	row withIndexDo:[:e :i|
		e = 1 ifTrue:[ mutualExclusiveIds add: i ].
		e = -1 ifTrue:[(collinearIds includes: i) ifFalse:[
			"collinearIds add:i."
			self select: collinearIds and: mutualExclusiveIds of: i from: matrix		
		] ]	
	].
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
	^ self voteForObstacle: mutualExclusiveEdges
	
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
