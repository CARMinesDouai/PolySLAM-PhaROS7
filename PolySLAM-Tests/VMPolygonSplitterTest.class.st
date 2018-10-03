Class {
	#name : #VMPolygonSplitterTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
VMPolygonSplitterTest >> testSplitOnPlane [
	"this test is splitting a polygon on one of its sides. this should result
	in all line segments to end up on the same side of the plane. we perform
	this test with a CW oriented polygon, and repeat it with a CCW oriented
	polygon."
	| points polygon splitter |
	
	"points := { -2 @ 2.  2 @ 2.  2 @ -2.  -2 @ -2. }."
	points := { -2.0 @ 2.0.  2.0 @ 2.0.  2.0 @ -2.0.  -2.0 @ -2.0. }.
	polygon := VMPolygon new fromPoints: points.
	splitter := VMPolygonSplitter new.
	
	splitter split: polygon onPlane: polygon first.
	
	self assert: splitter tempLeft size equals: 0.
	self assert: splitter tempRight size equals: 4.
	
	polygon := VMPolygon new fromPoints: points reversed.
	splitter split: polygon onPlane: polygon first.
	
	self assert: splitter tempLeft size equals: 4.
	self assert: splitter tempRight size equals: 0.
	

]

{ #category : #tests }
VMPolygonSplitterTest >> testSplitOnPlane10 [
	"this test is based on a data set (from the simulator) that used to cause the splitter to fail"
	| points polygon plane splitter |
	
	points := { 	(1@ -3.5). (0.8429043424786993@ -3.4249755821324603). (0.5738574187970265@ -3.3467541843420645). (0.6@ -3). (1@ -3). }.
	polygon := VMPolygon new fromPoints: points.
	splitter := VMPolygonSplitter new.
	plane := VMLineSegment pointA: (2.9627846794208335@ -4.15961098091387) pointB: (2.6560410393609537@ -4.055242978329907).
	
	"the test is successfull if the line below doesn't rise a signal"
	splitter split: polygon onPlane: plane.

]

{ #category : #tests }
VMPolygonSplitterTest >> testSplitOnPlane11 [
	"test case for a bug that appears when our data set contains very short line segments
	(e.g. length under 1e-12)"
	| polygon plane splitter |
	
	polygon := VMPolygon new fromPoints: {
		(-8.820204456999727@6.107730157777025). (-8.423612441731107@9.60567173244626).
		(-8.42361244173093@9.605671732447826). (-8.754462231966034@9.637416200874911).
		(-8.991977062612314@9.568090625725237). (-8.98901411639434@6.2278366275245105).
	}.

	plane := VMLine pointA: (-8.423612441731107@9.60567173244626) pointB: (-8.42361244173093@9.605671732447826).

	splitter := VMPolygonSplitter new.
	splitter split: polygon onPlane: plane.
	"expecting: 'error: failed to find a matching line segment...'
	should be: sielently splitting without any failure"

]

{ #category : #tests }
VMPolygonSplitterTest >> testSplitOnPlane2 [
	"this test splits a rectangle into two equal halfs. the hyperplane is parallel to the y-axis"
	| points polygon plane splitter |
	
	points := { -2 @ 2.  2 @ 2.  2 @ -2.  -2@ -2. }.
	polygon := VMPolygon new fromPoints: points.
	splitter := VMPolygonSplitter new.
	plane := VMLineSegment pointA: 0@2 pointB: 0@ -2.
	
	splitter split: polygon onPlane: plane.
	
	self assert: splitter tempLeft size equals: 3.
	self assert: splitter tempRight size equals: 3.
	
	self assert: splitter leftPolygons size equals: 1.
	self assert: splitter rightPolygons size equals: 1.
	
	"flip the direction of the hyperplane and repeat"
	splitter := VMPolygonSplitter new.
	plane := VMLineSegment pointA: 0@ -2 pointB: 0@ 2.
	
	splitter split: polygon onPlane: plane.
	
	self assert: splitter tempLeft size equals: 3.
	self assert: splitter tempRight size equals: 3.
	
	self assert: splitter leftPolygons size equals: 1.
	self assert: splitter rightPolygons size equals: 1.
]

{ #category : #tests }
VMPolygonSplitterTest >> testSplitOnPlane3 [
	"this test splits a polygon into three new polygons. the plane is not colinear with any line segment of the original polygon."
	| points polygon plane splitter |
	
	points := { -2 @ 2.  2 @ 2.  2 @ 1.  0 @ 1.  0 @ -1.  2 @ -1.  2 @ -2.  -2@ -2. }.
	polygon := VMPolygon new fromPoints: points.
	splitter := VMPolygonSplitter new.
	plane := VMLineSegment pointA: 1@2 pointB: 1@ -2.
	
	splitter split: polygon onPlane: plane.
	
	self assert: splitter leftPolygons size equals: 2.
	self assert: splitter rightPolygons size equals: 1.

]

{ #category : #tests }
VMPolygonSplitterTest >> testSplitOnPlane4 [
	"this test splits a polygon into three new polygons. the plane is  colinear with one of the line segments of the original polygon."
	| points polygon plane splitter |
	
	points := { -2 @ 2.  2 @ 2.  2 @ 1.  0 @ 1.  0 @ -1.  2 @ -1.  2 @ -2.  -2@ -2. }.
	polygon := VMPolygon new fromPoints: points.
	splitter := VMPolygonSplitter new.
	plane := VMLineSegment pointA: 0@2 pointB: 0@ -2.
	
	splitter split: polygon onPlane: plane.
	
	self assert: splitter leftPolygons size equals: 2.
	self assert: splitter rightPolygons size equals: 1.

]

{ #category : #tests }
VMPolygonSplitterTest >> testSplitOnPlane5 [
	"this test has a single corner on the hyperplane, and another line segment that is plit in half by the hyperplane."
	| points polygon plane splitter |
	
	points := { -2 @ 0.  0 @ 2.  2 @ 0. }.
	polygon := VMPolygon new fromPoints: points.
	splitter := VMPolygonSplitter new.
	plane := VMLineSegment pointA: 0@2 pointB: 0@ -2.
	
	splitter split: polygon onPlane: plane.
	
	self assert: splitter leftPolygons size equals: 1.
	self assert: splitter rightPolygons size equals: 1.

]

{ #category : #tests }
VMPolygonSplitterTest >> testSplitOnPlane6 [
	| points polygon plane splitter leftResult rightResult |
	
	points := { -2 @ 2.  2 @ 2.  2 @ 0.  0 @ 0.  0 @ -2.  -2 @ -2 }.
	leftResult := VMPolygon new fromPoints: { -2 @ 2.  0 @ 2.  0 @ 0.  0 @ -2.  -2 @ -2 }.
	rightResult := VMPolygon new fromPoints: { 0 @ 2.  2 @ 2.  2 @ 0.  0 @ 0 }.
	leftResult second type: VMLineTypeSector new.
	rightResult fourth type: VMLineTypeSector new.
	polygon := VMPolygon new fromPoints: points.
	splitter := VMPolygonSplitter new.
	plane := VMLineSegment pointA: 0@2 pointB: 0@ -2.
	
	splitter split: polygon onPlane: plane.
	
	self assert: splitter leftPolygons size equals: 1.
	self assert: splitter rightPolygons size equals: 1.
	
	self assert: (splitter leftPolygons first isSimilarTo: rightResult).
	self assert: (splitter rightPolygons first isSimilarTo: leftResult).

]

{ #category : #tests }
VMPolygonSplitterTest >> testSplitOnPlane7 [
	"this test has a single corner on the hyperplane"
	| points polygon plane splitter |
	
	points := { -2 @ 2.  0 @ 2.  -2 @ -2. }.
	polygon := VMPolygon new fromPoints: points.
	splitter := VMPolygonSplitter new.
	plane := VMLineSegment pointA: 2@2 pointB: 2@ -2.
	
	splitter split: polygon onPlane: plane.
	
	self assert: splitter leftPolygons size equals: 0.
	self assert: splitter rightPolygons size equals: 1.
	self assert: splitter rightPolygons first = polygon.

]

{ #category : #tests }
VMPolygonSplitterTest >> testSplitOnPlane8 [
	| points polygon plane splitter leftResult rightResult |
	
	points := { -2 @ 2.  2 @ 2.  2 @ 0.  0 @ 0.  0 @ -2.  -2 @ -2 }.
	leftResult := VMPolygon new fromPoints: { -2 @ 2.  0 @ 2.  0 @ 0.  0 @ -2.  -2 @ -2 }.
	rightResult := VMPolygon new fromPoints: { 0 @ 2.  2 @ 2.  2 @ 0.  0 @ 0 }.
	leftResult second type: VMLineTypeSector new.
	rightResult fourth type: VMLineTypeSector new.
	polygon := VMPolygon new fromPoints: points.
	splitter := VMPolygonSplitter new.
	plane := VMLineSegment pointA: 0@ -2 pointB: 0@ 2.
	
	splitter split: polygon onPlane: plane.
	
	self assert: splitter leftPolygons size equals: 1.
	self assert: splitter rightPolygons size equals: 1.
	
	self assert: (splitter leftPolygons first isSimilarTo: leftResult).
	self assert: (splitter rightPolygons first isSimilarTo: rightResult).
	

]

{ #category : #tests }
VMPolygonSplitterTest >> testSplitOnPlane9 [
	"this test splits a rectangle into two equal halfs. the hyperplane is parallel to the x-axis"
	| points polygon plane splitter |
	
	points := { -2 @ 2.  2 @ 2.  2 @ -2.  -2@ -2. }.
	polygon := VMPolygon new fromPoints: points.
	splitter := VMPolygonSplitter new.
	plane := VMLineSegment pointA: -2@0 pointB: 2@0.
	
	splitter split: polygon onPlane: plane.
	
	self assert: splitter tempLeft size equals: 3.
	self assert: splitter tempRight size equals: 3.
	
	self assert: splitter leftPolygons size equals: 1.
	self assert: splitter rightPolygons size equals: 1.
	
	"flip the direction of the hyperplane and repeat"
	splitter := VMPolygonSplitter new.
	plane := VMLineSegment pointA: 2@0 pointB: -2@0.
	
	splitter split: polygon onPlane: plane.
	
	self assert: splitter tempLeft size equals: 3.
	self assert: splitter tempRight size equals: 3.
	
	self assert: splitter leftPolygons size equals: 1.
	self assert: splitter rightPolygons size equals: 1.
]
