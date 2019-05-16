Class {
	#name : #VMFittingResultRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMFittingResultRenderer >> bounds [
	^ model line bounds merge: (self boundsForCollection: model vectorCollection)
]

{ #category : #'as yet unclassified' }
VMFittingResultRenderer >> renderOn: aCanvas [
	
	"inliers"
	(VMLineSegCollectionRenderer new model: model vectorCollection) lineWidth: lineWidth ; color: color; renderOn: aCanvas.
	
	"model (i.e. line)"
	model line asRenderableElement color: color; lineWidth: lineWidth; renderOn: aCanvas.

]
