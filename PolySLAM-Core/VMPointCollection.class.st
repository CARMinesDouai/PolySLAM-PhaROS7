Class {
	#name : #VMPointCollection,
	#superclass : #OrderedCollection,
	#instVars : [
		'collection'
	],
	#category : #'PolySLAM-Core-Collections, Trees & Graphs'
}

{ #category : #'as yet unclassified' }
VMPointCollection class >> rendererClass [
	^VMNNCollectionRenderer
]

{ #category : #adding }
VMPointCollection >> add: aPoint [
	super add: aPoint.
]

{ #category : #adding }
VMPointCollection >> addAll: aCollection [
	super addAll: aCollection.
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
