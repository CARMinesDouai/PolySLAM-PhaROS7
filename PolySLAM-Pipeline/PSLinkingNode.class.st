Class {
	#name : #PSLinkingNode,
	#superclass : #Object,
	#instVars : [
		'parent',
		'children',
		'nodeValue',
		'connected',
		'root'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
PSLinkingNode class >> from: anEdge parent: aNode with: helper [
	^ (self new parent: aNode) from: anEdge with: helper 
]

{ #category : #querying }
PSLinkingNode >> addNodeValue: currentNode to: comp [
		currentNode nodeValue segments do:[:e| comp indices add: e id].
		currentNode nodeValue class = PSEdgeApproximator
			ifTrue:[
				currentNode nodeValue approxChain reverseLinksDo:  [:e|
					comp chain addFirst: e value]						
			]
			ifFalse:[
				comp chain addFirst: currentNode nodeValue value  ] .
]

{ #category : #querying }
PSLinkingNode >> allChains [
	"brute force to get all chains starting from this node"
	|chains currentNode chain joinchains|
	chains := OrderedCollection new.
	self leave do:[:e|
		e isLeaf
			ifTrue:[
				chain := OrderedCollection new.
				currentNode := e.
				[
					currentNode ifNotNil: [  
						chain addFirst: currentNode].
					(currentNode = self) or: (currentNode isNil)
				] whileFalse:[ currentNode := currentNode parent ].
				chains add: chain.
			]
			ifFalse:[
				joinchains := e allChains.
				currentNode := e.
				[ 
					(currentNode = self) or: (currentNode isNil) .
				] whileFalse: [
					currentNode := currentNode parent.
					currentNode ifNotNil: [  
						joinchains do:[:c| c addFirst: currentNode]]].
				joinchains do:[:c| chains add: c].
			].
				
		].
	^ chains
]

{ #category : #querying }
PSLinkingNode >> allConnectedComponents [
	|components chains|
	"search for all connected component given my leaves"
	components := OrderedCollection new.
	self leave do:[:leaf|
		(leaf isConnected)  ifTrue: [
			chains := (leaf isLeaf)
				ifTrue:[self componentsFromLeaf: leaf]
				ifFalse:[self componentsFromJoin: leaf].
			chains do:[:e| components add:e ].
		]
	].
	
	^ components 
]

{ #category : #'instance creation' }
PSLinkingNode >> buildLeave: linkedEdges [
	|jList lList leaf join|
	jList := OrderedCollection new.
	lList := OrderedCollection new.
	linkedEdges do:[:e|
		(self hasAncestor: e id)
			ifTrue: [ lList add: e id ]
			ifFalse: [ jList add: e id ]
	].
	leaf := PSLinkingLeaf from: nodeValue parent: self parent  with:  lList.
	^ leaf
	"join := PSLinkingJoin from: nodeValue parent: self parent with: jList.
	((jList isEmpty) or: (join isConnected not) ) ifTrue: [ ^leaf ].
	((lList isEmpty ) or: (leaf isConnected not)) ifTrue: [ ^ join].
	children add: join; add: leaf.
	connected := true.
	nodeValue visited: connected.
	^ self"
	
]

{ #category : #'instance creation' }
PSLinkingNode >> buildTree: linkedEdges helper: decisionHelper [
	|child |
	linkedEdges  do:[:e|
		e visited ifFalse:[
			child := (PSLinkingNode from: e parent: self  with: decisionHelper).
			child ifNotNil: [  
				(child isConnected)
					ifTrue:[
						children add:  child.
						connected := true.
					]
				]
		]].
	nodeValue visited: connected.
	children isEmpty
		ifTrue:[
			^ self buildLeave: linkedEdges
		].
	^self	
]

{ #category : #accessing }
PSLinkingNode >> children [
	^ children
]

{ #category : #accessing }
PSLinkingNode >> children: anObject [
	children := anObject
]

{ #category : #querying }
PSLinkingNode >> componentsFromJoin: join [
	"a join connects a chain to another connected component,
	it forms a new connected component that shares a vector chain
	with the component it connects to"
	| components joinchains comp currentNode|
	"self halt."
	components := OrderedCollection new.
	"first collect all chains of the join node"
	joinchains := join allChains "select:[]".
	joinchains do:[:jchain|
		|leaf|
		leaf := jchain last.
		self assert: leaf isLeaf.
		jchain removeFirst.
		leaf joins do:[:rootNode|
			comp := PSLinkingComponent new.
			jchain do:[:c| self addNodeValue: c to: comp ].
			"chain removeFirst."
			currentNode := join.
			[
				currentNode ifNotNil: [
					self addNodeValue: currentNode to: comp.
					currentNode = rootNode
				]
				ifNil: [ true ]
			] whileFalse: [currentNode := currentNode parent].
			currentNode ifNotNil:[
				comp chain size > 2 ifTrue:[
					comp chain: (self relink: comp chain).
				components add: comp]]].
	].
	^ components 
]

{ #category : #querying }
PSLinkingNode >> componentsFromLeaf: leaf [
|currentNode comp components|
components := OrderedCollection new.
leaf joins do:[:rootNode|
	currentNode := leaf.
	comp := PSLinkingComponent new.
	[
		currentNode ifNotNil: [
			self addNodeValue: currentNode  to: comp.
				currentNode = rootNode
		]
		ifNil: [ true ]
	] whileFalse: [currentNode := currentNode parent].
	currentNode ifNotNil:[
		comp chain size > 2 ifTrue:[
			comp chain: (self relink: comp chain).
			components add: comp]]].
	^ components 
]

{ #category : #'instance creation' }
PSLinkingNode >> from: anObject with: decisionHelper [
	"anObject could be an edge or and edge approximator"
	|colinearEdges linkedEdges|
	connected := false.
	colinearEdges := decisionHelper colinearTo: anObject.
	colinearEdges ifNil: [ ^nil ].
	nodeValue := colinearEdges.
	"find all possible child"
	linkedEdges := BTree order: 4.
	
	nodeValue segments do:[:seg|
		(decisionHelper linkedTo: seg) do:[:e|
			linkedEdges at: (PSEdgePriorityKey from: e baseline: nodeValue firstEdge )   put:e.
			 ].
		].
	"linkedEdges size >= 2 ifTrue:[
			linkedEdges asOrderedCollection asRenderableElement  inspect.
			self halt.
			]."
		
	children := OrderedCollection new.
	nodeValue visited: true.
	"linkedEdges asRenderableElement inspect.
	self halt."
	^ self buildTree: linkedEdges helper: decisionHelper 
	
]

{ #category : #testing }
PSLinkingNode >> hasAncestor: id [
	"nodeValue ifNil: [ ^false ]."
	(nodeValue hasId: id) ifTrue:[^ true].
	parent ifNil: [ ^false ].
	^ parent hasAncestor: id
]

{ #category : #initialization }
PSLinkingNode >> initialize [
	super initialize.
	children := BTree order: 4.
]

{ #category : #testing }
PSLinkingNode >> isConnected [
	children do: [ :e|
		e isConnected
			ifTrue:[^ true]	
	].
	^ false.
]

{ #category : #testing }
PSLinkingNode >> isJoin [
	^ false
]

{ #category : #testing }
PSLinkingNode >> isLeaf [
	^ false
]

{ #category : #testing }
PSLinkingNode >> isRoot [
	^ parent = nil
]

{ #category : #querying }
PSLinkingNode >> largestConnectedComponent [
	|components maxv comp|
	components := self allConnectedComponents.
	components ifEmpty: [ ^nil ].
	comp := components removeFirst.
	maxv := comp chain area.
	
	components do:[:e| |v|
		v := e chain area.
		 v > maxv ifTrue:[
			maxv := v.
			comp := e
		]
	].
	^ comp
]

{ #category : #querying }
PSLinkingNode >> leave [
	|collection|
	collection := OrderedCollection new.
	self children do:[ :c|
		((c isLeaf) or: (c isJoin ))
			ifTrue:[
				collection add: c]
			ifFalse:[
				c leave do:[:e| collection add: e]
			]
	].
	^ collection 
	
]

{ #category : #search }
PSLinkingNode >> lookDown:anId [
	|el|
	(nodeValue hasId: anId) ifTrue: [ ^self ].
	children do:[:e|
		el := e lookDown:anId.
		el ifNotNil: [ ^ el ]
	].
	^ nil
]

{ #category : #search }
PSLinkingNode >> lookFor: anId [
	|node|
	node := self lookDown: anId.
	node ifNotNil: [ ^self ].
	^ self lookUp: anId
]

{ #category : #search }
PSLinkingNode >> lookUp: anId [
	(nodeValue hasId: anId) ifTrue:[^self].
	parent ifNil: [ ^nil ].
	^parent lookUp: anId
]

{ #category : #querying }
PSLinkingNode >> myConnectedComponents [
	"search for all possible longest connected components start with this node"
	|candidates components currentNode chain|
	candidates := self leave select:[:e| e isConnectedTo: self nodeValue segments].
	components := OrderedCollection new.
	candidates do:[ :c|
		currentNode := c.
		chain := OrderedCollection new.
		[ 
			chain addFirst: currentNode nodeValue.
			(currentNode isNotNil) & ( currentNode ~= self )
		] whileTrue: [ 
				currentNode := currentNode parent.	
		].
		
		components add: chain
	].
	^ components
]

{ #category : #accessing }
PSLinkingNode >> nodeValue [
	^ nodeValue
]

{ #category : #accessing }
PSLinkingNode >> nodeValue: anObject [
	nodeValue := anObject
]

{ #category : #accessing }
PSLinkingNode >> parent [
	^ parent
]

{ #category : #accessing }
PSLinkingNode >> parent: anObject [
	parent := anObject.
	parent
		ifNil: [ root := self ]
		ifNotNil: [ root := parent root  ]
	
]

{ #category : #'as yet unclassified' }
PSLinkingNode >> relink: list [
	|polygon  newSeg seg prevSeg nextSeg pointA pointB aChain|
	aChain := list asDoublyConnectedEdgeList.
	polygon := VMPolygon new.
	aChain close.
	aChain linksDo:[:link|
		newSeg := VMLineSegment new.
		seg := link value value.
		prevSeg := link previousLink value value.
		nextSeg := link nextLink value value.
		newSeg type: seg type.
		prevSeg isObstacle
			ifTrue:[
				pointA := prevSeg pointB asPoint]
			ifFalse:[
				pointA := seg pointA asPoint].
		seg isObstacle
			ifTrue:[
				pointB := seg pointB asPoint]
			ifFalse:[
				pointB := nextSeg pointA asPoint].
		(pointA dist: pointB) > 0.000001 ifTrue:[
			newSeg pointA: pointA; pointB: pointB.
			polygon add: newSeg
		]
	].
	^ polygon 
]

{ #category : #accessing }
PSLinkingNode >> reset [
	nodeValue visited: false.
	children do:[:e| e reset]
]

{ #category : #querying }
PSLinkingNode >> root [
	^root
]
