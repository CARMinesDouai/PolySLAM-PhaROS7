"
This class represents a topological graph, that links sectors/polygons.


This class is derived from the Set class. The nodes are directly stored in the Set, and accessable through the usual functions. The edges of the graph are stored inside the nodes, in the 'neighbors' collection.

note, that the hash of the sector/polygon is used as key, and that two notes that contain the same polygon are considered equal in this regard as well.


Public API and Key Messages
	- asRenderableElement
		returns a class instance that can be rendered by VMViewer
	
	- atSector: <VMPolygon>
		returns the node that contains the provided polygon. the polygon only needs to be equal, not identical.
	
	- bounds
		returns the geometric size (as a Rectangle instance) of the graph. used when rendering the graph with
		autozoom enabled.
		
"
Class {
	#name : #VMGraph,
	#superclass : #Set,
	#category : #'PolySLAM-Core-Top. Graph'
}

{ #category : #'rendering support' }
VMGraph class >> rendererClass [
	^VMGraphRenderer
]

{ #category : #converting }
VMGraph >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #converting }
VMGraph >> asVMGraph [
	^ self
]

{ #category : #accessing }
VMGraph >> atSector: aPolygon [
	| index start |
	index := start := aPolygon hash \\ array size + 1.
	[ 
		| element |
		((element := array at: index) == nil) ifTrue: [ self error: 'not found'. ^ nil ].
		(element enclosedSetElement sector = aPolygon) ifTrue: [ ^ array at: index ].
		(index := index \\ array size + 1) = start ] whileFalse.
	
	self errorNoFreeSpace
]

{ #category : #accessing }
VMGraph >> bounds [
	| rect anyOne |
	
	self ifEmpty: [ ^nil ].
	anyOne := self anyOne.
	rect := Rectangle origin: anyOne center corner: anyOne center.
	
	self do: [ :node |
		rect := rect encompass: node center.
	].

	^ rect

]

{ #category : #'as yet unclassified' }
VMGraph >> checkEdges [
	"this method ensures that all edges are bidirectional. this should be already the case,
	but for some unkown reasons (ie a bug in the code) this is currently not the case."
	| errorCounter |
	errorCounter := 0.
	
	self do: [ :node |
		node neighbors do: [ :neighbor |
			(neighbor neighbors includes: node)
				ifFalse: [
					neighbor neighbors add: node.
					errorCounter := errorCounter + 1.] ]. ].
	
	Transcript show: 'missing edges added=', errorCounter printString; cr.
]
