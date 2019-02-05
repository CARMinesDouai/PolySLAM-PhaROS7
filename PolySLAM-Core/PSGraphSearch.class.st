Class {
	#name : #PSGraphSearch,
	#superclass : #Object,
	#instVars : [
		'pQueue',
		'visitedNodes',
		'iterationCounter',
		'goal',
		'result'
	],
	#category : #'PolySLAM-Core-Top. Graph'
}

{ #category : #computing }
PSGraphSearch class >> computeGraph: graph from: startNode to: endNode [
	^ self new
		computeGraph: graph from: startNode to: endNode
]

{ #category : #computing }
PSGraphSearch >> computeGraph: graph from: startNode to: endNode [
	visitedNodes add: startNode.
	goal := endNode.
	pQueue add: (VMSearchPathNode node: startNode previous: nil goal: endNode).
	
	[ (pQueue isEmpty) or: [result isNotNil] ] whileFalse: [
		self iterateOnce. ].
	
	self printStats.
	
	^ result
	
]

{ #category : #initialization }
PSGraphSearch >> initialize [
	pQueue := Heap new.
	visitedNodes := Set new.
	iterationCounter := 0.
	result := nil.
	

]

{ #category : #computing }
PSGraphSearch >> iterateOnce [
	| curPath curNode |
	
	curPath := pQueue removeFirst.
	curNode := curPath node.
	iterationCounter := iterationCounter + 1.
	
	curPath node = goal ifTrue: [
		result := curPath.
		^ self. ].
	
	curNode neighbors
		select: [ :n | (visitedNodes includes: n) not] thenDo: [ :neighbor |
		(visitedNodes includes: neighbor) ifFalse: [
			visitedNodes add: neighbor.
			pQueue add: (VMSearchPathNode node: neighbor previous: curPath goal: goal).
		] ].
	
]

{ #category : #printing }
PSGraphSearch >> printStats [

	Transcript
		show: self class asString;
		show: ' iterations=';
		show: iterationCounter printString;
		cr.

]
