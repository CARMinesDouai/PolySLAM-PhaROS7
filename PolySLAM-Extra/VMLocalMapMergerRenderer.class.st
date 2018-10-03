Class {
	#name : #VMLocalMapMergerRenderer,
	#superclass : #VMElementRenderer,
	#instVars : [
		'infoRenderCollection'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMLocalMapMergerRenderer >> initialize [
	super initialize.
	
	showLabel := false.

]

{ #category : #'as yet unclassified' }
VMLocalMapMergerRenderer >> model: aModel [
	super model: aModel.
	
	infoRenderCollection := model infoCollection collect: [ :infoObj | infoObj asRenderableElement. ].
	

]

{ #category : #'as yet unclassified' }
VMLocalMapMergerRenderer >> renderOn: canvas [

	infoRenderCollection do: [ :renderObj |
		renderObj renderOn: canvas tf: (model frame).
	].

	super renderOn: canvas.
]
