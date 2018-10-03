Class {
	#name : #VMGridRenderer,
	#superclass : #VMBaseRenderer,
	#instVars : [
		'increment'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #accessing }
VMGridRenderer >> bounds [
	^nil
]

{ #category : #accessing }
VMGridRenderer >> increment: aNumber [
	increment := aNumber
]

{ #category : #initialization }
VMGridRenderer >> initialize [
	super initialize.
	
	increment := 1.0.
	lineWidth := 0.02.
	color := Color black.
]

{ #category : #rendering }
VMGridRenderer >> renderOn: aCanvas [
	| viewport top bottom left right |
	
	viewport := (self viewport: aCanvas) flipY.
	
	top := (viewport top - 1) floor.
	bottom := (viewport bottom + 1) ceiling.
	left := (viewport left - 1) floor.
	right := (viewport right + 1) ceiling.
	
	top to: bottom by: increment do: [ :yCoord |
		self renderStyledLineSegFrom: (left @ yCoord) to: (right @ yCoord) on: aCanvas color: self color.
	].
	
	left to: right by: increment do: [ :xCoord |
		self renderStyledLineSegFrom: (xCoord @ top) to: (xCoord @ bottom) on: aCanvas color: self color.
	].

]

{ #category : #rendering }
VMGridRenderer >> renderOn: aCanvas viewer: aViewer [
	self renderOn: aCanvas

]
