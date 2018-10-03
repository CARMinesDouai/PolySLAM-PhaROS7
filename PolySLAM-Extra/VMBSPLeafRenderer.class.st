Class {
	#name : #VMBSPLeafRenderer,
	#superclass : #VMBaseRenderer,
	#instVars : [
		'renderSectorBorder'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMBSPLeafRenderer >> initialize [
	super initialize.
	renderSectorBorder := true.
]

{ #category : #'as yet unclassified' }
VMBSPLeafRenderer >> renderOn: aCanvas [
	model sector ifNotNil: [
		(model sector asRenderableElement)
			renderSectorBorder: renderSectorBorder;
			renderOn: aCanvas.
	].

]

{ #category : #'as yet unclassified' }
VMBSPLeafRenderer >> renderOn: aCanvas viewer: aViewer [
	model sector ifNotNil: [
		(model sector asRenderableElement)
			renderSectorBorder: renderSectorBorder;
			renderOn: aCanvas viewer: aViewer.
	].

]

{ #category : #'as yet unclassified' }
VMBSPLeafRenderer >> renderSectorBorder [
	^renderSectorBorder
]

{ #category : #'as yet unclassified' }
VMBSPLeafRenderer >> renderSectorBorder: aBoolean [
	renderSectorBorder := aBoolean
]
