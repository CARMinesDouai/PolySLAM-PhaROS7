Class {
	#name : #PSAdjacencyMatrixTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
PSAdjacencyMatrixTest >> testEigen [
	|polygonA polygonB matrix collection|
	polygonA := VMPolygon new
		fromPoints:
			{(10.0 @ 5.0).
			(8 @ 11).
			(2 @ 8)}.
	polygonB := VMPolygon new
		fromPoints:
			{(15.0 @ 5.0).
			(17 @ 8).
			(13 @ 11)}.

	collection := OrderedCollection new.
	polygonA asDoublyConnectedEdgeListDo: [ :l| collection add:l ].
	polygonB asDoublyConnectedEdgeListDo: [ :l| collection add:l ].
	matrix := PSAdjacencyMatrix fromLines: collection.
	matrix  binaryAdjacencyMatrix makeSymetric eigen inspect.
	"matrix eigen inspect"
]

{ #category : #tests }
PSAdjacencyMatrixTest >> testInit [
	|polygonA  matrix matrix2 collection|
	polygonA := VMPolygon new
		fromPoints:
			{(10.0 @ 5.0).
			(8 @ 11).
			(2 @ 8)}.
	collection := OrderedCollection new.
	polygonA asDoublyConnectedEdgeListDo: [ :l| collection add:l ].
	matrix := PSAdjacencyMatrix fromLines: collection .
	matrix2 := PSAdjacencyMatrix rows: #(#(0 1 0 ) #(0 0 1 ) #(1 0 0 ) ).
	self assert: matrix = matrix2.
	self assert: matrix nonVaninshingElements size = 3.
	self assert: matrix nonVaninshingElements sum = 3.
	self assert: matrix mean = 1.
	self assert: matrix variance  = 0.
	self assert: matrix entropy  = 0.
	self assert: matrix th = 1
]
