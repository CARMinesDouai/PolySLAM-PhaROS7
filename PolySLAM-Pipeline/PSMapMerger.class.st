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
		helper perform.
		
		helper chains do:[:e| 
			((e isFrontier) & (e isCCW )) ifFalse:[ 
				newchains add:e]].
	].
	chains := newchains
]
