Class {
	#name : #VMConnectedGraphsTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
VMConnectedGraphsTest >> testCompute [
	"creates a simple BSP tree and computes the graph. the result should be a single connected graph"
	| root polygon graph graphCollection |
	
	root := VMBSPNode parent: nil plane: (VMLine pointA: 0@0 pointB: 0.8@2).
	root leftChild: (VMBSPNode parent: root plane: (VMLine pointA: -2@2.1 pointB: 0@2.1)).
	root rightChild: (VMBSPNode parent: root plane: (VMLine pointA: 0@0 pointB: 1.5@ -0.4)).
	root rightChild rightChild: (VMBSPNode parent: root rightChild plane: (VMLine pointA: 2@0 pointB: 2@ -1)).
	
	polygon := (VMPolygon fromRectangle: (-3@ -3 extent: 6@6)) collect: [:v| v type:1].
	root := root insert: polygon.
	graph := VMGraphBuilder new buildGraph: root.
	
	graphCollection := VMConnectedGraphs new compute: graph.
	self assert: graphCollection size equals: 1.

]

{ #category : #tests }
VMConnectedGraphsTest >> testCompute2 [
	"creates a BSP tree with two disconnected areas. the resulting graph should reflect that
	by forming two connected graphs instead of one."
	| root polygonA polygonB graph graphCollection |
	
	root := VMBSPNode parent: nil plane: (VMLine pointA: 0@0 pointB: 3@2).
	root leftChild: (VMBSPNode parent: root plane: (VMLine pointA: -2@0 pointB: -3@4)).
	root rightChild: (VMBSPNode parent: root plane: (VMLine pointA: 2@0 pointB: 2@ 1)).
	root rightChild rightChild: (VMBSPNode parent: root rightChild plane: (VMLine pointA: 2@ -1 pointB: 4@ -1)).
	
	polygonA := (VMPolygon fromRectangle: (-3@ -3 extent: 3@5)) collect: [:v| v type:1].
	polygonB := (VMPolygon fromRectangle: (1@ -1 extent: 3@4)) collect: [:v| v type:1].
	
	root := root insert: polygonA.
	root := root insert: polygonB.
	
	graph := VMGraphBuilder new buildGraph: root.
	
	graphCollection := VMConnectedGraphs new compute: graph.
	self assert: graphCollection size equals: 2.

]
