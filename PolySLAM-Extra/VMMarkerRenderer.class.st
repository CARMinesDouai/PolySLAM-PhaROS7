Class {
	#name : #VMMarkerRenderer,
	#superclass : #VMBaseRenderer,
	#instVars : [
		'position'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #accessing }
VMMarkerRenderer >> position [
	^position.
]

{ #category : #accessing }
VMMarkerRenderer >> position: aPoint [
	position := aPoint.
]

{ #category : #rendering }
VMMarkerRenderer >> renderOn: aCanvas viewer: aVMViewer [

	position ifNil: [ ^self ].
	
	aCanvas pathTransform restoreAfter: [
		aCanvas pathTransform loadIdentity.
		self renderPoint: position radius: lineWidth*3 on: aCanvas color: color.
	].

]
