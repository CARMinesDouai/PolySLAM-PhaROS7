"
This class represents a node in a graph. The node represents a sector/polygon and contains a collection of accessable neighbors (i.e. all polygons that share a sector border). note that 'neighbors' is a Set instance, to prevent the same neighbor being added multiple times.
"
Class {
	#name : #VMGraphNode,
	#superclass : #Object,
	#instVars : [
		'sector',
		'center',
		'neighbors'
	],
	#category : #'PolySLAM-Core-Top. Graph'
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
VMGraphNode >> asPoint [
	^ self center asPoint
]

{ #category : #converting }
VMGraphNode >> asPolygon [
	^ self sector
]

{ #category : #accessing }
VMGraphNode >> center [
	"returns the center of the sector, i.e. 'self sector centroid'. the value
	is casehed to speed up computations that use this method."
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
