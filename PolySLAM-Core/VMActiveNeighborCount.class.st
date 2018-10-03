"
VMActiveNeighborCount

This class is used to memorize how many edges (connections) of a vertex are currently used.

The polygon creation process in VMPolygonFactory and related classes are using this to keep track of the neighbors in use.

"
Class {
	#name : #VMActiveNeighborCount,
	#superclass : #Object,
	#instVars : [
		'dictionary'
	],
	#category : #'PolySLAM-Core-kernel'
}

{ #category : #accessing }
VMActiveNeighborCount >> at: aVertex [
	dictionary at: aVertex
		ifPresent: [ :value |
			^value.
		] ifAbsent: [
			^0.
		].
]

{ #category : #accessing }
VMActiveNeighborCount >> at: aVertex add: aNumber [
	dictionary at: aVertex
		ifPresent: [ :value |
			dictionary at: aVertex put: (value + aNumber).
		] ifAbsent: [
			dictionary at: aVertex put: aNumber.
		].
]

{ #category : #enumerating }
VMActiveNeighborCount >> do: aBlock [
	dictionary do: [ :value |
		aBlock value: value.
	].
]

{ #category : #accessing }
VMActiveNeighborCount >> freeNeighborsCount: aVertex [
	^(aVertex neighbors size) - (self at: aVertex).
]

{ #category : #initialization }
VMActiveNeighborCount >> initialize [
	dictionary := Dictionary new.
]

{ #category : #enumerating }
VMActiveNeighborCount >> keysDo: aBlock [
	dictionary keysDo: [ :vertex |
		aBlock value: vertex.
	].
]

{ #category : #'as yet unclassified' }
VMActiveNeighborCount >> printDebug [
	Transcript
		show: self class name asString;
		cr.
	dictionary keysDo: [ :vertex |
		| value |
		value := dictionary at: vertex.
		Transcript
			show: '    ', vertex printString, ', anc=', value printString;
			cr.
	].
]

{ #category : #computing }
VMActiveNeighborCount >> tryIncrementAt: aVertex ifFull: blockFull [
	| oldValue |
	
	dictionary at: aVertex ifPresent: [ :value |
			oldValue := value.
		] ifAbsent: [
			oldValue := 0.
		].
	
	oldValue < (aVertex neighbors size) ifTrue: [
			dictionary at: aVertex put: (oldValue + 1).
		] ifFalse: [
			blockFull value.
		].
]

{ #category : #computing }
VMActiveNeighborCount >> tryIncrementAt: aVertex ifFull: blockFull ifNotFull: blockNotFull [
	| oldValue |
	
	dictionary at: aVertex ifPresent: [ :value |
			oldValue := value.
		] ifAbsent: [
			oldValue := 0.
		].
	
	oldValue < (aVertex neighbors size) ifTrue: [
			dictionary at: aVertex put: (oldValue + 1).
			blockNotFull value.
		] ifFalse: [
			blockFull value.
		].
]
