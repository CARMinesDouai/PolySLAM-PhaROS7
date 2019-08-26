Class {
	#name : #PSObstacleFilter,
	#superclass : #PSPolygonOperationHelper,
	#instVars : [
		'edges',
		'lut',
		'inlier',
		'obstacles'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #querying }
PSObstacleFilter >> colinearTo: anEdge [
	|vset result|
	vset := Set new.
	result := Set new.
	
	self collectColinearEdgesAt: anEdge id 
		to: result 
		exclude: vset
		baseline: anEdge id.
	
	result := result asOrderedCollection  select: [:e| e visited  = false  ].
	result size = 1
		ifTrue:[ ^ result first ].
	result size = 0
		ifTrue:[ ^ nil ].
	^ (PSEdgeApproximator from: result asOrderedCollection) approximate; yourself
]

{ #category : #public }
PSObstacleFilter >> collectAllObstacles [
	|idx |
	obstacles  := OrderedCollection new.
	idx := 0.
	polygonA linksDo: [ :l| l value isObstacle ifTrue:[
		idx := idx + 1.
		l id: idx.
		obstacles add: l.]].
	idx := 0.
	polygonB linksDo: [ :l| l value isObstacle ifTrue:[
		idx := idx + 1.
		l id: idx.
		obstacles add: l.]].
	^ obstacles 
]

{ #category : #accessing }
PSObstacleFilter >> collectColinearEdgesAt: idx  to: segs exclude: visitedSet baseline: base [
	|row prob|
	(visitedSet includes: idx) ifTrue:[^ self].
	visitedSet add: idx.
	segs add:(obstacles at:idx).
	row := lut rowAt: idx.
	prob := PSInflateColinearProbability new.
	prob inlier:  inlier.
	1 to: row size do:[:i|
		((row at: i) = 1) 
			ifTrue:[
				prob from: (obstacles at:base) and:(obstacles at:i).
				prob colinearity = 1 ifTrue:[ 
					self collectColinearEdgesAt: i
						to: segs
						exclude: visitedSet  	
						baseline: base
				]
			]
	]
]

{ #category : #accessing }
PSObstacleFilter >> edges [
	^ edges
]

{ #category : #initialization }
PSObstacleFilter >> initialize [
	super initialize.
	edges := OrderedCollection new.
	inlier := 0.05.
]

{ #category : #public }
PSObstacleFilter >> perform [
	|colinearEdges|
	((polygonA isNil ) | (polygonB isNil )) ifTrue:[^self error: 'Please set the two input polygons'].
	self collectAllObstacles.
	lut := PSAdjacencyMatrix fromLines: obstacles  probabilityHelper: ((PSInflateOverlapProbability new) inlier: inlier;yourself).
	obstacles do:[:e|
		e visited ifFalse:[
			colinearEdges := self colinearTo: e.
			colinearEdges ifNil: [ colinearEdges := e ].
			colinearEdges visited: true.
			colinearEdges class = PSEdgeApproximator
				ifTrue:[colinearEdges approxChain linksDo: [:l| edges add: l ]]
				ifFalse:[edges add: colinearEdges].
		]].
	
	
]
