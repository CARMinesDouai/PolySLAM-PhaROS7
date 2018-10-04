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

{ #category : #comparing }
VMGraphNode >> = aNode [
	^ sector = aNode sector
]

{ #category : #converting }
VMGraphNode >> asPolygon [
	^ self sector
]

{ #category : #accessing }
VMGraphNode >> center [
	^center
]

{ #category : #comparing }
VMGraphNode >> hash [
	^ sector hash
]

{ #category : #initialization }
VMGraphNode >> initialize [
	super initialize.
	neighbors := Set new.
]

{ #category : #accessing }
VMGraphNode >> neighbors [
	^neighbors
]

{ #category : #accessing }
VMGraphNode >> sector [
	^ sector
]

{ #category : #accessing }
VMGraphNode >> sector: aSector [
	sector := aSector.
	center := sector centroid.
]
