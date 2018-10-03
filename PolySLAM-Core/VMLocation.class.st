Class {
	#name : #VMLocation,
	#superclass : #Object,
	#instVars : [
		'frame',
		'timestamp'
	],
	#category : #'PolySLAM-Core-SLAM - Data Structures'
}

{ #category : #constructor }
VMLocation class >> frame: aFrame timestamp: aTimestamp [
	^(self new)
		frame: aFrame;
		timestamp: aTimestamp;
		yourself.
]

{ #category : #'rendering support' }
VMLocation class >> rendererClass [
	^VMLocationRenderer.
]

{ #category : #'as yet unclassified' }
VMLocation >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #accessing }
VMLocation >> frame [
	^frame.
]

{ #category : #accessing }
VMLocation >> frame: aFrame [
	frame := aFrame.

]

{ #category : #accessing }
VMLocation >> timestamp [
	^timestamp.

]

{ #category : #accessing }
VMLocation >> timestamp: aTimestamp [
	timestamp := aTimestamp.

]
