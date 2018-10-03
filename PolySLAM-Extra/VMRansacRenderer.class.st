Class {
	#name : #VMRansacRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMRansacRenderer >> bounds [

	model ifNil: [ ^nil ].
	
	^((self collectionBounds: model inlier) merge:
		(self collectionBounds: model outlier)) merge:
		(self collectionBounds: model ignored)
]

{ #category : #rendering }
VMRansacRenderer >> renderOn: aCanvas [
	model ifNil: [ ^self. ].
	
	lineWidth := 0.005.
	
	model model ifNotNil: [ (model model asRenderableElement) lineWidth: lineWidth; color: Color green; renderOn: aCanvas ].
	
	model refinedModel ifNotNil: [ (model refinedModel asRenderableElement) lineWidth: lineWidth; color: Color orange; renderOn: aCanvas ].
	
	model outlier do: [ :vec |
		self renderArrow: vec on: aCanvas color: Color red
	].

	model inlier do: [ :vec |
		self renderArrow: vec on: aCanvas color: Color blue
	].

	model ignored do: [ :vec |
		self renderArrow: vec on: aCanvas color: Color pink
	].
]
