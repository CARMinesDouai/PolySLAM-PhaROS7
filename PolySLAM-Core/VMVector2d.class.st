"
this class is created for compatible purpose only
"
Class {
	#name : #VMVector2d,
	#superclass : #PMVector,
	#type : #variable,
	#category : #'PolySLAM-Core-LinAlgebra'
}

{ #category : #'as yet unclassified' }
VMVector2d class >> point: aPoint [
	^(self new: 2)
		at: 1 put: (aPoint x);
		at: 2 put: (aPoint y);
		yourself.
]
