Class {
	#name : #VMLineTests,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
VMLineTests >> testDistanceToPoint [
	| line point dist |
	
	line := VMLine pointA: (2@3.5) pointB: (2@2) type: 1.
	point := 1.6 @ -2.
	dist := line distanceToPoint: point.
	
	self assert: (dist closeTo: 0.4).

]

{ #category : #tests }
VMLineTests >> testIfIntersectsWithDo [
	"this test checks the results of 'aBlock' in the 'ifIntersectsWith: aLine do: aBlock'
	method. it does not test the boolean return value."
	| lineA data expectedResults epsilon |
	
	epsilon := 0.0000001.
	
	lineA := VMLine pointA: 0@0 pointB: 1@0.
	
	"note: this test contains only data that actually intersects"
	data := {
		VMLine pointA: 1@2 pointB: 1@1.
		VMLine pointA: 3@2 pointB: 3@1.
		VMLine pointA: 1@5 pointB: 1@3.
		VMLine pointA: -1@ -2 pointB: -1@ -3.
		VMLine pointA: 1@3 pointB: 4@0.
		VMLine pointA: -2@0 pointB: 0@1.
		VMLine pointA: -4@2 pointB: 4@ -2.
	}.
	
	expectedResults := {
		{1@0.  1.0.  2.0.}.
		{3@0.  3.0.  2.0.}.
		{1@0.  1.0.  2.5.}.
		{-1@0.  -1.0.  -2.0.}.
		{4@0.  4.0.  1.0.}.
		{-2@0.  -2.0.  0.0.}.
		{0@0.  0.0.  0.5.}.
	}.
	
	data doWithIndex: [ :lineB : index |
		| result |
		
		result := {nil. nil. nil}.
		lineA ifIntersectsWith: lineB do: [ :p :t :u | result := {p. t. u} ].
		
		self assert: (result first dist: (expectedResults at: index) first) < epsilon.
		self assert: (result second closeTo: (expectedResults at: index) second).
		self assert: (result third closeTo: (expectedResults at: index) third).
	].
	

]
