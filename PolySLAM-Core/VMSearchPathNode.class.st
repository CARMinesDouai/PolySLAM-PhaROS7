"
VMSearchPathNode: objects of this class represent a single node in the search of the visibility graph.

The objects provide the comparison operator '<=' for sorting, as required by the Heap class.
We also store the vertex of the visibility graph that this object is linked to, as well as the target node (goal) for the search. using these two nodes, we provide an estimate using the L-infinity norm.
The object further more computes the weight (L2 norm distance) of this node to its predecessor.


Class side methods
	vertex: <VMGraphVertex> previous: <VMPathSearchNode or nil> goal: <VMGraphVertex>
			constructor that returns an object instance with the parameters set according to the arguments


Instance methods
	<= <VMPathSearchNode>
			comparison operator, used by the Heap object
	computeEstimate
			computes the estimated weight/distance to the goal
	computeWeight
			computes the weight/distance to the previous node
	estimate
			returns the estimated weight/distance to the goal
	goal
			returns the vertex that is our target/goal
	goal: <VMGraphVertex>
			sets the target/goal vertex does not invoke any computation/update of the estimate
	prev
			returns the previous <VMPathSearchNode> in the linked list (which might be nil)
	prev: <VMPathSearchNode>
			sets the previous node in the linked list. does not invoke any computation/update of the weight
	printString
			returns a string, that contains all nodes in the linked list up to this node
	vertex
			returns the vertex that this object represents
	vertex
			sets the vertex. does not invoke any computations/updates of the estimate or weight
	weight
			returns the edge weight from the previous node to this


Instance Variables
	estimate:	<Float>
			the estimated distance to the goal
	goal:			<VMGraphVertex>
			the vertex of the visibility graph that we ultimatly want to reach
	prev:			<VMPathSearchNode>
			the previous node, which lead us to this node
	vertex:		<VMGraphVertex>
			the vertex of the visibility graph, that this object represents
	weight:		<Float>
			the weight/distance of the previous node to this node




"
Class {
	#name : #VMSearchPathNode,
	#superclass : #Object,
	#instVars : [
		'vertex',
		'weight',
		'prev',
		'goal',
		'estimate',
		'cost'
	],
	#category : #'PolySLAM-Core-kernel'
}

{ #category : #'instance creation' }
VMSearchPathNode class >> vertex: v previous: p goal: g [
	^(self new)
		vertex: v;
		prev: p;
		goal: g;
		computeWeight;
		computeEstimate;
		computeCost;
		yourself
]

{ #category : #'comparing (for the heap)' }
VMSearchPathNode >> <= aSearchNode [
	"this comparison operator is used by the heap to sort the elements by its estimated cost"
	^((self estimate + (self cost) - weight) <= (aSearchNode estimate + (aSearchNode cost) - weight)).
	
	"the compatison below would be the cost with an estimate of 0 (resulting in A* to degrade
	into dijkstras)."
	"^((self weight) <= (aSearchNode weight))."
]

{ #category : #computing }
VMSearchPathNode >> computeCost [
	prev ifNil: [
		cost := 0.
	] ifNotNil: [
		cost := prev cost + weight.
	].
]

{ #category : #computing }
VMSearchPathNode >> computeEstimate [
	"computes the L-infinity norm and returns the result."
	| point dx dy goalPoint |
	point := vertex asPoint.
	goalPoint := goal asPoint.
	
	dx := ((point x) - (goalPoint x)) abs.
	dy := ((point y) - (goalPoint y)) abs.
	
	self assert: ( dx isNotNil ).
	self assert: ( dy isNotNil ).
	
	"estimate := dx + dy."
	estimate := (dx squared + dy squared) sqrt.

]

{ #category : #computing }
VMSearchPathNode >> computeWeight [
	"computes the weight of this node, which is the euklidian distance from this vertex to the previous node's vertex.
	if we don't have a previos vertex, the weight is set to 0. Note: only the starting node should have no previous vertex."
	prev ifNil: [
		weight := 0.
	] ifNotNil: [
		weight := self vertex asPoint dist: (prev vertex asPoint).
	].
]

{ #category : #computing }
VMSearchPathNode >> countNodes [
	| counter node |
	counter := 1.
	node := self prev.
	[ node isNotNil ] whileTrue: [
		counter := counter + 1.
		node := node prev ].
	
	^ counter
]

{ #category : #accessing }
VMSearchPathNode >> estimate [
	^estimate.
]

{ #category : #accessing }
VMSearchPathNode >> goal [
	^goal.
]

{ #category : #accessing }
VMSearchPathNode >> goal: g [
	goal := g.
]

{ #category : #accessing }
VMSearchPathNode >> prev [
	^prev.
]

{ #category : #accessing }
VMSearchPathNode >> prev: p [
	prev := p.
]

{ #category : #printing }
VMSearchPathNode >> printStats [
	Transcript
		show: 'Path stats:'; cr;
		show: '  length='; show: self computeLength printString; cr;
		show: '  node count='; show: self countNodes printString; cr.
]

{ #category : #printing }
VMSearchPathNode >> printString [
	"creates a string containg the vertices from start to cur (cur usually being the goal)"
	| path |
	
	prev ifNil: [
		path := ''.
	] ifNotNil: [
		path := prev printString, ' --> '.
	].
	
	^(path, vertex printString).
]

{ #category : #accessing }
VMSearchPathNode >> vertex [
	^vertex.
]

{ #category : #accessing }
VMSearchPathNode >> vertex: v [
	vertex := v.
]

{ #category : #accessing }
VMSearchPathNode >> weight [
	^weight.
]
