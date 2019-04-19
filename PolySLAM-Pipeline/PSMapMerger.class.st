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
	|helper newchains|
	chains ifNil: [ 
		chains := OrderedCollection new.
		chains add: polygon.
		^ self.	
	].
	newchains := OrderedCollection new.
	chains do:[:chain|
		helper := PSPolygonMergingHelper merge: chain with: polygon.
		helper merge do:[:e| newchains add:e].
	].
	chains := newchains
]
