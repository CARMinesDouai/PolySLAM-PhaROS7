Class {
	#name : #PSEdgePartitioner,
	#superclass : #Object,
	#instVars : [
		'inlierTh',
		'approxChains'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #accessing }
PSEdgePartitioner >> approxChains [
	^ approxChains
]

{ #category : #accessing }
PSEdgePartitioner >> approxChains: anObject [
	approxChains := anObject
]

{ #category : #initialization }
PSEdgePartitioner >> initialize [
	super initialize.
	inlierTh := 0.02 "2cm"
]

{ #category : #accessing }
PSEdgePartitioner >> inlierTh [
	^ inlierTh
]

{ #category : #accessing }
PSEdgePartitioner >> inlierTh: anObject [
	inlierTh := anObject
]

{ #category : #clustering }
PSEdgePartitioner >> partition: aPolygon [
	|chain|
	chain := aPolygon asDoublyConnectedEdgeList.
	
	chain type = 4 ifTrue:[
		"single type chain"
		^ self partitionUniformChain: chain	
	].
	"mixte type chain, then cut the chain to multiple chain"
]

{ #category : #clustering }
PSEdgePartitioner >> partitionUniformChain: chain [	
	|link|
	"find the peak of the chain"
	link := chain firstLink.
	[
		
	]
]
