Class {
	#name : #PSFrontierFilter,
	#superclass : #PSPolygonOperationHelper,
	#instVars : [
		'resolution',
		'edges'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #public }
PSFrontierFilter >> collapseSmallVectors [
	polygonA collapseEdges: resolution.
	polygonB collapseEdges: resolution.
]

{ #category : #accessing }
PSFrontierFilter >> edges [
	^ edges
]

{ #category : #public }
PSFrontierFilter >> filterFrontier [
	"Replace all frontier which is inside another polygon as sector"
	edges := OrderedCollection new.
	
	polygonA linksDo: [ :link|
		link value isFrontier ifTrue:[
			(polygonB isLineInside: link) ifTrue: [
				link value type: 3.
			] ifFalse:[
				edges add: link .	
			].
		]].
	polygonB linksDo: [ :link|
		link value isFrontier ifTrue:[
			(polygonA isLineInside: link) ifTrue: [
				link value type: 3
			] ifFalse:[
				edges add: link 
			]
		]].

]

{ #category : #initialization }
PSFrontierFilter >> initialize [
	super initialize.
	resolution := 0.1 "5cm"
]

{ #category : #public }
PSFrontierFilter >> perform [
	| helper|
	((polygonA isNil ) | (polygonB isNil )) ifTrue:[^self error: 'Please set the two input polygons'].
	"self collapseSmallVectors."
	helper := PSPolygonDecompositionHelper new.
	helper polygonA: polygonA.
	helper polygonB: polygonB.
	helper perform.
	"self collapseSmallVectors."
	"now we need to remove all frontier that is inside another polygon"
	self filterFrontier
]
