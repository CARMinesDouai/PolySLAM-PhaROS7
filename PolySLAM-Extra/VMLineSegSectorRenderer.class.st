Class {
	#name : #VMLineSegSectorRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMLineSegSectorRenderer >> renderOn: aCanvas viewer: aViewer [
	
	self renderFilledPolygonOn: aCanvas lineSegments: model color: Color orange.
	

]
