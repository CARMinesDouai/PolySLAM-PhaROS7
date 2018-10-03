Class {
	#name : #VMVecMapBuilder3,
	#superclass : #Object,
	#instVars : [
		'img',
		'polygons',
		'obstacleThreshold',
		'freeThreshold',
		'dict'
	],
	#category : #'PolySLAM-Core-temp'
}

{ #category : #'as yet unclassified' }
VMVecMapBuilder3 >> addBorderToImg [
	| newForm |
	
	newForm := Form extent: (img width + 2) @ (img height + 2) depth: 8.
	newForm fill: (0@0 extent: (newForm width) @ (newForm height)) rule: 3 fillColor: Color veryLightGray.
	newForm copy: (1@1 extent: (img width @ img height)) from: 0@0 in: img rule: 3.
	
	img := newForm

]

{ #category : #'as yet unclassified' }
VMVecMapBuilder3 >> createPolygons [
	| count |
	count := 0.
	
	[ dict isEmpty ] whileFalse: [
		| start vec polygon |
		
		polygon := VMPolygon new.
		start := dict anyOne last.
		self removeFromDictVec: start.
		polygon add: start.
		
		vec := start.
		
		[ vec pointB = start pointA ] whileFalse: [
			vec := self nextVector: vec.
			self removeFromDictVec: vec.
			polygon add: vec.
		].
		
		count := count + 1.
		polygons add: polygon.
	].
	
	Transcript show: 'polygon count=', count printString; cr.

]

{ #category : #'as yet unclassified' }
VMVecMapBuilder3 >> createVectors [
	| count |
	dict := Dictionary new.
	count := 0.
	
	1 to: img height - 2 do: [ :y |
		1 to: img width -2 do: [ :x |
			(img colorAt: x @ y) brightness >= freeThreshold ifTrue: [
				(self createVectorsForPoint: x @ y)
					reject: [ :vec | vec type isSector ]
					thenDo: [ :vec |
						count := count + 1.
						dict at: vec pointA
							ifPresent: [ :collection | collection add: vec ]
							ifAbsent: [ dict at: vec pointA put: ((OrderedCollection new) add: vec; yourself) ].
						"Transcript show: (dict at: vec pointA) size printString, ' '."
					].
			].
		].
	].
	
	Transcript show: 'vector count=', count printString; cr.

]

{ #category : #'as yet unclassified' }
VMVecMapBuilder3 >> createVectorsForPoint: aPoint [
	"creates the line segments that encompase the pixel at the provided coordinates"
	^{
		VMLineSegment pointA: aPoint         pointB: aPoint + (1@0) type: (self typeOfPoint: aPoint + (0 @ -1)).
		VMLineSegment pointA: aPoint + (1@0) pointB: aPoint + (1@1) type: (self typeOfPoint: aPoint + (1 @ 0)).
		VMLineSegment pointA: aPoint + (1@1) pointB: aPoint + (0@1) type: (self typeOfPoint: aPoint + (0 @ 1)).
		VMLineSegment pointA: aPoint + (0@1) pointB: aPoint         type: (self typeOfPoint: aPoint + (-1 @ 0))
	}.
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder3 >> img [
	^img
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder3 >> img: aForm [
	img := aForm
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder3 >> initialize [
	polygons := VMPolygonCollection new.
	obstacleThreshold := 0.40.	"maximum brightness to consider a pixel an obstacle"
	freeThreshold := 0.95.		"minimum brightness to consider a pixel free space"
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder3 >> loadFromFile: filename [
	| newForm |
	img := (ImageReadWriter formFromFileNamed: filename) flipHorizontally asGrayScale.
	
	newForm := Form extent: (img width + 2) @ (img height + 2) depth: 8.
	newForm fill: (0@0 extent: (newForm width) @ (newForm height)) rule: 3 fillColor: Color veryLightGray.
	newForm copy: (1@1 extent: (img width @ img height)) from: 0@0 in: img rule: 3.
	
	img := newForm

]

{ #category : #'as yet unclassified' }
VMVecMapBuilder3 >> nextVector: aVector [
	dict at: aVector pointB
		ifPresent: [ :collection | ^collection last ]
		ifAbsent: [ self error: 'unable to find next vector for point=', aVector pointA printString; cr ].
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder3 >> polygons [
	^polygons
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder3 >> removeFromDictVec: aVector [
	dict at: aVector pointA
		ifPresent: [ :collection |
			collection size > 1 ifTrue: [ ^ collection remove: aVector ].
			dict removeKey: aVector pointA.
			^collection first.
		]
		ifAbsent: [ self error: 'unable to find vector for point=', aVector pointA printString ].
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder3 >> simplifyPolygon: aPolygon [
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
	[index <= (startIndex + aPolygon size - 1)] whileTrue: [
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

{ #category : #'as yet unclassified' }
VMVecMapBuilder3 >> simplifyPolygons [
	polygons := (polygons collect: [ :p | self simplifyPolygon: p ]) asVMPolygonCollection.
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder3 >> typeOfPoint: aPoint [
	"returns the type of the border for a pixel at 'aPoint' as an integer"
	| color |
	color := img colorAt: aPoint.
	(color brightness >= freeThreshold) ifTrue: [ ^3 ]. "free space, hence a sector border"
	(color brightness <= obstacleThreshold) ifTrue: [ ^1 ]. "occupied space, hence an obstacle border"
	^2 "unexplored space, hence a frontier"
]
