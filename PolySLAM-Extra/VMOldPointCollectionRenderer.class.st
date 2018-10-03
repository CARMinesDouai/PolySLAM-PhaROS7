Class {
	#name : #VMOldPointCollectionRenderer,
	#superclass : #VMFigureRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMOldPointCollectionRenderer >> renderOn: canvas [
	1 haltOnce.
	self renderOn: canvas pointCollection: model color: color label: label


]

{ #category : #'as yet unclassified' }
VMOldPointCollectionRenderer >> renderOn: canvas pointCollection: pointCollection color: renderColor label: aString [
	
	pointCollection ifNil: [ ^self. ].
	pointCollection ifEmpty: [ ^self. ].
	
	pointCollection do: [ :p |
		self renderPoint: p radius: lineWidth in: canvas color: renderColor.
	].

	self renderString: aString at: (pointCollection first) in: canvas color: renderColor.
	

]
