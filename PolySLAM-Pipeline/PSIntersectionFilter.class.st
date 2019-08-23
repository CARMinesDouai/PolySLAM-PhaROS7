Class {
	#name : #PSIntersectionFilter,
	#superclass : #PSPolygonOperationHelper,
	#instVars : [
		'resolution'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #public }
PSIntersectionFilter >> collapseSmallVectors [
	polygonA collapseEdges: resolution.
	polygonB collapseEdges: resolution.
]

{ #category : #public }
PSIntersectionFilter >> filterFrontier [
	|collection ignore|
	"Replace all frontier which is inside another polygon as sector"
	collection := OrderedCollection new.
	
	polygonA linksDo: [ :link|
		ignore := false.
		link value isFrontier ifTrue:[
			(polygonB isLineInside: link) ifTrue: [
				link value type: 3.
				ignore := true
			].
		].
	ignore ifFalse:[ 
	collection add: link value.]].
	polygonB linksDo: [ :link|
		ignore := false.
		link value isFrontier ifTrue:[
			(polygonA isLineInside: link) ifTrue: [
				link value type: 3.
				ignore := true.
			].
		].
		ignore ifFalse: [  
		collection add: link value]].
	
	collection asRenderableElement inspect.
	"self halt"
	

]

{ #category : #initialization }
PSIntersectionFilter >> initialize [
	super initialize.
	resolution := 0.05 "5cm"
]

{ #category : #public }
PSIntersectionFilter >> perform [
	| helper|
	((polygonA isNil ) | (polygonB isNil )) ifTrue:[^self error: 'Please set the two input polygons'].
	self collapseSmallVectors.
	helper := PSPolygonDecompositionHelper new.
	helper polygonA: polygonA.
	helper polygonB: polygonB.
	self collapseSmallVectors.
	helper perform.
	"now we need to remove all frontier that is inside another polygon"
	self filterFrontier
]
