Class {
	#name : #PSPolygonMergingHelperTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
PSPolygonMergingHelperTest >> testMerge [
	|c pA pB helper|
	c := FLMaterializer materializeFromFileNamed: '/home/mrsang/kf-test.fuel'.
	pA := (VMVectorCollectionSimplifier compute: ((c at:3) polygon) inlierThreshold: 0.01 ) result.
	pB := (VMVectorCollectionSimplifier compute: ((c at:4) polygon) inlierThreshold: 0.01 ) result.
	{ pA. pB. pA asDoublyConnectedEdgeList intersectWith: pB } asRenderableElement inspect.
	helper := PSPolygonMergingHelper merge: pA with: pB.
	helper merge asRenderableElement inspect.
]

{ #category : #tests }
PSPolygonMergingHelperTest >> testMerge1 [
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
	helper := PSPolygonMergingHelper merge: polygonA with: polygonB.
	helper merge asRenderableElement inspect.
]
