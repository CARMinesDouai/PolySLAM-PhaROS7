Class {
	#name : #VMVectorCollectionSimplifierOld,
	#superclass : #VMVectorCollectionSimplifier,
	#category : #'PolySLAM-Core-Line- & Vector Approximation'
}

{ #category : #'as yet unclassified' }
VMVectorCollectionSimplifierOld class >> compute: input [
	^(self new)
		compute: input;
		yourself
]

{ #category : #'as yet unclassified' }
VMVectorCollectionSimplifierOld class >> compute: input inlierThreshold: threshold [
	^(self new)
		inlierThreshold: threshold;
		compute: input;
		yourself
]

{ #category : #'rendering support' }
VMVectorCollectionSimplifierOld class >> rendererClass [
	^ VectorCollectionSimplifierRenderer
]

{ #category : #'basic algorithm' }
VMVectorCollectionSimplifierOld >> loopOverChain: vectorChain [
	| startIndex fittingResult |
	startIndex := 1.
	
	"debugging"
	"resultCollection size >= 58 ifTrue: [1 halt]."
	
	"initial run with full length"
	fittingResult := (VMLineFitterOld new) inlierThreshold: inlierThreshold;
		compute: vectorChain startVector: vectorChain first.
	startIndex := startIndex + fittingResult vectorCollection size.
	resultCollection add: fittingResult.
	
	"if the line fitting does not include all vectors from the chain, we continue with the remaining vectors until all are covered"
	[startIndex <= vectorChain size] whileTrue: [
		fittingResult := (VMLineFitterOld new) inlierThreshold: inlierThreshold;
			compute: (vectorChain collect: [:v|v] from: startIndex to: vectorChain size) startVector: (vectorChain at: startIndex).
		startIndex := startIndex + fittingResult vectorCollection size.
		resultCollection add: fittingResult.
	].

]
