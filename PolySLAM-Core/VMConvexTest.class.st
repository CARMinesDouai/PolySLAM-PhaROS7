"
This class is used to determine if a given collection of line segments (forming a simple polygon) is conves or not. In case that the shape is not convex, we also provide the index of the first offending line segment.


Note: #lineCollection: must be called before any of the other methods in order to get any meaningfull results.

Methods (instance-side):

	failIndex
		returns the index of the first line segment that violates the required criteria for the shape to be convex
	isConvex
		returns a boolean, answering whether or not the shape is convex.
	lineCollection
		performs the actuall computation whether or not the provided shape is convex
	result
		an alias for #isConvex, based on the name of the internal variable

Methods (class-side)
	
	lineCollection
		constructor, that automatically calls the instance-side #lineCollection method. returns a class-instance

"
Class {
	#name : #VMConvexTest,
	#superclass : #Object,
	#instVars : [
		'failIndex',
		'result'
	],
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #constructing }
VMConvexTest class >> lineCollection: aLineSegCollection [
	^(self new)
		lineCollection: aLineSegCollection;
		yourself.
]

{ #category : #accessing }
VMConvexTest >> failIndex [
	^failIndex
]

{ #category : #accessing }
VMConvexTest >> isConvex [
	^result.
]

{ #category : #computing }
VMConvexTest >> lineCollection: aCollectionOfLineSegs [
	
	aCollectionOfLineSegs doWithIndex: [ :aLineSeg :index |
		| nextLineSeg |
		nextLineSeg := aCollectionOfLineSegs atWrap: (index + 1).
		
		self assert: (aLineSeg pointB closeTo: nextLineSeg pointA).  "end point of first line seg should match start point of next line seg"
		
		"if the next line segment is rotated clockwise when compared to the current line
		segment, then the shape is not convex. if it is left or parallel, we continue
		with the next line segment in the collection"
		aLineSeg
			point: nextLineSeg pointB
			ifOnLeftSideDo: []
			ifOnRightSideDo: [ failIndex := index. result := false. ^self ]
			ifOnLineDo: [].
	].
	
	result := true.
	

]

{ #category : #accessing }
VMConvexTest >> result [
	^result
]
