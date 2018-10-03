Class {
	#name : #VMGraphBuilder,
	#superclass : #Object,
	#instVars : [
		'nodes'
	],
	#category : #'PolySLAM-Core-Collections, Trees & Graphs'
}

{ #category : #'as yet unclassified' }
VMGraphBuilder >> buildGraphFromBSPTree: aTreeRoot [
	
	self treeTraverse: aTreeRoot.
	^nodes
]

{ #category : #'as yet unclassified' }
VMGraphBuilder >> initialize [
	super initialize.
	nodes := VMGraph new.
]

{ #category : #'as yet unclassified' }
VMGraphBuilder >> treeTraverse: aNode [
	
	aNode isLeaf ifTrue: [
		| graphNode neighbors |
		graphNode := VMGraphNode sector: aNode sector.
		neighbors := aNode sectorNeighbors.
		graphNode neighbors addAll: neighbors.
		nodes add: graphNode.
		"Transcript show: 'tt: leaf, n=', neighbors size printString, ' nodes size=', nodes size printString; cr."
	] ifFalse: [
		"Transcript show: 'tt: node'; cr."
		self treeTraverse: aNode leftChild.
		self treeTraverse: aNode rightChild.
	].
]
