"
The VMGraphBuilder creates a topological graph from a BSP tree.


Public API and Key Messages
- buildGraph: <VMBSPLeaf/Node>
	primary public interface. takes a BSP tree as argument and returns the corresponding graph
- buildHyperplaneDictionary
	takes the content from 'storage' and places it in 'hyperplaneDict', using the hyperplane as the dictionary key
- connectSectors
	iterates over all entries of 'hyperplaneDict' and creates the actual graph with all the nodes and edges
-findHyperplaneVector: <aVector> node: <VMBSPLeaf/Node>
	returns the hyperplane of the node, if it is collinear with the vector. otherwise recursively does the same
	with the parent node. returns nil if the recursive call fails due the parent being nil.
- findMatches: <VMSectorVector>
	returns a collection of all VMSectorVector instances that overlap with the provided VMSectorVector's vector and have the oposite direction. hence collecting all sectors that are reachable through this vector.
-storeVector: <aVector> node: <VMBSPLeaf/Node>
	creates a VMSectorVector instance for the vector and node, finds the correct hyperplane for it too, and adds the new instance to 'storage'
-traverseTree: <VMBSPLeaf/Node>
	recusively collects all sector-typed vectors and calls #storeVector:node: on them.



"
Class {
	#name : #VMGraphBuilder,
	#superclass : #Object,
	#instVars : [
		'storage',
		'hyperplaneDict'
	],
	#category : #'PolySLAM-Core-Top. Graph'
}

{ #category : #'as yet unclassified' }
VMGraphBuilder class >> buildGraphFromGrid: grid [
	^ self new buildGraphFromGrid: grid
]

{ #category : #'as yet unclassified' }
VMGraphBuilder class >> buildGraphFromTree: root [
	^ self new buildGraph: root
]

{ #category : #'helper methods' }
VMGraphBuilder >> addGraph: graph fromTree: aBspTree [
	
	self traverseTree: aBspTree.
	self buildHyperplaneDictionary.
	self connectSectors: graph.
	
	"workaround to add missing edges"
	graph checkEdges.
	
	^ graph

]

{ #category : #'helper methods' }
VMGraphBuilder >> buildGraph: aBspTree [
	| graph |
	
	self traverseTree: aBspTree.
	self buildHyperplaneDictionary.
	graph := self connectSectors.
	
	"workaround to add missing edges"
	graph checkEdges.
	
	^ graph

]

{ #category : #'helper methods' }
VMGraphBuilder >> buildGraphFromGrid: aGridStorage [
	| graph |
	
	self loopOverGrid: aGridStorage.
		
	"workaround to add missing edges"
	graph checkEdges.
	
	^ graph

]

{ #category : #'helper methods' }
VMGraphBuilder >> buildHyperplaneDictionary [
	"all VMSectorVector instances in 'storage' are grouped into a dictionary
	by their hyperplane."
	storage do: [ :svObj |
		svObj hyperplane
			ifNil: [ "Transcript show: 'invalid hyperplane (nil) - ignored'; cr." ]
			ifNotNil: [
				hyperplaneDict at: svObj hyperplane
					ifPresent: [ :oc | oc add: svObj ]
					ifAbsent: [
						hyperplaneDict
							at: svObj hyperplane
							put: (OrderedCollection new add: svObj; yourself)
					].
			].
	].
]

{ #category : #'helper methods' }
VMGraphBuilder >> connectSectors [
	| graph neighbors node |
	graph := VMGraph new.
	hyperplaneDict do: [ :svCollection |
		svCollection do: [ :svObj |
			graph add: (VMGraphNode sector: svObj polygon). ].
		svCollection do: [:svObj |
			node := graph atSector: (svObj polygon).
			neighbors := self findMatches: svObj.
			neighbors do: [ :n |
				node neighbors add: (graph atSector: (n polygon)).
			].
		].
	].
	^ graph

]

{ #category : #'helper methods' }
VMGraphBuilder >> connectSectors: graph [
	| neighbors node |
	hyperplaneDict do: [ :svCollection |
		svCollection do: [ :svObj |
			graph add: (VMGraphNode sector: svObj polygon). ].
		svCollection do: [:svObj |
			node := graph atSector: (svObj polygon).
			neighbors := self findMatches: svObj.
			neighbors do: [ :n |
				node neighbors add: (graph atSector: (n polygon)).
			].
		].
	].
	^ graph

]

{ #category : #'helper methods' }
VMGraphBuilder >> debugLoopOverCells: aGridStorage [
	| graph builder timeSpent |
	graph := VMGraph new.
	aGridStorage doWithIndex: [ :cell :x :y |
		builder := VMGraphBuilder new.
		Transcript show: 'processing cell '; show: x printString; show: '@'; show: y printString; cr.
		"self northCollectionGrid: aGridStorage atX: x atY: y graph: graph.
		self eastCollectionGrid: aGridStorage atX: x atY: y graph: graph."
		timeSpent := [ builder addGraph: VMGraph new fromTree: cell root ] timeToRun.
		Transcript show: '  time spent='; show: timeSpent totalSeconds asFloat asTimeString; cr.
	].
	^ graph
	

]

{ #category : #'helper methods' }
VMGraphBuilder >> debugLoopOverGrid: aGridStorage [
	| graph builder |
	graph := VMGraph new.
	builder := VMGraphBuilder new.
	aGridStorage doWithIndex: [ :cell :x :y |
		Transcript show: 'processing cell '; show: x printString; show: '@'; show: y printString; cr.
		self northCollectionGrid: aGridStorage atX: x atY: y graph: graph.
		self eastCollectionGrid: aGridStorage atX: x atY: y graph: graph.
		"builder addGraph: graph fromTree: cell root."
	].
	^ graph
	

]

{ #category : #'helper methods' }
VMGraphBuilder >> eastCollectionGrid: grid atX: x atY: y graph: graph [
	| leftCell rightCell leftCollection rightCollection node |
	rightCell := grid at: x+1 at: y.
	leftCell := grid at: x at: y.
	leftCell ifNil: [ ^self ].
	rightCell ifNil: [ ^self ].
	
	leftCollection := leftCell collectBordersX: (x + 1) * (grid gridSize).
	rightCollection := rightCell collectBordersX: (x + 1) * (grid gridSize).
	
	leftCollection do: [ :leftSectorVector |
		rightCollection do: [ :rightSectorVector |
			(self vector: leftSectorVector vector byXOverlapsWith: rightSectorVector vector) ifTrue: [
				graph add: (VMGraphNode sector: leftSectorVector polygon).
				graph add: (VMGraphNode sector: rightSectorVector polygon).
				node := graph atSector: (leftSectorVector polygon).
				node neighbors add: (graph atSector: (rightSectorVector polygon)).
				node := graph atSector: (rightSectorVector polygon).
				node neighbors add: (graph atSector: (leftSectorVector polygon)).
			].
		].
	].

]

{ #category : #'helper methods' }
VMGraphBuilder >> findHyperplaneVector: aVector node: aNode [
	"starts at aNode and checks if the node's hyperplane is collinear with aVector.
	if not, the search is continued recursively upwards until the root has been reached
	or a matching hyperplane is found. if no matching hyperplane is found, then nil is
	returned."
	(aNode hyperplane isCollinearWith: aVector) ifTrue: [ ^aNode hyperplane ].
	aNode parent ifNil: [
		"Transcript show: 'reached root without finding a matching hyperplane for ', aVector printString; cr."
		^nil ].
	^ self findHyperplaneVector: aVector node: aNode parent
	
]

{ #category : #'helper methods' }
VMGraphBuilder >> findMatches: aSectorVector [
	| direction |
	direction := aSectorVector hyperplane direction.
	(direction x abs > direction y abs)
		ifTrue: [ ^ self findMatchesByX: aSectorVector ]
		ifFalse: [ ^ self findMatchesByY: aSectorVector ].

]

{ #category : #'helper methods' }
VMGraphBuilder >> findMatchesByX: aSectorVector [
	| sign candidates |
	
	sign := aSectorVector vector direction x sign.
	
	candidates := (hyperplaneDict at: aSectorVector hyperplane)
		select: [ :svObj | svObj vector direction x sign ~= sign ].
	
	^ candidates select: [ :svObj |
		self vector: aSectorVector vector byXOverlapsWith: svObj vector.
	].
	
]

{ #category : #'helper methods' }
VMGraphBuilder >> findMatchesByY: aSectorVector [
	| sign candidates |
	
	sign := aSectorVector vector direction y sign.
	
	candidates := (hyperplaneDict at: aSectorVector hyperplane)
		select: [ :svObj | svObj vector direction y sign ~= sign ].
	
	^ candidates select: [ :svObj |
		self vector: aSectorVector vector byYOverlapsWith: svObj vector
	].
	
]

{ #category : #initialization }
VMGraphBuilder >> initialize [
	super initialize.
	
	storage := OrderedCollection new.
	hyperplaneDict := Dictionary new.
]

{ #category : #'helper methods' }
VMGraphBuilder >> loopOverGrid: aGridStorage [
	| graph builder |
	graph := VMGraph new.
	aGridStorage doWithIndex: [ :cell :x :y |
		builder := VMGraphBuilder new.
		Transcript show: 'processing cell '; show: x printString; show: '@'; show: y printString; cr.
		self northCollectionGrid: aGridStorage atX: x atY: y graph: graph.
		self eastCollectionGrid: aGridStorage atX: x atY: y graph: graph.
		builder addGraph: graph fromTree: cell root.
	].
	^ graph
	

]

{ #category : #'helper methods' }
VMGraphBuilder >> northCollectionGrid: grid atX: x atY: y graph: graph [
	| topCell botCell botCollection topCollection node |
	topCell := grid at: x at: y+1.
	botCell := grid at: x at: y.
	topCell ifNil: [ ^self ].
	botCell ifNil: [ ^self ].
	
	topCollection := topCell collectBordersY: (y + 1) * (grid gridSize).
	botCollection := botCell collectBordersY: (y + 1) * (grid gridSize).
	
	topCollection do: [ :topSectorVector |
		botCollection do: [ :botSectorVector |
			(self vector: topSectorVector vector byXOverlapsWith: botSectorVector vector) ifTrue: [
				graph add: (VMGraphNode sector: topSectorVector polygon).
				graph add: (VMGraphNode sector: botSectorVector polygon).
				node := graph atSector: (topSectorVector polygon).
				node neighbors add: (graph atSector: (botSectorVector polygon)).
				node := graph atSector: (botSectorVector polygon).
				node neighbors add: (graph atSector: (topSectorVector polygon)).
			].
		].
	].

]

{ #category : #accessing }
VMGraphBuilder >> storage [
	^ storage
]

{ #category : #'helper methods' }
VMGraphBuilder >> storeVector: aVector node: aNode [
	| hyperplane |
	hyperplane := self findHyperplaneVector: aVector node: aNode parent.
	storage add: (VMSectorVector vector: aVector polygon: aNode sector hyperplane: hyperplane).
]

{ #category : #'helper methods' }
VMGraphBuilder >> traverseTree: aNode [
	aNode isLeaf
		ifTrue: [
			aNode parent ifNotNil: [
				aNode sector ifNil: [ ^self ].
				aNode sector do: [ :v | v isSector
					ifTrue: [ self storeVector: v node: aNode]. ]. ]
		] ifFalse: [
			self traverseTree: aNode leftChild.
			self traverseTree: aNode rightChild.
		].
]

{ #category : #'helper methods' }
VMGraphBuilder >> vector: vectorA byXOverlapsWith: vectorB [
	"note: we assume, that both vectors have oposite direction"
	vectorA direction x > 0 "if true, vector A is facing to the right and vectorB is facing to the left"
		ifTrue: [
			vectorA pointA x > vectorB pointB x
				ifTrue: [ vectorA pointA x > vectorB pointA x
					ifTrue: [ ^ false "vectorB is to the left, non-overlapping"]
					ifFalse: [ ^ true "vectorA overlaps at the left of vectorA"].]
				ifFalse: [
					vectorA pointB x < vectorB pointB x
						ifTrue: [ ^ false "vectorB is to the right of vectorA"]
						ifFalse: [ ^ true "vectorB overlaps at the right of vectorA"].
				].
		] ifFalse: [
			vectorA pointB x < vectorB pointA x
				ifTrue: [ vectorA pointA x < vectorB pointA x
					ifTrue: [ ^ false "vectorB is to the right, non-overlapping"]
					ifFalse: [ ^ true "vectorA overlaps at the right of vectorA"].]
				ifFalse: [
					vectorA pointB x > vectorB pointB x
						ifTrue: [ ^ false "vectorB is to the left of vectorA"]
						ifFalse: [ ^ true "vectorB overlaps at the left of vectorA"].
				].
		].

]

{ #category : #'helper methods' }
VMGraphBuilder >> vector: vectorA byYOverlapsWith: vectorB [
	"returns true if the two vectors overlap, false otherwise
	note: we assume, that both vectors have oposite direction, and are collinear"
	vectorA direction y > 0 "if true, vector A is facing up and vectorB is facing down"
		ifTrue: [
			vectorA pointA y > vectorB pointB y
				ifTrue: [ vectorA pointA y > vectorB pointA y
					ifTrue: [ ^ false ]
					ifFalse: [ ^ true ].]
				ifFalse: [
					vectorA pointB y < vectorB pointB y
						ifTrue: [ ^ false ]
						ifFalse: [ ^ true ].].]
		ifFalse: [
			vectorA pointB y < vectorB pointA y
				ifTrue: [ vectorA pointA y < vectorB pointA y
					ifTrue: [ ^ false ]
					ifFalse: [ ^ true ].]
				ifFalse: [
					vectorA pointB y > vectorB pointB y
						ifTrue: [ ^ false ]
						ifFalse: [ ^ true ].].].

]
