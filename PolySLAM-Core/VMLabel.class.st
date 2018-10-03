Class {
	#name : #VMLabel,
	#superclass : #Object,
	#instVars : [
		'text',
		'bounds',
		'color'
	],
	#category : #'PolySLAM-Core-temp'
}

{ #category : #'as yet unclassified' }
VMLabel class >> label: aString at: aPoint [
	^(self new)
		label: aString;
		bounds: (aPoint extent: 1@1);
		yourself
]

{ #category : #'as yet unclassified' }
VMLabel class >> text: aString at: aPoint [
	^(self new)
		label: aString;
		bounds: (aPoint extent: 1@1);
		yourself
]

{ #category : #accessing }
VMLabel >> bounds [
	^bounds
]

{ #category : #accessing }
VMLabel >> bounds: aRectangle [
	bounds := aRectangle.
]

{ #category : #accessing }
VMLabel >> color [
	^ color
]

{ #category : #accessing }
VMLabel >> color: aColor [
	color := aColor
]

{ #category : #initialization }
VMLabel >> initialize [
	text := ''.
	bounds := 0@0 extent: 1@1.
	color := Color red.
]

{ #category : #accessing }
VMLabel >> label [
	^text
]

{ #category : #accessing }
VMLabel >> label: aString [
	text := aString.
]
