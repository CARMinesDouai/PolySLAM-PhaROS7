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
DoublyConnectedEdgeListTest >> testIsLineInside [
	| points polygon lines result|
	
	points := {
	4@1. 9@4. 7@9. 2@7. 2@3. 6@5
	}.
	polygon := (VMPolygon new fromPoints: points) asDoublyConnectedEdgeList .
	
	lines := { 
		PSLinkedEdge from: 6@3 to: 8@1 type: 1.
		PSLinkedEdge from: 9@7 to: 10@9 type: 1.
		PSLinkedEdge from: 6@7 to: 7@5 type: 1.
		PSLinkedEdge from: 3@4 to: 5@2 type: 1.
		PSLinkedEdge from: 4@4 to: 5@3 type: 1.
		PSLinkedEdge from: 2@5 to: 4@4 type: 1.
		PSLinkedEdge from: 2@7 to: 6@5 type: 1.
		PSLinkedEdge from: 2@3 to: 4@1 type:1
	}.
	
	result := { false. false. true. false. false. true. true. false}.
	{ polygon. lines } asRenderableElement inspect.
	1 to: lines size do:[:i|
		self assert: (polygon isLineInside: (lines at:i)) = (result at:i)	
	]
	
	
	


]

{ #category : #tests }
DoublyConnectedEdgeListTest >> testIsPointInside [
	| points polygon point|
	
	points := {
	1@1. 5@3. 2@5
	}.
	polygon := (VMPolygon new fromPoints: points) asDoublyConnectedEdgeList .
	point := 3@3.

	self assert: (polygon isPointInside: point) = true.
	
	point := 3@2.
	self assert:(polygon isPointOnChain: point) = true.
	self assert: (polygon isPointInside: point) = true.
	
		point := 7@4.
	"{ polygon. point } asRenderableElement inspect."
	self assert:(polygon isPointOnChain: point) = false.
	self assert: (polygon isPointInside: point) = false.
	
	point := 3@1.
	self assert: (polygon isPointInside: point) = false.
	
	point := 2@5.
	{ polygon. point } asRenderableElement inspect.
	self assert: (polygon isPointInside: point) = true.


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

{ #category : #tests }
DoublyConnectedEdgeListTest >> testWindingNumber [
	| points expectedResults |
	
	points := {
		{ -2 @ 2.  2 @ 2.  2 @ -2.  -2 @ -2. }.
		{ 0.2 @ 3.  3 @ -1.  -2 @ -1.6. }.
		{ -3@ 2.  1 @ 2.  1 @ 1.  -1 @ 1. -2 @ -1.  1 @ -1.  1 @ -2.  -3 @ -2. }.
	}.
	"results (columns):
	  1) original polygon, tested with 0@0
	  2) original polygon, tested with 20@20
	  3) inverted polygon, tested with 0@0
	  4) inveretd polygon, tested with 20@20
	"
	expectedResults := {
		{ 1.  0.  -1.  0 }.
		{ 1.  0.  -1.  0 }.
		{ 0.  0.  0.  0 }.
	}.
	
	points doWithIndex: [ :pointCollection :index |
		| polygon wn results |
		
		results := expectedResults at: index.
		
		polygon := (VMPolygon new fromPoints: pointCollection) asDoublyConnectedEdgeList .
		wn := polygon windingNumber: 0@0.
		self assert: wn equals: results first.
		wn := polygon windingNumber: 20@20.
		self assert: wn equals: results second.
		
		polygon := VMPolygon new fromPoints: pointCollection reversed.
		wn := polygon windingNumber: 0@0.
		self assert: wn equals: results third.
		wn := polygon windingNumber: 20@20.
		self assert: wn equals: results fourth.
	].

]
