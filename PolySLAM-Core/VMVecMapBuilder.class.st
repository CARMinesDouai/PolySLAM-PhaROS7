"
The first attempt to build a PolyMap from a grid map. This class is too slow on medium-sized maps and might contain bugs. Use VMVecMapBuilder2 or VMVecMapComposer instead.
"
Class {
	#name : #VMVecMapBuilder,
	#superclass : #Object,
	#instVars : [
		'img',
		'polygons',
		'area'
	],
	#category : #'PolySLAM-Core-SLAM - Maps'
}

{ #category : #accessing }
VMVecMapBuilder >> area [
	^area
]

{ #category : #accessing }
VMVecMapBuilder >> area: aRectangle [
	area := aRectangle.
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder >> cleanupPolygon2: aPolygon [
	"first attempt - works, but too slow for normal-sized maps"
	aPolygon do: [ :lineSeg |
		| rev |
		rev := lineSeg reversed.
		(aPolygon includes: rev) ifTrue: [
			aPolygon remove: lineSeg.
			aPolygon remove: rev.
			^self cleanupPolygon2: aPolygon.
		]
	].
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder >> cleanupPolygon3: aPolygon [
	"second attempt - bugs out for no apparant reason. also not that much faster."
	| set |
	
	set := aPolygon asSet.
	
	set := self cleanupSet: set.
	
	^(VMPolygon new)
		addAll: set;
		yourself.
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder >> cleanupPolygon: aPolygon [
	"third attempt"
	| dict newPolygon |
	
	dict := Dictionary new.
	aPolygon do: [ :lineSeg |
		dict at: lineSeg put: true.
	].
	
	dict keysAndValuesDo: [ :lineSeg :valid |
		| rev |
		valid ifTrue: [
			rev := lineSeg reversed.
			dict at: rev ifPresent: [
				dict at: lineSeg put: false.
				dict at: rev put: false.
			]
			ifAbsent: [
				(aPolygon includes: rev) ifTrue: [
					Transcript show: '!! ', lineSeg printString, ' ', rev printString; cr.
				]
			].
		].
	].
	
	newPolygon := VMPolygon new.
	dict keysAndValuesDo: [ :lineSeg :valid |
		valid ifTrue:[ newPolygon add: lineSeg ].
	].
	
	^newPolygon

]

{ #category : #'as yet unclassified' }
VMVecMapBuilder >> cleanupSet: set [
	"checks if there are two line segments that are overlapping"
	
	set do: [ :lineSeg |
		| rev |
		rev := lineSeg reversed.
		(set includes: rev) ifTrue: [
			set remove: lineSeg.
			set remove: rev.
			^self cleanupSet: set.
		]
	].
	
	^set
]

{ #category : #'computation steps' }
VMVecMapBuilder >> createSquares [
	"polygons := Set new."
	polygons := OrderedCollection new.
	
	(1 max: area top) to: ((img height - 1) min: area bottom) do: [ :y |
		(1 max: area left) to: ((img width - 1) min: area right) do: [ :x |
			| color |
			color :=  img colorAt: (x @ y).
			(color brightness >= 0.95) ifTrue: [
				polygons add: ((VMPolygon new)
					fromPoints: { x @ y.  x+1 @ y.  x+1 @ (y+1).  x @ (y+1) }
					withTypes: {
						self typeByColor: (img colorAt: x @ (y-1)).
						self typeByColor: (img colorAt: x+1 @ y).
						self typeByColor: (img colorAt: x @ (y+1)).
						self typeByColor: (img colorAt: x-1 @ y).
						})
			].
		].
	].
	"Transcript show: 'createSquares p size=', polygons size printString; cr."


]

{ #category : #'as yet unclassified' }
VMVecMapBuilder >> extractInnerPolygon: aPolygon [
	| collection newPolygon copy |
	
	copy := aPolygon copy.
	collection := OrderedCollection new.
	
	"take a line segment from 'aPolygon copy', build a new polygon by finding connected line segments, and remove all involved line segments from 'copy'."
	[copy isEmpty] whileFalse: [
		| lineSeg |
		
		newPolygon := VMPolygon new.
		lineSeg := copy anyOne.
		copy remove: lineSeg.
		newPolygon add: lineSeg.
		
		"add/remove line segments until the end point matches the starting point"
		[lineSeg pointB = newPolygon first pointA] whileFalse: [
			lineSeg := copy nextLineSeg: lineSeg.
			newPolygon add: lineSeg.
			copy remove: lineSeg.
		].
	
		collection add: newPolygon.
	].
	
	^collection
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder >> findPolygonWithBorder: aLineSeg inCollection: aCollection do: aBlock [
	aCollection do: [ :polygon |
		polygon do: [ :pLineSeg |
			pLineSeg = aLineSeg ifTrue: [ ^aBlock value: polygon. ].
		].
	].
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder >> findStartPosition [
	"returns coordinates to a pixel that is white (i.e. traversable space)"
	1 to: img height do: [ :y |
		1 to: img width do: [ :x |
			| color |
			color :=  img colorAt: (x @ y).
			color = Color white ifTrue: [ ^ x @ y ].
		].
	].

	^ 0 @ 0
]

{ #category : #accessing }
VMVecMapBuilder >> img: aForm [
	img := aForm
]

{ #category : #initialization }
VMVecMapBuilder >> initialize [
	img := nil.
	area := nil.
	
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder >> loadFromFile: filename [
	img := (ImageReadWriter formFromFileNamed: filename) flipHorizontally asGrayScale.
	area := Rectangle point: 1 @ 1 point: img width @ img height.
]

{ #category : #'computation steps' }
VMVecMapBuilder >> makeConsistent [
	"makes sure that polygons dont contain polygons inside. if a polygon consists of multiple simple polygons. they are seperated into multiple polygons"
	| newCollection |
	
	newCollection := OrderedCollection new.
	
	polygons do: [ :aPolygon |
		newCollection addAll: (self extractInnerPolygon: aPolygon).
	].
	
	polygons := newCollection.

	"Transcript show: 'makeConsistent p size=', polygons size printString; cr."

]

{ #category : #'as yet unclassified' }
VMVecMapBuilder >> mapReduce [
	| squareSize left right top bottom results mapBuilder |
	
	squareSize := 32.
	results := OrderedCollection new.
	mapBuilder := self class new.
	
	left := area left.
	right := 0.
	top := area top.
	bottom := 0.
	
	[
		bottom := top + squareSize min: area bottom.
		left := area left.
		[
			right := left + squareSize min: area right.
			
			"Transcript show: 'rect=', (Rectangle point: left @ top point: right @ bottom) printString; cr."
			
			mapBuilder img: img.
			mapBuilder area: (Rectangle point: left @ top point: right @ bottom).
			mapBuilder createSquares.
			mapBuilder mergeSquares.
			mapBuilder makeConsistent.
			mapBuilder simplifyPolygons.
			results addAll: mapBuilder polygons.
			
			left := right + 1.
			
		] doWhileTrue: [ right < area right ].
		
		top := bottom + 1.
	
	] doWhileTrue: [ bottom < area bottom ].
	
	polygons := (OrderedCollection new)
		addAll: results;
		yourself.
	
	self mergeSquares.
	self workaround.
	"self makeConsistent."
	"self simplifyPolygons."
	

]

{ #category : #'as yet unclassified' }
VMVecMapBuilder >> mergePolygon: originalPolygon with: borderPolygon atLineSeg: aLineSeg [
	"returns a new polygon that has been merged from both polygons. if polygons don't share a border, a copy of the original polygon is returned"
	| newPolygon inverseLineSeg |
	
	newPolygon := VMPolygon new.
	inverseLineSeg := aLineSeg reversed.
	
	originalPolygon do: [ :ls |
		"add all line segments from originalPolygon except the overlapping one"
		ls = aLineSeg
			ifTrue: [
				"insert line segments from borderPolygon at the position where the overlapping line segment was"
				1 to: borderPolygon size do: [ :index |
					"find the index of the overlapping line segment in borderPolygon"
					(borderPolygon at: index) = inverseLineSeg ifTrue: [
						"add all line segments from borderPolygon to newPolygon except the overlapping one"
						1 to: borderPolygon size -1 do: [ :index2 |
							newPolygon add: (borderPolygon atWrap: index + index2).
						].
					].
				]
			]
			ifFalse: [ newPolygon add: ls ].
	].
	
	^newPolygon

]

{ #category : #'computation steps' }
VMVecMapBuilder >> mergeSquares [
	| newCollection |
	newCollection := OrderedCollection new.
	[polygons notEmpty] whileTrue: [
		| p index |
		p := polygons remove: polygons anyOne.
		index := 1.
		[index <= p size] whileTrue: [ 
			| lineSeg |
			lineSeg := p at: index.
			self findPolygonWithBorder: lineSeg reversed inCollection: polygons do: [ :borderPolygon |
				p := self mergePolygon: p with: borderPolygon atLineSeg: lineSeg.
				polygons remove: borderPolygon.
				index := index - 1.
			].
			index := index + 1.
		].
		p := self cleanupPolygon: p.
		newCollection add: p.
	].
	polygons := newCollection.
	
	"Transcript show: 'mergeSquares p size=', polygons size printString; cr."
	

]

{ #category : #testing }
VMVecMapBuilder >> polygonIsIsolated: aPolygon [
	"a polygon is considered isolated if all line segments are frontiers"
	^ aPolygon allSatisfy: [ :lineSeg | lineSeg type isFrontier ]
]

{ #category : #accessing }
VMVecMapBuilder >> polygons [
	^polygons
]

{ #category : #accessing }
VMVecMapBuilder >> polygons: aCollection [
	polygons := aCollection
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder >> printStatistics [
	| polygonCount lineSegCount |
	
	polygonCount := polygons size.
	lineSegCount := 0.
	
	polygons do: [ :p | lineSegCount := lineSegCount + p size ].
	
	Transcript show: 'Map Statistics:'; cr.
	Transcript show: '  polygon count=', polygonCount printString; cr.
	Transcript show: '  vector count=', lineSegCount printString; cr.

]

{ #category : #accessing }
VMVecMapBuilder >> removeIsolated [
	polygons := polygons reject: [ :p | self polygonIsIsolated: p ]
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder >> simplifyPolygon2: aPolygon [
	"merges consecetive line segments of the same type and orientation into a single longer line segment. returns a new polygon"
	| newPolygon index offset |
	
	newPolygon := VMPolygon new.
	index := 1.
	
	[index <= aPolygon size] whileTrue: [
		"find index of line segment that has a different orientation"
		offset := 1.
		[((aPolygon at: index) direction = (aPolygon atWrap: index + offset) direction) and: [(aPolygon at: index) type = (aPolygon atWrap: index + offset) type]] whileTrue: [
				offset := offset + 1.
		].
		newPolygon add: (VMLineSegment
				pointA: (aPolygon at: index) pointA 
				pointB: (aPolygon atWrap: index + offset - 1) pointB
				type: (aPolygon at: index) type).
		
		index := index + offset.
	].

	^newPolygon

]

{ #category : #'as yet unclassified' }
VMVecMapBuilder >> simplifyPolygon: aPolygon [
	"merges consecetive line segments of the same type and orientation into a single longer line segment.
	The line segments are expected to be in order!
	
	returns a new polygon, the original is not modified."
	| newPolygon startIndex index offset |
	
	newPolygon := VMPolygon new.
	startIndex := 1.
	
	"find index at which the direction changes from its previous line segment"
	[(aPolygon atWrap: startIndex - 1) direction normalized = (aPolygon atWrap: startIndex) direction normalized]
		whileTrue: [
			startIndex := startIndex + 1.
			(startIndex >= aPolygon size) ifTrue: [ self error: 'degenerated polygon: all line segments have the same direction (polygon size=', aPolygon size printString, ')' ].
		].
	
	index := startIndex.
	[index <= (startIndex + aPolygon size)] whileTrue: [
		"find index of line segment that has a different orientation"
		offset := 1.
		[((aPolygon atWrap: index) direction = (aPolygon atWrap: index + offset) direction) and: [(aPolygon atWrap: index) type = (aPolygon atWrap: index + offset) type]] whileTrue: [
				offset := offset + 1.
		].
		newPolygon add: (VMLineSegment
				pointA: (aPolygon atWrap: index) pointA 
				pointB: (aPolygon atWrap: index + offset - 1) pointB
				type: (aPolygon atWrap: index) type).
		
		index := index + offset.
	].

	^newPolygon

]

{ #category : #'computation steps' }
VMVecMapBuilder >> simplifyPolygons [
	polygons := polygons collect: [ :p | self simplifyPolygon: p ].
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder >> typeByColor: color [
	"Transcript show: color printString, ' '; cr."
	
	color brightness >= 0.95 ifTrue: [ ^3 ]. "sector, since neighbor is free space"
	color brightness <= 0.05 ifTrue: [ ^1 ]. "border, since neighbor is obstacle"
	^ 2 "frontier, since neighbor is unexplored space"

]

{ #category : #'as yet unclassified' }
VMVecMapBuilder >> workaround [
	| newCollection |
	
	newCollection := OrderedCollection new.
	
	polygons do: [ :p |
		newCollection add: ((VMPolygon new) addAll: (p reject: [ :lineSeg | lineSeg type isSector ]); yourself).
	].

	polygons := newCollection.
]
