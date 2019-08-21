Class {
	#name : #PSIntersectionFilter,
	#superclass : #PSPolygonOperationHelper,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #public }
PSIntersectionFilter >> filterFrontier [
	|collection|
	"Replace all frontier which is inside another polygon as sector"
	collection := OrderedCollection new.
	polygonA linksDo: [ :link|
		link value isFrontier ifTrue:[
			(polygonB isLineInside: link) ifTrue: [
				link value type: 3
			].
			collection add: link value.
		]].
	polygonB linksDo: [ :link|
		link value isFrontier ifTrue:[
			(polygonA isLineInside: link) ifTrue: [
				link value type: 3
			].
			collection add: link value
		]].
	
	collection asRenderableElement inspect.
	self halt
	

]

{ #category : #public }
PSIntersectionFilter >> perform [
	| helper|
	((polygonA isNil ) | (polygonB isNil )) ifTrue:[^self error: 'Please set the two input polygons'].
	helper := PSPolygonDecompositionHelper new.
	helper polygonA: polygonA.
	helper polygonB: polygonB.
	helper perform.
	"now we need to remove all frontier that is inside another polygon"
	self filterFrontier
]
