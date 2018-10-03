Class {
	#name : #VMConvexTestTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
VMConvexTestTest >> testResult [
	"tests the #isConvex method, which is an alias for the #result method."
	| test data data2 lineSegs lineSegs2 |
	
	data := { 1@1.  3@1.  3@3.  1@3 }.  "corners of a square"
	data2 := data reversed.  "reversed order will flip the direction of the line segments"
	
	lineSegs := OrderedCollection new.
	lineSegs2 := OrderedCollection new.
	
	data doWithIndex: [ :aPoint :index |
		lineSegs add: (VMLineSegment from: aPoint to: (data atWrap: (index+1))).
	].
	data2 doWithIndex: [ :aPoint :index |
		lineSegs2 add: (VMLineSegment from: aPoint to: (data2 atWrap: (index+1))).
	].
	
	"first setup is modelling an obstacle in free space. the obstacle is convex, but
	the traversable space around it is not, hence isConvex should return 'false'."
	test := VMConvexTest lineCollection: lineSegs.
	self assert: test isConvex.
	
	"the second setup is the oposite of the first: the traversable space is inside
	the square that is defined by the line segments"
	test := VMConvexTest lineCollection: lineSegs2.
	self assert: test isConvex not.
	

]

{ #category : #tests }
VMConvexTestTest >> testResult2 [
	"this test is similar to the previous one, but contains a pair of (connected)
	parallel line segments. the results should be the same as in the previous test"
	| test data data2 lineSegs lineSegs2 |
	
	data := { 1@1.  3@1.  3@2.  3@3.  1@3 }.  "a square, with one side made up from to half-length line segments"
	data2 := data reversed.  "reversed order will flip the direction of the line segments"
	
	lineSegs := OrderedCollection new.
	lineSegs2 := OrderedCollection new.
	
	data doWithIndex: [ :aPoint :index |
		lineSegs add: (VMLineSegment from: aPoint to: (data atWrap: (index+1))).
	].
	data2 doWithIndex: [ :aPoint :index |
		lineSegs2 add: (VMLineSegment from: aPoint to: (data2 atWrap: (index+1))).
	].
	
	"first setup is modelling an obstacle in free space. the obstacle is convex, but
	the traversable space around it is not, hence isConvex should return 'false'."
	test := VMConvexTest lineCollection: lineSegs.
	self assert: test isConvex.
	
	"the second setup is the oposite of the first: the traversable space is inside
	the square that is defined by the line segments"
	test := VMConvexTest lineCollection: lineSegs2.
	self assert: test isConvex not.
	

]
