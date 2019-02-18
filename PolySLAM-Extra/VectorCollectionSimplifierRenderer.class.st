Class {
	#name : #VectorCollectionSimplifierRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #accessing }
VectorCollectionSimplifierRenderer >> bounds [
	^self boundsForCollection: model input.
]

{ #category : #rendering }
VectorCollectionSimplifierRenderer >> renderOn: aCanvas [
	model ifNil: [ ^self ].
	
	"render original input (polygon)"
	model input asRenderableElement lineWidth: lineWidth / 2; renderOn: aCanvas.
	
	"render original input (points)"
	(VMPointCollectionRenderer new model: model input asPointCollection) lineWidth: lineWidth / 20; color: Color black; renderOn: aCanvas.
	
	"render result's vector collection & line"
	(VMLineSegCollectionRenderer new model: model result) lineWidth: lineWidth / 8; color: (Color lightGray); renderOn: aCanvas.
	

]
