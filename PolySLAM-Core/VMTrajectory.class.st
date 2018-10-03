Class {
	#name : #VMTrajectory,
	#superclass : #Object,
	#instVars : [
		'collection'
	],
	#category : #'PolySLAM-Core-SLAM - Data Structures'
}

{ #category : #'rendering support' }
VMTrajectory class >> rendererClass [
	^VMTrajectoryRenderer.
]

{ #category : #'as yet unclassified' }
VMTrajectory >> add: aLocation [
	collection add: aLocation.
]

{ #category : #'as yet unclassified' }
VMTrajectory >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #'as yet unclassified' }
VMTrajectory >> collection [
	^collection.
]

{ #category : #'as yet unclassified' }
VMTrajectory >> initialize [
	collection := OrderedCollection new.
]
