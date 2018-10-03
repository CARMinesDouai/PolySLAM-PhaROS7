Class {
	#name : #VMPointCollectionRenderer,
	#superclass : #VMCollectionRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMPointCollectionRenderer >> bounds [
	| rect |
	
	model ifEmpty: [ ^ nil ].
	
	rect := Rectangle origin: model first corner: model first.
	model do: [ :aPoint |
		rect := rect encompass: aPoint.
	].
	
	^rect

]

{ #category : #rendering }
VMPointCollectionRenderer >> renderOn: aCanvas [
	| collection |
	collection := self model.
	
	"Transcript show: self class printString, ' collection size=', collection size printString; cr."
	collection do: [ :aPoint |
		self renderPoint: aPoint radius: 2*lineWidth on: aCanvas color: color.
	].

]
