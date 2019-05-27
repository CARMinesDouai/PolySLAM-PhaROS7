Class {
	#name : #PSZonePartitioner,
	#superclass : #PSPTMHelper,
	#instVars : [
		'isReversal',
		'helper'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #initialization }
PSZonePartitioner >> initialize [
	super initialize.
	isReversal := false.
	helper := PSPolygonDecompositionHelper new.
]

{ #category : #public }
PSZonePartitioner >> mergeEdge: link using: cmatrix and: lmatrix [
	
	
]

{ #category : #public }
PSZonePartitioner >> perform [
	|collection cmatrix lmatrix idx|
	((polygonA isNil ) | (polygonB isNil )) ifTrue:[^self error: 'Please set the two input polygons'].
	helper polygonA: polygonA.
	helper polygonB: polygonB.
	helper perform.
	" first calculate the intersetion point"
	((polygonA isCCW) & (polygonB isCCW ) ) ifTrue:[isReversal := false].
	"now create the adjacent matrix"
	collection := OrderedCollection new.
	idx := 1.
	polygonA linksDo:[:e|
		e id:idx.
		collection add:e.
		idx := idx +1.
		"e asPSVertices do:[:v| Q at: (PSVertexKeyY from:v) put: v ]"].
	polygonB linksDo:[:e| e id:idx. collection add:e. idx := idx +1.].
	collection asRenderableElement inspect.
	cmatrix := PSAdjacencyMatrix fromLines: collection probabilityHelper: PSInflateOverlapProbability.
	cmatrix := cmatrix binaryAdjacencyMatrix makeSymetric.
	lmatrix := PSAdjacencyMatrix fromLines: collection probabilityHelper: PSInflateLinkingProbability.
	"merge all segments of A to B one by one"
	polygonB linksDo:[ :link|
			self mergeEdge: link using: cmatrix and: lmatrix
	].
	
]
