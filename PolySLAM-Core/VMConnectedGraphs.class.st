"
This class seperates a graph into connected graphs, i.e. splits a graph into parts that are connected/reachable.


Public API and Key Messages

- compute: <VMGraph>
	answers with an OrderedCollection of connected graphs (VMGraph instances). if the original graph is already connected,
	the OrderedCollection instance will contain only a single graph. all returned graphs are (shallow) copies, the
	original graph is not modified.
"
Class {
	#name : #VMConnectedGraphs,
	#superclass : #Object,
	#category : #'PolySLAM-Core-Top. Graph'
}

{ #category : #public }
VMConnectedGraphs class >> compute: aGraph [
	^self new compute: aGraph
]

{ #category : #public }
VMConnectedGraphs >> compute: aGraph [
	| newGraph remainder result |
	newGraph := IdentitySet new.
	remainder := IdentitySet new.
	result := OrderedCollection new.
	
	self traverse: aGraph anyOne newGraph: newGraph.
	aGraph do: [ :node |
		(newGraph includes: node) ifFalse: [ remainder add: node. ]. ].
	
	result add: newGraph asVMGraph.
	Transcript show: 'remainder size=', remainder size printString; cr.
	remainder ifNotEmpty: [ result addAll: (self compute: remainder). ].
	
	"sort by size, largest graph first"
	result sort: [ :a :b | a size > b size ].
	
	^ result

]

{ #category : #'as yet unclassified' }
VMConnectedGraphs >> traverse: aNode newGraph: newGraph [
	newGraph add: aNode.
	aNode neighbors do: [ :n |
		(newGraph includes: n) ifFalse: [self traverse: n newGraph: newGraph.]. ].
]
