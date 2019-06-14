Class {
	#name : #PSMapMerger,
	#superclass : #Object,
	#instVars : [
		'chains'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #accessing }
PSMapMerger >> chains [
	^ chains
]

{ #category : #'as yet unclassified' }
PSMapMerger >> consume: polygon [
	chains add: polygon.
	self merge
]

{ #category : #initialization }
PSMapMerger >> initialize [
	super initialize.
	chains := OrderedCollection new.
]

{ #category : #actions }
PSMapMerger >> makeMatrix [
	^PSPolygonOverlapMatrix from: chains
]

{ #category : #actions }
PSMapMerger >> merge [
	|matrix pair pA pB helper exclusive|
	matrix := self makeMatrix.
	[
		pair := matrix nextPair.
		pair isNil
	] whileFalse: [ 
		pA := chains at: pair x.
		pB := chains at: pair y.
		chains remove: pA.
		chains remove: pB.
		helper := PSLinkingTreeQuery from:pA and: pB.
		helper perform
			ifTrue:[
				helper chains do:[:c| chains add:c]]
			"ifFalse:[
				chains add: pA; add: pB	
			]".
		matrix := self makeMatrix 
	]
]
