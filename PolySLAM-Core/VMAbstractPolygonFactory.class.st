Class {
	#name : #VMAbstractPolygonFactory,
	#superclass : #Object,
	#instVars : [
		'activeNeighborCount',
		'polygonVertices',
		'startVertex'
	],
	#category : #'PolySLAM-Core-kernel'
}

{ #category : #testing }
VMAbstractPolygonFactory >> activeNeighborCount: anc [
	activeNeighborCount := anc.
]

{ #category : #initialize }
VMAbstractPolygonFactory >> createWithVertex: aVertex [
	self subclassResponsibility.
]

{ #category : #testing }
VMAbstractPolygonFactory >> freeNeighborsCount: vertex [
	^activeNeighborCount freeNeighborsCount: vertex.
]

{ #category : #initialize }
VMAbstractPolygonFactory >> initialize [
	polygonVertices := OrderedCollection new
]
