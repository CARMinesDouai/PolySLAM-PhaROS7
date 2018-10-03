Class {
	#name : #VMTFTests,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #'as yet unclassified' }
VMTFTests >> testApplyToPoint [
	"testing a simple 90 degree rotation on a view points"
	| tfMatrix data expectedData epsilon |
	
	epsilon := 0.00001.
	tfMatrix := VMTFMatrix r: (VMMatrix2d angle: Float halfPi) t: (VMVector2d point: 0@0 ).
	data := {
		1@0.  0@1.  1@1.  3@2.  -1@4.  -1@ -4.
	}.
	expectedData := data collect: [ :aPoint |
		aPoint rotateBy: (Float halfPi) about: 0@0.
	].
	
	tfMatrix applyToCollection: data.
	
	data doWithIndex: [ :pointA :index |
		| error |
		error := pointA dist: (expectedData at: index).
		"
		Transcript
			show: '#', index printString, ': error=', error printString;
			cr.
		"
		self assert: (error < epsilon).
	].
	

]

{ #category : #'as yet unclassified' }
VMTFTests >> testApplyToPoint2 [
	"same as the previous test, but with a different angle (named theta)."
	| tfMatrix data expectedData theta epsilon |
	
	epsilon := 0.00001.
	theta := 0.12334 * (Float pi).
	tfMatrix := VMTFMatrix r: (VMMatrix2d angle: theta) t: (VMVector2d point: 0@0 ).
	data := {
		1@0.  0@1.  1@1.  3@2.  -1@4.  -1@ -4.
	}.
	expectedData := data collect: [ :aPoint |
		aPoint rotateBy: theta about: 0@0.
	].
	
	tfMatrix applyToCollection: data.
	
	data doWithIndex: [ :pointA :index |
		| error |
		error := pointA dist: (expectedData at: index).
		self assert: (error < epsilon).
	].
	

]

{ #category : #'as yet unclassified' }
VMTFTests >> testApplyToPoint3 [
	"same as the previous test, but with an additional translation"
	| tfMatrix data expectedData theta shift epsilon |
	
	epsilon := 0.00001.
	theta := 0.12334 * (Float pi).
	shift := 2@5.
	tfMatrix := VMTFMatrix r: (VMMatrix2d angle: theta) t: (VMVector2d point: shift ).
	data := {
		1@0.  0@1.  1@1.  3@2.  -1@4.  -1@ -4.
	}.
	expectedData := data collect: [ :aPoint |
		((aPoint rotateBy: theta about: 0@0) + shift).
	].
	
	tfMatrix applyToCollection: data.
	
	data doWithIndex: [ :pointA :index |
		| error |
		error := pointA dist: (expectedData at: index).
		self assert: (error < epsilon).
	].
	

]

{ #category : #'as yet unclassified' }
VMTFTests >> testIdentity [
	| mat error epsilon expectedValues |
	
	mat := VMTFMatrix identity.
	epsilon := 0.000001.
	expectedValues := {
		{ 1.0.  0.0.  0.0 }.
		{ 0.0.  1.0.  0.0 }.
		{ 0.0.  0.0.  1.0 }.
	}.
	
	expectedValues doWithIndex: [ :row :rIndex |
		row doWithIndex: [ :value :cIndex |
			error := (value - (mat at: rIndex at: cIndex)) abs.
			self assert: ( error < epsilon ).
		].
	].


]

{ #category : #'as yet unclassified' }
VMTFTests >> testRotation [
	"test the result of the 'angle' method for the values +/- halfPi and pi"
	| mat error epsilon angles expectedValues |
	
	mat := VMTFMatrix identity.
	epsilon := 0.000001.
	angles := { Float halfPi.  Float halfPi negated. Float pi. }.
	expectedValues := {
		{
			{ 0.0.  -1.0.  0.0 }.
			{ 1.0.  0.0.  0.0 }.
			{ 0.0.  0.0.  1.0 }.
		}.
		{
			{ 0.0.  1.0.  0.0 }.
			{ -1.0.  0.0.  0.0 }.
			{ 0.0.  0.0.  1.0 }.
		}.
		{
			{ -1.0.  0.0.  0.0 }.
			{ 0.0.  -1.0.  0.0 }.
			{ 0.0.  0.0.  1.0 }.
		}.
	}.
	
	angles doWithIndex: [ :angle :index |
		mat angle: angle.
		
		(expectedValues at: index) doWithIndex: [ :row :rIndex |
			row doWithIndex: [ :value :cIndex |
				error := (value - (mat at: rIndex at: cIndex) ) abs.
				self assert: (error < epsilon).
			].
		].
	].



]
