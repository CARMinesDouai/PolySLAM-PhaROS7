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
				chain := OrderedCollection new.
				[
					currentNode ifNotNil: [  
						chain addFirst: currentNode nodeValue.
						currentNode nodeValue hasId: rootIdx
					]
					ifNil: [ true ] 
				] whileFalse: [currentNode := currentNode parent].
				currentNode ifNotNil:[
					components add: chain]
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
	nodeValue := colinearEdges.
	"find all possible child"
	linkedEdges := (decisionHelper linkedTo: nodeValue lastEdge).
	children := BTree order: 4.
	nodeValue visited: true.
	linkedEdges  do:[:e| e visited = false ifTrue:[
		child := (PSLinkingNode from: e parent: self  with: decisionHelper ).
		child isConnected
			ifTrue:[
				children at: (PSEdgePriorityKey from: e)  put:  child.
				connected := true.
			]
	]].
	nodeValue visited: connected.
	children isEmpty
		ifTrue:[
			^ PSLinkingLeaf from: nodeValue parent: self parent with: (linkedEdges  collect:[:e| e id])]
	
	
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
