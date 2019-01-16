"
The VMMap class represents a map that consists of multiple polygons. As such it is pretty much only a storage class, and used to transfer maps (e.g. between ROS nodes)

"
Class {
	#name : #VMMap,
	#superclass : #Object,
	#instVars : [
		'polygonCollection'
	],
	#category : #'PolySLAM-Core-SLAM - Maps'
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
