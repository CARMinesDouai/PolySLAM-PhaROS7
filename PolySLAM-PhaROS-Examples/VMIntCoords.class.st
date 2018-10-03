"
This class represents the indices of a two-dimensional array-like structure.


Public API and Key Messages

- x
	accessor, returns the index for the x-axis
- x: <aNumber>
	accessor, sets the x index to aNumber as integer
- y
	accessor, returns the index for the y-axis
- y: <aNumber>
	accessor, sets the y index to aNumber as integer
- setTo: <VMIntCoords instance>
	sets this instance to have the same coordinates as the provided argument

"
Class {
	#name : #VMIntCoords,
	#superclass : #Object,
	#instVars : [
		'x',
		'y'
	],
	#category : #'PolySLAM-PhaROS-Examples-Helper'
}

{ #category : #'as yet unclassified' }
VMIntCoords class >> x: x y: y [
	^self new
		x: x;
		y: y;
		yourself.
]

{ #category : #modify }
VMIntCoords >> decX [
	x := x - 1.
]

{ #category : #modify }
VMIntCoords >> decY [
	y := y - 1.
]

{ #category : #modify }
VMIntCoords >> incX [
	x := x + 1.
]

{ #category : #modify }
VMIntCoords >> incY [
	y := y + 1.
]

{ #category : #modify }
VMIntCoords >> setTo: intCoords [
	x := intCoords x.
	y := intCoords y.
]

{ #category : #accessing }
VMIntCoords >> x [
	^x.
]

{ #category : #accessing }
VMIntCoords >> x: anInteger [
	x := anInteger asInteger.
]

{ #category : #accessing }
VMIntCoords >> y [
	^y.
]

{ #category : #accessing }
VMIntCoords >> y: anInteger [
	y := anInteger asInteger.
]
