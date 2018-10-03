Class {
	#name : #VMMap,
	#superclass : #Object,
	#instVars : [
		'polygonCollection'
	],
	#category : #'PolySLAM-Core-temp'
}

{ #category : #'rendering support' }
VMMap class >> rendererClass [
	^VMMapRenderer.
]

{ #category : #'rendering support' }
VMMap >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #accessing }
VMMap >> bounds [
	| rect |
	polygonCollection ifEmpty: [ ^VMRectangle origin: 0@0 corner: 0@0 ].
	
	rect := polygonCollection first bounds.
	polygonCollection allButFirstDo: [ :element |
		rect := rect merge: element bounds.
	].
	
	^rect

]

{ #category : #initialization }
VMMap >> initialize [
	polygonCollection := VMPolygonCollection new.
]

{ #category : #accessing }
VMMap >> polygons [
	^polygonCollection.
]

{ #category : #accessing }
VMMap >> polygons: aVMPolygonCollection [
	polygonCollection := aVMPolygonCollection asVMPolygonCollection.
]

{ #category : #'rendering support' }
VMMap >> rendererClass [
	^VMMapRenderer.
]
