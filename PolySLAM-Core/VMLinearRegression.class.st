"
This class fits a line to a collection ov vectors by means of linear regression.

Public API and Key Messages
	- compute: <Collection of vectors>
		answers with the line that minimizes the square error distance between the line and the vector start/end points.
	- computeWithDataX: <Collection of Numbers> dataY: <Collection of Numbers>
		similar to #compute:, but takes points instead of vectors. unlike #compute: this method does not handle data well
		that would result in a very steep line (i.e. a line with a direction dominated in the y axis) 
	-collectData: <Collection of vectors>
		a helper function that takes a collection of vectors and returns two collections of numbers to be used in
		#computeWithDataX:dataY:


Example:

	points := { 0@1.  1@2.  2@1.  3@2.  4@1 }.
	vectors := OrderedCollection new.
	2 to: points size do: [ :i | vectors add: (VMLineSegment pointA: (points at: i-1) pointB: (points at: i)) ].
	line := VMLinearRegression compute: vectors.
	line inspect.
 

"
Class {
	#name : #VMLinearRegression,
	#superclass : #Object,
	#category : #'PolySLAM-Core-Line- & Vector Approximation'
}

{ #category : #public }
VMLinearRegression class >> compute: vectorCollection [
	"important: answers with a VMLine instance, NOT with a VMLinearRegression instance"
	^(self new)
		compute: vectorCollection
]

{ #category : #'as yet unclassified' }
VMLinearRegression >> collectData: collectionOfVectors [
	"note: we assume here that the vectors form a chain, i.e. the vector end point at
	position n is the same as the start point of the vector at position n+1."
	| dataX dataY |
	
 	dataX := collectionOfVectors collect: [ :vec | vec pointA x ].
	dataX add: collectionOfVectors last pointB x.
	
	dataY := collectionOfVectors collect: [ :vec | vec pointA y ].
	dataY add: collectionOfVectors last pointB y.
	
	^{ dataX.  dataY }

]

{ #category : #public }
VMLinearRegression >> compute: collectionOfVectors [
	"fits a line by means of linear regression to the points of the vectors in 'collectionOfVectors'"
	| data direction line |
	
	data := self collectData: collectionOfVectors.
	direction := collectionOfVectors last pointB - (collectionOfVectors first pointA).
	
	(direction x abs >= direction y abs)
		ifTrue: [ line := self computeWithDataX: data first dataY: data last ]
		ifFalse: [
			line := self computeWithDataX: data last dataY: data first.
			line := VMLine
				pointA: line pointA y @ line pointA x
				pointB: line pointB y @ line pointB x
		].
	
	((direction deltaAngle: line direction) abs > Float halfPi) ifTrue: [ line := line inverse ].
	
	^line

]

{ #category : #'as yet unclassified' }
VMLinearRegression >> computeWithDataX: dataX dataY: dataY [
	| matrixX matrixXTX matrixXTY beta |
	
	matrixX := PMMatrix rows: (dataX collect: [ :x | { 1. x } ] ).
	
	" compute X^T * X "
	matrixXTX := (matrixX transpose * matrixX) inverse.
	
	" compute X^T * Y "
	matrixXTY := (matrixX) transpose * (PMMatrix rows: dataY).
	
	beta := matrixXTX * matrixXTY.

	^VMLineSegment
		pointA: 0 @ beta rows first first
		pointB: 1 @ ((beta rows first first) + (beta rows last first))

]
