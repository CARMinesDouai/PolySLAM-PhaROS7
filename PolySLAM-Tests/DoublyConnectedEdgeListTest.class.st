Class {
	#name : #DoublyConnectedEdgeListTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
DoublyConnectedEdgeListTest >> testDecomposeAfterIntersectWith [
	|polygonA polygonB helper|
	polygonA := VMPolygon new
		fromPoints:
			{(10.0 @ 5.0).
			(8 @ 11).
			(2 @ 8)}.
	polygonB := VMPolygon new
		fromPoints:
			{
			(12 @ 7).
			(6 @ 12).
			(4 @ 4).
			}.
	helper := PSPolygonDecompositionHelper from: polygonA and: polygonB.
	helper perform.
	"{polygonA. polygonB.
	helper intersections } asRenderableElement inspect."
	(helper components) asRenderableElement inspect.
]

{ #category : #tests }
DoublyConnectedEdgeListTest >> testDecomposeAfterIntersectWith1 [
	|polygonA polygonB helper|
	polygonA := VMPolygon new
		fromPoints:
			{(5.0 @ 1.0).
			(9 @ 1.5).
			(6 @ 10)}.
	polygonB := VMPolygon new
		fromPoints:
			{
			(10 @ 5).
			(3 @ 10).
			(4 @ 8).
			(10.0 @ 5.0).
			(2.0 @ 6.0).
			(3.75 @ 4).
			(10 @ 5).
			(3.5 @ 2.5).
			(3 @ 1).
			}.
	"{polygonA. polygonB} asRenderableElement inspect."
	"(polygonA mergeWith:  polygonB)."
	"{polygonA. polygonB.
	( polygonA asDoublyConnectedEdgeList  intersectWith:  polygonB) } asRenderableElement inspect."
	helper := PSPolygonDecompositionHelper from: polygonA and: polygonB.
	helper perform.
	"{polygonA. polygonB.
	helper intersections } asRenderableElement inspect."
	(helper components) asRenderableElement inspect.
]

{ #category : #tests }
DoublyConnectedEdgeListTest >> testDecomposeAfterIntersectWith2 [
		|polygonA polygonB helper|
	polygonA := VMPolygon new
		fromPoints:
			{(10.0 @ 5.0).
			(8 @ 11).
			(2 @ 8)}.
	polygonB := VMPolygon new
		fromPoints:
			{
			(10 @ 5).
			(6 @ 12).
			(4 @ 4).
			}.
	helper := PSPolygonDecompositionHelper from: polygonA and: polygonB.
	helper perform.
	"{polygonA. polygonB.
	helper intersections } asRenderableElement inspect."
	(helper components) asRenderableElement inspect.
]

{ #category : #tests }
DoublyConnectedEdgeListTest >> testPSVertexKeyY [
	|lines tree|
	lines := { 
		PSLinkedEdge from: -10@5 to: -3.5@2.5 type: 2.
		PSLinkedEdge from: -10@5 to: -3.75@4.0 type: 2.
		PSLinkedEdge from: -10@5 to: -3@1 type: 2.
		PSLinkedEdge from: -10@5 to: -4@8 type: 2.
		PSLinkedEdge from: -10@5 to: -2@6 type: 2.
		PSLinkedEdge from: -10@5 to: -3@10 type: 2.
	}.
	lines asRenderableElement inspect.
	tree := BTree order: 4.
	lines do:[:l|
		tree at: (PSVertexKeyY from: l value pointA) put:l.	
	].
	tree inspect.
]

{ #category : #tests }
DoublyConnectedEdgeListTest >> testSurgeryAtIntersectionWith [
	|polygonA polygonB helper|
	polygonA := VMPolygon new
		fromPoints:
			{(10.0 @ 5.0).
			(8 @ 11).
			(2 @ 8)}.
	polygonB := VMPolygon new
		fromPoints:
			{
			(12 @ 7).
			(6 @ 12).
			(4 @ 4).
			}.

	helper := PSPolygonDecompositionHelper from: polygonA and: polygonB.
	helper perform.
	"{polygonA. polygonB.
	helper intersections } asRenderableElement inspect."
	{ helper polygonA. helper polygonB } asRenderableElement inspect.
	
]
