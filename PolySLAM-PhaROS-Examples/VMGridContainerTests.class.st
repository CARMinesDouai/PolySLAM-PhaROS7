Class {
	#name : #VMGridContainerTests,
	#superclass : #TestCase,
	#instVars : [
		'gridContainer'
	],
	#category : #'PolySLAM-PhaROS-Examples-Tests'
}

{ #category : #running }
VMGridContainerTests >> setUp [
	gridContainer := VMGridContainer new
		cellSize: 0.5;
		initWithCorner: 0.5@0.5;
		yourself.
]

{ #category : #tests }
VMGridContainerTests >> testCellAtPoint [
	| data |
	
	data := {
		0.6@0.6.
		0.9@0.6.
		0.6@0.9.
		0.9@0.9.
	}.
	
	data do: [ :point |
		| obj |
		obj := gridContainer cellCoordsAtPoint: point.
		self assert: (obj x = 1).
		self assert: (obj y = 1).
	].

]

{ #category : #tests }
VMGridContainerTests >> testCellAtPoint2 [
	| data expectedResults |
	
	data := {
		0.6@0.6.
		0.2@0.2.
		1.6@0.9.
		0.9@1.6.
	}.
	
	expectedResults := {
		{ 1. 1 }.
		{ 0. 0 }.
		{ 3. 1 }.
		{ 1. 3 }.
	}.
	
	data doWithIndex: [ :point :index |
		| obj |
		obj := gridContainer cellCoordsAtPoint: point.
		self assert: (obj x = ((expectedResults at:index) first)).
		self assert: (obj y = ((expectedResults at:index) second)).
	].

]

{ #category : #tests }
VMGridContainerTests >> testCellBottomBorder [
	| borderLineSeg |
	
	borderLineSeg := gridContainer cellBottomBorderX: 1 y: 1.
	
	self assert: ((borderLineSeg pointA dist: 0.5@1) < 0.00001 ).
	self assert: ((borderLineSeg pointB dist: 1@1) < 0.00001 ).
	
	borderLineSeg := gridContainer cellBottomBorderAt: (VMIntCoords x: 1 y: 1).
	
	self assert: ((borderLineSeg pointA dist: 0.5@1) < 0.00001 ).
	self assert: ((borderLineSeg pointB dist: 1@1) < 0.00001 ).

]

{ #category : #tests }
VMGridContainerTests >> testCellLeftBorder [
	| borderLineSeg |
	
	borderLineSeg := gridContainer cellLeftBorderX: 1 y: 1.
	
	self assert: ((borderLineSeg pointA dist: 0.5@0.5) < 0.00001 ).
	self assert: ((borderLineSeg pointB dist: 0.5@1) < 0.00001 ).
	
	borderLineSeg := gridContainer cellLeftBorderAt: (VMIntCoords x: 1 y: 1).
	
	self assert: ((borderLineSeg pointA dist: 0.5@0.5) < 0.00001 ).
	self assert: ((borderLineSeg pointB dist: 0.5@1) < 0.00001 ).

]

{ #category : #tests }
VMGridContainerTests >> testCellRightBorder [
	| borderLineSeg |
	
	borderLineSeg := gridContainer cellRightBorderX: 1 y: 1.
	
	self assert: ((borderLineSeg pointA dist: 1@0.5) < 0.00001 ).
	self assert: ((borderLineSeg pointB dist: 1@1) < 0.00001 ).
	
	borderLineSeg := gridContainer cellRightBorderAt: (VMIntCoords x: 1 y: 1).
	
	self assert: ((borderLineSeg pointA dist: 1@0.5) < 0.00001 ).
	self assert: ((borderLineSeg pointB dist: 1@1) < 0.00001 ).

]

{ #category : #tests }
VMGridContainerTests >> testCellTopBorder [
	| borderLineSeg |
	
	borderLineSeg := gridContainer cellTopBorderX: 1 y: 1.
	
	self assert: ((borderLineSeg pointA dist: 0.5@0.5) < 0.00001 ).
	self assert: ((borderLineSeg pointB dist: 1@0.5) < 0.00001 ).
	
	borderLineSeg := gridContainer cellTopBorderAt: (VMIntCoords x: 1 y: 1).
	
	self assert: ((borderLineSeg pointA dist: 0.5@0.5) < 0.00001 ).
	self assert: ((borderLineSeg pointB dist: 1@0.5) < 0.00001 ).

]

{ #category : #tests }
VMGridContainerTests >> testConstructor [
	| container |
	
	container := VMGridContainer new.
	container initWithCorner: 1.2 @ 1.2.
	
	"this test is already successfull if there are no signals raised"
	self assert: true.
	
]

{ #category : #tests }
VMGridContainerTests >> testFindNearest [
	| data lineSeg collection result |
	
	data := {
		0.25 @ 0.25.
		0.25 @ 1.75.
		1.75 @ 1.75.
		1.75 @ 0.75.
		1.25 @ 0.25.
	}.
	
	collection := OrderedCollection new.
	
	data doWithIndex: [ :point :index |
		lineSeg := VMLineSegment from: point to: (data atWrap: (index+1)).
		collection add: lineSeg.
		gridContainer insert: lineSeg.
	].
	
	result := gridContainer findNearest: 0.3 @ 0.4 abortDist: 1.0.
	self assert: result object equals: (collection at: 1).
	
	result := gridContainer findNearest: 0.6 @ 0.7 abortDist: 1.0.
	self assert: result object equals: (collection at: 1).
	
	result := gridContainer findNearest: 1 @ 2 abortDist: 1.0.
	self assert: result object equals: (collection at: 2).
	
	result := gridContainer findNearest: 1.75 @ 0.5 abortDist: 1.0.
	self assert: result object equals: (collection at: 4).
	
	result := gridContainer findNearest: 0.75 @ -0.25 abortDist: 1.0.
	self assert: result object equals: (collection at: 5).
	

]

{ #category : #tests }
VMGridContainerTests >> testGrowing [
	| container startCorner newCorner |
	
	startCorner := 1.2 @ 1.2.
	container := VMGridContainer new
		initWithCorner: startCorner;
		yourself.
	
	container growRight: 5.
	container growLeft: 4.
	container growTop: 4.
	
	newCorner := container corner.
	
	self assert: ((newCorner dist: (-0.8 @ -0.8)) < 0.00001).
	self assert: (container cellCountX = 10).

]

{ #category : #tests }
VMGridContainerTests >> testInsert [
	| lineSeg |
	
	lineSeg := VMLineSegment from: (0.9@0.9) to: (1.1@1.1).
	
	gridContainer insert: lineSeg.
	
	"we consider this test successfull if we don't rise any signals"
	self assert: true.

]

{ #category : #tests }
VMGridContainerTests >> testInsert2 [
	| data lineSeg |
	
	data := {
		1.1 @ 1.2.
		2.3 @ 1.0.
		3.0 @ 1.0.
		1.0 @ 0.2.
		-3.1 @ 0.2.
		-3.2 @ -2.1.
		-5.3 @ -1.0.
	}.
	
	data doWithIndex: [ :point :index |
		lineSeg := VMLineSegment from: point to: (data atWrap: (index+1)).
		gridContainer insert: lineSeg.
	].
	
	"we consider this test successfull if we don't rise any signals"
	self assert: true.

]

{ #category : #tests }
VMGridContainerTests >> testInsert3 [
	| data lineSeg |
	
	data := {
		1.0 @ 1.0.
		3.0 @ 0.2.
		-3.0 @ 0.2.
		-3.5 @ -2.1.
		-5.3 @ -2.0.
	}.
	
	data doWithIndex: [ :point :index |
		lineSeg := VMLineSegment from: point to: (data atWrap: (index+1)).
		gridContainer insert: lineSeg.
	].
	
	"we consider this test successfull if we don't rise any signals"
	self assert: true.

]

{ #category : #tests }
VMGridContainerTests >> testInsertAndRemove [
	| lineSeg |
	
	lineSeg := VMLineSegment from: (0.9@0.9) to: (1.1@1.1).
	
	gridContainer insert: lineSeg.
	
	self assert: ( gridContainer numObjects = 1 ).
	
	gridContainer remove: lineSeg.
	
	self assert: ( gridContainer numObjects = 0 ).

]

{ #category : #tests }
VMGridContainerTests >> testInsertAndRemove2 [
	| data lineSeg allLineSegs |
	
	data := {
		1.1 @ 1.2.
		2.3 @ 1.0.
		3.0 @ 1.0.
		1.0 @ 0.2.
		-3.1 @ 0.2.
		-3.2 @ -2.1.
		-5.3 @ -1.0.
	}.
	
	allLineSegs := data collectWithIndex: [ :point :index |
		lineSeg := VMLineSegment from: point to: (data atWrap: (index+1)).
	].
	
	allLineSegs doWithIndex: [ :obj :index |
		gridContainer insert: obj.
		self assert: (gridContainer numObjects = index).
	].
	
	allLineSegs doWithIndex: [ :obj :index |
		gridContainer remove: obj.
		self assert: (gridContainer numObjects = (data size - index)).
	].
	

]

{ #category : #tests }
VMGridContainerTests >> testNumObjects [
	| data lineSeg |
	
	data := {
		1.1 @ 1.2.
		2.3 @ 1.0.
		3.0 @ 1.0.
		1.0 @ 0.2.
		-3.1 @ 0.2.
		-3.2 @ -2.1.
		-5.3 @ -1.0.
	}.
	
	data doWithIndex: [ :point :index |
		lineSeg := VMLineSegment from: point to: (data atWrap: (index+1)).
		gridContainer insert: lineSeg.
		self assert: (gridContainer numObjects = index).
	].
	
	"we consider this test successfull if we don't rise any signals"

]
