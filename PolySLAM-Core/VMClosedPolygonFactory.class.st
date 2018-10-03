"
VMClosedPolygonFactory

This class creates a (single) polygon by prviding it with a collection of vertices (the verticesPoll) and a starting vertex, which will be part of the final polygon.


Example code:

polygon := (VMClosedPolygonFactory new)
	activeNeighborCount: activeNC;
	createPolygonWithVertex: (aVertexCollection first).


 
Internal Representation and Key Implementation Points.

    Instance Variables:

	activeNeighborCount <VMActiveNeighborCount>
		used to keep track how many neighbors of a vertex are already used
	polygonVertices <VMOrderedVertexCollection>
		a collection of vertices that will define the polygon (if successfull)
	startVertex <VMGraphVertex>
		the vertex that we start with
	viewer <VMViewer>
	optional - if set, we can use it to visualize the algorithm (for debugging)



"
Class {
	#name : #VMClosedPolygonFactory,
	#superclass : #VMAbstractPolygonFactory,
	#category : #'PolySLAM-Core-kernel'
}

{ #category : #'instance creation' }
VMClosedPolygonFactory class >> createWithVertex: aVertex activeNeighborCount: anc [
	^(self new)
		activeNeighborCount: anc;
		createWithVertex: aVertex.
]

{ #category : #testing }
VMClosedPolygonFactory >> checkNeighborVertex: vertex prevVertex: prevVertex ifStartVertex: startBlock ifValid: validBlock ifInvalid: invalidBlock [
	"returns 'false' if invalid and true otherwise."
	(vertex = prevVertex) ifFalse: [
		(vertex = polygonVertices first) ifTrue: [
			"we have reached the starting vertex, meaning that we have collected all the vertices for a valid closed polygon"
			startBlock value.
			^true.
		] ifFalse: [
			(polygonVertices includes: vertex) ifTrue: [
				self onAlreadyUsed: vertex.
				invalidBlock value.
				^false.
			].
		
			((self freeNeighborsCount: vertex) >= 2) ifTrue: [
				validBlock value.
				^true.
			].
		].
	] ifTrue: [
		"we consider the previous vertex as invalid but don't execute the invalid block because this is a common case that doesn't need our attention"
		^false.
	].
	
	invalidBlock value.
	^false.
]

{ #category : #'public: create' }
VMClosedPolygonFactory >> createWithVertex: vertex [
	
	startVertex := vertex.
	"polygonVertices add: startVertex."
	
	(self recursiveLineWalk: startVertex prevVertex: nil) ifTrue: [
		^VMClosedPolygon fromOrderedVertices: polygonVertices.
	] ifFalse: [
		^nil.
	].
]

{ #category : #'public: hooks' }
VMClosedPolygonFactory >> onAlreadyUsed: aVertex [
	"executed when we try to add a vertex that is already in 'polygonVertices'. this can only
	happen with vertices that have more than 2 neighbors."
	Transcript
		show: 'vertex (', aVertex printString,') is already part of the current collection';
		cr.
]

{ #category : #'public: hooks' }
VMClosedPolygonFactory >> onLineWalkInvalid: invalidVertex [
	"this is executed when we try to add a vertex that is invalid for some reason, e.g. a free neighbor count of less than 2."
	
	Transcript
		show: 'VMClosedPolygonFactory warning: aborting at vertex=',
			invalidVertex printString,
			' activeNeighborCount=', (activeNeighborCount at: invalidVertex) printString,
			' neighborCount=', invalidVertex neighbors size printString;
		cr.
	
	Transcript show: '  vertices in collection so far:'.
	polygonVertices do: [ :v |
		Transcript show: ' ', v index printString.
	].

]

{ #category : #'public: hooks' }
VMClosedPolygonFactory >> onLineWalkOutOfNeighbors [
	"Transcript show: 'VMClosedPolygonFactory warning: out of neighbors at vertex=', polygonVertices last printString; cr."
]

{ #category : #computing }
VMClosedPolygonFactory >> recursiveLineWalk: currentVertex prevVertex: prevVertex [
	
	self tryConnectVertex: prevVertex with: currentVertex ifFailedDo: [
		^false.
	].
	polygonVertices add: currentVertex.
	
	currentVertex neighbors do: [ :neighbor |
		
		self checkNeighborVertex: neighbor prevVertex: prevVertex
			ifStartVertex: [
				self tryConnectVertex: (polygonVertices first) with: (polygonVertices last)
					ifFailedDo: [
						self error: 'failed to connect first and last vertex in polygon'.
						self undoConnectVertex: prevVertex with: currentVertex.
						polygonVertices removeLast.
						^false.
					].
				^true.
			]
			ifValid: [
				(self recursiveLineWalk: neighbor prevVertex: currentVertex) ifTrue: [
					"if true, we return here. otherwise we stay in the loop until we run out of neighbors"
					^true.
				].
			]
			ifInvalid: [
				self onLineWalkInvalid: neighbor.
				"1 halt."
			].
	
	].
	
	"1 halt."
	self undoConnectVertex: prevVertex with: currentVertex.
	polygonVertices removeLast.
	self onLineWalkOutOfNeighbors.
	
	^false.
]

{ #category : #connecting }
VMClosedPolygonFactory >> tryConnectVertex: vertexA with: vertexB ifFailedDo: failBlock [
	
	(vertexA isNil or: [ vertexB isNil ]) ifTrue: [ ^true. ].
	
	activeNeighborCount tryIncrementAt: vertexA
		ifFull: [
			^false.
		].
	
	activeNeighborCount tryIncrementAt: vertexB
		ifFull: [
			activeNeighborCount at: vertexA add: -1.
			^false.
		].
	^true.

]

{ #category : #connecting }
VMClosedPolygonFactory >> undoActiveNeighborCount: collectionSize [
]

{ #category : #connecting }
VMClosedPolygonFactory >> undoConnectVertex: vertexA with: vertexB [
	(vertexA isNil or: [ vertexB isNil ]) ifTrue: [ ^true. ].
	
	activeNeighborCount at: vertexA add: -1.
	activeNeighborCount at: vertexB add: -1.

]
