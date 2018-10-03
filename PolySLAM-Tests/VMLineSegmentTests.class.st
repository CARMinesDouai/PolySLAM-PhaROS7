Class {
	#name : #VMLineSegmentTests,
	#superclass : #Object,
	#category : #'PolySLAM-Tests'
}

{ #category : #'test support' }
VMLineSegmentTests >> createLinesFromData: pointsCollection [
	^ pointsCollection collect: [ :col |
		VMLineSegment from: col first to: col second ]
]

{ #category : #'test support' }
VMLineSegmentTests >> openViewerOn: line intersectingWith: testLines [
	self ifVisualDebugDo: [
		|elems|
		elems := { line asRenderableElement color: Color red } asOrderedCollection.
		testLines do: [ :l  | 
			elems add: (l asRenderableElement color: Color green ; beDashed; showLabel: true).
			l ifIntersectsWith: line do: [ :p :f |
				elems add: ( 
					(VMGraphVertex point: p) asRenderableElement 
						color: Color yellow 
				)
			]	
		].
		(VMMapViewer openOn: elems)
			zoomFactor: 5.4 at: 0@0;
			panTo: 96@58
	].
]

{ #category : #tests }
VMLineSegmentTests >> testIfStrictSegmentIntersection [
	"this function tests the 'ifIntersectsWith: do:' method."
		
	|  line  expectedResults testLines results |
	
	line := VMLineSegment from: (0@0) to: (6@6).
	testLines := self createLinesFromData: {
		{ (-3@ -3).  (3@3) }.	"#1: parallel, overlaps at the start point, intersection point at 0.5"
		{ (3@3).  (9@9) }.		"#2: parallel, overlaps at the end point, intersection point at 1.0 (1.5)"
		{ (2@2).  (4@4) }.		"#3: parallel, lies in the middle, intersection point at 0.667"
		{ (-2@ -2).  (9@9) }	."#4: parallel, completly engulfs the line, intersection point at 1.0 (1.5)"
		{ (-6@ -6).  (-2@ -2) }.	"#5: parallel, no intersection"
		{ (9@9).  (12@12) }.	"#6: parallel, no intersection"
		{ (0@2).  (4@6) }.		"#7: parallel, but not even on the same line"
	}.
	
	expectedResults := { true. true. true. true. false. false. false }.
	
	results := testLines collect: [ :testLine |
		line intersectsWith: testLine 
	].
	
	self openViewerOn: line intersectingWith: testLines.
	
	self assertCollection: results hasSameElements: expectedResults
	
]

{ #category : #tests }
VMLineSegmentTests >> testIntersectionPoints [
	| line testLines expectedResults results |
	
	line := VMLineSegment from: 1@1 to: 5@1.
	
	testLines := self createLinesFromData: {
		{2@2 . 2@4}.
		{2@2 . 6@2}
	}.
	
	expectedResults := { 2@1 . nil }.
	
	results := testLines collect: [ :testLine |
		|intersectionPoint|
		line intersectionPointWith: testLine ifPresentDo: [ :result | intersectionPoint := result ].
		intersectionPoint  
	].
	
	self openViewerOn: line intersectingWith: testLines.
	
	self assertCollection: results hasSameElements: expectedResults
]

{ #category : #tests }
VMLineSegmentTests >> testPointDistance [
	| line data |
	
	line := VMLineSegment from: (1@1) to: (1@4).
	
	data := {
		"first: test point,  last: expected distance to the line segment"
		{0@0.  (2 sqrt)}.
		{2@1.  1}.
		{2@1.  1}.
		{2@2.  1}.
		{2@3.  1}.
		{2@4.  1}.
		{2@5.  (2 sqrt)}.
	}.
	
	data do: [ :obj |
		| dist error |
		dist := line distanceToPoint: obj first.
		error := (dist - obj last) abs.
		Transcript
			show: 'p=', obj first printString, ', dist=', dist printString, ', should be=', obj last printString;
			cr.
		self assert: error < 0.000001.
	].
]

{ #category : #tests }
VMLineSegmentTests >> testSegmentIntersection [
	"this function tests the intersectsWith method."
	
	| line expectedResults testLines results |
	
	line := VMLineSegment from: 0@0 to: 50@50.

	testLines := self createLinesFromData: {
		{ -10@20. 70@30 }.
		{ 60@60.  80@80 }.
		{ 50@50.  80@50 }.
		{ 10@90.  30@50 } }.
	
	self openViewerOn: line intersectingWith: testLines.
	
	results := testLines collect: [ :testLine |
		line intersectsWith: testLine ].
	
	expectedResults := { true. false. false. false }.

	self assertCollection: results hasSameElements: expectedResults
	

]

{ #category : #tests }
VMLineSegmentTests >> testSegmentIntersection2 [
	"this function tests the intersectsWith method."
	
	| line expectedResults testLines results |
	
	line := VMLineSegment from: (6@9) to: (6@4).
	
	testLines := self createLinesFromData: {
		{ (-1@2). (7@3) }.
		{ (6@6). (8@8) }.
		{ (5@5). (8@5) }.
		{ (1@9). (3@5) } }.
		
	expectedResults := { false. true. true. false }.
		
	results := testLines collect: [ :testLine |
		line intersectsWith: testLine ].
	
	self openViewerOn: line intersectingWith: testLines.
	
	self assertCollection: results hasSameElements: expectedResults
	

]
