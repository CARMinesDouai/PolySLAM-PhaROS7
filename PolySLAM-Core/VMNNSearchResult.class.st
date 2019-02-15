"
This object carries the result of the nearest neighbor search from a VMNNCollection instance.


Public API and Key Messages

- object
	returns the point-like object that was found during the seach. returns nil if nothing was found.
	
- printString
	used for development and debugging mostly. returns a string with info about the search result.

- squareDist
	returns the squared distance from the point-like object and it's nearest neighbor (i.e. the search result). this method returns nil if no nearest neighbor was found.



"
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
