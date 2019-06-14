Class {
	#name : #PSLinkingTreeQuery,
	#superclass : #PSPolygonOperationHelper,
	#instVars : [
		'chains'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #accessing }
PSLinkingTreeQuery >> chains [
	^ chains
]

{ #category : #public }
PSLinkingTreeQuery >> perform [
	|collection idx helper disjoint visitedIds node comp|
	((polygonA isNil ) | (polygonB isNil )) ifTrue:[^self error: 'Please set the two input polygons'].
	helper := PSPolygonDecompositionHelper new.
	helper polygonA: polygonA.
	helper polygonB: polygonB.
	helper perform.
	disjoint := helper isDisjoint.
	" first calculate the intersetion point"
	"((polygonA isCCW) & (polygonB isCCW ) ) ifTrue:[isReversal := false]."
	"now create the adjacent matrix"
	collection := OrderedCollection new.
	idx := 1.
	polygonA linksDo:[:e| e id:idx. collection add:e. idx := idx +1.].
	polygonB linksDo:[:e| e id:idx. collection add:e. idx := idx +1].
	chains := OrderedCollection new.
	helper := PSInflateDecisionHelper from: collection.
	"collection asRenderableElement inspect."
	(disjoint & (helper isDisjoint )) ifTrue:[^ false].
	"collection asRenderableElement inspect."
	"tree add: (PSLinkingNode from: polygonB peak segments first parent: nil with: helper)."
	visitedIds := Set new.
	collection do:[:e|
		(visitedIds includes: e id)
			ifFalse:[
				node := PSLinkingNode from: e parent: nil  with: helper.
				node
					ifNotNil: [ 
						"node allConnectedComponents inspect.
						self halt."
						comp := node largestConnectedComponent.
						comp ifNil: [ 
							visitedIds add: e id
						] ifNotNil: 
						[
							comp indices do:[:i| visitedIds add: i].
							chains add: comp chain.
						]
					]
					ifNil: [ visitedIds add: e id]
			
		].
		self reset: collection  with: visitedIds 
	].
	chains ifEmpty: [ ^ false ].
	^ true
	
]

{ #category : #public }
PSLinkingTreeQuery >> reset: collection with:  indices [
	collection do:[:e|
		(collection at: e id) visited: (indices includes:  e id)	
	].
]
