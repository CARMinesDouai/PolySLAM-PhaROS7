Class {
	#name : #VMPointRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMPointRenderer >> renderOn: aCanvas [
	self renderPoint: self model radius: lineWidth on: aCanvas color: color.
]
