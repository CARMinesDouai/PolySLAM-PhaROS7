Class {
	#name : #VMPolygonTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
VMPolygonTest >> testArea [
	| p points area expectedResults |
	
	points := {
		{ 0 @ 0.  0 @ 2.  2 @ 2. }.
		{ -2 @ 0.  0 @ 2.  2 @ 0.  0 @ -2. }.
		{ 0 @ 0.  0 @ 2.  4 @ 0.  0 @ -2. }.
		{ 0 @ -2.  0 @ 2.  2 @ 2.  1 @ 0.  2 @ -2. }.
	}.
	expectedResults := { 2.  8.  8.  6. }.
	
	points doWithIndex: [ :pointCollection :index |
		p := VMPolygon new fromPoints: pointCollection.
		area := p area.
		self assert: (area closeTo: (expectedResults at: index)).
	].

]

{ #category : #tests }
VMPolygonTest >> testCentroid [
	| p points centroid expectedResults |
	
	points := {
		{ -2 @ 0.  0 @ 2.  2 @ 0.  0 @ -2. }.
		{ 0 @ 0.  2 @ 2.  4 @ 0.  2 @ -2. }.
		"{ 0 @ -2.  0 @ 2.  2 @ 2.  1 @ 0.  2 @ -2. }."
	}.
	expectedResults := { 0 @ 0.  2 @ 0. }.
	
	points doWithIndex: [ :pointCollection :index |
		p := VMPolygon new fromPoints: pointCollection.
		centroid := p centroid.
		self assert: (centroid closeTo: (expectedResults at: index)).
	].

]

{ #category : #tests }
VMPolygonTest >> testEquals [
	| points p1 p2 |
	
	points := { 0 @ 2.  4 @ 2.  4 @ -2.  0 @ -2. }.
	
	p1 := VMPolygon new fromPoints: points.
	p2 := VMPolygon new fromPoints: (points collectWithIndex: [ :point : index | points atWrap: index+2 ]).
	
	self assert: p1 = p2.
	self assert: (p1 = (p2 reversed)) not.

]

{ #category : #tests }
VMPolygonTest >> testFindClosest [
	| points types polygon testPoints expectedResults |
	
	points := { 0@0.  4@0.  4@4.  0@4 }.
	types := { 1. 2. 1. 1 }.
	testPoints := { -1@2.  1@2.  3@1.5.  3@5 }.
	expectedResults := { 0@2.  0@2.  4@1.5.  3@4 }.
	polygon := VMPolygon fromPoints: points withTypes: types.
	
	testPoints with: expectedResults do: [ :testPoint :expectedPoint |
		| result |
		result := polygon findNearest: testPoint.
		self assert: result object isNotNil.
		self assert: (result object dist: expectedPoint) < 0.0000001.
	].
]

{ #category : #tests }
VMPolygonTest >> testFindClosestObstacle [
	| points types polygon testPoints expectedResults renderCollection |
	
	points := { 0@0.  4@0.  4@4.  0@4 }.
	types := { 1. 2. 1. 1 }.
	testPoints := { -1@2.  1@2.  3@1.5.  3@5 }.
	expectedResults := { 0@2.  0@2.  3@0.  3@4 }.
	polygon := VMPolygon fromPoints: points withTypes: types.
	
	renderCollection := OrderedCollection new.
	renderCollection add: polygon asRenderableElement.
	
	testPoints with: expectedResults do: [ :testPoint :expectedPoint |
		| result |
		result := polygon findNearestObstacle: testPoint.
		self assert: result object isNotNil.
		self assert: (result object dist: expectedPoint) < 0.0000001.
		
		renderCollection add: "a line, connecting the test point to the expected result. color: purple"
			((VMLineSegment from: testPoint to: expectedPoint)
				asRenderableElement
					color: Color purple;
					lineWidth: 0.06).
		renderCollection add: "a line, connecting the test point to the actual result. color: cyan"
			((VMLineSegment from: testPoint to: result object)
				asRenderableElement
					color: Color cyan;
					lineWidth: 0.02).
		renderCollection add: ((VMPointRenderer model: testPoint) lineWidth: 0.04; color: Color orange).
		renderCollection add: ((VMPointRenderer model: expectedPoint) lineWidth: 0.04; color: Color yellow).
		renderCollection add: ((VMPointRenderer model: result object) lineWidth: 0.02; color: Color blue).
	].
	
	"renderCollection asRenderableElement inspect."
]

{ #category : #tests }
VMPolygonTest >> testFromPoints [
	| points polygon |
	
	points := {
		-2 @ -2.
		4 @ -2.
		0 @ 5.
	}.
	
	polygon := VMPolygon new fromPoints: points.
	
	self assert: polygon size equals: points size.
	

]

{ #category : #tests }
VMPolygonTest >> testFromPoints2 [
	| points polygon |
	
	points := {
		0 @ 0.
		-2.5 @ 0.
		1.1 @ 0.5.
	}.
	
	polygon := VMPolygon new fromPoints: points.
	
	self assert: polygon size equals: points size.
	

]

{ #category : #tests }
VMPolygonTest >> testIfConvexDoOtherwiseDo [
	| data expectedResults polygon result |
	data := {
		{  0 @ 2.  2 @ 0.  0 @ -2.  -2 @ 0. }.
		{ -2 @ 2.  2 @ 2.  2 @ 0.    1 @ 0.  1 @ -2.  -2 @ -2. }.
	}.
	expectedResults := {
		true.
		false. 
	}.
	
	data doWithIndex: [ :points :index |
		result := nil.
		polygon := VMPolygon new fromPoints: points.
		
		polygon
			ifConvex: [ :p | result := true ]
			otherwise: [ :p :l | result := false ].
		
		self assert: result equals: (expectedResults at: index).
	].
	
	

]

{ #category : #tests }
VMPolygonTest >> testIntersect [
	|polygonA polygonB intersections|
	polygonA := VMPolygon new fromPoints: {7.0@2.0. 2.0@5.5. 5.0@1.0 }.
	polygonB := VMPolygon new fromPoints: {6.5@1.3. 6.0@5.0. 1.0@2.0 }.
	"{ polygonA. polygonB  } asRenderableElement inspect"
	intersections := polygonA intersectWith:  polygonB.
	{polygonA. polygonB. intersections} asRenderableElement inspect.
	self assert: intersections size = 6.
]

{ #category : #tests }
VMPolygonTest >> testIsCW [
	| data expectedResults polygon |
	
	data := {
		{ -2 @ 2.  1 @ -1. -4 @ -1. }.
		{  0 @ 2.  2 @ 2.  -2 @ 0  }.
		{ -2 @ 2.  1 @ 0.  -2 @ -2 }.
		{ -2 @ 2.  2 @ 1.   0 @ -1 }.
		{  0 @ 2. -1 @ 0.  -2 @ 0  }.
		{ -2 @ 2.  2 @ 2.  -2 @ -2 }.
		{ -2 @ 2.  2 @ 2.   2 @ -2 }.
	}.
	expectedResults := {
		true.
		true.
		true.
		true.
		true.
		true.
		true.
	}.
	
	data doWithIndex: [ :aPointCollection :index |
		polygon := VMPolygon new fromPoints: aPointCollection.
		self assert: polygon isCW equals: (expectedResults at: index).
		
		polygon := VMPolygon new fromPoints: aPointCollection reversed.
		self assert: polygon isCW not equals: (expectedResults at: index).
	].
	

]

{ #category : #tests }
VMPolygonTest >> testIsConvex [
	| data expectedResults polygon result |
	data := {
		{  0 @ 2.  2 @ 0.  0 @ -2.  -2 @ 0. }.
		{ -2 @ 2.  2 @ 2.  2 @ 0.    1 @ 0.  1 @ -2.  -2 @ -2. }.
	}.
	expectedResults := {
		true.
		false. 
	}.
	
	data doWithIndex: [ :points :index |
		result := nil.
		polygon := VMPolygon new fromPoints: points.
		
		self assert: polygon isConvex equals: (expectedResults at: index).
	].
	
	

]

{ #category : #tests }
VMPolygonTest >> testMergeShortVectors [
	| points polygon expectedResults minLength |
	
	points := {
		{ -2 @ 0.  0 @ 2.  2 @ 0.  0 @ -2 }.
		{ -2 @ 2.  2 @ 2.  2 @ 2.  2 @ -2.  -2 @ -2 }.
		{ -2 @ 2.  2 @ 2.  1.99 @ 2.01.  2 @ -2.  -2 @ -2 }.
	}.
	expectedResults := {
		4.  4.  5.
	}.
	minLength := 0.00001.
	
	points doWithIndex: [ :pointCollection :index |
		| newPolygon |
		polygon := VMPolygon new fromPoints: pointCollection.
		newPolygon := polygon mergeShortVectors: minLength.
		self assert: newPolygon size equals: (expectedResults at: index).
	].
	

]

{ #category : #tests }
VMPolygonTest >> testMergeWith [
	|polygonA polygonB intersections|
	polygonA := VMPolygon new fromPoints: {7.0@2.0. 2.0@5.5. 5.0@1.0 }.
	polygonB := VMPolygon new fromPoints: {6.5@1.3. 6.0@5.0. 1.0@2.0 }.
	{ polygonA. polygonB } asRenderableElement inspect.
	(polygonA mergeWith:  polygonB).
]

{ #category : #tests }
VMPolygonTest >> testReplaceChainWith [
	| points points2 replacementVector polygon newPolygon polygon2 |
	
	"points for the original polygon"
	points := {
		0 @ 3.  0 @ 0.  10 @ 0.  10 @ 4.
		9 @ 4.  8 @ 2.  7 @ 4.  6 @ 3.  5 @ 4.  4 @ 2.  3 @ 2.  2 @ 4.  1 @ 4.
	}.
	"points for the expected result"
	points2 := {
		0.5 @ 3.5.  0 @ 0.  10 @ 0.  9.5 @ 3.5.
	}.
	
	polygon := VMPolygon fromPoints: points.
	polygon2 := VMPolygon fromPoints: points2.
	replacementVector := VMLineSegment from: 9.5@3.5 to: 0.5@3.5 type: polygon first type.
		
	newPolygon := polygon replaceChain: (polygon collect: [:v|v] from: 4 to: 13) with: replacementVector.
	self assert: newPolygon = polygon2.

]

{ #category : #tests }
VMPolygonTest >> testTransform [
	| polygon transformedPolygon expectedResult tf |
	
	polygon := VMPolygon new fromPoints: { 1@1.  1@2.  2@2.  2@1 }.
	expectedResult := VMPolygon new fromPoints: { 3@2.  3@3.  4@3.  4@2 }.
	tf := VMTFMatrix angle:0 translation: 2@1.
	
	transformedPolygon := polygon transform: tf.
	
	self assert: transformedPolygon = expectedResult.
]

{ #category : #tests }
VMPolygonTest >> testWindingNumber [
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
		
		polygon := VMPolygon new fromPoints: pointCollection.
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
