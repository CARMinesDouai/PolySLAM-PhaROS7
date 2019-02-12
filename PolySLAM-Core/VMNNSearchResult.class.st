Class {
	#name : #VMNNSearchResult,
	#superclass : #Object,
	#instVars : [
		'object',
		'squareDist'
	],
	#category : #'PolySLAM-Core-Nearest Neighbor Search'
}

{ #category : #'as yet unclassified' }
VMNNSearchResult class >> object: obj squareDist: dist [
	^(self new)
		object: obj;
		squareDist: dist;
		yourself
]

{ #category : #converting }
VMNNSearchResult >> asRenderableElement [
	object ifNil: [ ^ nil ].
	^ self object asVMPoint asRenderableElement
]

{ #category : #accessing }
VMNNSearchResult >> object [
	^object
]

{ #category : #accessing }
VMNNSearchResult >> object: obj [
	object := obj.
]

{ #category : #printing }
VMNNSearchResult >> printString [
	^object printString, ' dist=', (squareDist sqrt) printString.
]

{ #category : #accessing }
VMNNSearchResult >> result [
	"an alias for #object to provide more semantic information"
	^object
]

{ #category : #accessing }
VMNNSearchResult >> squareDist [
	^squareDist.
]

{ #category : #accessing }
VMNNSearchResult >> squareDist: squareDistance [
	squareDist := squareDistance.
]
