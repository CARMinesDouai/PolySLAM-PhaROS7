Class {
	#name : #VMKeyFrameCollection,
	#superclass : #Object,
	#instVars : [
		'collection'
	],
	#category : #'PolySLAM-Core-SLAM - Data Structures'
}

{ #category : #'rendering support' }
VMKeyFrameCollection class >> rendererClass [
	^VMKeyFrameCollectionRenderer.
]

{ #category : #adding }
VMKeyFrameCollection >> add: keyFrame [
	collection add: keyFrame.
]

{ #category : #'as yet unclassified' }
VMKeyFrameCollection >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #accessing }
VMKeyFrameCollection >> collection [
	^collection.
]

{ #category : #initialization }
VMKeyFrameCollection >> initialize [
	collection := OrderedCollection new.
]
