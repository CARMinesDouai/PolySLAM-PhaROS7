Class {
	#name : #VMGraphCleaner,
	#superclass : #Object,
	#category : #'PolySLAM-Core-Top. Graph'
}

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
