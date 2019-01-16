Class {
	#name : #VMGridStorage,
	#superclass : #Object,
	#instVars : [
		'columns',
		'gridSize',
		'cellClass'
	],
	#category : #'PolySLAM-Core-Nearest Neighbor Search'
}

{ #category : #'as yet unclassified' }
VMGridStorage class >> gridSize: gridSize [
	^self new
		gridSize: gridSize;
		yourself
]

{ #category : #'as yet unclassified' }
VMGridStorage class >> gridSize: gridSize cellClass: cellClass [
	^ self new
		gridSize: gridSize;
		cellClass: cellClass;
		yourself
]

{ #category : #adding }
VMGridStorage >> add: aPolygon [
	| collection |
	"note: returns self, not aPolygon"
	collection := self splitVerticalPolygon: aPolygon.
	collection do: [ :p |
		| center x y |
		center := p bounds center.
		x := (center x // gridSize).
		y := (center y // gridSize).
		self at: x at: y add: p.
	].

]

{ #category : #accessing }
VMGridStorage >> at: xCoord at: yCoord [
	| xIndex yIndex |
	
	xIndex := xCoord "\\ gridSize".
	yIndex := yCoord "\\ gridSize".
	
	^ (columns at: xIndex ifAbsent: [ ^ nil ])
		at: yIndex ifAbsent: [ ^ nil ]
	
]

{ #category : #accessing }
VMGridStorage >> at: xCoord at: yCoord add: anObj [
	| xIndex yIndex |
	
	xIndex := xCoord "\\ gridSize".
	yIndex := yCoord "\\ gridSize".
	
	((columns at: xIndex)
		at: yIndex)
			add: anObj.
	
]

{ #category : #accessing }
VMGridStorage >> at: xCoord at: yCoord addAll: aCollection [
	| xIndex yIndex |
	
	"xIndex := xCoord \\ gridSize.
	yIndex := yCoord \\ gridSize."
	xIndex := xCoord.
	yIndex := yCoord.
	
	((columns at: xIndex)
		at: yIndex)
			addAll: aCollection.
	
]

{ #category : #accessing }
VMGridStorage >> bounds [
	"returns the boundary of this structure. cells don't need to be occupied to count towards the boundary, even an
	empty collection is enough. if this structure is completly empty, an 1x1 cell is returned as boundary."
	| left right top bottom |
	
	left := columns offset negated.
	right := left + columns size.
	top = 0.
	bottom := 0.
	
	columns do: [
		| temp |
		temp := columns offset negated.
		bottom := bottom min: temp.
		top := top max: (temp + columns size).
	].

	left = right ifTrue: [ left := left - 1 ].
	top = bottom ifTrue: [ bottom := bottom - 1 ].
	
	^ Rectangle
		point: (top * gridSize) @ (left * gridSize)
		point: (bottom * gridSize) @ (right * gridSize)

	
]

{ #category : #accessing }
VMGridStorage >> cellClass [
	^ cellClass
]

{ #category : #accessing }
VMGridStorage >> cellClass: aClass [
	cellClass := aClass.
]

{ #category : #'private - accessing' }
VMGridStorage >> columns [
	^ columns
]

{ #category : #enumerating }
VMGridStorage >> do: aBlock [
	columns do: [ :row |
		row ifNotNil: [
			row do: [ :cell |
				cell ifNotNil: [ aBlock cull: cell ]. ]. ]. ].
]

{ #category : #enumerating }
VMGridStorage >> doWithIndex: aBlock [
	"iterates over all cells, executes aBlock with cell instance, x & y indices.
	cells may be empty, but they will not be nil (thouse are skipped instead)"
	columns doWithIndex: [ :row :xIndex |
		"Transcript show: 'xIndex=', xIndex printString; cr."
		row ifNotNil: [
			row doWithIndex: [ :cell :yIndex|
			"Transcript show: '  yIndex=', yIndex printString; cr."
				cell ifNotNil: [
					aBlock cull: cell cull: xIndex cull: yIndex ]. ]. ]. ].
]

{ #category : #accessing }
VMGridStorage >> gridSize [
	^ gridSize
]

{ #category : #'private - accessing' }
VMGridStorage >> gridSize: aNumber [
	"marked private, because the grid size should no be changed after instance creation"
	gridSize := aNumber
]

{ #category : #initialization }
VMGridStorage >> initialize [
	super initialize.
	gridSize := 2.5.
	
	columns := VMDoubleEndedCollection
		newWithEntryBlock: [ VMDoubleEndedCollection newWithEntryBlock: [cellClass new] ].
	cellClass := OrderedCollection.
]

{ #category : #adding }
VMGridStorage >> insert: aPolygon [
	self add: aPolygon
]

{ #category : #accessing }
VMGridStorage >> polygonAt: aPoint [
	| cell |
	cell := self at: (aPoint x / gridSize) floor at: (aPoint y / gridSize) floor.
	cell ifNil: [ Transcript show: 'cell is nill'; cr. ^ nil ].
	
	^ cell polygonAt: aPoint
	
]

{ #category : #printing }
VMGridStorage >> printStats [
	| cellCount polygonCount vectorCount |
	
	cellCount := 0.
	polygonCount := 0.
	vectorCount := 0.
	
	self doWithIndex: [ :cell :x :y |
		cell isEmpty ifFalse: [
			| polygonCollection |
			cellCount := cellCount + 1.
			polygonCollection := cell asVMPolygonCollection.
			polygonCount := polygonCount + polygonCollection size.
			polygonCollection do: [ :polygon |
				vectorCount := vectorCount + polygon size. ]. ].	].
	
	Transcript show: self class name;
		show: ' stats:'; cr;
		show: '  cellCount='; show: cellCount printString; cr;
		show: '  polygonCount='; show: polygonCount printString; cr;
		show: '  vectorCount='; show: vectorCount printString; cr.

]

{ #category : #'as yet unclassified' }
VMGridStorage >> simplify [
	self doWithIndex: [ :cell :x :y |
		Transcript show: self class name;
			show: ' simplify x=';
			show: x printString;
			show: ' y=';
			show: y printString;
			cr.
			
		cell simplify. ].
]

{ #category : #splitting }
VMGridStorage >> splitHorizontalPolygonCollection: aCollection xIndex: xIndex [
	"splits a collection of polygons (received from #splitVerticalPolygon:) into polygons that align with the grid.
	the polygons are expected to be already split to fit into the vertical grid and are now split to fit into the
	horizontal grid as well.
	returns a collection of all final polygons"
	| bounds splitter top bottom result |
	
	splitter := VMPolygonSplitter new.
	result := VMPolygonCollection new.
	
	aCollection do: [ :aPolygon |
		| currentCollection remainderCollection |
		bounds := aPolygon bounds.
		top := bounds top // gridSize.
		bottom := bounds bottom // gridSize.
		remainderCollection := { aPolygon }.
		
		top to: bottom do: [ :yIndex |
			currentCollection := remainderCollection.
			remainderCollection := OrderedCollection new.
			currentCollection do: [ :currentPolygon |
				splitter split: currentPolygon onPlane: (-1 @ ((yIndex+1)*gridSize) lineTo: 1 @ ((yIndex+1) * gridSize)).
				result addAll: splitter rightPolygons.

				self at: xIndex at: yIndex addAll: splitter rightPolygons.
				remainderCollection addAll: splitter leftPolygons.
			].
		].
	].
	
	^ result

]

{ #category : #splitting }
VMGridStorage >> splitPolygon: aPolygon [
	| bounds splitter |
	bounds := aPolygon bounds.
	"VMPolygonSplitter split: aPolygon onPlane: aPlane"
]

{ #category : #splitting }
VMGridStorage >> splitVerticalPolygon: aPolygon [
	"splits a single polygon into multiple polygons so that each new polygon fits into the grid.
	polygons that fit into the grid without splitting are kept as they are."
	| bounds splitter left right result currentCollection remainderCollection |
	
	bounds := aPolygon bounds.
	result := VMPolygonCollection new.
	splitter := VMPolygonSplitter new.
	left := bounds left // gridSize.
	right := bounds right // gridSize.
	currentCollection := { aPolygon }.
	remainderCollection := OrderedCollection new.
	
	left to: right do: [ :xIndex |
		currentCollection do: [ :currentPolygon |
			Transcript show: 'splitting at x='; show: xIndex printString; show: '+1'; cr.
			splitter split: currentPolygon onPlane: ((xIndex+1)*gridSize @ -1 lineTo: (xIndex+1)*gridSize @ 1).
			result addAll: (self splitHorizontalPolygonCollection: splitter leftPolygons xIndex: xIndex).
			remainderCollection addAll: splitter rightPolygons.
		].
		currentCollection := remainderCollection.
		remainderCollection := OrderedCollection new.
	].
	
	^ result

]
