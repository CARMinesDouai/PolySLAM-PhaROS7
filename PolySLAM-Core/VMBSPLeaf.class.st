Class {
	#name : #VMBSPLeaf,
	#superclass : #VMBSPBase,
	#instVars : [
		'sector'
	],
	#category : #'PolySLAM-Core-Nearest Neighbor Search'
}

{ #category : #'instance creation' }
VMBSPLeaf class >> new [
	^(super new)
		parent: nil;
		yourself
]

{ #category : #'instance creation' }
VMBSPLeaf class >> parent: aNode [
	^self new
		parent: aNode;
		yourself.

]

{ #category : #'instance creation' }
VMBSPLeaf class >> parent: aNode sector: aSector [
	"important: do not return 'yourself' here, because #sector: may return a newly created node,
	if the sector cannot be stored in a leaf (i.e. if the sector is not convex)."
	^self new
		parent: aNode;
		sector: aSector.
]

{ #category : #'rendering support' }
VMBSPLeaf class >> rendererClass [
	^VMBSPLeafRenderer
]

{ #category : #adding }
VMBSPLeaf >> addToDB: aSector [
	vectorDB
]

{ #category : #converting }
VMBSPLeaf >> asCollectionOfSectors [
	sector ifNil: [ ^VMPolygonCollection new: 0 ].
	
	^ (VMPolygonCollection new: 1)
		add: sector;
		yourself

]

{ #category : #accessing }
VMBSPLeaf >> bounds [
	"empty leafs return a default rectangle bounds to prevent error messages while rendering in the inspector"
	sector ifNil: [ ^ Rectangle origin: 0@0 corner: 1@1 ].
	^sector bounds
]

{ #category : #private }
VMBSPLeaf >> changeLineSeg: lineSeg type: type inPolygon: polygon [
	"creates a new line segment with the provided type and swaps it in the polygon with the old line segment"
	| newLineSeg |
	newLineSeg := lineSeg clone type: type.
	
	polygon at: (polygon indexOf: lineSeg) put: newLineSeg.

]

{ #category : #'private - create hyperplane' }
VMBSPLeaf >> checkCollinear: aVMLineSegment [
	"returns true if any of the parent elements' hyperplane is collinear with the provided
	line segment, false otherwise"
	| node |
	node := parent.
	[ node isNil] whileFalse: [
		(aVMLineSegment isCollinearWith: node hyperplane) ifTrue: [ ^true ].
		node := node parent.
	].
	^ false
]

{ #category : #private }
VMBSPLeaf >> checkLineTypes: aSectorOrPolygon [
	"this method checks if any line segments of the sector overlap (i.e. are collinear) with
	any line segments from aSectorOrPolygon. those that overlap will share the 'strongest'
	line segment type. the types are ordered as:
	(lowest) frontier < obstacle < sector (highest)
	
	NOTE: this method is very optimistic about the whole 'collinear' check. there are certain
	conditions where the test is inaccurate at best."
	| maxDist |
	
	maxDist := 0.00001.
	"Transcript show: 'checkLineTypes'; cr."
	aSectorOrPolygon do: [ :lineSeg |
		lineSeg type isFrontier ifFalse: [ "frontiers never change the type of other line segments"
			sector do: [ :sectorLineSeg |
				sectorLineSeg type isSector ifFalse: [ "sectors borders always remain sectors borders"
					(((sectorLineSeg distanceToPoint: lineSeg pointA) <= maxDist)
						and: [(sectorLineSeg distanceToPoint: lineSeg pointB) <= maxDist])
							ifTrue: [
								lineSeg type isSector
									ifTrue: [ self changeLineSeg: lineSeg type: lineSeg type inPolygon: aSectorOrPolygon ]
									ifFalse: [
										sectorLineSeg type isFrontier ifTrue: [
											"self changeLineSeg: sectorLineSeg type: lineSeg type inPolygon: aSectorOrPolygon."
											self changeLineSeg: lineSeg type: lineSeg type inPolygon: aSectorOrPolygon.
											sectorLineSeg type: lineSeg type
										].
									].
							].
				].
			].
		].
	].
]

{ #category : #'as yet unclassified' }
VMBSPLeaf >> checkVector: v type: type [
	"v type = type ifFalse: [ Transcript show: 'type differs: ', v type asInteger printString, '/', type asInteger printString; cr. ]."
	
	v type isSector ifTrue: [ ^self ].
	type asLineSegmentType isSector ifTrue: [ v type: type ].
	v type isFrontier ifTrue: [ v type: type ].

]

{ #category : #'as yet unclassified' }
VMBSPLeaf >> checkVectorType: aSector [
	"Transcript show: 'checkVectorType'; cr."
	aSector do: [ :vec |
		(vectorDB findSimilarVectors: vec) do: [ :v |
			v == vec ifFalse: [
				self checkVector: v type: vec type.
				self checkVector: vec type: v type.
			].
		].
	].
]

{ #category : #'private - create hyperplane' }
VMBSPLeaf >> collectConcaveLineSegs: aPolygon cw: cw [
	"creates a collection of indices of vectors that cause the polygon to be non-convex"
	| collection |
	
	collection := OrderedCollection new.
	
	cw
		ifTrue: [
			aPolygon doWithIndex: [ :vec :index |
				vec point: (aPolygon atWrap: index+1) pointB
					ifOnLeftSideDo: [ collection add: index ]
					ifOnRightSideDo: []
					ifOnLineDo: [].
			].
		] ifFalse: [
			aPolygon doWithIndex: [ :vec :index |
				vec point: (aPolygon atWrap: index+1) pointB
					ifOnLeftSideDo: []
					ifOnRightSideDo: [ collection add: index ]
					ifOnLineDo: [].
			].
		].
	
	^ collection
	

]

{ #category : #'private - create hyperplane' }
VMBSPLeaf >> createPlane: aPolygon [
	| collection cw minDelta minDeltaIndex minDeltaStartIndex |
	
	cw := aPolygon isCW.
	collection := self collectConcaveLineSegs: aPolygon cw: cw.
	collection ifEmpty: [
		self error: 'no concave line segment found in polygon'.
	].
	
	minDelta := 180.
	minDeltaIndex := 1.
	minDeltaStartIndex := 1.
	
	collection do: [ :vectorIndex |
		| rightVector |
		rightVector := cw
			ifTrue: [ (aPolygon at: vectorIndex) rotateCW ]
			ifFalse: [ (aPolygon at: vectorIndex) rotateCCW ].
		
		1 to: aPolygon size -1 do: [ :i |
			| v delta |
			v := VMLineSegment from: (aPolygon at: vectorIndex) pointB to: (aPolygon atWrap: vectorIndex + i) pointB type: 3.
			"v := VMLineSegment from: (aPolygon at: vectorIndex) pointA to: (aPolygon atWrap: vectorIndex + i) pointB type: 3."
			((parent isNil) or: [ (v isCollinearWith: parent hyperplane) not ]) ifTrue: [
				delta := rightVector deltaAngle: v.
				"Transcript show: 'vectorIndex=', vectorIndex printString, ', delta=', delta printString; cr."
				minDelta > delta abs ifTrue: [ minDelta := delta. minDeltaIndex := i. minDeltaStartIndex := vectorIndex].
			].
		].
	].
	
	^ VMLine
		pointA: (aPolygon at: minDeltaStartIndex) pointB
		pointB: (aPolygon atWrap: (minDeltaStartIndex + minDeltaIndex)) pointB.

]

{ #category : #'private - create hyperplane' }
VMBSPLeaf >> createPlaneForPolygon: aSectorOrPolygon ifNoneDo: aBlock [
	"returns a new hyperplane, or nil if no hyperplane was found (which should only
	happen if 'aSectorOrPolygon' lies inside the current sector."
	
	^ self createPlaneForPolygon: aSectorOrPolygon polygon: sector ifNoneDo: [
		^ self createPlaneForPolygon: sector polygon: aSectorOrPolygon ifNoneDo: aBlock ]

]

{ #category : #'private - create hyperplane' }
VMBSPLeaf >> createPlaneForPolygon: polygonA polygon: polygonB ifNoneDo: aBlock [
	"returns a new hyperplane, or nil if no hyperplane was found (which should only
	happen if polygonA lies inside polygonB."
	| counter hyperplane cw |
	
	self assert: polygonB isNotNil.
	
	counter := 0.
	hyperplane := nil.
	cw := polygonB isCW.
	
	"try every line segment of polygonB as a hyperplane"
	sector do: [ :plane |
		| localCounter |
		"iterate over all line segments of the new sector and count how many line segment start
		points are on the wrong side (i.e. are not on the same side as polygonB)"
		((parent isNil) or: [(plane isCollinearWith: parent hyperplane) not]) ifTrue: [
			localCounter := 0.
			cw ifTrue: [
				polygonA do: [ :lineSeg |
					plane fuzzyPoint: lineSeg pointA
						ifOnLeftSideDo: [ localCounter := localCounter + 1. ]. ].
			] ifFalse: [
				polygonA do: [ :lineSeg |
					plane fuzzyPoint: lineSeg pointA
						ifOnRightSideDo: [ localCounter := localCounter + 1. ]. ]. ].
			localCounter > counter ifTrue: [
				hyperplane := plane.
				counter := localCounter
			].
		].
	].
	
	hyperplane ifNil: [ "this case happens when polygonA is inside polygonB"
		self ifOnlySectors: polygonA do: [ aBlock value. ^ nil ].
		polygonA do: [ :v |
			(v isObstacle and: [(self checkCollinear: v) not]) ifTrue: [
				^ v ] ].
			"self ifNotTouching: aSectorOrPolygon do: [
			Transcript show: 'skipping polygon=', aSectorOrPolygon printString; cr.
			aBlock value.
			^niln]."
	].
	
	^ hyperplane

]

{ #category : #enumerating }
VMBSPLeaf >> do: aBlock [
	sector ifNil: [ ^self ].
	aBlock value: sector.
]

{ #category : #accessing }
VMBSPLeaf >> findHyperplaneFor: aLineSeg [
	parent ifNil: [ ^ nil ].
	^ parent hyperplane
]

{ #category : #operations }
VMBSPLeaf >> findNearest: aPoint [
	sector ifNil: [ ^nil ].
	
	^ sector findNearestObstacle: aPoint
]

{ #category : #accessing }
VMBSPLeaf >> findSectorByLineSeg: aLineSeg [
	"^sector"
	sector ifNil: [ ^nil ].
	
	sector do: [ :lineSeg |
		(lineSeg isSimilarTo: aLineSeg) ifTrue: [ ^sector ]
	].
	
	^nil.
	

]

{ #category : #accessing }
VMBSPLeaf >> findSectorsByLineSeg: aLineSeg [
	sector ifNil: [ ^{} ].
	^{sector}

]

{ #category : #'inserting polygons' }
VMBSPLeaf >> growAndInsert: aPolygon [
	| newPlane newNode |
	
	newPlane := self createPlane: aPolygon.
	newNode := self class nodeClass parent: parent plane: newPlane level: level maxDepth: maxDepth.
	
	sector ifNotNil: [ newNode insert: sector. ].
	newNode insert: aPolygon.
	
	^newNode.
	
]

{ #category : #'as yet unclassified' }
VMBSPLeaf >> handDownVectors: aPolygon. [
	"all obstacles and sectors are 'inserted' into the sector, so that dominant vector types can
	merge into the sector. for example, a frontier in the sector polygon can overlap with an obstacle
	from 'aPolygon', causing the frontier to turn into an obstacle. partial overlaps result into
	vectors being split into smaller vectors before type merging."
	aPolygon select: [ :v | v isObstacle or: [v isSector]] thenDo: [ :v | self insertVector: v ].

]

{ #category : #testing }
VMBSPLeaf >> ifEmpty: aBlock [
	sector ifNotNil: [ aBlock value. ^false ].
	^true
	
]

{ #category : #private }
VMBSPLeaf >> ifNotTouching: aSectorOrPolygon do: aBlock [
	"check if any of the polygon's corners is close to any of the sectors line segments"
	sector do: [ :sectorLineSeg |
		aSectorOrPolygon do: [ :lineSeg |
			((sectorLineSeg distanceToPoint: lineSeg pointA) < 0.000001) ifTrue: [ ^self ].
		].
	].
	
	aBlock value.

]

{ #category : #private }
VMBSPLeaf >> ifOnlySectors: aSectorOrPolygon do: aBlock [
	aSectorOrPolygon do: [ :v |
		v isObstacle ifTrue: [ ^ self ].
		"v isFrontier ifTrue: [ ^ self ]."
	].
	^ aBlock value
]

{ #category : #initialization }
VMBSPLeaf >> initialize [
	super initialize.
	
	sector := nil.
]

{ #category : #'inserting polygons' }
VMBSPLeaf >> insert: aPolygon [
	| newPlane newNode |
	
	"check if we have reached the maximum depth of the tree."
	(level > self maxDepth) ifTrue: [ ^ self onMaxDepthInsert: aPolygon. ].

	sector ifNil: [ ^ self onEmptyInsert: aPolygon ].
	
	newPlane := self createPlaneForPolygon: aPolygon
		ifNoneDo: [
			self checkLineTypes: aPolygon.
			"self logCr: self class name, ' insert status: skipping'.
			self logCr: '  polygon=', aPolygon printString.
			self logCr: '  sector=', sector printString."
			self checkVectorType: aPolygon.
			^self.
		].
	newPlane ifNil: [
		"this case should only happen if aPolygon lies completly inside sector. they still may share borders, hence the
		call to #handDownVectors:"
		"self handDownVectors: aPolygon."
		"Transcript show: 'BSPLeaf: skipping insert - invalid plane (nil)'; cr.
		{sector asRenderableElement autoColor: false; color: Color orange. aPolygon.} asRenderableElement.
		1 halt."
		^ self].
	
	"Transcript show: 'selected hyperplane=', newPlane printString; cr."
	parent ifNotNil: [
		(newPlane isCollinearWith: parent hyperplane)
			"this is an old error that should no longer occure"
			ifTrue: [self error: 'reusing same plane as parent node'. ^self ].
	].
	
	newNode := self class nodeClass parent: parent plane: newPlane level: level maxDepth: maxDepth.
	sector ifNotNil: [ newNode insert: sector. ].
	newNode insert: aPolygon.
	
	^newNode.

]

{ #category : #'inserting vectors' }
VMBSPLeaf >> insertVector: aVector [
	"this method inserts 'aVector' into the sector. this is used to add obstacles to the current sector when the polygon
	that should be inserted into this leaf does not contribute anything shape-wise, but still contributes in terms of
	line types (e.g. obstacles that currently might be frontiers or sectors."
	| chains startNormal endNormal intersectionA intersectionB tempPointA tempPointB |
	
	sector ifNil: [ ^ self ].
	startNormal := aVector pointA vectorTo: (aVector pointA + aVector normal).
	endNormal := aVector pointB vectorTo: (aVector pointB + aVector normal).
	
	chains := VMVectorChainCollection
		fromTypelessVectorCollection: (sector select: [ :v |
			(v isCollinearWith: aVector) and: [(v direction normalized + aVector direction normalized) length > 1.0] ]).
	chains do: [ :chain |
		chain do: [ :v |
			intersectionA := VMIntersection intersectLine: v withLine: startNormal.
			intersectionB := VMIntersection intersectLine: v withLine: endNormal.
			tempPointA := v pointA + (v direction * intersectionA factorT).
			tempPointB := v pointA + (v direction * intersectionB factorT).
			
			intersectionA factorT <= 0.0001
				ifTrue: [ "start point of v lies within aVector"
					intersectionB factorT >= 0.9999
						ifTrue: [ "v lies completely in 'aVector'"
							sector replaceVector: v with: (v copy type: (aVector type useDominantType: v type); yourself). ]
						ifFalse: [ "v starts inside of 'aVector', but the end sticks out"
							sector replaceVector: v withCollection: {
								v pointA vectorTo: tempPointB type: (aVector type useDominantType: v type).
								tempPointB vectorTo: v pointB type: v type.
								}. ]. ]
				ifFalse: [ "start point of v is outside of aVector"
					intersectionA factorT < 0.9999 ifTrue: [ "v and aVector do intersect"
						intersectionB factorT >= 0.9999
							ifTrue: [ "endPoint of v lies inside of aVector"
								sector replaceVector: v withCollection: {
									v pointA vectorTo: tempPointA type: v type.
									tempPointA vectorTo: v pointB type: (aVector type useDominantType: v type). }. ]
							ifFalse: [ "aVector lies inside of v"
								sector replaceVector: v withCollection: {
									v pointA vectorTo: tempPointA type: v type.
									tempPointA vectorTo: tempPointB type: (aVector type useDominantType: v type).
									tempPointB vectorTo: v pointB type: v type }. ]. ]. ]. ]. ].


]

{ #category : #testing }
VMBSPLeaf >> isLeaf [
	^true
]

{ #category : #'inserting polygons' }
VMBSPLeaf >> onEmptyInsert: aPolygon [
	"called when the leaf is empty"
	
	aPolygon
		ifConvex: [ :ignored |
			self sector: aPolygon.
			^ self
		] otherwise: [ :ignored :lineSeg |
			^ self growAndInsert: aPolygon
		].

]

{ #category : #'inserting polygons' }
VMBSPLeaf >> onMaxDepthInsert: aPolygon [
	"called when we have reached the maximum depth. we still allow to insert, but we
	no longer grow. consequently, if the leaf already contains a polygon, we ignore
	any further attempts to insert another polygon"
	
	sector ifNotNil: [
		Transcript
			show: 'skipping (level='; show: level printString; show: '):'; cr;
			show: '  polygon='; show: aPolygon printString; cr.
		^ self ].

	"note that we don't check if the polygon is convex and just insert it"
	self sector: aPolygon.

]

{ #category : #accessing }
VMBSPLeaf >> polygonAt: aPoint [
	1 halt.
	sector ifNil: [ ^ nil ].
	(sector isPointInside: aPoint) ifTrue: [ ^ sector ] ifFalse: [ ^ nil ].
]

{ #category : #accessing }
VMBSPLeaf >> sector [
	^sector
]

{ #category : #accessing }
VMBSPLeaf >> sector: aSector [
	sector := aSector.
	self checkVectorType: sector.
	vectorDB addAll: aSector.

]

{ #category : #accessing }
VMBSPLeaf >> sectorCount [
	sector ifNil: [ ^0 ].
	^1
]

{ #category : #'as yet unclassified' }
VMBSPLeaf >> sectorNeighbors [
	| root neighbors  |
	
	root := self root.
	neighbors := sector select: [ :lineSeg | lineSeg type isSector ] thenCollect: [ :lineSeg |
		root findSectorByLineSeg: lineSeg reversed		
	].
	Transcript show: 'sectorNeighbors size=', neighbors size printString; cr.
	
	^ neighbors

]

{ #category : #'as yet unclassified' }
VMBSPLeaf >> sectorNeighbors2 [
	| root neighbors temp |
	
	root := self root.
	temp := sector select: [ :lineSeg | lineSeg type isSector ] thenCollect: [ :lineSeg |
		root findSectorsByLineSeg: lineSeg reversed		
	].
	neighbors := OrderedCollection new.
	temp do: [ :collection |
		neighbors addAll: collection
	].
	Transcript show: 'sectorNeighbors size=', neighbors size printString; cr.
	
	^ neighbors

]

{ #category : #testing }
VMBSPLeaf >> size [
	sector ifNil: [ ^ 0 ].
	^ 1
]
