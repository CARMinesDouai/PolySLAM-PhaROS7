Class {
	#name : #VMOldPolygonTests,
	#superclass : #Object,
	#instVars : [
		'polygons',
		'boundary'
	],
	#category : #'PolySLAM-Tests'
}

{ #category : #running }
VMOldPolygonTests >> setUp [
	| index |
	
	super setUp.
		
	polygons := OrderedCollection new.
	
	polygons add: VMDataSet dataPolygon_1.
	polygons add: VMDataSet dataPolygon_2.
	polygons add: VMDataSet dataPolygon_3.
	polygons add: VMDataSet dataPolygon_4.
	
	index := 0.
	"assign a unique id and index to every vertex"
	polygons doWithIndex: [ :p :pIndex |
		p vertices doWithIndex: [ :v :vIndex |
			index := index + 1.
			v id: (pIndex printString, '.', vIndex printString).
			v index: index.
		].
	].
	
	boundary := VMClosedPolygon fromOrderedPoints: { ( -8 @ -8). (8@ -8). (8@8). ( -8 @ 8). }.
	boundary makeCW.
	
	self logCr: '---- VMPolygonTests setup complete ----'.
	^polygons.
]

{ #category : #tests }
VMOldPolygonTests >> testExpandClosedPolygon [
	| polygonA viewer polygonAExpanded |
	
	self logCr: 'starting testExpandClosedPolygon'.
	
	polygonA :=  VMDataSet dataPolygon_1.
	polygonA makeCCW.
	polygonAExpanded := polygonA expand: 0.5.
	
	showViewer ifTrue: [
		viewer := #VMViewer bounds: (Rectangle origin: ( -10 @ -10 ) corner: (10@10) ).
		viewer addObj: boundary style: (#VMNamedOptions pairs: { {'color'. Color green.}. {'solid'. true. }. } ).
		viewer addObj: polygonA style: (#VMNamedOptions pairs: { {'color'. Color blue.}. {'solid'. false. }. {'showVertices'. true.}. } ).
		viewer addObj: polygonAExpanded style: (#VMNamedOptions pairs: { {'color'. Color cyan.}. {'solid'. false. }. {'showVertices'. true.}. } ).
	].
	
	self assert: (polygonAExpanded vertices size = 4)
	

]

{ #category : #tests }
VMOldPolygonTests >> testLineSegIntersection [
	| lineSeg segments polygon result expectedResults |
	
	segments := {
		{ 0@0. 4@0 }.		"horizontal line, miss"
		{ 0@0. 0@4. }.		"vertical line, miss"
		{ 0@0. -4 @ -4 }.	"diagonal line, miss"
		{ 0@0. 4@4 }.		"diagonal line, hitting through a corner"
		
		{ 0@4. 1@4 }.		"horizontal line, hitting a polygon side, but not punching through"
		{ 0@4. 3@4 }.		"horizontal line, punching through a side of the polygon"
		{ 0@3. 2@1 }.		"diagonal line, touching a corner"
		{ 0@4. 3@1 }.		"diagonal line, punching through two sides of the polygon"
	}.
	expectedResults := {
		false. false. false. true.
		true. true. true. true.
	}.
	
	polygon := polygons at: 1.
	
	self logCr: 'testLineSegIntersection'.
	
	segments doWithIndex: [ :s :i |
		lineSeg := VMLineSegment from: (s at: 1) to: (s at: 2).
		result := polygon intersectsWithLine: lineSeg.
		self logCr: '  ', result printString.
		self assert: ( result = (expectedResults at: i) ).
	].

]

{ #category : #tests }
VMOldPolygonTests >> testMerge [
	"tests the merging of two simple squares (VMClosedPolygon objects). the result is a single closed polygon."
	| polygonA polygonB viewer mergedPolygon |
	
	self logCr: 'starting testMerge'.
	polygonA := VMDataSet dataPolygon_1.
	polygonB := VMDataSet dataPolygon_1.
	polygonB move: 1@1.
	
	showViewer ifTrue: [
		viewer := #VMViewer bounds: (Rectangle origin: ( -10 @ -10 ) corner: (10@10) ).
		viewer addObj: polygonA style: (#VMNamedOptions pairs: { {'color'. Color blue.}. {'solid'. false. }. } ).
		viewer addObj: polygonB style: (#VMNamedOptions pairs: { {'color'. Color cyan.}. {'solid'. false.}. } ).
	].
	
	mergedPolygon := polygonA merge: { polygonB. }.
	showViewer ifTrue: [
		viewer addObj: mergedPolygon style: (#VMNamedOptions pairs: { {'color'. Color yellow.}. {'solid'. false.}. {'style'. 'dashed'}. } ).
	].
	
	self assert: (mergedPolygon vertices size = 8).

]

{ #category : #tests }
VMOldPolygonTests >> testMerge2 [
	"merging a square and a triangle into a single closed polygon."
	| polygonA polygonB viewer mergedPolygon |
	
	self logCr: 'starting testMerge2'.
	polygonA := VMDataSet dataPolygon_1.
	polygonB := VMDataSet dataPolygon_5.
	polygonB move: (-1 @ 1).
	polygonA makeCCW.
	
	showViewer ifTrue: [
		viewer := #VMViewer bounds: (Rectangle origin: ( -10 @ -10 ) corner: (15@15) ).
		viewer addObj: polygonA style: (#VMNamedOptions pairs: { {'color'. Color blue.}. {'solid'. true. }. } ).
		viewer addObj: polygonB style: (#VMNamedOptions pairs: { {'color'. Color cyan.}. {'solid'. true. }.  } ).
	].

	mergedPolygon := polygonA merge: { polygonB. }.
	mergedPolygon vertices doWithIndex: [ :v :i |
		v id: i.
	].
	
	showViewer ifTrue: [
		viewer addObj: mergedPolygon style: (#VMNamedOptions pairs: { {'color'. Color red.}. {'solid'. false.}. {'style'. 'dashed'}. {'showVertices'. true.}. {'dashSize'. {0.2}}. } ).
	].

	self assert: (mergedPolygon vertices size = 8).
	
]

{ #category : #tests }
VMOldPolygonTests >> testMerge3 [
	"merging the map boundary (a polygon with CW winding order) with two obstacles (closed polygons with CCW winding order)"
	| polygonA polygonB viewer mergedPolygon |
	
	self logCr: 'starting testMerge3'.
	polygonA := VMDataSet dataPolygon_1.
	polygonB := VMDataSet dataPolygon_1.
	polygonA move: 0@3.
	polygonB move: -10@0.
	polygonA makeCCW.
	polygonB makeCCW.
	
	showViewer ifTrue: [
		viewer := #VMViewer bounds: (Rectangle origin: ( -10 @ -10 ) corner: (10@10) ).
		viewer addObj: boundary style: (#VMNamedOptions pairs: { {'color'. Color green.}. {'solid'. true. }. } ).
		viewer addObj: polygonA style: (#VMNamedOptions pairs: { {'color'. Color blue.}. {'solid'. true. }. } ).
		viewer addObj: polygonB style: (#VMNamedOptions pairs: { {'color'. Color cyan.}. {'solid'. true. }. } ).
	].

	mergedPolygon := boundary merge: { polygonA. polygonB. }.
	mergedPolygon vertices doWithIndex: [ :v :i |
		v id: i.
	].

	showViewer ifTrue: [
		viewer addObj: mergedPolygon style: (#VMNamedOptions pairs: { {'color'. Color red.}. {'solid'. false.}. {'showVertices'. true.}. {'style'. 'dashed'}. {'dashSize'. {0.2}}. } ).
	].

	self assert: (mergedPolygon vertices size = 8) "should be 12?"
	
]

{ #category : #tests }
VMOldPolygonTests >> testMerge4 [
	"this is a special case that currently fails. it is similar to the previous test case, but the starting
	vertex choosen by the mergin algorithm would not be part of the correctly merged polygon,
	hence the algorithm fails"
	| polygonA polygonB viewer mergedPolygon |
	
	self logCr: 'starting testMerge4'.
	polygonA := VMDataSet dataPolygon_1.
	polygonB := VMDataSet dataPolygon_1.
	polygonA move: 0@3.
	polygonB move: 5@0.
	polygonA makeCCW.
	polygonB makeCCW.
	
	showViewer ifTrue: [
		viewer := #VMViewer bounds: (Rectangle origin: ( -10 @ -10 ) corner: (10@10) ).
		viewer addObj: boundary style: (#VMNamedOptions pairs: { {'color'. Color green.}. {'solid'. true. }. } ).
		viewer addObj: polygonA style: (#VMNamedOptions pairs: { {'color'. Color blue.}. {'solid'. true. }. } ).
		viewer addObj: polygonB style: (#VMNamedOptions pairs: { {'color'. Color cyan.}. {'solid'. true. }. } ).
	].

	mergedPolygon := boundary merge: { polygonA. polygonB. }.
	mergedPolygon vertices doWithIndex: [ :v :i |
		v id: i.
	].

	showViewer ifTrue: [
		viewer addObj: mergedPolygon style: (#VMNamedOptions pairs: { {'color'. Color red.}. {'solid'. false.}. {'style'. 'dashed'}. {'showVertices'. true.}. {'dashSize'. {0.2}}. } ).
	].

	self assert: (mergedPolygon vertices size = 8). "should be 4?"
	

]

{ #category : #tests }
VMOldPolygonTests >> testMerge5 [
	"note: this test failed until we added a tolerance to the merging's line-intersection test to compensate for numerical issues"
	| polygonA polygonB polygonC viewer mergedPolygon |
	
	self logCr: 'starting testMerge5'.
	
	polygonA := (VMDataSet dataPolygon_1)
		move: 0@ -1;
		makeCCW;
		yourself.
	
	polygonB := (VMDataSet dataPolygon_1)
		move: -6 @ -5;
		makeCCW;
		yourself.
	
	polygonC := (VMIsolatedPoint fromPoint: 0@0) expand: 2.0 segCount: 8.
	polygonC makeCCW.
	
	showViewer ifTrue: [
		viewer := #VMViewer bounds: (Rectangle origin: ( -10 @ -10 ) corner: (10@10) ).
		viewer addObj: boundary style: (#VMNamedOptions pairs: { {'color'. Color green.}. {'solid'. true. }. } ).
		viewer addObj: polygonA style: (#VMNamedOptions pairs: { {'color'. Color blue.}. {'solid'. true. }. } ).
		viewer addObj: polygonB style: (#VMNamedOptions pairs: { {'color'. Color cyan.}. {'solid'. true. }. } ).
		viewer addObj: polygonC style: (#VMNamedOptions pairs: { {'color'. Color orange.}. {'solid'. true. }. } ).
	].
	
	mergedPolygon := polygonC merge: { polygonA. polygonB. }.
	mergedPolygon vertices doWithIndex: [ :v :i |
		v id: i.
	].

	showViewer ifTrue: [
		viewer addObj: mergedPolygon style: (#VMNamedOptions pairs: { {'color'. Color red.}. {'solid'. false.}. {'style'. 'dashed'}. {'showVertices'. true.}. {'dashSize'. {0.2}}. } ).
	].
	
	self assert: (mergedPolygon vertices size = 15).
	
]

{ #category : #tests }
VMOldPolygonTests >> testPointsInside [
	
	| data testVecs polygon expectedResults |
	
	"vectors that start at pointing to the right and rotate in 45 deg steps"
	testVecs := {
		2@0. 2@2. 0@2. -2@2. -2@0. -2@ -2. 0@ -2. 2@ -2.
	}.

	expectedResults := {
		{ true. true. true. true. false. false. false. true }.		"first polygon, cw"
		{ false. false. false. false. false. true. false. false }	"first polygon, ccw"
	}.
	
	data := self dataPolygon_Triangles.
	
	polygon := data at: 1.
	
	Transcript show: (polygon) printString; cr.
	testVecs doWithIndex: [ :v :i |
		self assert: (  (polygon pointsInward: v index: 1) = ((expectedResults at: 1) at: i)  ).
	].
	
	polygon makeCCW.
	Transcript show: (polygon) printString; cr.
	testVecs doWithIndex: [ :v :i |
		self assert: (  (polygon pointsInward: v index: 3) = ((expectedResults at: 2) at: i)  ).
	].

]

{ #category : #tests }
VMOldPolygonTests >> testPointsInside2 [
	
	| testVecs polygon expectedResults |
	
	"vectors that start at pointing to the right and rotate in 45 deg steps"
	testVecs := {
		2@0. 2@2. 0@2. -2@2. -2@0. -2@ -2. 0@ -2. 2@ -2.
	}.

	expectedResults := {
		{ false. false. true. false. false. false. false. false }.		"first polygon, cw"
		{ true. false. false. false. true. true. true. true }	"first polygon, ccw"
	}.
	
	polygon := VMDataSet dataPolygon_2.	"a dimond shaped polygon"
	
	Transcript show: (polygon) printStringEx; cr.
	testVecs doWithIndex: [ :v :i |
		self assert: (  (polygon pointsInward: v index: 1) = ((expectedResults at: 1) at: i)  ).
		"Transcript show: 'point=', (polygon vertices at:1)printString, ' v=', v printString, ' inwards=', (polygon pointsInward: v index: 1)printString; cr."
	].
	
	polygon makeCW.
	Transcript show: (polygon) printStringEx; cr.
	testVecs doWithIndex: [ :v :i |
		self assert: (  (polygon pointsInward: v index: 4) = ((expectedResults at: 2) at: i)  ).
		"Transcript show: 'point=', (polygon vertices at:4)printString, ' v=', v printString, ' inwards=', (polygon pointsInward: v index: 4)printString; cr."
	].

]

{ #category : #tests }
VMOldPolygonTests >> testPointsInside3 [
	
	| testVecs polygon expectedResults |
	
	"vectors that start at pointing to the right and rotate in 45 deg steps"
	testVecs := {
		2@0. 2@2. 0@2. -2@2. -2@0. -2@ -2. 0@ -2. 2@ -2.
	}.

	expectedResults := {
		{ false. false. false. true. true. true. true. true }.		"first polygon, cw"
		{ false. true. false. false. false. false. false. false }	"first polygon, ccw"
	}.
	
	polygon := VMDataSet dataPolygon_1.	"a square shaped polygon"
	
	"Transcript show: (polygon) printStringEx; cr."
	testVecs doWithIndex: [ :v :i |
		self assert: (  (polygon pointsInward: v index: 1) = ((expectedResults at: 1) at: i)  ).
		"Transcript show: 'point=', (polygon vertices at:1)printString, ' v=', v printString, ' inwards=', (polygon pointsInward: v index: 1)printString; cr."
	].
	
	polygon makeCCW.
	"Transcript show: (polygon) printStringEx; cr."
	testVecs doWithIndex: [ :v :i |
		self assert: (  (polygon pointsInward: v index: 4) = ((expectedResults at: 2) at: i)  ).
		"Transcript show: 'point=', (polygon vertices at:4)printString, ' v=', v printString, ' inwards=', (polygon pointsInward: v index: 4)printString; cr."
	].

]

{ #category : #tests }
VMOldPolygonTests >> testPointsInside4 [
	
	| testVecs polygon expectedResults |
	
	"vectors that start at pointing to the right and rotate in 45 deg steps"
	testVecs := {
		4@0. 4@4. 0@4. -4@4. -4@0. -4@ -4. 0@ -4. 4@ -4.
	}.

	expectedResults := {
		{ false. false. false. true. true. true. true. true }.		"first polygon, cw"
		{ false. true. false. false. false. false. false. false }	"first polygon, ccw"
	}.
	
	polygon := VMDataSet dataPolygon_1.	"a square shaped polygon"
	
	"Transcript show: (polygon) printStringEx; cr."
	testVecs doWithIndex: [ :v :i |
		self assert: (  (polygon pointsInward: v index: 1) = ((expectedResults at: 1) at: i)  ).
		Transcript show: 'point=', (polygon vertices at:1)printString, ' v=', v printString, ' inwards=', (polygon pointsInward: v index: 1)printString; cr.
	].
	
	polygon makeCCW.
	"Transcript show: (polygon) printStringEx; cr."
	testVecs doWithIndex: [ :v :i |
		self assert: (  (polygon pointsInward: v index: 4) = ((expectedResults at: 2) at: i)  ).
		Transcript show: 'point=', (polygon vertices at:4)printString, ' v=', v printString, ' inwards=', (polygon pointsInward: v index: 4)printString; cr.
	].

]

{ #category : #tests }
VMOldPolygonTests >> testSelfMerge [
	"testing self-mergin of a polygon chain after expanding it."
	| polygonA viewer mergedPolygon polyChain |
	
	self logCr: 'starting testSelfMerge'.
	
	polyChain := (VMPolygonChain  fromOrderedPoints: { -3@ -3.  -3@2.  -2.2@0.  3@1. } ).
	polygonA := polyChain expand: 0.5.
	polygonA makeCCW.
	
	showViewer ifTrue: [
		viewer := VMViewer bounds: (Rectangle origin: ( -10 @ -10 ) corner: (10@10) ).
		viewer addObj: boundary style: (VMNamedOptions pairs: { {'color'. Color green.}. {'solid'. true. }. } ).
		viewer addObj: polygonA style: (VMNamedOptions pairs: { {'color'. Color blue.}. {'solid'. true. }. {'showVertices'. true.}. } ).
		viewer addObj: polyChain style: (VMNamedOptions pairs: { {'color'. Color blue.}. {'solid'. true. }. {'showVertices'. true.}. } ).
	].
	
	mergedPolygon := polygonA merge: {}.
	mergedPolygon vertices doWithIndex: [ :v :i |
		v id: i.
	].

	showViewer ifTrue: [
		"viewer addObj: mergedPolygon style: (VMNamedOptions pairs: { {'color'. Color red.}. {'solid'. false.}. {'style'. 'dashed'}. {'showVertices'. true.}. {'dashSize'. {0.2}}. } )."
	].
	
	"self assert: (mergedPolygon vertices size = 15).
	
	1 halt."
]

{ #category : #tests }
VMOldPolygonTests >> testSelfMerge2 [
	"testing self-mergin of a polygon chain after expanding it."
	| polygonA viewer mergedPolygon polyChain |
	
	self logCr: 'starting testSelfMerge2'.
	
	polyChain := (VMPolygonChain  fromOrderedPoints: { -3@ -3.  -3@2.  -2.3@0.  3@1. } ).
	polygonA := polyChain expand: 0.5.
	polygonA makeCCW.
	
	showViewer ifTrue: [
		viewer := VMViewer bounds: (Rectangle origin: ( -10 @ -10 ) corner: (10@10) ).
		viewer addObj: boundary style: (VMNamedOptions pairs: { {'color'. Color green.}. {'solid'. true. }. } ).
		viewer addObj: polygonA style: (VMNamedOptions pairs: { {'color'. Color blue.}. {'solid'. true. }. {'showVertices'. true.}. } ).
		viewer addObj: polyChain style: (VMNamedOptions pairs: { {'color'. Color blue.}. {'solid'. true. }. {'showVertices'. true.}. } ).
	].
	
	mergedPolygon := polygonA merge: {}.
	mergedPolygon vertices doWithIndex: [ :v :i |
		v id: i.
	].

	showViewer ifTrue: [
		viewer addObj: mergedPolygon style: (VMNamedOptions pairs: { {'color'. Color red.}. {'solid'. false.}. {'style'. 'dashed'}. {'dashSize'. {0.2}}. } ).
	].
	
	"self assert: (mergedPolygon vertices size = 15).
	
	1 halt."
]

{ #category : #tests }
VMOldPolygonTests >> testSelfMerge3 [
	"testing self-mergin of a polygon chain after expanding it."
	| polygonA viewer mergedPolygon polyChain |
	
	self logCr: 'starting testSelfMerge3'.
	
	polyChain := (VMPolygonChain  fromOrderedPoints: { -0.4@ -3.  -3@ -3.  -3@3.  3@3.  3@ -3.3. 0.4@ -3.3 } ).
	polygonA := polyChain expand: 0.5.
	polygonA makeCCW.
	
	showViewer ifTrue: [
		viewer := VMViewer bounds: (Rectangle origin: ( -10 @ -10 ) corner: (10@10) ).
		viewer addObj: boundary style: (VMNamedOptions pairs: { {'color'. Color green.}. {'solid'. true. }. } ).
		viewer addObj: polygonA style: (VMNamedOptions pairs: { {'color'. Color blue.}. {'solid'. true. }. } ).
		viewer addObj: polyChain style: (VMNamedOptions pairs: { {'color'. Color blue.}. {'solid'. true. }. {'showVertices'. true.}. } ).
	].
	
	mergedPolygon := polygonA merge: {}.
	mergedPolygon vertices doWithIndex: [ :v :i |
		v id: i.
	].

	showViewer ifTrue: [
		viewer addObj: mergedPolygon style: (VMNamedOptions pairs: { {'color'. Color red.}. {'solid'. false.}. {'style'. 'dashed'}. {'showVertices'. true.}. {'dashSize'. {0.2}}. } ).
	].
	
	self assert: (mergedPolygon vertices size = 6)
	
	"1 halt."
]

{ #category : #tests }
VMOldPolygonTests >> testWindingOrder [
	"checks the winding order of several polygons which are defined in dataPolygon_Triangles.
	each test polygon comes in a cw and ccw version. the polygons cover all basic configurations
	that may occure."
	| data |
	
	data := self dataPolygon_Triangles.
	
	data doWithIndex: [ :p :i |
		Transcript show: i printString, ' cw=', (p cw)printString; cr.
	].
	
	self assert: ((data at: 1) cw) = true.
	self assert: ((data at: 2) cw) = false.
	
	self assert: ((data at: 3) cw) = true.
	self assert: ((data at: 4) cw) = false.
	
	self assert: ((data at: 5) cw) = false.
	self assert: ((data at: 6) cw) = true.
	
	self assert: ((data at: 7) cw) = true.
	self assert: ((data at: 8) cw) = false.
	
	self assert: ((data at: 9) cw) = false.
	self assert: ((data at: 10) cw) = true.
	
	self assert: ((data at: 11) cw) = false.
	self assert: ((data at: 12) cw) = true.
	
	self assert: ((data at: 13) cw) = true.
	self assert: ((data at: 14) cw) = false.
	
	self assert: ((data at: 15) cw) = true.
	self assert: ((data at: 16) cw) = false.
	"1 halt."
]
