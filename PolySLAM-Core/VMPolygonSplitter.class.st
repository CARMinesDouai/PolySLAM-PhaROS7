"
The VMPolygonSplitter is splitting a polygon along a plane. This will result in one or more polygons. The original polygon provided will not be modified in the process.


Public API Messages:

- split: <aPolygon> onPlane: <aPlane>
	invokes the actual process of splitting the polygon along the provided plane
- leftPolygons
- rightPolygons
	provides the polygons of the left/right side of the plane after the splitting process
		

	
Private Key Messages:

- processLineSegments
	tries to split every line segment of the polygon along the plane. the results are stored in tempLineSeg
	if necessary, splitPoints will additionally store intersection points of the split process
- sortSplitPoints
	sorts the points in splitPoints, so that they are in order of increasing x (or y) values
- createBorderLineSegs
	creates line segments that result from line segments that have been split by the plane
- createPolygons
	creates polygons from the line segments

One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

Instance Variables
	borderLineSegs:		<OrderedCollection of <VMLineSegment>>
			contains line segments that are created in the splitting process and lie on 'plane'
	originalPolygon:		<VMPolygon>
			contains the original polygon that we want to split. this object is not modified in the process,
			copies are created whenever necessary
	plane:		<VMLine>
			the plane (line) that defines where the polygon has to be split
	polygons:		<LRCollection>
			a collection that holds the polygons of the left and right side of the splitting plane
	reversed:		<Boolean>
			true if the plane direction has been reversed, false if the plane remains unchanged.
			the leftPolygons/rightPolygons accessor uses this to provide the correct polygon collections.
	sortByX:		<Boolean>
			indicator on whether sorting is done by the x or y coordinates pf the points. based on the gradient of the plane.
	splitHint:		<Symbol>
			indicator in what direction the line segments in borderLineSegments should be facing
	splitPoints:		<OrderedCollection>
			a collection of intersection points from line segments intersecting with the plane
	tempLineSegs:		<LRCollection>
			a left-right-collection that contains the line segments that lie on the left/right side of the plane.
			contains both unmodified line segments (that do not intersect with the plane) and new line segments
			from the splitting process.
	tempOnLine:		<LRCollection>
			same as 'tempLineSegs', but for line segments that lie on the plane. line segments here are
			also associated with either left or right side of the plane, depending on which side will incooporate them
			into the new polygons.
	tempPolygon:		<VMPolygon>
			this is the polygon that is currently being reconstructed by #createPolygons and #createPolygonsFromCollection... .
			if the method was interrupted (e.g. by rising a signal), tempPolygon may contain an incomplete polygon (i.e.
			missing one or more line segments and therefor being not closed).


    Implementation Points
"
Class {
	#name : #VMPolygonSplitter,
	#superclass : #Object,
	#instVars : [
		'originalPolygon',
		'plane',
		'polygons',
		'tempLineSegs',
		'tempOnLine',
		'tempPolygon',
		'splitPoints',
		'borderLineSegs',
		'sortByX',
		'reversed'
	],
	#category : #'PolySLAM-Core-Data Structures: Polygons'
}

{ #category : #'public - splitting' }
VMPolygonSplitter class >> split: aPolygon onPlane: aPlane [
	^ self new
		split: aPolygon onPlane: aPlane
]

{ #category : #'private - accessing (for sunit tests)' }
VMPolygonSplitter >> borderLineSegs [
	"contains (sector) line segments that were newly created and lie on the hyperplane"
	^borderLineSegs
]

{ #category : #'public - accessing' }
VMPolygonSplitter >> bounds [
	originalPolygon ifNil: [ ^ nil ].
	^ originalPolygon bounds
]

{ #category : #'private - computing' }
VMPolygonSplitter >> createBorderLineSegs [
	
	splitPoints ifEmpty: [ ^self ].
	
	1 to: splitPoints size - 1 do: [ :index |
		(splitPoints at: index) = (splitPoints at: index + 1) ifFalse: [
			borderLineSegs add: 
				(VMLineSegment
					from: (splitPoints at: index+1)
					to: (splitPoints at: index)
					type: VMLineTypeSector new)
		].
	].
	

]

{ #category : #'private - computing' }
VMPolygonSplitter >> createPolygons [

	originalPolygon isCW ifTrue: [
		self createPolygonsFromCollection: tempLineSegs left withBorders: borderLineSegs asSet to: polygons left.
		self createPolygonsFromCollection: tempLineSegs right withBorders: (borderLineSegs collect: [:lineSeg | lineSeg reversed]) asSet to: polygons right.
	] ifFalse: [
		self createPolygonsFromCollection: tempLineSegs left withBorders: (borderLineSegs collect: [:lineSeg | lineSeg reversed]) asSet to: polygons left.
		self createPolygonsFromCollection: tempLineSegs right withBorders: borderLineSegs asSet to: polygons right.
	].
	

]

{ #category : #'private - computing' }
VMPolygonSplitter >> createPolygonsFromCollection: sourceCollection withBorders: borderSet to: targetCollection [
	| sourceSet |
	"1 halt."
	sourceSet := sourceCollection asSet. "creates a copy"
	
	[ sourceSet isEmpty ] whileFalse: [
		tempPolygon := originalPolygon species new.
		
		"start with a random line segment from the set"
		tempPolygon add: (sourceSet remove: sourceSet anyOne).
		
		"find a line segment that connects to the previous line segment"
		[ tempPolygon first pointA = tempPolygon last pointB] whileFalse: [
			"look in leftSet first, then in border set. if none is found we rise an error"
			sourceSet detect: [ :element | element pointA = tempPolygon last pointB ]
				ifFound: [ :element | tempPolygon add: (sourceSet remove: element) ]
				ifNone: [
					borderSet detect: [ :element | element pointA = tempPolygon last pointB ]
						ifFound: [ :element | tempPolygon add: (borderSet remove: element) ]
						ifNone: [
							"1 halt."
							self error: self class printString, ' - failed to find a matching line segment to create a closed polygon'.
				]
			]
		
		].
		
		"polygons must have the same orientation as originalPolygon, which should always be clock-wise"
		(tempPolygon size > 2)
			ifTrue: [
				"polygon isCW ifFalse: [ Transcript show: 'warning: polygon is oriented CCW'; cr. ]."
				targetCollection add: tempPolygon.
			] ifFalse: [
				Transcript show: 'warning: polygon size='; show: tempPolygon size printString; cr.
				1 halt.
			].
		
	]

]

{ #category : #'GT Inspector' }
VMPolygonSplitter >> gtInspectorDebugRenderedIn: composite [
	<gtInspectorPresentationOrder: 51>
	
	(composite morph)
		title: 'Viewer (L/R vectors)';
		morph: [
			| renderObjects bounds |
			renderObjects := OrderedCollection new.
			bounds := 0@0 extent: 1@1.
			originalPolygon
				ifNotNil: [
					renderObjects add: (originalPolygon asRenderableElement lineWidth: 0.01).
					bounds := (originalPolygon bounds).
					bounds := bounds expandBy: (bounds width max: bounds height) * 0.3].
			plane
				ifNotNil: [
					renderObjects add: ((plane asVMLineSegment fitIntoRectangle: bounds) asRenderableElement) ].
			tempLineSegs left do: [ :v |
				renderObjects add: (v asRenderableElement color: (Color fromString: '#FFB700'); lineWidth: 0.02). ].
			tempLineSegs right do: [ :v |
				renderObjects add: (v asRenderableElement color: (Color fromString: '#9BFF00'); lineWidth: 0.02). ].
			
			(VMViewer openWindowlessOn: renderObjects)
				autozoom.
		].
]

{ #category : #'GT Inspector' }
VMPolygonSplitter >> gtInspectorRenderedIn: composite [
	<gtInspectorPresentationOrder: 50>
	
	(composite morph)
		title: 'Viewer (org.)';
		morph: [
			| renderObjects bounds |
			renderObjects := OrderedCollection new.
			bounds := 0@0 extent: 1@1.
			originalPolygon
				ifNotNil: [
					renderObjects add: originalPolygon asRenderableElement.
					bounds := (originalPolygon bounds).
					bounds := bounds expandBy: (bounds width max: bounds height) * 0.3].
			plane
				ifNotNil: [
					renderObjects add: ((plane asVMLineSegment fitIntoRectangle: bounds) asRenderableElement) ].
			
			(VMViewer openWindowlessOn: renderObjects)
				autozoom.
		].
]

{ #category : #'GT Inspector' }
VMPolygonSplitter >> gtInspectorTempPolygonRenderedIn: composite [
	<gtInspectorPresentationOrder: 52>
	
	(composite morph)
		title: 'Viewer (temp polygon)';
		morph: [
			| renderObjects bounds |
			renderObjects := OrderedCollection new.
			bounds := 0@0 extent: 1@1.
			originalPolygon
				ifNotNil: [
					renderObjects add: (originalPolygon asRenderableElement lineWidth: 0.01).
					bounds := (originalPolygon bounds).
					bounds := bounds expandBy: (bounds width max: bounds height) * 0.3].
			plane
				ifNotNil: [
					renderObjects add: ((plane asVMLineSegment fitIntoRectangle: bounds) asRenderableElement lineWidth: 0.02) ].
			tempPolygon do: [ :v | v asRenderableElement color: (Color fromString: '#00AFFF'). ].
"			tempLineSegs left do: [ :v |
				renderObjects add: (v asRenderableElement color: (Color fromString: '#FFB700'); lineWidth: 0.02). ].
			tempLineSegs right do: [ :v |
				renderObjects add: (v asRenderableElement color: (Color fromString: '#9BFF00'); lineWidth: 0.02). ]."
			
			(VMViewer openWindowlessOn: renderObjects)
				autozoom.
		].
]

{ #category : #'private - computing' }
VMPolygonSplitter >> leavingLeftLineSeg: aLineSeg atIndex: index [
	splitPoints add: aLineSeg pointA.
	
	self logCr: 'leaving-left, ', aLineSeg printString.
	
	^self.
	

]

{ #category : #'private - computing' }
VMPolygonSplitter >> leavingRightLineSeg: aLineSeg atIndex: index [
	splitPoints add: aLineSeg pointA.
	
	self logCr: 'leaving-right, ', aLineSeg printString.
	
	^self

]

{ #category : #'public - accessing' }
VMPolygonSplitter >> leftPolygons [
	reversed ifTrue: [ ^polygons right ]
		ifFalse: [ ^polygons left ].

]

{ #category : #'logging-Deprecated' }
VMPolygonSplitter >> logCr: someText [
	"^super logCr: someText"

]

{ #category : #'private - computing' }
VMPolygonSplitter >> onLinePlacement: lineSeg [
	| cw deltaAngle |
	
	cw := originalPolygon isCW.
	deltaAngle := (plane deltaAngle: lineSeg) abs.
	
	((deltaAngle < Float halfPi) xor: [cw])
		ifTrue: [ tempLineSegs left add: lineSeg. ]
		ifFalse: [ tempLineSegs right add: lineSeg. ].
	

]

{ #category : #'private - computing' }
VMPolygonSplitter >> onLinePlacementOld: lineSeg [
	"places the line segment either in tempLeft or tempRight, depending on
	which side is free/traversable space.
	
	we first create a point that is close to the center of the line segment,
	but does not lie on the line segment itself. then we check if this point
	is inside the polygon or not to determine if the line segment should be
	added to the left or the right side of the plane."
	| testPoint |
	
	"create a point that lies 0.000001 units (meters) from the center of the line segment."
	testPoint := lineSeg pointA
			+ (lineSeg direction * 0.5)
			+ (plane normal normalized * 0.000001).
	
	"self logCr: 'onLinePlacement=', ((originalPolygon isPointInside: testPoint) ifTrue: [ 'inside'] ifFalse: [ 'outside' ]), ', ', lineSeg printString."
	
	(originalPolygon isPointInside: testPoint)
		ifTrue: [ tempLineSegs left add: lineSeg. tempOnLine left add: lineSeg. self logCr: 'onLinePlacement: CW, inside (left), ', lineSeg printString ]
		ifFalse: [ tempLineSegs right add: lineSeg. tempOnLine right add: lineSeg. self logCr: 'onLinePlacement: CW, outside (right), ', lineSeg printString ].

]

{ #category : #'private - accessing (for sunit tests)' }
VMPolygonSplitter >> originalPolygon [
	^ originalPolygon
]

{ #category : #'private - accessing (for sunit tests)' }
VMPolygonSplitter >> originalPolygon: aPolygon [
	originalPolygon := aPolygon
]

{ #category : #'public - accessing' }
VMPolygonSplitter >> plane [
	^ plane
]

{ #category : #'private - accessing (for sunit tests)' }
VMPolygonSplitter >> plane: aLine [
	"aLine is a hyperplane, represented by a VMLine (or derived class) instance"
	plane := aLine asVMLine.
	
	sortByX := (plane dX abs > plane dY abs).
	reversed := false.
	
	sortByX ifTrue: [
		(plane pointA x > plane pointB x) ifTrue: [
			plane := plane reversed.
			reversed := true.].
	] ifFalse: [
		(plane pointA y > plane pointB y) ifTrue: [
			plane := plane reversed.
			reversed := true.].
	].

]

{ #category : #'private - computing' }
VMPolygonSplitter >> processLineSegment: aLineSeg index: index [
	plane fuzzyPoint: aLineSeg pointA
		ifOnLeftSideDo: [
			plane fuzzyPoint: aLineSeg pointB
				ifOnLeftSideDo: [ tempLineSegs left add: aLineSeg. self logCr: 'left (1), ', aLineSeg printString ]
				ifOnRightSideDo: [ self splitLeftToRightLineSeg: aLineSeg ]
				ifOnLineDo: [
					tempLineSegs left add: aLineSeg.
					splitPoints add: aLineSeg pointB.
					self logCr: 'left (2), ', aLineSeg printString].
		]
		ifOnRightSideDo: [
			plane fuzzyPoint: aLineSeg pointB
				ifOnLeftSideDo: [ self splitRightToLeftLineSeg: aLineSeg ]
				ifOnRightSideDo: [ tempLineSegs right add: aLineSeg. self logCr: 'right (1), ', aLineSeg printString ]
				ifOnLineDo: [
					tempLineSegs right add: aLineSeg.
					splitPoints add: aLineSeg pointB.
					self logCr: 'right (2), ', aLineSeg printString ].
		]
		ifOnLineDo: [
			plane fuzzyPoint: aLineSeg pointB
				ifOnLeftSideDo: [ tempLineSegs left add: aLineSeg. self leavingLeftLineSeg: aLineSeg atIndex: index. ]
				ifOnRightSideDo: [ tempLineSegs right add: aLineSeg. self leavingRightLineSeg: aLineSeg atIndex: index. ]
				ifOnLineDo: [ self onLinePlacement: aLineSeg ].
		].
	

]

{ #category : #'private - computing' }
VMPolygonSplitter >> processLineSegments [

	originalPolygon doWithIndex: [ :lineSeg :index |
		self processLineSegment: lineSeg index: index.
	].

]

{ #category : #'private - initializing' }
VMPolygonSplitter >> reset [
	
	tempLineSegs := VMLRCollection new.
	polygons := VMLRCollection new.
	tempOnLine := VMLRCollection new.
	borderLineSegs := OrderedCollection new.
	splitPoints := OrderedCollection new.
	

]

{ #category : #'public - accessing' }
VMPolygonSplitter >> rightPolygons [
	reversed ifTrue: [ ^polygons left ]
		ifFalse: [ ^polygons right ].

]

{ #category : #'private - computing' }
VMPolygonSplitter >> sortSplitPoints [
	| sortBlock |
	
	sortBlock := sortByX
		ifTrue: [ [ :a :b | a x < b x] ]
		ifFalse: [ [ :a :b | a y < b y] ].
	
	splitPoints sort: sortBlock.

]

{ #category : #'public - splitting' }
VMPolygonSplitter >> split: aPolygon onPlane: aPlane [
	
	(aPlane pointA = aPlane pointB) ifTrue: [ "1 halt." self error: self class printString, ' - invalid plane (zero length)'. ].
	self originalPolygon: aPolygon.
	self plane: aPlane.
	self reset.
	
	self processLineSegments.
	self sortSplitPoints.
	self createBorderLineSegs.
	self createPolygons.

]

{ #category : #'private - computing' }
VMPolygonSplitter >> splitLeftToRightLineSeg: lineSeg [
	| intersection iPoint leftLineSeg rightLineSeg |
	
	intersection := VMIntersection intersectLine: lineSeg withLine: plane.
	iPoint := intersection intersectionPoint.
	
	leftLineSeg := VMLineSegment pointA: lineSeg pointA pointB: iPoint type: lineSeg type.
	VMLineSegReferences at: leftLineSeg put: lineSeg.
	tempLineSegs left add: leftLineSeg.
	
	rightLineSeg := VMLineSegment pointA: iPoint pointB: lineSeg pointB type: lineSeg type.
	VMLineSegReferences at: rightLineSeg put: lineSeg.
	tempLineSegs right add: rightLineSeg.
	
	self logCr: 'split left -> right, ', leftLineSeg printString, ', ', rightLineSeg printString.
	
	splitPoints add: iPoint.

]

{ #category : #'private - computing' }
VMPolygonSplitter >> splitRightToLeftLineSeg: lineSeg [
	| intersection iPoint leftLineSeg rightLineSeg |
	
	intersection := VMIntersection intersectLine: lineSeg withLine: plane.
	iPoint := intersection intersectionPoint.
	
	rightLineSeg := VMLineSegment pointA: lineSeg pointA pointB: iPoint type: lineSeg type.
	VMLineSegReferences at: rightLineSeg put: lineSeg.
	tempLineSegs right add: rightLineSeg.
	
	leftLineSeg := VMLineSegment pointA: iPoint pointB: lineSeg pointB type: lineSeg type.
	VMLineSegReferences at: leftLineSeg put: lineSeg.
	tempLineSegs left add: leftLineSeg.
	
	self logCr: 'split: right -> left, ', rightLineSeg printString, ', ', leftLineSeg printString.
	
	splitPoints add: iPoint.

]

{ #category : #'private - accessing (for sunit tests)' }
VMPolygonSplitter >> tempLeft [
	^tempLineSegs left
]

{ #category : #'private - accessing (for sunit tests)' }
VMPolygonSplitter >> tempOnLine [
	^tempOnLine
]

{ #category : #'private - accessing (for sunit tests)' }
VMPolygonSplitter >> tempRight [
	^tempLineSegs right
]
