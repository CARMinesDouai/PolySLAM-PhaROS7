Class {
	#name : #VMRansacResultRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMRansacResultRenderer >> bounds [
	^ model line bounds merge: (self boundsForCollection: model vectorCollection)
]

{ #category : #'as yet unclassified' }
VMRansacResultRenderer >> renderOn: aCanvas [
	
	"inliers"
	(VMLineSegCollectionRenderer new model: model vectorCollection) lineWidth: lineWidth ; color: color; renderOn: aCanvas.
	
	"model (i.e. line)"
	model line asRenderableElement color: color; lineWidth: lineWidth; renderOn: aCanvas.

]
