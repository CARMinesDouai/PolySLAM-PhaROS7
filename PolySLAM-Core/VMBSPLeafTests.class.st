Class {
	#name : #VMBSPLeafTests,
	#superclass : #VMTests,
	#category : #'PolySLAM-Core-SLAM - Maps'
}

{ #category : #tests }
VMBSPLeafTests >> testCreatePlaneForPolygonIfNoneDo [
	"we create two sectors that share a common line segment. #createPlaneForPolygon: 
	is expected to return the shared line segment, since it is the only one that
	has all line segments of the second sector on the 'correct' side."
	| pointsA pointsB sectorA sectorB root plane |
	
	pointsA := { -2 @ 2.  0.2 @ 2.  0.4 @ -1.  2.2 @ -1. }.
	pointsB := { 0.2 @ 2.  2.2 @ 2.  2.2 @ -1.  0.4 @ -1. }.
	
	sectorA := VMSector new fromPoints: pointsA.
	sectorB := VMSector new fromPoints: pointsB.
	
	root := VMBSPLeaf parent: nil sector: sectorA.
	plane := root createPlaneForPolygon: sectorB ifNoneDo: [ self assert: false ].
	
	self assert: plane pointA equals: pointsA second.
	self assert: plane pointB equals: pointsA third.
	
	

]

{ #category : #tests }
VMBSPLeafTests >> testFindNearest [
	"testing #findNearest: with a bunch of points on a relatively simple but not trival BSP tree"
	| root points types polygons testPoints expectedResults renderCollection |
	
	points := {
		{ -2 @ -1.  2 @ -1.  2 @ 1.  -2 @ 1. }.
		{ -1 @ -2.  1 @ -2.  1 @ 2.  -1 @ 2. }.
	}.
	types := {
		{ 2.  1.  2.  1. }.
		{ 1.  2.  1.  2. }.
	}.
	testPoints := {      -3 @ 0.  -0.5@0.25.  0.5 @ 1.  1.25@1.75 }.
	expectedResults := { -2 @ 0.  -2 @ 0.25.  0.5 @ 2.    1 @ 2. }.
	renderCollection := OrderedCollection new.
	
	polygons := points with: types collect: [ :pointCollection :typesCollection |
		VMPolygon fromPoints: pointCollection withTypes: typesCollection
	].
	
	root := VMBSPLeaf new.
	polygons do: [ :p | root := root insert: p ].
	testPoints with: expectedResults do: [ :testPoint :expectedPoint |
		| result |
		
		result := root findNearest: testPoint.
		self assert: (result object dist: expectedPoint) < 0.0000001.
		
		renderCollection add:
			((VMLineSegment from: testPoint to: result object) asRenderableElement
				color: Color cyan;
				lineWidth: 0.04).
	].

	renderCollection addFirst: root asRenderableElement.
	"renderCollection asRenderableElement inspect."
	
	
]

{ #category : #tests }
VMBSPLeafTests >> testFindSectorByLineSeg [
	"note: this tree is currently broken. the dataset needs to be changed
	(the polygons' winding order is wrong), and the process of creating
	a hyperplane has changed too (resulting in a different order of left/right
	children to follow."
"	| polygons root sector results |
	
	polygons := VMDataSet toyExample_polygons.

	root := VMBSPLeaf new.
	
	root := root insert: polygons first.
	root := root insert: polygons second.
	root := root insert: polygons third.
	root := root insert: polygons fourth.
	
	sector := root rightChild rightChild rightChild leftChild rightChild rightChild sector.
	results := sector select: [ :lineSeg | lineSeg type isSector ] thenCollect: [ :lineSeg |
		root findSectorByLineSeg: lineSeg reversed		
	].
	
	self assert: results size equals: 4.
	results do: [ :obj |
		self assert: obj isNotNil.
	]."

]

{ #category : #tests }
VMBSPLeafTests >> testInsert [
	| points polygons expectedResults tree |
	
	points := {
		{ -2 @ 2.  2 @ 2.  2 @ -2.  -2 @ -2 }. "the starting polygon - a square"
		{ -1 @ 1.  1 @ 1.  1 @ -1.  -1 @ -1 }. "a smaller square the fits inside the first polygon"
		{ -2 @ 2.  2 @ 2.  2 @ 0.  -2 @ 0 }. "a rectangle that is half the size of the first polygon, and lies inside the first polygon, touching it on three sides"
		{ 4 @ 2.  6 @ 2.  6 @ -2.  4 @ -2. }. "another rectangle, outside and not touching any of the other polygons"
	}.
	
	expectedResults := {
		1.  1.  1.  2.
	}.
	
	polygons := points collect: [ :pointCollection |
		VMPolygon new fromPoints: pointCollection
	].

	polygons second do: [ :lineSeg |
		lineSeg type: VMLineTypeFrontier new.
	].
	
	tree := VMBSPLeaf new.
	
	polygons doWithIndex: [ :polygon :index |
		tree := tree insert: polygon.
		self assert: tree sectorCount equals: (expectedResults at: index).
	].

]

{ #category : #tests }
VMBSPLeafTests >> testInsert2 [
	"merging two rectangular polygons"
	| points polygons expectedResults tree |
	
	points := {
		{ -2 @ 1.  2 @ 1.  2 @ -1.  -2 @ -1 }.
		{ -1 @ 2.  1 @ 2.  1 @ -2.  -1 @ -2 }.
	}.
	
	expectedResults := {
		1.  1.  1.  2.
	}.
	
	polygons := points collect: [ :pointCollection |
		VMPolygon new fromPoints: pointCollection
	].
	polygons := polygons collect: [ :p |
		p do: [ :ls | ls type: VMLineTypeObstacle new. ].
		p reversed
	].
	
	tree := VMBSPLeaf new.
	
	polygons doWithIndex: [ :polygon :index |
		tree := tree insert: polygon.
		"self assert: tree sectorCount equals: (expectedResults at: index)."
	].
	
	tree inspect.


]

{ #category : #tests }
VMBSPLeafTests >> testInsert2b [
	"same as #testInsert2 but with the polygons modelling obstacles instead of free space"
	| points polygons expectedResults tree |
	
	points := {
		{ -2 @ 1.  2 @ 1.  2 @ -1.  -2 @ -1 }.
		{ -1 @ 2.  1 @ 2.  1 @ -2.  -1 @ -2 }.
	}.
	
	expectedResults := {
		1.  1.  1.  2.
	}.
	
	polygons := points collect: [ :pointCollection |
		VMPolygon new fromPoints: pointCollection
	].
	polygons do: [ :p |
		p do: [ :ls | ls type: VMLineTypeObstacle new. ].
	].
	
	tree := VMBSPLeaf new.
	
	polygons doWithIndex: [ :polygon :index |
		tree := tree insert: polygon.
		"self assert: tree sectorCount equals: (expectedResults at: index)."
	].
	
	"tree inspect."


]

{ #category : #tests }
VMBSPLeafTests >> testInsert3 [
	| points types  polygons tree tfMatrix |
	
	points := { -2 @ -2.  2 @ -2.  2 @ 2.  -2 @ 2 }.
	types := { 1.  1.  2.  2. }.
	
	polygons := OrderedCollection new.
	polygons add: (VMPolygon new fromPoints: points withTypes: types).
	
	1 to: 10 do: [ :i |
		tfMatrix := VMTFMatrix angle: (Float twoPi * 45 / 360.0 / i) translation: 0@0.
		polygons add: (polygons first transform: tfMatrix).
	].	

	tree := VMBSPLeaf new.
	tree := tree insert: polygons first.
	
	polygons allButFirstDo: [ :p |
		tree := tree insert: p.
	].
	tree inspect.

]

{ #category : #tests }
VMBSPLeafTests >> testInsertVector [
	| polygon leaf |
	
	polygon := VMPolygon fromPoints: { 0@0.  4@0. 4@4. 0@4. } withTypes: { 2. 2. 2. 2. }.
	leaf := VMBSPLeaf new sector: polygon copy; yourself.
	leaf insertVector: (1@0 vectorTo: 3@0 type: 1).
	self assert: leaf sector size equals: 6.
	leaf insertVector: (4@2 vectorTo: 4@2.5 type: 1).
	self assert: leaf sector size equals: 8.
	self assert: leaf sector isClosed.
	
	polygon := VMPolygon fromPoints: { 0@0.  4@0. 4@4. 0@4. } withTypes: { 2. 2. 2. 2. }.
	leaf := VMBSPLeaf new sector: polygon copy; yourself.
	leaf insertVector: (0@0 vectorTo: 2@0 type: 1).
	self assert: leaf sector size equals: 5.
	self assert: leaf sector isClosed.
	self assert: leaf sector containsZeroLengthVectors not.
	
	polygon := VMPolygon fromPoints: { 0@0.  4@0. 4@4. 0@4. } withTypes: { 2. 2. 2. 2. }.
	leaf := VMBSPLeaf new sector: polygon copy; yourself.
	leaf insertVector: (2@0 vectorTo: 4@0 type: 1).
	self assert: leaf sector size equals: 5.
	self assert: leaf sector isClosed.
	self assert: leaf sector containsZeroLengthVectors not.
	
	polygon := VMPolygon fromPoints: { 0@0. 2@0. 4@0. 4@4. 0@4. } withTypes: { 2. 2. 2. 2. 2. }.
	leaf := VMBSPLeaf new sector: polygon; yourself.
	leaf insertVector: (1@0 vectorTo: 3@0 type: 1).
	self assert: leaf sector size equals: 7.
	self assert: leaf sector isClosed.
	self assert: leaf sector containsZeroLengthVectors not.

]

{ #category : #tests }
VMBSPLeafTests >> testSectorNeighbors [
	"note: this tree is currently broken. the dataset needs to be changed
	(the polygons' winding order is wrong), and the process of creating
	a hyperplane has changed too (resulting in a different order of left/right
	children to follow."
"	| polygons root leaf results |
	
	polygons := VMDataSet toyExample_polygons.

	root := VMBSPLeaf new.
	
	root := root insert: polygons first.
	root := root insert: polygons second.
	root := root insert: polygons third.
	root := root insert: polygons fourth.
	
	leaf := root rightChild rightChild rightChild leftChild rightChild rightChild.
	results := leaf sectorNeighbors.
	
	self assert: results size equals: 4.
	results do: [ :obj |
		self assert: obj isNotNil.
	]."

]
