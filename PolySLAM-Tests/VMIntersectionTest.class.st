Class {
	#name : #VMIntersectionTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #'as yet unclassified' }
VMIntersectionTest >> testIntersectLineWithLine [
	"basic test that checks if the intersections are classified correctly as: 1) intersecting, 2) parallel, or 3) collinear."
	| lineA lineB dataIntersecting dataParallel dataCollinear iObj |
	
	lineA := VMLine pointA: 0@0 pointB: 2@0.
	dataIntersecting := {
		{ 2@1.  2@3 }.
		{ 2@1.  4@3 }.
		{ 4@3.  2@1 }.
		{ -3@ -3.  -1@ -1 }.
		{ 0@ -4.  -3@ -2 }.
	}.
	dataParallel := {
		{ 0@2. 3@2 }.
		{ 6@1. 5@1 }.
	}.
	dataCollinear := {
		{ 0@0. 2@0 }.
		{ -3@0. 5@0 }.
	}.
	
	dataIntersecting do: [ :coords |
		lineB := VMLine pointA: coords first pointB: coords second.
		iObj := VMIntersection intersectLine: lineA withLine: lineB.
		iObj ifIntersectsDo: [ :iP :t :u | self assert: true. ] ifParallelDo: [ self assert: false ] ifCollinearDo: [ :v :w | self assert: false ].
	].
	
	dataParallel do: [ :coords |
		lineB := VMLine pointA: coords first pointB: coords second.
		iObj := VMIntersection intersectLine: lineA withLine: lineB.
		iObj ifIntersectsDo: [ :iP :t :u | self assert: false. ] ifParallelDo: [ self assert: true ] ifCollinearDo: [ :v :w | self assert: false ].
	].
	
	dataCollinear do: [ :coords |
		lineB := VMLine pointA: coords first pointB: coords second.
		iObj := VMIntersection intersectLine: lineA withLine: lineB.
		iObj ifIntersectsDo: [ :iP :t :u | self assert: false. ] ifParallelDo: [ self assert: false ] ifCollinearDo: [ :v :w | self assert: true ].
	].

]

{ #category : #'as yet unclassified' }
VMIntersectionTest >> testifCollinear [
	| lineA lineB lineC data expectedResults iObj epsilon |
	
	lineA := VMLine pointA: 0@0 pointB: 2@0.
	epsilon := 0.000001.
	data := {
		{ -3@0.  -1@0 }.
		{ -3@0.  0@0 }.
		{ 0.5@0.  1.5@0 }.
		{ 1@0.  2@0 }.
		{ 1@0.  4@0 }.
		{ 3@0.  4@0 }.
	}.
	expectedResults := {
		{ -1.5.  -0.5 }.
		{ -1.5.  0.0 }.
		{ 0.25.  0.75 }.
		{ 0.5.  1.0 }.
		{ 0.5.  2.0 }.
		{ 1.5.  2.0 }.
	}.
	
	data doWithIndex: [ :coords :index |
		lineB := VMLine pointA: coords first pointB: coords second.
		lineC := VMLine pointA: coords second pointB: coords first.
		iObj := VMIntersection intersectLine: lineA withLine: lineB.
		iObj
			ifIntersectsDo: [ :iP :t :u | self assert: false. ]
			ifParallelDo: [ self assert: false ]
			ifCollinearDo: [ :v :w |
				| result |
				
				result := expectedResults at: index.
				self assert: (v closeTo: result first).
				self assert: (w closeTo: result second).
				
				"Transcript show: 'v=', v printString, ', w=', w printString; cr."
			].
		iObj := VMIntersection intersectLine: lineA withLine: lineC.
		iObj
			ifIntersectsDo: [ :iP :t :u | self assert: false. ]
			ifParallelDo: [ self assert: false ]
			ifCollinearDo: [ :v :w |
				| result |
				
				result := expectedResults at: index.
				self assert: (v closeTo: result second).
				self assert: (w closeTo: result first).
				
				"Transcript show: 'v=', v printString, ', w=', w printString; cr."
			].

	].
	

]

{ #category : #'as yet unclassified' }
VMIntersectionTest >> testifIntersecting [
	| lineA lineB data expectedResults iObj epsilon |
	
	lineA := VMLine pointA: 0@0 pointB: 2@0.
	epsilon := 0.000001.
	data := {
		{ 2@1.  2@3 }.
		{ 2@1.  4@3 }.
		{ 4@3.  2@1 }.
		{ -3@ -3.  -1@ -1 }.
		{ 0@ -4.  -3@ -2 }.
	}.
	expectedResults := {
		{ 2@0.  1.0.  -0.5 }.
		{ 1@0.  0.5.  -0.5 }.
		{ 1@0.  0.5.  1.5 }.
		{ 0@0.  0.0.  1.5 }.
		{ -6@0.  -3.0.  2 }.
	}.
	
	data doWithIndex: [ :coords :index |
		lineB := VMLine pointA: coords first pointB: coords second.
		iObj := VMIntersection intersectLine: lineA withLine: lineB.
		iObj
			ifIntersectsDo: [ :iP :t :u |
				| result |
				
				result := expectedResults at: index.
				self assert: (iP dist: result first) < epsilon.
				self assert: (t closeTo: result second).
				self assert: (u closeTo: result third).
				
				"Transcript show: 'iP=', iP printString, ', t=', t printString, ', u', u printString; cr."
			]
			ifParallelDo: [ self assert: false ]
			ifCollinearDo: [ :v :w | self assert: false ].
	].
	

]
