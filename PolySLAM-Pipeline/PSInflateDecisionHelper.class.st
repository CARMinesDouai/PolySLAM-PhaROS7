Class {
	#name : #PSInflateDecisionHelper,
	#superclass : #Object,
	#instVars : [
		'inlier',
		'cmatrix',
		'lmatrix',
		'collection'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
PSInflateDecisionHelper class >> from: list [
	^ self new from: list; yourself
]

{ #category : #querying }
PSInflateDecisionHelper >> colinearTo: anEdge [
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

{ #category : #querying }
PSInflateDecisionHelper >> collectColinearEdgesAt: idx  to: segs exclude: visitedSet baseline: base [
	|row prob|
	(visitedSet includes: idx) ifTrue:[^ self].
	visitedSet add: idx.
	segs add:(collection at:idx).
	row := cmatrix rowAt: idx.
	prob := PSInflateColinearProbability new.
	prob inlier: self inlier.
	1 to: row size do:[:i|
		((row at: i) = 1) 
			ifTrue:[
				prob from: (collection at:base) and:(collection at:i).
				prob colinearity = 1 ifTrue:[ 
					self collectColinearEdgesAt: i
						to: segs
						exclude: visitedSet  	
						baseline: base
				]
			]
	]
]

{ #category : #'instance creation' }
PSInflateDecisionHelper >> from: anEdgeCollection [
	|chelper lhelper|
	chelper := PSInflateOverlapProbability new.
	chelper inlier: self inlier.
	lhelper := PSInflateLinkingProbability new.
	lhelper inlier: 1e-6"self inlier".
	cmatrix := PSAdjacencyMatrix fromLines: anEdgeCollection probabilityHelper: chelper.
	cmatrix := cmatrix makeSymetric.
	lmatrix := PSAdjacencyMatrix fromLines: anEdgeCollection probabilityHelper: lhelper.
	collection := anEdgeCollection.
]

{ #category : #initialization }
PSInflateDecisionHelper >> initialize [
	super initialize.
	inlier := 0.05
]

{ #category : #accessing }
PSInflateDecisionHelper >> inlier [
	^ inlier
]

{ #category : #accessing }
PSInflateDecisionHelper >> inlier: anObject [
	inlier := anObject
]

{ #category : #testing }
PSInflateDecisionHelper >> isDisjoint [
	^cmatrix isZeros 
]

{ #category : #querying }
PSInflateDecisionHelper >> linkedTo: anEdge [
	|result   edge|
	result := BTree order:4.
	"anEdge segments do:[:e|"
		(lmatrix rowAt: anEdge id) withIndexDo: [ :v :i|
			v = 1 ifTrue:[
				edge := collection at:i.
				result at: (PSEdgePriorityKey from: edge baseline:anEdge)  put: edge
			]]"]".
	"result := result  select: [:e| e visited  = false  ]."
	^ result
]
