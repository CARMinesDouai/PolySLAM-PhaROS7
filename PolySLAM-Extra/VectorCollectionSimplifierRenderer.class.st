Class {
	#name : #VectorCollectionSimplifierRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VectorCollectionSimplifierRenderer >> bounds [
	^self boundsForCollection: model input.
]

{ #category : #'as yet unclassified' }
VectorCollectionSimplifierRenderer >> renderOn: aCanvas [
	model ifNil: [ ^self ].
	
	"render original input"
	model input asRenderableElement lineWidth: lineWidth; renderOn: aCanvas.
	
	"render result's vector collection & line"
	model resultCollection doWithIndex: [ :result :index |
		| vectors |
		vectors := result vectorCollection.
		"(VMLineSegCollectionRenderer new model: vectors) lineWidth: lineWidth / 2; color: (Color byInteger: index); renderOn: aCanvas."
		
		self renderArrow: result computeVector on: aCanvas color: Color white.
		"result line asRenderableElement lineWidth: lineWidth; color: (Color byInteger: index); renderOn: aCanvas."
	].
	

]
