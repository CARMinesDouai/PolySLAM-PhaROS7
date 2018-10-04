Class {
	#name : #VMGraphBuilder,
	#superclass : #Object,
	#instVars : [
		'storage',
		'hyperplaneDict'
	],
	#category : #'PolySLAM-Core-Collections, Trees & Graphs'
}

{ #category : #'helper methods' }
VMGraphBuilder >> buildGraph: aBspTree [
	| graph |
	
	self traverseTree: aBspTree.
	self buildHyperplaneDictionary.
	graph := self connectSectors.
	^ graph

]

{ #category : #'helper methods' }
VMGraphBuilder >> buildHyperplaneDictionary [
	"all VMSectorVector instances in 'storage' are grouped into a dictionary
	by their hyperplane."
	storage do: [ :svObj |
		svObj hyperplane
			ifNil: [ Transcript show: 'invalid hyperplane (nil) - ignored'; cr. ]
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
VMGraphBuilder >> findHyperplaneVector: aVector node: aNode [
	"starts at aNode and checks if the node's hyperplane is collinear with aVector.
	if not, the search is continued recursively upwards until the root has been reached
	or a matching hyperplane is found. if no matching hyperplane is found, then nil is
	returned."
	(aNode hyperplane isCollinearWith: aVector) ifTrue: [ ^aNode hyperplane ].
	aNode parent ifNil: [ Transcript show: 'reached root without finding a matching hyperplane for ', aVector printString; cr. ^nil ].
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
	| sign candidates a b |
	
	sign := aSectorVector vector direction x sign.
	a := aSectorVector vector pointA x.
	b := aSectorVector vector pointB x.
	
	candidates := (hyperplaneDict at: aSectorVector hyperplane)
		select: [ :svObj | svObj vector direction x sign ~= sign ].
	
	^ candidates select: [ :svObj |
		self vector: aSectorVector vector byXOverlapsWith: svObj vector
	].
	
]

{ #category : #'helper methods' }
VMGraphBuilder >> findMatchesByY: aSectorVector [
	| sign candidates a b |
	
	sign := aSectorVector vector direction y sign.
	a := aSectorVector vector pointA y.
	b := aSectorVector vector pointB y.
	
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
			aNode sector do: [ :v | v isSector
				ifTrue: [ self storeVector: v node: aNode]. ]
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
					vectorA pointB x < vectorB pointA x
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
	vectorA direction y > 0 "if true, vector A is facing to the right and vectorB is facing to the left"
		ifTrue: [
			vectorA pointA y > vectorB pointB y
				ifTrue: [ vectorA pointA y > vectorB pointA y
					ifTrue: [ ^ false ]
					ifFalse: [ ^ true ].]
				ifFalse: [
					vectorA pointB y < vectorB pointA y
						ifTrue: [ ^ false ]
						ifFalse: [ ^ true ].].]
		ifFalse: [
			vectorA pointB y < vectorB pointA y
				ifTrue: [ vectorA pointA y < vectorB pointA y
					ifTrue: [ ^ false ]
					ifFalse: [ ^ true ].]
				ifFalse: [
					vectorA pointB x > vectorB pointB x
						ifTrue: [ ^ false ]
						ifFalse: [ ^ true ].].].

]
