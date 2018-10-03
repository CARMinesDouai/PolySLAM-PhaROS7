Class {
	#name : #VMPolygonChainFactory,
	#superclass : #VMAbstractPolygonFactory,
	#category : #'PolySLAM-Core-kernel'
}

{ #category : #'instance creation' }
VMPolygonChainFactory class >> createWithVertex: aVertex [
	^(self new)
		createWithVertex: aVertex.
]

{ #category : #'instance creation' }
VMPolygonChainFactory class >> createWithVertex: aVertex activeNeighborCount: anc [
	^(self new)
		activeNeighborCount: anc;
		createWithVertex: aVertex.
]

{ #category : #initialize }
VMPolygonChainFactory >> createWithVertex: aVertex [
	startVertex := aVertex.
	
	(self recursiveLineWalk: startVertex prevVertex: nil) ifTrue: [
		polygonVertices size < 2 ifTrue: [ 1 halt. ].
		^VMPolygonChain fromOrderedVertices: polygonVertices.
	] ifFalse: [
		^nil.
	].
]

{ #category : #'as yet unclassified' }
VMPolygonChainFactory >> getFreeNeighbor: aVertex prevVertex: prevVertex ifNormal: normalBlock ifEnd: endBlock ifFailed: failedBlock [

	aVertex neighbors do: [ :n |
		n ~~ prevVertex ifTrue: [
			
			(self freeNeighborsCount: n) == 2 ifTrue: [
				^normalBlock value: n.
			].
		
			(self freeNeighborsCount: n) > 0 ifTrue: [
				^endBlock value: n.
			].
			
		].
	].
	
	^failedBlock value.

]

{ #category : #computing }
VMPolygonChainFactory >> recursiveLineWalk: currentVertex prevVertex: prevVertex [
	Transcript show: 'recLineWalk (1)'; cr.
	self tryConnectVertex: currentVertex with: prevVertex
		ifFailedDo: [
			self error: 'unable to create edge between neighbors'.
			^false.
		].
	
	polygonVertices add: currentVertex.
	Transcript show: 'recLineWalk (2)'; cr.
	
	self getFreeNeighbor: currentVertex prevVertex: prevVertex
		ifNormal: [ :nextVertex |
			Transcript show: 'normal (', polygonVertices size printString, ')'; cr.
			^self recursiveLineWalk: nextVertex prevVertex: currentVertex.
		]
		ifEnd: [ :endVertex |
			Transcript show: 'end (', polygonVertices size printString, ')'; cr.
			polygonVertices add: endVertex.
			self tryConnectVertex: currentVertex with: endVertex
				ifFailedDo: [ self error: 'failed to create edge between two neighboring vertices'. ].
			^true.
		]
		ifFailed: [
			Transcript show: 'failed (', polygonVertices size printString, ')'; cr.
			^false.
		].
	
	
	
	
]

{ #category : #connecting }
VMPolygonChainFactory >> tryConnectVertex: vertexA with: vertexB ifFailedDo: failBlock [
	
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
