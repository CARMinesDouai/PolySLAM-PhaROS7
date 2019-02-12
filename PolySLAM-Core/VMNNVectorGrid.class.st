"
This class provides a nearest neighbor search for a set of vectors (typically obstacles). In this regard, it provides the same service as VMBSPLeaf/Node and VMGridStorage, but tends to be faster on small data sets. The vectors are indexed in a grid structure, the nearest neighbor search first looks up the closest cell(s) and then performs a linear search within the cell(s).


Public API and Key Messages

- add: <aVector>
	adds a single vector to the grid. the vector may be associated with multiple grid cells in the process
- addAll: <aCollectionOfVectors>
	iteratively adds all vectors of the collection via #add:
- insert: <aVector>
	simply an alias for #add: for compability with some older classes
- addedVectors
	a collection of all vector added via #add: (and methods that call #add:)
- findNearest: <aPoint>
	returns a VMNNSearchResult instance, which provides the closest point for the provided search query
- findNearest: <aPoint> sensorPoint: <aPoint>
	same as #findNearest: , but only considers vectors whose normal is pointing towards the provided sensor point.
	this method practically performs backface culling, ignoring all vectors that are impossible matches for the
	provided sensor center.
- do: <aBlockClosure>
	the standard #do: method, same as calling 'addedVectors do:'
- size
	returns the number of vectors added. same as 'addedVectors size'
- ifEmpty: <aBlock>
	executes aBlock if no vectors have been added yet.
- bounds
	returns a rectangle that encompasses all added vectors
- asRenderableElement
	returns an object that is renderable for the GUI-Athens interface from the PolySLAM-Extra package



Example
| vc v1 v2 |
vc := VMNNVectorGrid new.
vc addAll: (VMPolygon fromPoints: {0@0.  2@0.  3@3.  0@3} withTypes: {1. 1. 1. 1}).
v1 := (vc findNearest: 0.5@1) result.
v2 := (vc findNearest: 0.5@1 sensorPoint: -2@1) result.
(VMRenderCollection new addAll: {vc. v1. v2}; yourself) inspect.


 
Internal Representation and Key Implementation Points.

	addedVectors: <a collection>
		a collection that contains all vectors that have been added
	xCollection: <a 2D grid>
		a 2d grid (collection of collections) that contains the vectors
	xOffset: <anInteger>
		the offset of the xCollection, to allow for negative indices


"
Class {
	#name : #VMNNVectorGrid,
	#superclass : #Object,
	#instVars : [
		'xCollection',
		'xOffset',
		'addedVectors'
	],
	#category : #'PolySLAM-Core-Nearest Neighbor Search'
}

{ #category : #adding }
VMNNVectorGrid >> add: aVector [
	| x y direction stopX stopY stepValue |
	addedVectors add: aVector.
	self checkXSize: aVector.
	"1) get starting cell
	2) find cell where the line hits the y border
	3) add to cells until the cell from (2), unless the vector ends before that
	4) change row and repeat"
	x := aVector pointA x floor.
	y := aVector pointA y floor.
	stopX := aVector pointB x floor.
	stopY := aVector pointB y floor.
	direction := aVector direction.
	stepValue := direction x > 0 ifTrue: [1] ifFalse:[-1].
	
	"aVector is pointing upwards"
	direction y > 0 ifTrue: [
		| iPoint stopX2 |
		[ y <= stopY ] whileTrue: [
			iPoint := (VMIntersection intersectLine: aVector withLine: (VMLine pointA: 0@(y+1) pointB: 1@(y+1))) intersectionPoint.
			stopX2 := stepValue > 0 ifTrue: [ iPoint x floor min: stopX ] ifFalse: [ iPoint x floor max: stopX ].
			x to: stopX2 by: stepValue do: [ :i | self at: i at: y put: aVector ].
			y := y + 1.
			x := stopX2
		]
	].
	
	"aVector is point downwards"
	direction y < 0 ifTrue: [
		| iPoint stopX2 |
		[ y >= stopY ] whileTrue: [
			iPoint := (VMIntersection intersectLine: aVector withLine: (VMLine pointA: 0@(y) pointB: 1@(y))) intersectionPoint.
			stopX2 := stepValue > 0 ifTrue: [ iPoint x floor min: stopX ] ifFalse: [ iPoint x floor max: stopX ].
			x to: stopX2 by: stepValue do: [ :i | self at: i at: y put: aVector ].
			y := y - 1.
			x := stopX2
		]
	].
	
	"horizontal vector - y coordinate never changes"
	direction y = 0 ifTrue: [
		x to: stopX by: stepValue  do: [ :i | self at: i at: y put: aVector ].
	].

]

{ #category : #adding }
VMNNVectorGrid >> addAll: aCollection [
	aCollection do: [ :obj |
		self add: obj.
	].
]

{ #category : #accessing }
VMNNVectorGrid >> addedVectors [
	^ addedVectors
]

{ #category : #converting }
VMNNVectorGrid >> asNNCollection [
	^self
]

{ #category : #converting }
VMNNVectorGrid >> asRenderableElement [
	^ (VMCollectionRenderer new)
		collection: addedVectors.
]

{ #category : #accessing }
VMNNVectorGrid >> at: x at: y [
	^ ((xCollection at: x+xOffset ifAbsent: [ ^ nil ])
		at: y)
			
]

{ #category : #accessing }
VMNNVectorGrid >> at: x at: y put: aVector [
	| row |
	row := xCollection at: x+xOffset ifAbsent: [ self error: 'invalid x index'. ].
	row checkBoundary: y.
	(row at: y) add: aVector.
	"((xCollection at: x+xOffset ifAbsent: [ self error: 'invalid x index'. ])
		at: y)
			add: aVector."
]

{ #category : #accessing }
VMNNVectorGrid >> bounds [
	| rect |
	
	rect := addedVectors first bounds.
	addedVectors allButFirstDo: [ :v | rect := rect merge: v bounds ].
	
	^ rect
]

{ #category : #'find nearest neighbor - helper' }
VMNNVectorGrid >> checkCenterX: x y: y point: point [
	| collection result |
	
	result := VMNNSearchResult object: nil squareDist: Float infinity.
	
	collection := self at: x at: y.
	
	^ self checkCollection: collection point: point result: result
]

{ #category : #'find nearest neighbor - helper' }
VMNNVectorGrid >> checkCenterX: x y: y point: point sensorPoint: sensorPoint [
	"same as #checkCenterX:y:point but ignores backface vectors (i.e. vectors who's normal faces away from sensorPoint)"
	| collection result |
	
	result := VMNNSearchResult object: nil squareDist: Float infinity.
	
	collection := self at: x at: y.
	
	^ self checkCollection: collection point: point result: result sensorPoint: sensorPoint

]

{ #category : #'find nearest neighbor - helper' }
VMNNVectorGrid >> checkCollection: collection point: point result: result [
	| minDist minPoint |
	
	collection ifNil: [ ^ result ].
	
	minDist := result squareDist.
	minPoint := nil.
	
	collection do: [ :v |
		| dist cPoint |
		"(v isPointOnLeftSide: point) ifTrue: ["
			cPoint := v closestPoint: point.
			dist := cPoint squaredDistanceTo: point.
			dist < minDist ifTrue: [ minDist := dist. minPoint := cPoint. ].
		"]"
	].
	
	^ VMNNSearchResult object: (minPoint ifNil: [ result object.] ifNotNil: [(minPoint)]) squareDist: minDist

]

{ #category : #'find nearest neighbor - helper' }
VMNNVectorGrid >> checkCollection: collection point: point result: result sensorPoint: sensorPoint [
	"computes the distance from 'point' to every vector in 'collection', where 'sensorPoint'
	lies on the left side of the vector (i.e. ignoring backfacing vectors). if this results
	in a distance less than 'result squareDist', then we update 'result'. otherwise we just
	return a copy of the original 'result'"
	| minPoint minDist |
	
	collection ifNil: [ ^ result ].
	
	minPoint := nil.
	minDist := result squareDist.
	
	collection do: [ :v |
		| dist cPoint |
		(v isPointOnLeftSide: sensorPoint) ifTrue: [
			cPoint := v closestPoint: point.
			dist := cPoint squaredDistanceTo: point.
			dist < minDist ifTrue: [ minDist := dist. minPoint := cPoint. ].
		]
	].
	
	^ VMNNSearchResult
		object: (minPoint ifNil: [ result object.] ifNotNil: [(minPoint)])
		squareDist: minDist

]

{ #category : #'find nearest neighbor - helper' }
VMNNVectorGrid >> checkRing: ringSize point: point result: result [
	"searches in a ring around the center cell. for example, with ringSize=1, we search in a 3x3 area, excluding the 1x1 center.
	with ringSize=2, we search in a 5x5 area, excluding the 3x3 center."
	| x y collection newResult |
	
	x := point x floor.
	y := point y floor.
	newResult := result.

	result squareDist > (self distToNearestCell: point cellCounter: ringSize - 1) ifTrue: [
		"horizontal cells (top & bottom rows)"
		y-ringSize to: y+ringSize by: 2*ringSize do: [ :j |
			x-ringSize to: x+ringSize do: [ :i |
				collection := self at: i at: j.
				newResult := self checkCollection: collection point: point result: result.
			].
		].
		
		"vertical cells (left and right columns)"
		y-ringSize+1 to: y+ringSize-1 do: [ :j |
			x-ringSize to: x+ringSize by: 2*ringSize do: [ :i |
				collection := self at: i at: j.
				newResult := self checkCollection: collection point: point result: result.
			].
		].
	].
	
	^ newResult

]

{ #category : #'find nearest neighbor - helper' }
VMNNVectorGrid >> checkRing: ringSize point: point result: result sensorPoint: sensorPoint [
	"searches in a ring around the center cell. for example, with ringSize=1, we search in a 3x3 area, excluding the 1x1 center.
	with ringSize=2, we search in a 5x5 area, excluding the 3x3 center."
	| x y collection newResult |
	
	x := point x floor.
	y := point y floor.
	newResult := result.

	result squareDist > (self distToNearestCell: point cellCounter: ringSize - 1) ifTrue: [
		"horizontal cells (top & bottom rows)"
		y-ringSize to: y+ringSize by: 2*ringSize do: [ :j |
			x-ringSize to: x+ringSize do: [ :i |
				collection := self at: i at: j.
				newResult := self checkCollection: collection point: point result: result sensorPoint: sensorPoint.
			].
		].
		
		"vertical cells (left and right columns)"
		y-ringSize+1 to: y+ringSize-1 do: [ :j |
			x-ringSize to: x+ringSize by: 2*ringSize do: [ :i |
				collection := self at: i at: j.
				newResult := self checkCollection: collection point: point result: result sensorPoint: sensorPoint.
			].
		].
	].
	
	^ newResult

]

{ #category : #growing }
VMNNVectorGrid >> checkXSize: aVector [
	"ensures that xCollection is large enough to contain 'aVector'."
	| xStart xEnd minX maxX |
	
	xStart := aVector pointA x floor.
	xEnd := aVector pointB x floor.
	minX := xStart min: xEnd.
	maxX := xStart max: xEnd.
	
	"grow to the left if necessary"
	[ minX + xOffset <= 0 ] whileTrue: [
		xCollection addFirst: VMDoubleEndedCollection new.
		xOffset := xOffset + 1.
	].
	
	"grow to the right if necessary"
	[ maxX >= (xCollection size - xOffset) ] whileTrue: [ xCollection add: VMDoubleEndedCollection new. ].
	
	
]

{ #category : #'find nearest neighbor - helper' }
VMNNVectorGrid >> distToNearestCell: point cellCounter: cellCounter [
	"returns the square distance to the closest cell. cellCounter is the distance to the center cell,
	e.g. cellCounter = 0 means the 3x3 cells (minus the 1x1 center),
	cellCounter = 1 means the 5x5 cells (minus the 3x3 center), etc."
	| x y |
	x := point x fractionPart.
	y := point y fractionPart.
	
	x > 0.5 ifTrue: [ x := 1.0 - x ].
	y > 0.5 ifTrue: [ y := 1.0 - y ].
	
	x > y
		ifTrue: [ ^ (y + cellCounter) squared ]
		ifFalse: [ ^ (x + cellCounter) squared ].
	

]

{ #category : #'as yet unclassified' }
VMNNVectorGrid >> do: aBlock [
	addedVectors do: aBlock
]

{ #category : #'find nearest neighbor' }
VMNNVectorGrid >> findNearest: pointLikeObject [
	"searches in an up to 7x7 radius around the point"
	| x y result |
	x := pointLikeObject x floor.
	y := pointLikeObject y floor.
	
	"start with the cell that the point in inside"
	result := self checkCenterX: x y: y point: pointLikeObject.
	
	"check in rings (L-infinity norm) around the center until we found something or give up. note: units are meters"
	1 to: 3 do: [ :ringSize |
		result := self checkRing: ringSize point: pointLikeObject result: result.
		"result object ifNotNil: [ ^ result ]."
	].
	
	^ result
	
]

{ #category : #'find nearest neighbor' }
VMNNVectorGrid >> findNearest: pointLikeObject sensorPoint: sensorPoint [
	"searches in an up to 7x7 radius around the point. backface vectors are ignored."
	| x y result |
	x := pointLikeObject x floor.
	y := pointLikeObject y floor.
	
	"start with the cell that the point in inside"
	result := self checkCenterX: x y: y point: pointLikeObject sensorPoint: sensorPoint.
	
	"check in rings (L-infinity norm) around the center until we found something or give up. note: units are meters"
	1 to: 3 do: [ :ringSize |
		result := self checkRing: ringSize point: pointLikeObject result: result sensorPoint: sensorPoint.
		"result object ifNotNil: [ ^ result ]."
	].
	
	^ result
	
]

{ #category : #'GT Inspector' }
VMNNVectorGrid >> gtInspectorRenderedIn: composite [
	<gtInspectorPresentationOrder: 50>
	
	(composite morph)
		title: 'Viewer';
		morph: [
			(VMViewer openWindowlessOn: { self asRenderableElement })
				autozoom.
		].
		
]

{ #category : #testing }
VMNNVectorGrid >> ifEmpty: aBlock [
	addedVectors isEmpty ifTrue: [ aBlock value ].
]

{ #category : #initialization }
VMNNVectorGrid >> initialize [
	xCollection := OrderedCollection new.
	addedVectors := VMRenderCollection new.
	xOffset := 0.
]

{ #category : #adding }
VMNNVectorGrid >> insert: aVector [
	^ self add: aVector
]

{ #category : #helper }
VMNNVectorGrid >> printDebug [
	xCollection doWithIndex: [ :yCol :indexX |
		Transcript show: (indexX-xOffset) printString; cr.
		
		yCol doWithIndex: [ :cellCol :indexY |
			Transcript show: '  ';
				show: ((indexY - (yCol offset)) printString);
				show: ': '.
			cellCol
				ifNil: [ Transcript show: 'nil'. ]
				ifNotNil: [
					cellCol
						ifEmpty: [ Transcript show: 'empty' ]
						ifNotEmpty: [
							cellCol do: [ :vec |
								Transcript
									show: vec pointA;
									show: ' '.
							]
						].
				].
			Transcript cr.
		].
	].
	^ 'see Transcript output'
]

{ #category : #accessing }
VMNNVectorGrid >> size [
	^ addedVectors size.
]
