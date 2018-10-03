Class {
	#name : #VMSectorRenderer,
	#superclass : #VMPolygonRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMSectorRenderer >> renderOn: aCanvas viewer: aViewer [
	lineWidth := 0.02.
	self renderFilledPolygonOn: aCanvas collection: model color: color
]
