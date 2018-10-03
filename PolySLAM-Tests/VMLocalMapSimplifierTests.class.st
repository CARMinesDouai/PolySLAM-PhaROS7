Class {
	#name : #VMLocalMapSimplifierTests,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
VMLocalMapSimplifierTests >> testMeanSquareError [
	"this method tests the computation of the mean square error for replacing a collcetion of line segments with a single line segment.
	the error is determined by the distance of the start/end points of the removed line segments to the new line segment"
	| data expectedResults simplifier |
	
	data := {
		{ 1@1. 4@1. 7@1 }.
		{ 1@1. 4@2. 7@1 }.
		{ 1@1. 4@0. 7@1 }.
	}.
	expectedResults := { 0. 1. 1 }.
	simplifier := VMLocalMapSimplifier new.
	
	data doWithIndex: [ :pointCollection :i |
		| lineSegments mse error |
		
		lineSegments := OrderedCollection new.
		
		pointCollection doWithIndex: [ :point :index |
			(index < pointCollection size) ifTrue: [
				lineSegments add: (VMLineSegment from: point to: (pointCollection at: (index + 1))).
			].
		].
		
		simplifier oldCollection: lineSegments.
		simplifier startIndex: 1.
		simplifier endIndex: lineSegments size.
		
		mse := simplifier meanSquareError.
		error := ((expectedResults at: i) - mse) abs.
		
		"Transcript
			show: 'mean square error=', mse printString;
			cr.
		"
		self assert: error < 0.0000001.
	].
	
]

{ #category : #tests }
VMLocalMapSimplifierTests >> testMeanSquareError2 [
	| data expectedResults simplifier |
	
	data := {
		{ 1@1. 4@1. 7@1. 10@1. 13@1. }.
		{ 1@1. 4@1. 7@1. 10@1. 13@1.2. }.
		{ 1@1. 4@1. 7@1. 10@1. 13@1.5. }.
		{ 1@1. 4@1. 7@1. 10@1. 13@2. }.
		{ 1@1. 4@1. 7@1. 10@1. 13@3. }.
		{ 1@1. 4@1. 7@1. 10@1. 13@5. }.
	}.
	expectedResults := {
		0.
		0.011663426825881687.
		0.07279029462738303.
		0.28965517241379307.
		1.1351351351351353.
		4.199999999999998.
	}.
	simplifier := VMLocalMapSimplifier new.
	
	data doWithIndex: [ :pointCollection :i |
		| lineSegments mse error |
		
		lineSegments := OrderedCollection new.
		
		pointCollection doWithIndex: [ :point :index |
			(index < pointCollection size) ifTrue: [
				lineSegments add: (VMLineSegment from: point to: (pointCollection at: (index + 1))).
			].
		].
		
		simplifier oldCollection: lineSegments.
		simplifier startIndex: 1.
		simplifier endIndex: lineSegments size.
		
		mse := simplifier meanSquareError.
		error := ((expectedResults at: i) - mse) abs.
		
		Transcript
			show: 'mean square error=', mse printString;
			cr.
		
		self assert: error < 0.0000001.
		
	].
	
]

{ #category : #tests }
VMLocalMapSimplifierTests >> testSimplify [
	| data lineSegments simplifier newCollection |
	
	data := {
		2@2. 4@2. 6@2. 8@2.
		8@5.
		8@8. 6@8. 4@8. 2@8.
		2@5.
	}.
	
	lineSegments := OrderedCollection new.
	simplifier := VMLocalMapSimplifier new.
	
	data doWithIndex: [ :point :index |
		lineSegments add: (VMLineSegment from: point to: (data atWrap: (index+1)) type: (VMLineTypeObstacle new)).
	].

	newCollection := simplifier simplify: lineSegments.
	
	self assert: newCollection size = 4.

]
