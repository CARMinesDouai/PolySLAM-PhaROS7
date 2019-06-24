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
PSMapMerger >> consume1: polygon [
	chains add: polygon.
	self merge
]

{ #category : #'as yet unclassified' }
PSMapMerger >> consume: polygon [
	|helper newchains components merged|
	chains ifNil: [ 
		chains := OrderedCollection new.
		chains add: polygon.
		^ self.	
	].
	merged := false.
	newchains := OrderedCollection new.
	chains do:[:chain|
		helper := PSLinkingTreeQuery from: chain and: polygon.

		helper perform.
		components := helper chains.
		
		components isEmpty
			ifTrue:[ newchains add: chain]
			ifFalse:[
				components do:[:comp|
					comp ifNotNil: [ newchains add: comp.
						merged := true ]]]
		
	].
	merged ifFalse: [ newchains add: polygon  ].
	"self merge."
	chains := newchains
]

{ #category : #initialization }
PSMapMerger >> initialize [
	super initialize.
	chains := nil.
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
				helper chains do:[:c|
					c area > 5e-4 ifTrue:[
						chains add:c]]]
			ifFalse:[
				chains add: pA; add: pB	
			].
		matrix := self makeMatrix 
	]
]
