Class {
	#name : #VMDataSet,
	#superclass : #Object,
	#category : #'PolySLAM-Extra-Examples'
}

{ #category : #'obsolete / unused' }
VMDataSet class >> dataLocalMap_1 [
	"a very small local map, designed to test the map merging on stright line segments.
	this local map has a 'gap' (a frontier) that should be filled when merged with the local
	map from dataLocalMap_2."
	| data lineSegments localMap obst front |
	obst := VMLineTypeObstacle new.
	front := VMLineTypeFrontier new.
	
	data := {
		{ 0@0. 2@0. obst }.
		{ 2@0. 4@0. obst }.
		{ 4@0. 6@0. front }.
		{ 6@0. 8@0. obst }.
		{ 8@0. 10@0. obst }.
		{ 10@0. 5@5. front }.
		{ 5@5. 0@0. front }.
	}.
	
	lineSegments := data asOrderedCollection collect: [ :obj |
		(VMLineSegment from: obj first to: obj second type: (obj third))
	].
	
	localMap := (VMLocalMap new)
		lineSegments: lineSegments;
		yourself.
	
	^localMap.
	
]

{ #category : #'obsolete / unused' }
VMDataSet class >> dataLocalMap_2 [
	"a very small local map, designed to test the map merging on stright line segments.
	this local map is meant to be used in conjungtion with dataLocalMap_1."
	| data lineSegments localMap obst front |
	obst := VMLineTypeObstacle new.
	front := VMLineTypeFrontier new.
	
	data := {
		{ 1@0. 3@0. obst }.
		{ 3@0. 5@0. obst }.
		{ 5@0. 7@0. obst }.
		{ 7@0. 9@0. obst }.
		{ 9@0. 4.5@5. front }.
		{ 4.5@5. 1@0. front }.
	}.
	
	lineSegments := data asOrderedCollection collect: [ :obj |
		(VMLineSegment from: obj first to: obj second type: (obj third))
	].
	
	localMap := (VMLocalMap new)
		lineSegments: lineSegments;
		yourself.
	
	^localMap.
	
]

{ #category : #'obsolete / unused' }
VMDataSet class >> dataLocalMap_3 [
	"a very small local map, designed to test the map merging in a corner.
	this local map is meant to be used in conjungtion with dataLocalMap_4."
	| data lineSegments localMap obst front |
	obst := VMLineTypeObstacle new.
	front := VMLineTypeFrontier new.
	
	data := {
		{ 1@0. 1@2. obst }.
		{ 1@2. 2@3. obst }.
		{ 2@3. 4@3. obst }.
		{ 4@3. 4@0. front }.
		{ 4@0. 1@0. front }.
	}.
	
	lineSegments := data asOrderedCollection collect: [ :obj |
		(VMLineSegment from: obj first to: obj second type: (obj third))
	].
	
	localMap := (VMLocalMap new)
		lineSegments: lineSegments;
		yourself.
	
	^localMap.
	
]

{ #category : #'obsolete / unused' }
VMDataSet class >> dataLocalMap_4 [
	"a very small local map, designed to test the map merging in a corner.
	this local map is meant to be used in conjungtion with dataLocalMap_3."
	| data lineSegments localMap obst front |
	obst := VMLineTypeObstacle new.
	front := VMLineTypeFrontier new.
	
	data := {
		{ 1@0.5. 1@2.9. obst }.
		{ 1@2.9. 3@3. obst }.
		{ 3@3. 5@3. obst }.
		{ 5@3. 5@0. front }.
		{ 5@0. 1@0.5. front }.
	}.
	
	lineSegments := data asOrderedCollection collect: [ :obj |
		(VMLineSegment from: obj first to: obj second type: (obj third))
	].
	
	localMap := (VMLocalMap new)
		lineSegments: lineSegments;
		yourself.
	
	^localMap.
	
]

{ #category : #'obsolete / unused' }
VMDataSet class >> dataLocalMap_5 [
	"a very small local map, designed to test the map merging.
	this local map is meant to be used in conjungtion with dataLocalMap_6."
	| data lineSegments localMap obst front |
	obst := VMLineTypeObstacle new.
	front := VMLineTypeFrontier new.
	
	data := {
		{ -2@ -4. -2@ -1. obst }.
		{ -2@ -1. 0@0. obst }.
		{ 0@0. 2@0. obst }.
		{ 2@0. 4@0. obst }.
		{ 4@0. 2@ -4. front }.
		{ 2@ -4. -2@ -4. front }.
	}.
	
	lineSegments := data asOrderedCollection collect: [ :obj |
		(VMLineSegment from: obj first to: obj second type: (obj third))
	].
	
	localMap := (VMLocalMap new)
		lineSegments: lineSegments;
		yourself.
	
	^localMap.
	
]

{ #category : #'obsolete / unused' }
VMDataSet class >> dataLocalMap_6 [
	"a very small local map, designed to test the map merging.
	this local map is meant to be used in conjungtion with dataLocalMap_5."
	| data lineSegments localMap obst front |
	obst := VMLineTypeObstacle new.
	front := VMLineTypeFrontier new.
	
	data := {
		{ -1.9@ -3. -1@ 0. obst }.
		{ -1@0. 1@0.1. obst }.
		{ 1@0.1. 3@0.1. obst }.
		{ 3@0.1. 5@0.1. obst }.
		{ 5@0.1. 5@ -2. obst }.
		{ 5@ -2. 5@ -5. obst }.
		{ 5@ -5. 2.5@ -5. front }.
		{ 2.5@ -5. -1.9@ -3. front }.
	}.
	
	lineSegments := data asOrderedCollection collect: [ :obj |
		(VMLineSegment from: obj first to: obj second type: (obj third))
	].
	
	localMap := (VMLocalMap new)
		lineSegments: lineSegments;
		yourself.
	
	^localMap.
	
]

{ #category : #'data - maps' }
VMDataSet class >> dataMap_1 [
	"a very simple test map. It has a closed boundary and a single obstacle inside."
	| info vertices edges |
	
	info := '8 8 0.01'.
	vertices:= '-20.0 -10.0 1 30.0 -10.0 1 30.0 40.0 1 -20.0 40 1 5.0 0.0 1 9.0 4.0 1 -3.0 16.0 1 -7.0 12.0 1'.
	edges := '1 2 2 3 3 4 4 1 5 6 6 7 7 8 8 5'.
	
	^{ info. vertices. edges }.
]

{ #category : #'data - maps' }
VMDataSet class >> dataMap_2 [
	"a simple test map. It has a closed boundary and contains a few obstacles inside."
	| info vertices edges |
	
	info := '18 18 0.01'.
	vertices:= '-1.0 -1.0 1 25 0 1 30 5 1 31 21 1 5 20 1 0 15 1 4.5 2 1 14 2 1 14 3 1 6 3 1 9 16 1 20 16 1 20 17 1 8 17 1 12 7 1 24 7 1 24 12 1 12 12 1'.
	edges := '1 2 2 3 3 4 4 5 5 6 6 1 7 8 8 9 9 10 10 11 11 12 12 13 13 14 14 7 15 16 16 17 17 18 18 15'.
	
	^{ info. vertices. edges }.
]

{ #category : #'data - maps' }
VMDataSet class >> dataMap_3 [
	"a test map to test several strange but valid obstacles, including poly-lines and closed polygons
	that are connected via poly-lines. this map also contains two isolated points.
	
	returns: an array of three strings (info, vertices, and edges) that can be used to create a VMMap object"
	| info vertices edges |
	
	info := '28 27 0.01'.
	vertices:= '-5 -5 1 35 -5 1 35 35 1 -5 35 1', "map boundary (1-4 / 4)"
		' 30 0 1 25 0 1 20 5 1', "poly-line (5-7 /3)"
		' 15 5 1 10 7.5 1 5 7.5 1 0 5 1 0 10 1', "triangle with attached poly-line (8-12 / 5)"
		' 10 15 1 15 10 1 20 15 1 25 10 1 30 15 1 25 20 1 15 20 1', "two dimond-shaped polygons, attached at a single vertex (13-19 / 7)"
		' 0 20 1 0 30 1 5 25 1 15 25 1 20 20 1 25 25 1 20 30 1', "a triangle connected to a line segment, connected to a dimond-shaped polygon (20-)"
		' 10 30 1 30 30 1'.
	edges := '1 2 2 3 3 4 4 1',
		' 5 6 6 7',
		' 8 9 9 10',
		' 10 11 11 12 12 10',
		' 13 14 14 15 15 16 16 17 17 18 18 15 15 19 19 13',
		' 20 21 20 22 22 21',
		' 22 23',
		' 23 24 23 26 25 24 25 26'.
	
	^{ info. vertices. edges }.
]

{ #category : #'data - maps' }
VMDataSet class >> dataMap_4 [
	"a test map to test poly-lines
	
	returns: an array of three strings (info, vertices, and edges) that can be used to create a VMMap object"
	| info vertices edges |
	
	info := '30 23 0.01'.
	vertices:= '-5 -5 1 35 -5 1 35 35 1 -5 35 1', "map bounds (1-4 / 4)"
		' 2 2 1 5 2 1 8 2 1 11 2 1', "horizontal poly-line (5-8 / 4)"
		' 4 10 1 8 6 1 12 6 1 16 10 1 12 14 1 8 12 1 8 8 1 12 8 1 12 10 1 10 10 1', "spiral (9-18 / 10)"
		' 20 3 1 17 6 1', "diagonal line segment (19-20 / 2)"
		' 15 0 1 12 0 1', "horizontal line segment (21-22 / 2)"
		' 30 -2 1 30 4 1', "vertical line segment (23-24 / 2)"
		' 0 20 1 1 24 1 5 21 1', "poly-line (25-27 / 3)"
		' 10 22 1 10 26 1 11 20 1', "poly-line (28-30 / 3)"
		' 25 11 1 23 15 1 21 14 1'. "poly-line (31-33 / 3)"
	edges := '1 2 2 3 3 4 4 1', "1-4 / 4"
		' 5 6 6 7 7 8 ', "5-8 / 3"
		' 9 10 10 11 11 12 12 13 13 14 14 15 15 16 16 17 17 18', "9-18 / 9"
		' 19 20', "19-20 / 1"
		' 21 22', "21-22 / 1"
		' 23 24', "23-24 / 1"
		' 25 26 26 27', "25-27 / 2"
		' 28 29 29 30', "28-30 / 2"
		' 31 32 32 33'. "31-33 / 2"
	^{ info. vertices. edges }.
]

{ #category : #'data - maps' }
VMDataSet class >> dataMap_5 [
	"a completly empty map (except for the borders)
	
	returns: an array of three strings (info, vertices, and edges) that can be used to create a VMMap object"
	| info vertices edges |
	
	info := '4 4 0.01'.
	vertices:= '-8 -6 1 8 -6 1 8 6 1 -8 6 1'. "map bounds (1-4 / 4)"
	edges := '1 2 2 3 3 4 4 1'. "1-4 / 4"
	^{ info. vertices. edges }.
]

{ #category : #'data - maps' }
VMDataSet class >> dataMap_6 [
	"a map where the obstacles are part of the boundary
	
	returns: an array of three strings (info, vertices, and edges) that can be used to create a VMMap object"
	| info vertices edges |
	
	info := '12 12 0.01'.
	vertices:= '-10 -10 1 -10 10 1 -1 10 1 -1 5 1 1 5 1 1 10 1 10 10 1 10 -10 1 1 -10 1 1 0 1 -1 0 1 -1 -10 1 '. "map bounds (1-12 / 12)"
	edges := '1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 10 11 11 12 12 1'. "1-12 / 12"
	^{ info. vertices. edges }.
]

{ #category : #'data - maps' }
VMDataSet class >> dataMap_7 [
	"a test map to test poly-lines
	
	returns: an array of three strings (info, vertices, and edges) that can be used to create a VMMap object"
	| info vertices edges |
	
	info := '30 23 0.01'.
	vertices:= '-5 -5 1 35 -5 1 35 35 1 -5 35 1', "map bounds (1-4 / 4)"
		' 2 2 1 5 2 1 8 2 1 11 2 1', "horizontal poly-line (5-8 / 4)"
		' 4 10 1 8 6 1 12 6 1 16 10 1 12 14 1 8 12 1 8 8 1 12 8 1 12 10 1 10 10 1', "spiral (9-18 / 10)"
		' 20 3 1 17 6 1', "diagonal line segment (19-20 / 2)"
		' 15 0 1 12 0 1', "horizontal line segment (21-22 / 2)"
		' 30 -2 1 30 4 1', "vertical line segment (23-24 / 2)"
		' 0 20 1 1 24 1 5 21 1', "poly-line (25-27 / 3)"
		' 10 22 1 10 26 1 11 20 1', "poly-line (28-30 / 3)"
		' 25 11 1 23 15 1 21 14 1'. "poly-line (31-33 / 3)"
	edges := '1 2 2 3 3 4 4 1', "1-4 / 4"
		' 5 6 6 7 7 8 ', "5-8 / 3"
		' 9 10 10 11 11 12 12 13 13 14 14 15 15 16 16 17 17 18', "9-18 / 9"
		' 19 20', "19-20 / 1"
		' 21 22', "21-22 / 1"
		' 23 24', "23-24 / 1"
		' 25 26 26 27', "25-27 / 2"
		' 28 29 29 30', "28-30 / 2"
		' 31 32 32 33'. "31-33 / 2"
	^{ info. vertices. edges }.
]

{ #category : #'data - maps' }
VMDataSet class >> dataMap_8 [
	"a semi-complex map to test SLAM on a small scale."
	| info vertices edges points obstacles startIndex left right top bottom |
	
	points := {
		-6@4.
		-3.9@4.
			-3.9@4.1. -6@4.1. -6@8.1. -1.05@8.1. -1.05@4.1. -3.1@4.1.
		-3.1@4.
		2.1@4.
			2.1@4.1. -0.95@4.1. -0.95@8.1. 3.95@8.1. 3.95@4.1. 2.9@4.1.
		2.9@4.
		5.1@4.
			5.1@4.1. 4.1@4.1. 4.1@8.1. 8@8.1. 8@4.1. 5.9@4.1.
		5.9@4.
		8@4.
		8@ -4.
		-6@ -4.
	}.
	
	obstacles := {
		{  -4.5@2.5.  2.2@2.5.  0.2@ -2.5.  -2@ -2.5.  -2@ -2.4.  -0.1@ -2.4.  -0.1@0.  0.9@2.4.  -4.4@2.4.  -4.4@ -2.4.  -2.8@ -2.4.  -2.8@ -2.5.  -4.5@ -2.5.  }.
		{  4@2.5.  6.5@2.5.  6.5@ -2.5.  2@ -2.5  }.
	} asOrderedCollection.
		
	info := '1 1 0.01'.
	edges := ''.
	vertices:= '-1 0 0 '.   "origin"
	
	
	"create boundary"
	points do: [ :p |
		vertices := vertices, p x printString, ' ', p y printString, ' 1 '.
	].
	
	"outer wall"
	left := points first x.
	right := points first x.
	top := points first y.
	bottom := points first y.
	points do: [ :p |
		(left > p x) ifTrue: [ left := p x. ].
		(right < p x) ifTrue: [ right := p x. ].
		(top > p y) ifTrue: [ top := p y. ].
		(bottom < p y) ifTrue: [ bottom := p y. ].
	].
	"
	obstacles add: {
		(left - 0.1) @ (top - 0.1).
		(left - 0.1) @ (bottom + 0.1).
		(right + 0.1) @ (bottom + 0.1).
		(right + 0.1) @ (top - 0.1).
	}.
	"
	
	1 to: (points size-1) do: [ :i |
		edges := edges, i printString, ' ', (i+1) printString, ' '.
	].
	edges := edges, (points size) printString, ' 1 '.
	
	
	"create obstacles"
	startIndex := points size.
	obstacles do: [ :aObstacle |
		aObstacle do: [ :p |
			vertices := vertices, p x printString, ' ', p y printString, ' 1 '.
		].
		1 to: (aObstacle size-1) do: [ :i |
			edges := edges, (i+startIndex) printString, ' ', (i+startIndex+1) printString, ' '.
		].
		edges := edges, ((aObstacle size) + startIndex) printString, ' ', (startIndex +1) printString, ' '.
		
		startIndex := startIndex + (aObstacle size).
	].

	vertices := vertices trimRight.
	edges := edges trimRight.
	
	^{ info. vertices. edges }.
	






]

{ #category : #'data - maps' }
VMDataSet class >> dataMap_9 [
	"a semi-complex map to test SLAM on a small scale."
	| info vertices edges points obstacles startIndex |
	
	points := {
		-6@4.
		-3.9@4.
			-3.9@4.1. -6@4.1. -6@8.1. -1.05@8.1. -1.05@4.1. -3.1@4.1.
		-3.1@4.
		2.1@4.
			2.1@4.1. -0.95@4.1. -0.95@8.1. 3.95@8.1. 3.95@4.1. 2.9@4.1.
		2.9@4.
		5.1@4.
			5.1@4.1. 4.1@4.1. 4.1@8.1. 8@8.1. 8@4.1. 5.9@4.1.
		5.9@4.
		8@4.
		8@ -4.
		-6@ -4.
	}.
	
	obstacles := {
		{  -4.5@2.5.  2.2@2.5.  0.2@ -2.5.  -2@ -2.5.  -2@ -2.4.  -0.1@ -2.4.  -0.1@0.  0.9@2.4.  -4.4@2.4.  -4.4@ -2.4.  -2.8@ -2.4.  -2.8@ -2.5.  -4.5@ -2.5.  }.
		{  4@2.5.  6.5@2.5.  6.5@ -2.5.  2@ -2.5  }.
	}.
		
	info := '1 1 0.01'.
	edges := ''.
	vertices:= '-1 0 0 '.   "origin"
	
	
	"create boundary"
	points do: [ :p |
		vertices := vertices, p x printString, ' ', p y printString, ' 1 '.
	].

	1 to: (points size-1) do: [ :i |
		edges := edges, i printString, ' ', (i+1) printString, ' '.
	].
	edges := edges, (points size) printString, ' 1 '.
	
	
	"create obstacles"
	startIndex := points size.
	obstacles do: [ :aObstacle |
		aObstacle do: [ :p |
			vertices := vertices, p x printString, ' ', p y printString, ' 1 '.
		].
		1 to: (aObstacle size-1) do: [ :i |
			edges := edges, (i+startIndex) printString, ' ', (i+startIndex+1) printString, ' '.
		].
		edges := edges, ((aObstacle size) + startIndex) printString, ' ', (startIndex +1) printString, ' '.
		
		startIndex := startIndex + (aObstacle size).
	].

	vertices := vertices trimRight.
	edges := edges trimRight.
	
	^{ info. vertices. edges }.
	






]

{ #category : #'data - polygons' }
VMDataSet class >> dataPolygon_1 [
	"a simple 4x4 square, from 0@0 to 4@4"
	| polygon points |
	
	points := { 0@0. 40@0. 40@40. 0@40 }.
	
	polygon :=VMClosedPolygon fromOrderedPoints: points.
	
	polygon vertices doWithIndex: [ :v :i |
		v id: i.
		v index: i.
	].
	
	^polygon.
	
]

{ #category : #'data - polygons' }
VMDataSet class >> dataPolygon_1bis [
	"a simple 4x4 square, from 10@20 to 50@60"
	| polygon points |
	
	points := { 10@20. 10@60. 50@60. 50@20 }.
	
	polygon :=VMClosedPolygon fromOrderedPoints: points.
	
	polygon vertices doWithIndex: [ :v :i |
		v id: i.
		v index: i.
	].
	
	^polygon.
	

]

{ #category : #'data - polygons' }
VMDataSet class >> dataPolygon_2 [
	"a simple rotate square (aka dimond shape)"
	| polygon points |
	
	points := { 10@1. 13@4. 10@7. 7@4 }.
	
	polygon :=VMClosedPolygon fromOrderedPoints: points.
	
	polygon vertices doWithIndex: [ :v :i |
		v id: i.
		v index: i.
	].
	
	^polygon.
	

]

{ #category : #'data - polygons' }
VMDataSet class >> dataPolygon_3 [
	"same as dataPolygon_2, but with reveresed winding order."
	| polygon points |
	
	points := { 10@8. 7@11. 10@14. 13@11 }.
	
	polygon :=VMClosedPolygon fromOrderedPoints: points.
	
	polygon vertices doWithIndex: [ :v :i |
		v id: i.
		v index: i.
	].
	
	^polygon.
	

]

{ #category : #'data - polygons' }
VMDataSet class >> dataPolygon_4 [
	"a non-convex polygon in the shape of a square with two dented sides"
	| polygon points |
	
	points := { 1@8. 1@13. 6@13. 5@10.5. 6@8. 3.5@9 }.
	
	polygon :=VMClosedPolygon fromOrderedPoints: points.
	
	polygon vertices doWithIndex: [ :v :i |
		v id: i.
		v index: i.
	].
	
	^polygon.
	

]

{ #category : #'data - polygons' }
VMDataSet class >> dataPolygon_5 [
	"a triangle"
	| polygon points |
	
	points := { 0@0. 30@30. 0@30. }.
	
	polygon :=VMClosedPolygon fromOrderedPoints: points.
	
	polygon vertices doWithIndex: [ :v :i |
		v id: i.
		v index: i.
	].
	
	^polygon.
	

]

{ #category : #'data - polygons' }
VMDataSet class >> dataPolygon_Triangles [
	"an ordered collection of triangles for testing the computation of the polygons winding oder. contains all configurations
	that can occure when computing the winding order."
	| polygons points swap vertices |
	
	"creates a copy of the array and swaps the second and third entries, which inverts the winding order"
	swap := [ :array |
		| oc |
		oc := OrderedCollection new.
		oc add: array first.
		oc add: (array at: 3).
		oc add: (array at: 2).
		
		oc
	].
	
	"all relevant test cases"
	points := {
		{ 3@3. 3@1. 1@3 }.
		{ 3@3. 3@1. 1@2 }.
		{ 3@3. 3@1. 5@1 }.
		{ 3@3. 1@1. 1@2 }.
		{ 3@3. 1@1. 5@1 }.
		{ 3@3. 4@1. 5@1 }.
		{ 3@3. 1@1. 1@3 }.
		{ 3@3. 5@1. 1@3 }.
	}.
	vertices := OrderedCollection new.
	points doWithIndex: [ :array :aIndex |
		| v collection |
		collection := OrderedCollection new.
		
		array doWithIndex: [ :p :pIndex |
			v := VMGraphVertex point: p.
			v id: (aIndex printString, '.', pIndex printString).
			v index: pIndex.	"for testing only. usually the index should be unique."
			collection add: v.
		].
		vertices add: collection.
	].
	
	polygons := OrderedCollection new.
	
	vertices do: [ :a |
		polygons add: (VMClosedPolygon fromOrderedVertices: a).
		polygons add: (VMClosedPolygon fromOrderedVertices: (swap value: a)).
	].
	
	^polygons.
	

]

{ #category : #'obsolete / unused' }
VMDataSet class >> localMap_1 [
	"
	(VMViewer openOn: { self localMap_1.  VMGridRenderer new }) autozoom; backgroundColor: Color gray.
	"

	^VMLocalMap lineSegments: {VMLineSegment from:(0.326@8.01) to:(0.634@8.06) type: 1. VMLineSegment from:(0.634@8.06) to:(0.902@8.11) type: 1. VMLineSegment from:(0.902@8.11) to:(1.166@8.128) type: 1. VMLineSegment from:(1.166@8.128) to:(1.47@8.034) type: 1. VMLineSegment from:(1.47@8.034) to:(1.6580000000000001@8.084) type: 1. VMLineSegment from:(1.6580000000000001@8.084) to:(1.842@8.116) type: 1. VMLineSegment from:(1.842@8.116) to:(2.028@8.132) type: 1. VMLineSegment from:(2.028@8.132) to:(2.21@8.13) type: 1. VMLineSegment from:(2.21@8.13) to:(2.378@8.164) type: 1. VMLineSegment from:(2.378@8.164) to:(2.5500000000000003@8.182) type: 1. VMLineSegment from:(2.5500000000000003@8.182) to:(2.722@8.236) type: 1. VMLineSegment from:(2.722@8.236) to:(2.898@8.226) type: 1. VMLineSegment from:(2.898@8.226) to:(3.082@8.252) type: 1. VMLineSegment from:(3.082@8.252) to:(3.258@8.212) type: 1. VMLineSegment from:(3.258@8.212) to:(3.314@7.83) type: 1. VMLineSegment from:(3.314@7.83) to:(3.352@7.5440000000000005) type: 1. VMLineSegment from:(3.352@7.5440000000000005) to:(3.396@7.354) type: 1. VMLineSegment from:(3.396@7.354) to:(3.442@7.21) type: 1. VMLineSegment from:(3.442@7.21) to:(3.594@7.222) type: 1. VMLineSegment from:(3.594@7.222) to:(3.786@7.2540000000000004) type: 1. VMLineSegment from:(3.786@7.2540000000000004) to:(3.988@7.26) type: 1. VMLineSegment from:(3.988@7.26) to:(4.122@7.182) type: 1. VMLineSegment from:(4.122@7.182) to:(4.162@7.032) type: 1. VMLineSegment from:(4.162@7.032) to:(4.148@6.862) type: 1. VMLineSegment from:(4.148@6.862) to:(4.298@6.78) type: 1. VMLineSegment from:(4.298@6.78) to:(4.446@6.678) type: 1. VMLineSegment from:(4.446@6.678) to:(4.44@6.5200000000000005) type: 1. VMLineSegment from:(4.44@6.5200000000000005) to:(4.47@6.376) type: 1. VMLineSegment from:(4.47@6.376) to:(4.488@6.23) type: 1. VMLineSegment from:(4.488@6.23) to:(4.494@6.082) type: 1. VMLineSegment from:(4.494@6.082) to:(4.5360000000000005@5.93) type: 1. VMLineSegment from:(4.5360000000000005@5.93) to:(4.566@5.772) type: 1. VMLineSegment from:(4.566@5.772) to:(4.534@5.62) type: 1. VMLineSegment from:(4.534@5.62) to:(4.3020000000000005@5.534) type: 1. VMLineSegment from:(4.3020000000000005@5.534) to:(4.296@5.384) type: 1. VMLineSegment from:(4.296@5.384) to:(4.322@5.208) type: 1. VMLineSegment from:(4.322@5.208) to:(4.328@5.022) type: 1. VMLineSegment from:(4.328@5.022) to:(4.356@4.8) type: 1. VMLineSegment from:(4.356@4.8) to:(4.354@4.5680000000000005) type: 1. VMLineSegment from:(4.354@4.5680000000000005) to:(4.362@4.29) type: 1. VMLineSegment from:(4.362@4.29) to:(0.0@0.0) type: 2. VMLineSegment from:(0.0@0.0) to:(0.326@8.01) type: 2.  } asOrderedCollection.

]

{ #category : #'obsolete / unused' }
VMDataSet class >> localMap_2 [
	"
	(VMViewer openOn: { self localMap_2.  VMGridRenderer new }) autozoom; backgroundColor: Color gray.
	"
	^VMLocalMap lineSegments: {VMLineSegment from:(-1.476@6.2) to:(-1.536@6.5440000000000005) type: 1. VMLineSegment from:(-1.536@6.5440000000000005) to:(-1.618@6.9) type: 1. VMLineSegment from:(-1.618@6.9) to:(-1.672@7.272) type: 1. VMLineSegment from:(-1.672@7.272) to:(-1.6420000000000001@7.640000000000001) type: 1. VMLineSegment from:(-1.6420000000000001@7.640000000000001) to:(-0.11800000000000001@7.5) type: 2. VMLineSegment from:(-0.11800000000000001@7.5) to:(0.016@7.71) type: 1. VMLineSegment from:(0.016@7.71) to:(0.21@7.88) type: 1. VMLineSegment from:(0.21@7.88) to:(0.41600000000000004@8.024000000000001) type: 1. VMLineSegment from:(0.41600000000000004@8.024000000000001) to:(0.744@8.054) type: 1. VMLineSegment from:(0.744@8.054) to:(0.986@8.108) type: 1. VMLineSegment from:(0.986@8.108) to:(1.224@8.134) type: 1. VMLineSegment from:(1.224@8.134) to:(1.514@8.054) type: 1. VMLineSegment from:(1.514@8.054) to:(1.7@8.064) type: 1. VMLineSegment from:(1.7@8.064) to:(1.854@8.098) type: 1. VMLineSegment from:(1.854@8.098) to:(2.008@8.116) type: 1. VMLineSegment from:(2.008@8.116) to:(2.142@8.168000000000001) type: 1. VMLineSegment from:(2.142@8.168000000000001) to:(2.29@8.162) type: 1. VMLineSegment from:(2.29@8.162) to:(2.426@8.192) type: 1. VMLineSegment from:(2.426@8.192) to:(2.566@8.21) type: 1. VMLineSegment from:(2.566@8.21) to:(2.704@8.216) type: 1. VMLineSegment from:(2.704@8.216) to:(2.848@8.26) type: 1. VMLineSegment from:(2.848@8.26) to:(2.998@8.294) type: 1. VMLineSegment from:(2.998@8.294) to:(3.156@8.314) type: 1. VMLineSegment from:(3.156@8.314) to:(3.236@8.08) type: 1. VMLineSegment from:(3.236@8.08) to:(3.286@7.8500000000000005) type: 1. VMLineSegment from:(3.286@7.8500000000000005) to:(3.298@7.62) type: 1. VMLineSegment from:(3.298@7.62) to:(3.334@7.484) type: 1. VMLineSegment from:(3.334@7.484) to:(3.352@7.352) type: 1. VMLineSegment from:(3.352@7.352) to:(3.384@7.258) type: 1. VMLineSegment from:(3.384@7.258) to:(3.442@7.202) type: 1. VMLineSegment from:(3.442@7.202) to:(3.612@7.234) type: 1. VMLineSegment from:(3.612@7.234) to:(3.794@7.242) type: 1. VMLineSegment from:(3.794@7.242) to:(4.0680000000000005@7.274) type: 1. VMLineSegment from:(4.0680000000000005@7.274) to:(4.078@7.138) type: 1. VMLineSegment from:(4.078@7.138) to:(4.126@7.024) type: 1. VMLineSegment from:(4.126@7.024) to:(4.116@6.894) type: 1. VMLineSegment from:(4.116@6.894) to:(4.142@6.7780000000000005) type: 1. VMLineSegment from:(4.142@6.7780000000000005) to:(4.408@6.686) type: 1. VMLineSegment from:(4.408@6.686) to:(4.416@6.546) type: 1. VMLineSegment from:(4.416@6.546) to:(4.462@6.404) type: 1. VMLineSegment from:(4.462@6.404) to:(0.0@0.0) type: 2. VMLineSegment from:(0.0@0.0) to:(-1.476@6.2) type: 2.  }.


]

{ #category : #'obsolete / unused' }
VMDataSet class >> localMap_3 [
	"
	(VMViewer openOn: { self localMap_3.  VMGridRenderer new }) autozoom; backgroundColor: Color gray.
	"
	^VMLocalMap lineSegments: {VMLineSegment from:(-1.31@5.152) to:(-1.3920000000000001@5.496) type: 1. VMLineSegment from:(-1.3920000000000001@5.496) to:(-1.446@5.8420000000000005) type: 1. VMLineSegment from:(-1.446@5.8420000000000005) to:(-1.518@6.18) type: 1. VMLineSegment from:(-1.518@6.18) to:(-1.564@6.5200000000000005) type: 1. VMLineSegment from:(-1.564@6.5200000000000005) to:(-1.6280000000000001@6.864) type: 1. VMLineSegment from:(-1.6280000000000001@6.864) to:(-1.668@7.216) type: 1. VMLineSegment from:(-1.668@7.216) to:(-1.726@7.582) type: 1. VMLineSegment from:(-1.726@7.582) to:(-0.05@7.546) type: 2. VMLineSegment from:(-0.05@7.546) to:(0.012@7.7620000000000005) type: 1. VMLineSegment from:(0.012@7.7620000000000005) to:(0.182@7.934) type: 1. VMLineSegment from:(0.182@7.934) to:(0.452@8.038) type: 1. VMLineSegment from:(0.452@8.038) to:(0.724@8.104000000000001) type: 1. VMLineSegment from:(0.724@8.104000000000001) to:(0.988@8.134) type: 1. VMLineSegment from:(0.988@8.134) to:(1.206@8.164) type: 1. VMLineSegment from:(1.206@8.164) to:(1.52@8.06) type: 1. VMLineSegment from:(1.52@8.06) to:(1.6500000000000001@8.106) type: 1. VMLineSegment from:(1.6500000000000001@8.106) to:(1.808@8.1) type: 1. VMLineSegment from:(1.808@8.1) to:(1.936@8.116) type: 1. VMLineSegment from:(1.936@8.116) to:(2.058@8.124) type: 1. VMLineSegment from:(2.058@8.124) to:(2.16@8.166) type: 1. VMLineSegment from:(2.16@8.166) to:(2.2800000000000002@8.152000000000001) type: 1. VMLineSegment from:(2.2800000000000002@8.152000000000001) to:(2.384@8.176) type: 1. VMLineSegment from:(2.384@8.176) to:(2.488@8.192) type: 1. VMLineSegment from:(2.488@8.192) to:(2.596@8.198) type: 1. VMLineSegment from:(2.596@8.198) to:(2.702@8.196) type: 1. VMLineSegment from:(2.702@8.196) to:(2.816@8.234) type: 1. VMLineSegment from:(2.816@8.234) to:(2.924@8.214) type: 1. VMLineSegment from:(2.924@8.214) to:(3.0460000000000003@8.23) type: 1. VMLineSegment from:(3.0460000000000003@8.23) to:(3.174@8.238) type: 1. VMLineSegment from:(3.174@8.238) to:(3.258@8.142) type: 1. VMLineSegment from:(3.258@8.142) to:(3.2800000000000002@7.96) type: 1. VMLineSegment from:(3.2800000000000002@7.96) to:(3.3040000000000003@7.822) type: 1. VMLineSegment from:(3.3040000000000003@7.822) to:(3.314@7.688) type: 1. VMLineSegment from:(3.314@7.688) to:(3.338@7.5920000000000005) type: 1. VMLineSegment from:(3.338@7.5920000000000005) to:(3.356@7.5) type: 1. VMLineSegment from:(3.356@7.5) to:(3.362@7.41) type: 1. VMLineSegment from:(3.362@7.41) to:(3.358@7.322) type: 1. VMLineSegment from:(3.358@7.322) to:(3.346@7.24) type: 1. VMLineSegment from:(3.346@7.24) to:(3.372@7.18) type: 1. VMLineSegment from:(3.372@7.18) to:(3.488@7.144) type: 1. VMLineSegment from:(3.488@7.144) to:(0.0@0.0) type: 2. VMLineSegment from:(0.0@0.0) to:(-1.31@5.152) type: 2.  }



]

{ #category : #'obsolete / unused' }
VMDataSet class >> localMap_4 [
	"
	(VMViewer openOn: { self localMap_4.  VMGridRenderer new }) autozoom; backgroundColor: Color gray.
	"
	^VMLocalMap lineSegments: {VMLineSegment from:(4.2860000000000005@2.192) to:(3.838@2.078) type: 1. VMLineSegment from:(3.838@2.078) to:(3.39@2.004) type: 1. VMLineSegment from:(3.39@2.004) to:(2.96@1.92) type: 1. VMLineSegment from:(2.96@1.92) to:(2.536@1.824) type: 1. VMLineSegment from:(2.536@1.824) to:(2.106@1.762) type: 1. VMLineSegment from:(2.106@1.762) to:(1.6620000000000001@2.236) type: 2. VMLineSegment from:(1.6620000000000001@2.236) to:(1.262@2.146) type: 1. VMLineSegment from:(1.262@2.146) to:(0.762@1.498) type: 2. VMLineSegment from:(0.762@1.498) to:(0.276@1.436) type: 1. VMLineSegment from:(0.276@1.436) to:(-0.254@1.324) type: 2. VMLineSegment from:(-0.254@1.324) to:(-0.658@1.6320000000000001) type: 2. VMLineSegment from:(-0.658@1.6320000000000001) to:(-1.46@1.118) type: 2. VMLineSegment from:(-1.46@1.118) to:(-2.172@1.006) type: 2. VMLineSegment from:(-2.172@1.006) to:(-1.014@3.544) type: 2. VMLineSegment from:(-1.014@3.544) to:(-1.096@3.992) type: 1. VMLineSegment from:(-1.096@3.992) to:(-1.192@4.36) type: 1. VMLineSegment from:(-1.192@4.36) to:(-1.248@4.722) type: 1. VMLineSegment from:(-1.248@4.722) to:(-1.304@5.048) type: 1. VMLineSegment from:(-1.304@5.048) to:(-1.372@5.338) type: 1. VMLineSegment from:(-1.372@5.338) to:(-1.408@5.63) type: 1. VMLineSegment from:(-1.408@5.63) to:(-1.468@5.896) type: 1. VMLineSegment from:(-1.468@5.896) to:(-1.504@6.162) type: 1. VMLineSegment from:(-1.504@6.162) to:(-1.566@6.418) type: 1. VMLineSegment from:(-1.566@6.418) to:(-1.606@6.678) type: 1. VMLineSegment from:(-1.606@6.678) to:(-1.624@6.938) type: 1. VMLineSegment from:(-1.624@6.938) to:(-1.67@7.204) type: 1. VMLineSegment from:(-1.67@7.204) to:(-1.696@7.476) type: 1. VMLineSegment from:(-1.696@7.476) to:(-1.748@7.764) type: 1. VMLineSegment from:(-1.748@7.764) to:(-0.29@7.61) type: 2. VMLineSegment from:(-0.29@7.61) to:(-0.006@7.668) type: 1. VMLineSegment from:(-0.006@7.668) to:(0.008@7.816) type: 1. VMLineSegment from:(0.008@7.816) to:(0.078@7.942) type: 1. VMLineSegment from:(0.078@7.942) to:(0.196@8.034) type: 1. VMLineSegment from:(0.196@8.034) to:(0.322@8.11) type: 1. VMLineSegment from:(0.322@8.11) to:(0.482@8.14) type: 1. VMLineSegment from:(0.482@8.14) to:(0.61@8.186) type: 1. VMLineSegment from:(0.61@8.186) to:(0.764@8.178) type: 1. VMLineSegment from:(0.764@8.178) to:(0.886@8.2) type: 1. VMLineSegment from:(0.886@8.2) to:(1.006@8.208) type: 1. VMLineSegment from:(1.006@8.208) to:(1.102@8.25) type: 1. VMLineSegment from:(1.102@8.25) to:(0.0@0.0) type: 2. VMLineSegment from:(0.0@0.0) to:(4.2860000000000005@2.192) type: 2.  }




]

{ #category : #'data - maps' }
VMDataSet class >> map_7 [
	"a test map to test poly-lines
	
	returns: an array of three strings (info, vertices, and edges) that can be used to create a VMMap object"
	| map roomA roomB roomC polygons |
	
	map := VMPolygonMap new.
	map origin: 0@0.
	polygons := OrderedCollection new.
	
	roomA := VMPolygonChain fromOrderedPoints: { 1@5.  0@5.  0@0.  7@0.  7@5.  2@5.  }.
	roomB := VMPolygonChain fromOrderedPoints: {  5@3.  5@5.  0@5.  0@0.  5@0.  5@2.  }.
	roomC := VMPolygonChain fromOrderedPoints: {  1@0.  0@0.  0@5.  7@5.  7@0.  2@0.  }.
	
	"map bounds"
	polygons addAll: ( {
		"map boundary
		(VMClosedPolygon fromOrderedPoints: { -15@  -15.  15@ -15.  15@15.  -15@15. })
			makeCW;			
			expand: 0.1."
		"room 1"
		((VMPolygonChain fromOrderedPoints: { 6@7.  5@8.  5@10.  0@ 10.  0@0.  10@0.  10@5.  8@5.  7@6  })
			expand: 0.1)
			move: -15@ -15;
			yourself.
		(roomA
			expand: 0.1)
			move: -5@ -15;
			yourself.
		"(roomC
			expand: 0.1)
			move: 8@ -7.5;
			yourself.
		(roomC
			expand: 0.1)
			move: 1@ -7.5;
			yourself.
		(roomA
			expand: 0.1)
			move: 2@ -15;
			yourself.
		(roomB
			expand: 0.1)
			move: -15@ -5;
			yourself.
		(roomB
			expand: 0.1)
			move: -15@0;
			yourself.
		(roomB
			expand: 0.1)
			move: -15@5;
			yourself.
		(roomB
			expand: 0.1)
			move: -15@10;
			yourself.
			"
	} ).
	
	map polygons add: (VMPolygonMergerOld merge: polygons).
	"map polygons add: ( polygons first merge: polygons )."
	map computeBounds.
	
	^map.
]

{ #category : #'data - simulator' }
VMDataSet class >> robot1: map [
	
	^(VMRobot id: 'robo')
		map: map;
		radius: 0.22;
		orientation: Float pi * 1.1;
		speed: 0.2@ -0.01;
		position: -2@0.
	
]

{ #category : #'data - simulator' }
VMDataSet class >> sensor1 [
	
	^(VMSensorLRF id: 'lrf')
		angle: (Float pi / 1.3);
		maxRange: 10.0;
		rayCount: 30.
	
]

{ #category : #'data - simulator' }
VMDataSet class >> sensor2 [
	
	^(VMSensorLRF id: 'lrf')
		angle: (Float pi * 1.25);
		maxRange: 10.0;
		rayCount: (151).
	
]

{ #category : #'toy-example: polygons' }
VMDataSet class >> toyExample_polygons [
	"a small toy examples consisting of 4 polygons that cover a small room with one obstacle"
	| points types polygons |
	points := {
		{ -2 @ -2.  -2 @ 5.5. -1.5 @ 6.  0.5 @ 6.  2 @ 3.5.  2 @ 2.  3 @ 2.  2.5 @ -2 }.
		{ -2 @ 3.  -2 @ 6.  6 @ 6.  6 @ 5.  4 @ 4.  2 @ 4.  2 @ 2.25 }.
		{ -2 @ 4.  -2 @ 6.  3.5 @ 6.  6 @ 5.  6 @ -1.  4 @ 2.  4 @ 4.  2 @ 4 }.
		{ -2 @ 0.  -2 @ 2.  2 @ 3.  2 @ 2.  4 @ 2.  6 @ 3.  6 @ -2.  0 @ -2 }.
	}.
	types := {
		{ 1.  1.  1.  2.  1.  1.  2.  1. }.
		{ 1.  1.  1.  2.  1.  1.  2. }.
		{ 1.  1.  2.  1.  2.  1.  1.  2. }.
		{ 1.  2.  1.  1.  2.  1.  1.  2. }.
	}.
	
	polygons := points collect: [ :pointCollection | VMPolygon new fromPoints: pointCollection ].
	polygons doWithIndex: [ :p :polygonIndex |
		p doWithIndex: [ :lineSeg : lineSegIndex |
			lineSeg type: ((types at:polygonIndex) at: lineSegIndex).
		].
	].
	
	^polygons

]

{ #category : #'toy-example: polygons' }
VMDataSet class >> toyExample_polygons2 [
	"a small toy examples consisting of 2 polygons"
	| points types polygons |
	points := {
		{ -3 @ -2.  -3 @ 0.  1 @ 2.  3 @ 2. }.
		{ -3 @ -1.  -2 @ 2.  2 @ 2.  2 @ -2. }.
	}.
	types := {
		{ 1.  1.  1.  2. }.
		{ 1.  1.  2.  2. }.
	}.
	
	polygons := points collect: [ :pointCollection | VMPolygon new fromPoints: pointCollection ].
	polygons doWithIndex: [ :p :polygonIndex |
		p doWithIndex: [ :lineSeg : lineSegIndex |
			lineSeg type: ((types at:polygonIndex) at: lineSegIndex).
		].
	].
	
	^polygons

]

{ #category : #'toy-example: polygons' }
VMDataSet class >> toyExample_polygons3 [
	"a small toy examples consisting of 2 polygons. this is used to test merging of concave structures"
	| points types polygons |
	points := {
		{ -2 @ -2.  -2 @ -0.5.  0.5 @ 2.  2 @ 2.  2 @ -2 }.
		{ -2 @ -0.1.  0 @ 0.  0.1 @ 2.  1.5 @ -1.5. }.
	}.
	types := {
		{ 1.  1.  1.  2.  2. }.
		{ 1.  1.  2.  2. }.
	}.
	
	polygons := points collect: [ :pointCollection | VMPolygon new fromPoints: pointCollection ].
	polygons doWithIndex: [ :p :polygonIndex |
		p doWithIndex: [ :lineSeg : lineSegIndex |
			lineSeg type: ((types at:polygonIndex) at: lineSegIndex).
		].
	].
	
	^polygons

]

{ #category : #'toy-example: polygons' }
VMDataSet class >> toyExample_polygons4 [
	"a small toy examples consisting of 2 polygons. used to test polygon merging."
	| points types polygons |
	points := {
		{ -4 @ -3.  -4 @ -1.  -3 @ 0.  0 @ 1.  1 @ -3 }.
		{ -3 @ -4.  -4 @ -0.5.  -0.5 @ 0.  0 @ 1.5.  2 @ 4.  2 @ 1 }.
	}.
	types := {
		{ 1.  1.  1.  2.  2. }.
		{ 1.  1.  1.  1.  2.  2. }.
	}.
	
	polygons := points collect: [ :pointCollection | VMPolygon new fromPoints: pointCollection ].
	polygons doWithIndex: [ :p :polygonIndex |
		p doWithIndex: [ :lineSeg : lineSegIndex |
			lineSeg type: ((types at:polygonIndex) at: lineSegIndex).
		].
	].
	
	^polygons

]

{ #category : #'toy-example: polygons' }
VMDataSet class >> toyExample_polygons5 [
	"a small toy examples consisting of 2 polygons. used for space carving test."
	| points types polygons |
	points := {
		{ -4 @ 4.  4 @ 4.  4 @ -4.  -4 @ -4. }.
		{ -5 @ -1.  -5 @ 1.  2 @ 0. }.
	}.
	types := {
		{ 1.  1.  1.  1. }.
		{ 1.  2.  2. }.
	}.
	
	polygons := points collect: [ :pointCollection | VMPolygon new fromPoints: pointCollection ].
	polygons doWithIndex: [ :p :polygonIndex |
		p doWithIndex: [ :lineSeg : lineSegIndex |
			lineSeg type: ((types at:polygonIndex) at: lineSegIndex).
		].
	].
	
	^polygons

]

{ #category : #'toy-example: polygons' }
VMDataSet class >> toyExample_polygons_ICIRA [
	"a small toy examples consisting of 4 polygons that cover a small room with one obstacle"
	| points types polygons |
	points := {
		{ -2 @ -2.  -2 @ 5.5. -1.5 @ 6.  0.5 @ 6.  2 @ 3.5.  2 @ 2.  3 @ 2.  2.5 @ -2 }.
		{ -2 @ 3.  -2 @ 6.  6 @ 6.  6 @ 5.  4 @ 4.  2 @ 4.  2 @ 2.25 }.
		{ -2 @ 4.  -2 @ 6.  3.5 @ 6.  6 @ 5.  6 @ -1.  4 @ 2.  4 @ 4.  2 @ 4 }.
		{ -2 @ 0.  -2 @ 2.  2 @ 3.  2 @ 2.  4 @ 2.  6 @ 3.  6 @ -2.  5.5 @ -2.  6.8 @ -3.5. 4.4 @ -3.5. 4 @ -2.  0 @ -2 }.
	}.
	types := {
		{ 1.  3.  1.  3.  1.  1.  3.  1. }.
		{ 1.  1.  1.  3.  1.  1.  3. }.
		{ 1.  1.  3.  1.  3.  1.  1.  3. }.
		{ 1.  3.  1.  1.  3.  1.  1.  2.  1.  2.  1.  3. }.
	}.
	
	polygons := points collect: [ :pointCollection | VMPolygon new fromPoints: pointCollection ].
	polygons doWithIndex: [ :p :polygonIndex |
		p doWithIndex: [ :lineSeg : lineSegIndex |
			lineSeg type: ((types at:polygonIndex) at: lineSegIndex).
		].
	].
	
	^polygons

]
