Class {
	#name : #PSLinkedTree,
	#superclass : #PSPolygonOperationHelper,
	#instVars : [
		'tree'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #public }
PSLinkedTree >> perform [
	|collection idx helper|
	((polygonA isNil ) | (polygonB isNil )) ifTrue:[^self error: 'Please set the two input polygons'].
	helper := PSPolygonDecompositionHelper new.
	helper polygonA: polygonA.
	helper polygonB: polygonB.
	helper perform.
	" first calculate the intersetion point"
	"((polygonA isCCW) & (polygonB isCCW ) ) ifTrue:[isReversal := false]."
	"now create the adjacent matrix"
	collection := OrderedCollection new.
	idx := 1.
	polygonA linksDo:[:e| e id:idx. collection add:e. idx := idx +1].
	polygonB linksDo:[:e| e id:idx. collection add:e. idx := idx +1].
	tree := OrderedCollection new.
	helper := PSInflateDecisionHelper from: collection.
	collection do:[:e|
		e visited ifFalse:[
			tree add: (PSLinkingNode from: e parent: nil  with: helper )
		]
	].

	(tree collect:[:e| e allConnectedComponents ]) inspect.
	
]

{ #category : #accessing }
PSLinkedTree >> tree [
	^tree
]
