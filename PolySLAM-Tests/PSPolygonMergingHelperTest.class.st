Class {
	#name : #PSPolygonMergingHelperTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
PSPolygonMergingHelperTest >> testMerge [
	|c pA pB helper helper1|
	c := FLMaterializer materializeFromFileNamed: '/home/mrsang/kf-test.fuel'.
	pA := (VMVectorCollectionSimplifier compute: ((c at:3) polygon) inlierThreshold: 0.01 ) result.
	pB := (VMVectorCollectionSimplifier compute: ((c at:4) polygon) inlierThreshold: 0.01 ) result.
	"helper1 :=PSPolygonIntersectionHelper  from: pA and: pB.
	helper1 perform."
	{ pA. pB. } asRenderableElement inspect.
	
	helper := PSPTMHelper from: pA and: pB.
	helper perform.
]

{ #category : #tests }
PSPolygonMergingHelperTest >> testMerge1 [
	|polygonA polygonB helper |
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
	helper := PSPolygonMergingHelper from: polygonA and: polygonB helperClass: PSPolygonDecompositionHelper.
	helper perform.
	helper chains asRenderableElement inspect.
]

{ #category : #tests }
PSPolygonMergingHelperTest >> testMerge2 [
	|polygonA polygonB helper helper2|
	polygonA := VMPolygon new
		fromPoints:
			{(21.425210168457966@ -12.775517411510322).
			(21.141888982863566@ -9.025210084737392).
			18.183298092698166@ -9.071700941360628.
			20.54286331033431@ -12.68151468341522.
			20.44537764198814@ -12.907433069750383}.
	(polygonA at:1) type: 2.
	(polygonA at:2) type: 1.
	(polygonA at:3) type: 2.
	(polygonA at:4) type: 1.
	(polygonA at:5) type: 2.
	polygonA.
	polygonB := VMPolygon new
		fromPoints:
			{
			(21.424379048469767@ -12.79172668034918).
			(21.26779853221434@ -9.024896504898416).
			(18.416467909650255@ -9.066805865346007).
			(20.56603037341612@ -12.720884266491723).
			(20.44537366936693@ -12.795412654771388).
			}.
	(polygonB at:1) type: 2.
	(polygonB at:2) type: 1.
	(polygonB at:3) type: 2.
	(polygonB at:4) type: 1.
	(polygonB at:5) type: 2.
	"helper := PSPolygonIntersectionHelper from: polygonA and: polygonB.
	helper2 := PSProbabilistPolygonIntersectionHelper from: polygonA and: polygonB.
	helper perform.
	helper2 perform.
	{ polygonA. polygonB. helper intersections } asRenderableElement inspect.
	{ polygonA. polygonB. helper2 intersections } asRenderableElement inspect."
	helper := PSPolygonMergingHelper from: polygonA and: polygonB helperClass: PSPolygonDecompositionHelper.
	helper perform.
	helper chains asRenderableElement inspect.
]
