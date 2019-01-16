"
This class is an extension to a normal OrderedCollection that provides to key methods:
	#asRenderableElement 
		allows to visualize this collection of points with the VMViewer
	#transform: <VMTFMatrix>
		returns a copy of self with the provided transformation applied to all points
"
Class {
	#name : #VMPointCollection,
	#superclass : #OrderedCollection,
	#instVars : [
		'collection'
	],
	#category : #'PolySLAM-Core-Collections'
}

{ #category : #'as yet unclassified' }
VMPointCollection class >> rendererClass [
	^VMNNCollectionRenderer
]

{ #category : #converting }
VMPointCollection >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #converting }
VMPointCollection >> asVMPointCollection [
	^ self
]

{ #category : #accessing }
VMPointCollection >> collection [
	^ self
]

{ #category : #accessing }
VMPointCollection >> transform: aVMTFMatrix [
	^ self collect: [ :point | point transform: aVMTFMatrix ].
	

]
