Class {
	#name : #VMLinearRegressionTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #'as yet unclassified' }
VMLinearRegressionTest >> testCompute [
	| points vectors linReg result expectedResult |
	
	points := {  2 @ 2.  4 @ 0.  6 @ 0.  8 @ 2  }.
	vectors := OrderedCollection new.
	1 to: points size - 1 do: [ :index |
		vectors add: (VMLineSegment
			pointA: (points at: index)
			pointB: (points at: index+1)).
	].

	linReg := VMLinearRegression new.
	result := linReg compute: vectors.
	expectedResult := VMLine pointA: 0@1 pointB: 1@1.
	
	self assert: (result isCollinearWith: expectedResult).

]

{ #category : #'as yet unclassified' }
VMLinearRegressionTest >> testCompute2 [
	"same data set as #testCompute, but mirrored on the diagonal. consequently the result is expected to be parallel to the y axis"
	| points vectors linReg result expectedResult |
	
	points := {  2 @ 2.  0 @ 4.  0 @ 6.  2 @ 8  }.
	vectors := OrderedCollection new.
	1 to: points size - 1 do: [ :index |
		vectors add: (VMLineSegment
			pointA: (points at: index)
			pointB: (points at: index+1)).
	].

	linReg := VMLinearRegression new.
	result := linReg compute: vectors.
	expectedResult := VMLine pointA: 1@0 pointB: 1@1.
	
	self assert: (result isCollinearWith: expectedResult).

]

{ #category : #'as yet unclassified' }
VMLinearRegressionTest >> testCompute3 [
	"testing linear regression with a single vector"
	| vectors linReg result expectedResult |
	
	vectors := {VMLineSegment from: 2@2 to: 4@3 type: 1} asOrderedCollection.

	linReg := VMLinearRegression new.
	result := linReg compute: vectors.
	expectedResult := vectors first asVMLine.
	
	self assert: (result isCollinearWith: expectedResult).

]

{ #category : #'as yet unclassified' }
VMLinearRegressionTest >> testCompute4 [
	| vectors linReg result expectedResult |
	
	vectors := {
		VMLineSegment from: 2@2 to: 4@3 type: 1.
		VMLineSegment from: 4@3 to: 6@4 type: 1.
	} asOrderedCollection.

	linReg := VMLinearRegression new.
	result := linReg compute: vectors.
	expectedResult := vectors first asVMLine.
	
	self assert: (result isCollinearWith: expectedResult).

]
