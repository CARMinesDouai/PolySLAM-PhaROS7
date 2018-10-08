Class {
	#name : #VMGraphBuilderTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
VMGraphBuilderTest >> testBuildGraph [
	| root polygon graph |
	
	root := VMBSPNode parent: nil plane: (VMLine pointA: 0@0 pointB: 0.8@2).
	root leftChild: (VMBSPNode parent: root plane: (VMLine pointA: -2@2.1 pointB: 0@2.1)).
	root rightChild: (VMBSPNode parent: root plane: (VMLine pointA: 0@0 pointB: 1.5@ -0.4)).
	root rightChild rightChild: (VMBSPNode parent: root rightChild plane: (VMLine pointA: 2@0 pointB: 2@ -1)).
	
	polygon := (VMPolygon fromRectangle: (-3@ -3 extent: 6@6)) collect: [:v| v type:1].
	root := root insert: polygon.
	graph := VMGraphBuilder new buildGraph: root.
	
	self assert: graph size equals: 5.

]

{ #category : #tests }
VMGraphBuilderTest >> testBuildGraph2 [
	| root polygonA polygonB polygonC graph graphCollection |
	
	polygonA := VMPolygon fromPoints:{   -3 @ -2.    0@ -2.    0@2.        -3@2} withTypes: {1. 2. 1. 1}.
	polygonB := VMPolygon fromPoints:{ -0.5 @ -2.5.  2@ -2.5.  2@ -1.5.  -0.5@ -1.5} withTypes: {1. 1. 1. 2}.
	polygonC := VMPolygon fromPoints:{ -0.5 @ 1.5.  2@ 1.5.    2@ 2.5.   -0.5@ 2.5} withTypes: {1. 1. 1. 2}.
	
	
	root := VMBSPLeaf new.
	{ polygonA. polygonB. polygonC } do: [ :p | root := root insert: p ].
	
	graph := VMGraphBuilder new buildGraph: root.
	
	graphCollection := VMConnectedGraphs compute: graph.
	"note: at the time of writing this test, it fails due to a bug in the BSP-tree building
	process, not because of VMGraphBuilder itself. However VMGraphBuilder & VMConnectedGraphs
	are affected by the bug and hence can detect it"
	self assert: graphCollection size equals: 1.
]

{ #category : #tests }
VMGraphBuilderTest >> testVectorByXOverlapsWith [
	| vectorA vectorB builder dir |
	
	vectorA := 0@0 vectorTo: 3.2@1.1.
	dir := vectorA direction.
	builder := VMGraphBuilder new.
	
	vectorB := vectorA inverse.
	self assert: (builder vector: vectorA byXOverlapsWith: vectorB).
	
	vectorB := (vectorA pointB + (0.5 * dir)) vectorTo: (vectorA pointA + (0.5 * dir)).
	self assert: (builder vector: vectorA byXOverlapsWith: vectorB).
	
	vectorB := (vectorA pointB + (2.5 * dir)) vectorTo: (vectorA pointA + (1.5 * dir)).
	self assert: (builder vector: vectorA byXOverlapsWith: vectorB) not.
	
	vectorB := (vectorA pointB + (-0.5 * dir)) vectorTo: (vectorA pointA + (-0.5 * dir)).
	self assert: (builder vector: vectorA byXOverlapsWith: vectorB).
	
	vectorB := (vectorA pointB + (-2.5 * dir)) vectorTo: (vectorA pointA + (-1.5 * dir)).
	self assert: (builder vector: vectorA byXOverlapsWith: vectorB) not.
	
	vectorB := (vectorA pointB + (0.1 * dir)) vectorTo: (vectorA pointA + (-0.1 * dir)).
	self assert: (builder vector: vectorA byXOverlapsWith: vectorB).
	
	vectorB := (vectorA pointB + (-0.1 * dir)) vectorTo: (vectorA pointA + (0.1 * dir)).
	self assert: (builder vector: vectorA byXOverlapsWith: vectorB).

]

{ #category : #tests }
VMGraphBuilderTest >> testVectorByYOverlapsWith [
	| vectorA vectorB builder dir |
	
	vectorA := 0@0 vectorTo: 1.2@4.3.
	dir := vectorA direction.
	builder := VMGraphBuilder new.
	
	vectorB := vectorA inverse.
	self assert: (builder vector: vectorA byYOverlapsWith: vectorB).
	
	vectorB := (vectorA pointB + (0.5 * dir)) vectorTo: (vectorA pointA + (0.5 * dir)).
	self assert: (builder vector: vectorA byYOverlapsWith: vectorB).
	
	vectorB := (vectorA pointB + (2.5 * dir)) vectorTo: (vectorA pointA + (1.5 * dir)).
	self assert: (builder vector: vectorA byYOverlapsWith: vectorB) not.
	
	vectorB := (vectorA pointB + (-0.5 * dir)) vectorTo: (vectorA pointA + (-0.5 * dir)).
	self assert: (builder vector: vectorA byYOverlapsWith: vectorB).
	
	vectorB := (vectorA pointB + (-2.5 * dir)) vectorTo: (vectorA pointA + (-1.5 * dir)).
	self assert: (builder vector: vectorA byYOverlapsWith: vectorB) not.
	
	vectorB := (vectorA pointB + (0.1 * dir)) vectorTo: (vectorA pointA + (-0.1 * dir)).
	self assert: (builder vector: vectorA byYOverlapsWith: vectorB).
	
	vectorB := (vectorA pointB + (-0.1 * dir)) vectorTo: (vectorA pointA + (0.1 * dir)).
	self assert: (builder vector: vectorA byYOverlapsWith: vectorB).

]
