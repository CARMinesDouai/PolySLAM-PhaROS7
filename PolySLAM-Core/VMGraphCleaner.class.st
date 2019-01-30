Class {
	#name : #VMGraphCleaner,
	#superclass : #Object,
	#category : #'PolySLAM-Core-Top. Graph'
}

{ #category : #'as yet unclassified' }
VMGraphCleaner >> checkCollisionsGraph: graph nnc: nnc [
	| count collisionCounter toBeRemoved |
	
	count := 0.
	collisionCounter := 0.
	toBeRemoved := OrderedCollection new.
	
	graph do: [ :node |
		count := count + 1.
		count \\ 10 = 0 ifTrue: [ Transcript show: '.'. ].
		count \\ 200 = 0 ifTrue: [ Transcript show: '. '; show: count printString; cr. ].
		toBeRemoved removeAll.
		node neighbors do: [ :neighbor |
			(self checkVector: (node center vectorTo: neighbor center) nnc: nnc)
				ifTrue: [
					toBeRemoved add: neighbor.
					"node neighbors remove: neighbor."
					[neighbor neighbors remove: node] on: Error do: [ Transcript show: 'x'. ].
					collisionCounter := collisionCounter + 1. ].].
		toBeRemoved do: [ :n | [node neighbors remove: n] on: Error do: [Transcript show: 'o'.] ]. ].
	
	Transcript show: 'removed '; show: collisionCounter printString; show: ' edges due collisions'; cr.
	
	^ graph

]

{ #category : #'as yet unclassified' }
VMGraphCleaner >> checkVector: aVector nnc: nnc [
	"returns true if 'aVector' intersects with at least one vector from 'nnc', false otherwise"
	nnc addedVectors do: [ :v |
		( VMIntersection intersectLine: aVector withLine: v) intersectsAsVectors ifTrue: [ ^ true ].
	].
	
	^ false
]

{ #category : #'as yet unclassified' }
VMGraphCleaner >> cleanGraph: graph nnc: nnc radius: radius [
	| newGraph count toBeRemoved squareRadius |
	newGraph := graph.
	toBeRemoved := OrderedCollection new.
	count := 0.
	squareRadius := radius squared.
	
	newGraph do: [ :graphNode |
		count := count + 1.
		count \\ 10 = 0 ifTrue: [ Transcript show: '.'. ].
		count \\ 200 = 0 ifTrue: [ Transcript show: '. '; show: count printString; cr. ].
		
		(nnc findNearest: graphNode center) squareDist <= squareRadius ifTrue: [
			graphNode neighbors do: [ :node | node neighbors remove: graphNode ].
			toBeRemoved add: graphNode. ]. ].
	
	Transcript cr; show: 'finished, removing edges'; cr.
	toBeRemoved do: [ :node | newGraph remove: node ].
	Transcript show: 'removed nodes='; show: toBeRemoved size printString; cr.
	Transcript show: 'done'; cr.
	
	^ newGraph
]
