Class {
	#name : #VMPolygonMerger,
	#superclass : #Object,
	#category : #'PolySLAM-Core-Data Structures: Polygons'
}

{ #category : #'as yet unclassified' }
VMPolygonMerger >> merge: sourcePolygon into: targetPolygon [
	
]

{ #category : #'as yet unclassified' }
VMPolygonMerger >> mergeCollection: aPolygonCollection graph: aGraph [
	| newPolygon visitedNeighbors neighborsQueue |
	newPolygon := aPolygonCollection first copy.
	visitedNeighbors := Set new.
	neighborsQueue := VMQueue new.
	
	(aGraph at: aPolygonCollection first) neighbors do: [ :n | neighborsQueue push: n ].
	[ neighborsQueue isEmpty ] whileFalse: [
		self merge: neighborsQueue pop sector into: newPolygon.
	].
	
	^ newPolygon
]
