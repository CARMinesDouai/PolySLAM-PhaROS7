Class {
	#name : #VMGraphNode,
	#superclass : #Object,
	#instVars : [
		'sector',
		'center',
		'neighbors'
	],
	#category : #'PolySLAM-Core-Collections, Trees & Graphs'
}

{ #category : #'as yet unclassified' }
VMGraphNode class >> sector: aSector [
	^(self new)
		sector: aSector;
		yourself.
]

{ #category : #'as yet unclassified' }
VMGraphNode >> center [
	^center
]

{ #category : #'as yet unclassified' }
VMGraphNode >> hash [
	^ sector hash
]

{ #category : #'as yet unclassified' }
VMGraphNode >> initialize [
	super initialize.
	neighbors := Set new.
]

{ #category : #'as yet unclassified' }
VMGraphNode >> neighbors [
	^neighbors
]

{ #category : #'as yet unclassified' }
VMGraphNode >> sector [
	^ sector
]

{ #category : #'as yet unclassified' }
VMGraphNode >> sector: aSector [
	sector := aSector.
	center := sector centroid.
]
