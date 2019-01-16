Class {
	#name : #VMPathSearch,
	#superclass : #Object,
	#category : #'PolySLAM-Core-kernel'
}

{ #category : #'as yet unclassified' }
VMPathSearch class >> compute: visGraph from: start to: goal [
	"computes the path from start to goal. returns the VMPathSearchNode of the goal, which
	contains a linked list of the path. returns nil if no path was found."
	|	pQueue					"the priority queue for the A* algorithm"
		markedVertices		"a Set that we use to remember which vertices we have already marked (inserted into the queue, and possibly already processed)"
		cur						"the current VMPathSearchNode that we are working with"
		makeNode				"a block that marks the vertex and creates a VMPathSearchNode, which is returned"
	|
	
	pQueue := Heap new.		"we use a heap as priority queue"
	markedVertices := Set new.
	makeNode := [ :v :p |
		markedVertices add: v.
		VMSearchPathNode vertex: v previous: p goal: goal.
	].
	
	cur := makeNode value: start value: nil.
	
	[ cur vertex ~= goal ] whileTrue: [
		"check all neighbors of 'cur vertex', add all new edges to the priority queue"
		cur vertex neighbors do: [ :n |
			(markedVertices includes: n) ifFalse: [
				pQueue add: (makeNode value: n value: cur).
			].
		].
		
		"check if we have any elements left in the priority queue. if it is empty then there is no path from start to stop."
		pQueue isEmpty ifTrue: [
			self logCr: 'empty queue - no path found from ', start printString, ' to ', goal printString.
			^nil.
		].
		cur := pQueue removeFirst.
	].
	
	self logCr: 'found path from ', start printString, ' to ', goal printString.
	self logCr: 'path: ', cur printString.
	
	^cur.
	
]
