Class {
	#name : #PSLinkingNode,
	#superclass : #Object,
	#instVars : [
		'parent',
		'children',
		'nodeValue',
		'connected'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
PSLinkingNode class >> from: anEdge parent: aNode with: helper [
	^ (self new parent: aNode) from: anEdge with: helper 
]

{ #category : #querying }
PSLinkingNode >> allConnectedComponents [
	|components chain currentNode|
	"search for all connected component given my leaves"
	components := OrderedCollection new.
	self leave do:[:leaf|
		leaf isConnected ifTrue: [
			leaf connectedRoots do:[:rootIdx|
				currentNode := leaf.
				chain := VMPolygon new.
				[
					currentNode ifNotNil: [
						currentNode nodeValue class = PSEdgeApproximator
							ifTrue:[
								currentNode nodeValue approxChain reverseLinksDo:  [:e|
									chain addFirst: e value]						
							]
							ifFalse:[
								chain addFirst: currentNode nodeValue value  ] .
						currentNode nodeValue hasId: rootIdx
					]
					ifNil: [ true ] 
				] whileFalse: [currentNode := currentNode parent].
				currentNode ifNotNil:[
					chain size > 2 ifTrue:[
						components add: (self relink:chain)]]
			]
		]
	].
	
	^ components 
]

{ #category : #accessing }
PSLinkingNode >> children [
	^ children
]

{ #category : #accessing }
PSLinkingNode >> children: anObject [
	children := anObject
]

{ #category : #'instance creation' }
PSLinkingNode >> from: anObject with: decisionHelper [
	"anObject could be an edge or and edge approximator"
	|colinearEdges linkedEdges child|
	connected := false.
	colinearEdges := decisionHelper colinearTo: anObject.
	colinearEdges ifNil: [ ^nil ].
	nodeValue := colinearEdges.
	"find all possible child"
	linkedEdges := (decisionHelper linkedTo: nodeValue lastEdge).
	children := OrderedCollection new.
	nodeValue visited: true.
	"linkedEdges asRenderableElement inspect.
	self halt."
	linkedEdges  do:[:e| e visited ifFalse:[
		"(children isEmpty ) ifTrue: [ " 
			child := (PSLinkingNode from: e parent: self  with: decisionHelper).
			child ifNotNil: [  
				(child isConnected)
					ifTrue:[
						children add:  child.
						connected := true.
				]]]]"]".
	nodeValue visited: connected.
	children isEmpty
		ifTrue:[
			^ PSLinkingLeaf from: nodeValue parent: self parent with: (linkedEdges asOrderedCollection collect:[:e| e id])]
	
	
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
PSLinkingNode >> isLeaf [
	^ false
]

{ #category : #querying }
PSLinkingNode >> leave [
	|collection|
	collection := OrderedCollection new.
	self children do:[ :c|
		c isLeaf
			ifTrue:[
				collection add: c]
			ifFalse:[
				c leave do:[:e| collection add: e]
			]
	].
	^ collection 
	
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
	parent := anObject
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
