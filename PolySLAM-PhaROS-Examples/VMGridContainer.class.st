"
This class creates a grid-like 2D storage structure that can grow in any direction. The structure is meant to hold VMLineSegment instances. The grid cells are quadratic with a legth of 'cellSize'


Note: this class needs some cleanup for a well-defined API instead of the current mix of naming and addressing conventions.


Construction:
	VMGridContainer new.
		this will create an empty grid container. it will automatically initialize when the first line segment is inserted. until then the corner will be nil.
		
	VMGridContainer new initWithCorner: <aPoint>
		this will create an empty but initialized grid container.
	
	VMGridContainer new cellSize: <aNumber>; initWithCorner: <aPoint>.
		this will create a grid container with a custom cell size and initialize it with the provided corner.

Adding  line segments:
	gc := VMGridContainer new.
	gc  insert: <aVMLineSegment>.
		in this example the newly constructed grid container will initialize itself, using the line segments pointA to construct a corner.
	
Public API and Key Messages

- at: <x> at: <y>
	returns the cell with the given coordinates. if no space has been allocated for the cell an assertion will be raised.
- atCoord: <aVMIntCoord instance>
	same as above, but uses a VMIntCoord object to address the cell.
- cellSize / cellSize: <aNumber>
	accessor for the cell size. the cell size must not be changed after the initWithCorner message has been send (which may happen implicitly by inserting a line segment or setting the corner).
- insert: <aVMLineSegment>
	inserts a line segment. a line segment can occupy mulitple cells in the grid storage
- insertAll: <a Collection of line segments>
	calls 'self insert:' on all elements inside the provided collection
- initWithCorner: <aPoint>
	fully initializes the grid container. the top left corner is set to 'aPoint'.
- numObjects
	returns the number of line segments that are stored in the grid storage. line segments that span mulitple cells still only count as one object is this regard.
- remove: <VMLineSegment>
	removes a line segment from the structure. the line segment will be removed from all cells where it has been stored. the function must be used only on line segments are actually stored in the grid container.


Instance Variables
	container
		this is an OrderedCollection of OrderedCollection of OrderedCollection, representing columns, rows, and cells. rows and cells are allocated on demand only.

"
Class {
	#name : #VMGridContainer,
	#superclass : #Object,
	#instVars : [
		'collection',
		'corner',
		'cellSize',
		'cellCountX',
		'numObjects'
	],
	#category : #'PolySLAM-PhaROS-Examples-Helper'
}

{ #category : #accessing }
VMGridContainer >> at: x at: y [
	| col row |
	
	self assert: ( x > 0 ).
	self assert: ( y > 0 ).
	self assert: ( x <= (collection size)).
	
	col := collection at: x.
	
	col ifEmpty: [ col := OrderedCollection new. ].
	
	(col size < y) ifTrue: [
		col size to: y do: [ :i | col add: OrderedCollection new. ].
	].
	
	row := col at: y.
	^row.

]

{ #category : #accessing }
VMGridContainer >> at: x at: y put: lineSeg [
	| col row |
	
	self assert: ( x > 0 ).
	self assert: ( y > 0 ).
	self assert: ( x <= (collection size)).
	
	col := collection at: x.
	
	col ifEmpty: [
		collection at: x put: OrderedCollection new.
		col := collection at: x.
	].
	
	(col size < y) ifTrue: [
		col size to: y do: [ :i | col add: OrderedCollection new. ].
	].
	
	row := col at: y.
	row add: lineSeg.
	

]

{ #category : #accessing }
VMGridContainer >> atCoord: intCoord [
	| col row |
	
	self assert: ( intCoord x > 0 ).
	self assert: ( intCoord y > 0 ).
	self assert: ( intCoord x <= (collection size)).
	
	col := collection at: intCoord x.
	
	col ifEmpty: [ col := OrderedCollection new. ].
	
	(col size < intCoord y) ifTrue: [
		col size to: intCoord y do: [ :i | col add: OrderedCollection new. ].
	].
	
	row := col at: intCoord y.
	^row.

]

{ #category : #accessing }
VMGridContainer >> atCoord: intCoord put: lineSeg [
	
	self at: intCoord x at: intCoord y put: lineSeg.
	

]

{ #category : #accessing }
VMGridContainer >> cellAt: coords [
	"returns the cell at the provided coordinates or nil if no cell is found"
	| col |
	
	"basic check to discard invalid coordinates"
	((coords x < 0) or: [coords y < 0]) ifTrue: [ ^nil ].
	
	col := collection at: coords x.
	
	((col isEmpty) or: [coords y > col size]) ifTrue: [ ^nil ].
	
	^col at: coords y.

]

{ #category : #'cell borders' }
VMGridContainer >> cellBottomBorderAt: intCoord [
	^self cellTopBorderX: intCoord x y: intCoord y+1.
]

{ #category : #'cell borders' }
VMGridContainer >> cellBottomBorderX: x y: y [
	^self cellTopBorderX: x y: y+1.
]

{ #category : #private }
VMGridContainer >> cellCoordsAtPoint: aPoint [
	| cellX cellY |
	
	cellX := ((aPoint x) - (corner x) / cellSize) ceiling.
	cellY := ((aPoint y) - (corner y) / cellSize) ceiling.
	
	
	^VMIntCoords x: cellX y: cellY.

]

{ #category : #accessing }
VMGridContainer >> cellCountX [
	^cellCountX.
]

{ #category : #'cell borders' }
VMGridContainer >> cellLeftBorderAt: intCoord [
	^self cellRightBorderX: intCoord x-1 y: intCoord y.
]

{ #category : #'cell borders' }
VMGridContainer >> cellLeftBorderX: x y: y [
	^self cellRightBorderX: x-1 y: y.
]

{ #category : #'cell borders' }
VMGridContainer >> cellRightBorderAt: intCoord [
	| pointA pointB |
	
	pointA := (intCoord x * cellSize) @ ((intCoord y - 1) * cellSize).
	pointB := (intCoord x * cellSize) @ (intCoord y * cellSize).
	
	^VMLineSegment
		from: corner + pointA
		to: corner + pointB.

]

{ #category : #'cell borders' }
VMGridContainer >> cellRightBorderX: x y: y [
	| pointA pointB |
	
	pointA := (x * cellSize) @ ((y-1) * cellSize).
	pointB := (x * cellSize) @ (y * cellSize).
	
	^VMLineSegment
		from: corner + pointA
		to: corner + pointB.

]

{ #category : #accessing }
VMGridContainer >> cellSize [
	^cellSize.
]

{ #category : #accessing }
VMGridContainer >> cellSize: aNumber [
	"we must not change the cell size after full initialization"
	self assert: corner isNil.
	cellSize := aNumber.
]

{ #category : #'cell borders' }
VMGridContainer >> cellTopBorderAt: intCoord [
	| pointA pointB |
	
	pointA := ((intCoord x-1) * cellSize) @ ((intCoord y-1) * cellSize).
	pointB := (intCoord x * cellSize) @ ((intCoord y-1) * cellSize).
	
	^VMLineSegment
		from: corner + pointA
		to: corner + pointB.

]

{ #category : #'cell borders' }
VMGridContainer >> cellTopBorderX: x y: y [
	| pointA pointB |
	
	pointA := ((x-1) * cellSize) @ ((y-1) * cellSize).
	pointB := (x * cellSize) @ ((y-1) * cellSize).
	
	^VMLineSegment
		from: corner + pointA
		to: corner + pointB.

]

{ #category : #private }
VMGridContainer >> cellsAround: aPoint coords: coords within: minDist [
	"currently this just adds the 8 cells neighboring the cell at 'coords'. in the future we
	want to discard all cells that are already farther away then 'minDist'."
	| cellCollection |
	
	cellCollection := OrderedCollection new.
	-1 to: 1 do: [ :i |
		self ifCellAt: coords x + i at: coords y -1 do: [ :cell |
			cellCollection add: cell.
		].
		self ifCellAt: coords x + i at: coords y +1 do: [ :cell |
			cellCollection add: cell.
		].
	].
	self ifCellAt: coords x + 1 at: coords y do: [ :cell |
		cellCollection add: cell.
	].
	self ifCellAt: coords x - 1 at: coords y do: [ :cell |
		cellCollection add: cell.
	].
	
	^cellCollection.

]

{ #category : #private }
VMGridContainer >> checkBoundsLineSeg: lineSeg [
	"checks if 'lineSeg' is within the bounds of this grid countainer. if it is out of bounds then the container grows to fit 'lineSeg'."
	| minX maxX minY cellsA cellsB |
	
	cellsA := self cellCoordsAtPoint: lineSeg pointA.
	cellsB := self cellCoordsAtPoint: lineSeg pointB.
	
	minX := cellsA x min: cellsB x.
	maxX := cellsA x max: cellsB x.
	minY := cellsA y min: cellsB y.
	
	(maxX > collection size) ifTrue: [
		self growRight: maxX - collection size.
	].
	
	(minX < 1) ifTrue: [
		self growLeft: 1 - minX.
	].
	
	(minY < 1 ) ifTrue: [
		self growTop: 1 - minY.
	].

]

{ #category : #accessing }
VMGridContainer >> corner [
	^corner.
]

{ #category : #operations }
VMGridContainer >> findNearest: aPoint abortDist: abortDist [
	| coords minDist result |
	
	result := VMNNSearchResult new
		object: nil;
		squareDist: abortDist squared;
		yourself.
	
	minDist := abortDist.
	
	"note, that the coordinates don't necessary address an existing cell. they may even be negative."
	coords := self cellCoordsAtPoint: aPoint.
	
	self ifCellAt: coords do: [ :cell |
		minDist := self findNearest: aPoint inCell: cell abortDist: abortDist result: result.
	].
	
	(self cellsAround: aPoint coords: coords within: minDist) do: [ :cell |
		minDist := self findNearest: aPoint inCell: cell abortDist: minDist result: result.
	].
	
	self logCr: 'MinDist=', minDist printString.
	
	^result.

]

{ #category : #private }
VMGridContainer >> findNearest: aPoint inCell: aCell abortDist: abortDist result: result [
	| minDist |
	
	minDist := abortDist.
	
	aCell do: [ :lineSeg |
		| dist |
		dist := lineSeg distanceToPoint: aPoint.
		(dist < minDist) ifTrue: [
			minDist := dist.
			result object: lineSeg.
			result squareDist: dist squared.
		].
	].
	
	
	^minDist.

]

{ #category : #'private - growing' }
VMGridContainer >> growLeft: cellCount [
	"grows 'collection' to the left by 'cellCount' new entries. the old entries (representing the y-axis) are moved to their new positions."
	| newCollection |
	
	corner := corner - ((cellCount * cellSize) @ 0).
	
	newCollection := OrderedCollection new.
	
	1 to: cellCount do: [ :index |
		newCollection add: OrderedCollection new..
	].
	
	newCollection addAll: collection.
	
	cellCountX := cellCountX + cellCount.
	collection := newCollection.

]

{ #category : #'private - growing' }
VMGridContainer >> growRight: cellCount [
	1 to: cellCount do: [ :i | collection add: OrderedCollection new. ].
	cellCountX := cellCountX + cellCount.
]

{ #category : #'private - growing' }
VMGridContainer >> growTop: cellCount [
	"grows 'collection' towards the top. any non-empty rows are shifted downwards to compensate for the growth."
	collection doWithIndex: [ :col :index |
		col ifNotEmpty: [
			| newCollection |
			
			newCollection := OrderedCollection new.
			1 to: cellCount do: [ :i | newCollection add: OrderedCollection new. ].
			newCollection addAll: col.
			
			collection at: index put: newCollection.
		].
	].
	
	corner := corner - (0 @ (cellCount * cellSize)).

]

{ #category : #private }
VMGridContainer >> ifCellAt: x at: y do: aBlock [
	| col |
	
	(x < 1) ifTrue: [ ^false. ].
	(y < 1) ifTrue: [ ^false. ].
	(x > cellCountX ) ifTrue: [ ^false. ].
	
	col := collection at: x.
	
	(col size < y) ifTrue: [ ^false. ].
	
	aBlock value: ( col at: y ).
	^true.

]

{ #category : #private }
VMGridContainer >> ifCellAt: coords do: aBlock [
	^self ifCellAt: coords x at: coords y do: aBlock.

]

{ #category : #initialization }
VMGridContainer >> initWithCorner: aPoint [
	corner := aPoint.
	
	cellCountX := 1.
	
	collection := OrderedCollection new.
	collection add: OrderedCollection new.
]

{ #category : #initialization }
VMGridContainer >> initialize [
	
	corner := nil.
	cellSize := 0.5.
	
	cellCountX := 0.
	
	numObjects := 0.
	
	collection := OrderedCollection new.
]

{ #category : #operations }
VMGridContainer >> insert: lineSeg [
	
	corner ifNil: [
		self initWithCorner: lineSeg pointA - ( (cellSize/2)@(cellSize/2) ).
	].
	
	self checkBoundsLineSeg: lineSeg.
	
	self insertWithoutCheck: lineSeg.

]

{ #category : #operations }
VMGridContainer >> insertAll: aCollectionOfLineSegs [
	
	aCollectionOfLineSegs do: [ :lineSeg |
		self insert: lineSeg.
	].

]

{ #category : #private }
VMGridContainer >> insertWithoutCheck: lineSeg [
	"same as insert, but without checking if properly initialized or 'lineSeg' is out of bounds."
	| startCellCoord endCellCoord stepX stepY maxIterations iterationCount curCoord |
	
	numObjects := numObjects + 1.
	
	startCellCoord := self cellCoordsAtPoint: lineSeg pointA.
	endCellCoord := self cellCoordsAtPoint: lineSeg pointB.
	
	stepX := (startCellCoord x < endCellCoord x) ifTrue: [ 1 ] ifFalse: [ -1 ].
	stepY := (startCellCoord y < endCellCoord y) ifTrue: [ 1 ] ifFalse: [ -1 ].

	curCoord := startCellCoord copy.	
	
	iterationCount := 0.
	maxIterations := 100.
	
	self at: startCellCoord x at: startCellCoord y put: lineSeg.
	
	[ (curCoord x = endCellCoord x) and: [curCoord y = endCellCoord y] ] whileFalse: [
		| newCoords |
		
		newCoords := self walkLineSeg: lineSeg at: curCoord stepX: stepX stepY: stepY.
		curCoord setTo: newCoords.
		
		self atCoord: newCoords put: lineSeg.
		
		iterationCount := iterationCount + 1.
		self assert: maxIterations > iterationCount.
	].
	
	^iterationCount.

]

{ #category : #accessing }
VMGridContainer >> numObjects [
	^numObjects.
]

{ #category : #'as yet unclassified' }
VMGridContainer >> raycast: aRay [
	| coords cell |
	
	"todo:
	 - check if we are inside the bounding borders of the grid container
	   - if we are outside, check if we ever hit the bounding box
	     - if we never hit the bounding box, then we are outside of the map
	     - if we hit the bounding box, we need to access the related cell and continue from there
	   - if we are inside the bounding box, we need to:
	     - check for hits with all line segments within the affected cell
	     - move to the next cell
	
	"
	
	coords := self cellCoordsAtPoint: aRay point.
	cell := self cellAt: coords.
	
	"check if we are right on a line segment"
	"cast the ray"
]

{ #category : #operations }
VMGridContainer >> remove: lineSeg [
	"same as insert, but without checking if properly initialized or 'lineSeg' is out of bounds."
	| startCellCoord endCellCoord stepX stepY maxIterations iterationCount curCoord |
	
	startCellCoord := self cellCoordsAtPoint: lineSeg pointA.
	endCellCoord := self cellCoordsAtPoint: lineSeg pointB.
	
	stepX := (startCellCoord x < endCellCoord x) ifTrue: [ 1 ] ifFalse: [ -1 ].
	stepY := (startCellCoord y < endCellCoord y) ifTrue: [ 1 ] ifFalse: [ -1 ].

	curCoord := startCellCoord copy.	
	
	iterationCount := 0.
	maxIterations := 100.
	
	(self at: startCellCoord x at: startCellCoord y) remove: lineSeg ifAbsent: [ self errorNotFound: lineSeg ].
	
	[ (curCoord x = endCellCoord x) and: [curCoord y = endCellCoord y] ] whileFalse: [
		| newCoords |
		
		newCoords := self walkLineSeg: lineSeg at: curCoord stepX: stepX stepY: stepY.
		curCoord setTo: newCoords.
		
		(self atCoord: newCoords) remove: lineSeg ifAbsent: [ self errorNotFound: lineSeg ].
		
		iterationCount := iterationCount + 1.
		self assert: maxIterations > iterationCount.
	].
	
	numObjects := numObjects - 1.
	
	^iterationCount.

]

{ #category : #private }
VMGridContainer >> walkLineSeg: lineSeg at: intCoord stepX: stepX stepY: stepY [

	(stepX > 0) ifTrue: [
		((self cellRightBorderAt: intCoord) intersectsOrSharesWith: lineSeg)
			ifTrue: [ ^VMIntCoords x: intCoord x+1 y: intCoord y. ].
		^VMIntCoords x: intCoord x y: (intCoord y+stepY).
	] ifFalse: [
		((self cellLeftBorderAt: intCoord) intersectsOrSharesWith: lineSeg)
			ifTrue: [ ^VMIntCoords x: intCoord x-1 y: intCoord y. ].
		^VMIntCoords x: intCoord x y: (intCoord y+stepY).
	].
]

{ #category : #private }
VMGridContainer >> walkLineSeg: lineSeg cellX: x cellY: y stepX: stepX stepY: stepY [

	(stepX > 0) ifTrue: [
		((self cellRightBorderX: x y: y) intersectsOrSharesWith: lineSeg)
			ifTrue: [ ^VMIntCoords x: x+1 y: y. ].
		^VMIntCoords x: x y: (y+stepY).
	] ifFalse: [
		((self cellLeftBorderX: x y: y) intersectsOrSharesWith: lineSeg)
			ifTrue: [ ^VMIntCoords x: x-1 y: y. ].
		^VMIntCoords x: x y: (y+stepY).
	].
]
