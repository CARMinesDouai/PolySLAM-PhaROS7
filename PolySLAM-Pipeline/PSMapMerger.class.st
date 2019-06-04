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
	|helper newchains components|
	chains ifNil: [ 
		chains := OrderedCollection new.
		chains add: polygon.
		^ self.	
	].
	newchains := OrderedCollection new.
	chains do:[:chain|
		helper := PSLinkedTree from: chain and: polygon.

		helper perform.
		components := (helper tree collect:[:e| e allConnectedComponents ] thenSelect:[:e| (e isNotEmpty)  ]).
		
		components isEmpty
			ifTrue:[ newchains add: chain]
			ifFalse:[
				components do:[:e| |comp|
					comp := self selectComponent: e.
					comp ifNotNil: [ newchains add: comp ]
				]]
		
	].
	chains := newchains
]

{ #category : #'as yet unclassified' }
PSMapMerger >> selectComponent: aCollection [
	|comp maxarea a|
	comp := aCollection first.
	maxarea := comp area.
	aCollection removeFirst.
	aCollection do:[:e|
		a := e area.
		a > maxarea ifTrue: [ 
			maxarea := a.
			comp := e.
		]].
	^ comp
]
