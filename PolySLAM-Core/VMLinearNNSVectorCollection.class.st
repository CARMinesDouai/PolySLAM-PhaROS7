"
This class acts as a collection that supports #findNearest with point-to-vector nearest neighbor search.

Nearest neighbors are searched in a simple brute-force matter, testing all stored vectors, resulting in linear time complexity in ragards to the number of vectors stored. It is considerable faster than VMNNVectorGrid for small number of vectors (for example n<100) and considerable slower for a large amount of vectors (e.g. n>200).
"
Class {
	#name : #VMLinearNNSVectorCollection,
	#superclass : #OrderedCollection,
	#category : #'PolySLAM-Core-Nearest Neighbor Search'
}

{ #category : #'as yet unclassified' }
VMLinearNNSVectorCollection >> asNNCollection [
	^ self
]

{ #category : #'find nearest neighbor' }
VMLinearNNSVectorCollection >> findNearest: aPoint [
	| closestPoint minDist |
	
	closestPoint := self first closestPoint: aPoint.
	minDist := aPoint squaredDistanceTo: closestPoint.
	
	self allButFirstDo: [ :vec |
		| tempPoint tempDist |
		tempPoint := vec closestPoint: aPoint.
		tempDist := aPoint squaredDistanceTo: tempPoint.
		tempDist < minDist
			ifTrue: [
				closestPoint := tempPoint.
				minDist := tempDist.
			].
	].
	
	^ VMNNSearchResult object: closestPoint squareDist: minDist

]
