"
This class  creates a PolyMap from a grid map (e.g. a PNG image).


Public API and Key Messages

- loadFromFile: <filename>
	loads the grid map from an image, e.g. a GIF or PNG file. the image will be converted into a grayscale image upon loading.
- createPolygons
	creates polygons based on the image stored in 'img'. polygons are not cleaned up yet.
- makeConsistent
	any polygons that are actually multiple polygons inside a single VMPolygon instance are seperated
	into each polygon. this method also ensures that all vectors inside the polygons are in order, i.e. the
	end point of a vector is the starting point of the next vector.
- simplifyPolygons
	reduces the number of vectors in a polygon by merging neighboring vectors that have the same
	orientation and type
- polygons
	answeres with an ordered collection of the polygons that have been created

Example code:

	map := (VMVecMapBuilder2 new)
			loadFromFile: '/opt/shared/developer/data/grid_maps/toy_example_5.png'.
			createPolygons;
			makeConsistent;
			simplifyPolygons.

	r := VMPolygonCollectionRenderer model: map polygons.
	r inspect.

 
Instance Variables
	dict:	 <Dictionary>
		a dictionary that assignes vectors (keys) to polygons (values). used to quickly find overlapping vectors
	freeThreshold: <Float>
		brightness threshold for grid cells that are considered free space. default value is 0.95 (very light gray)
	img:		<Form>
		a Form instance (bitmap image)
	obstacleThreshold: <Float>
		brightness threshold for grid cells that are considered obstacles. default value is 0.4 (dark gray)
	polygons: <OrderedCollection>
		OrderedCollection of VMPolygon instances. contains the polygons that we are working on, including the final result



"
Class {
	#name : #VMVecMapBuilder2,
	#superclass : #Object,
	#instVars : [
		'img',
		'polygons',
		'obstacleThreshold',
		'freeThreshold',
		'dict'
	],
	#category : #'PolySLAM-Core-SLAM - Maps'
}

{ #category : #'adding and merging' }
VMVecMapBuilder2 >> addVectorCollection: vecCollection [
	"checks if any of the vectors in vecCollection are already part of a polygon.
	if no, create a new polygon and add it to 'polygons'.
	if yes, check if it touches more than one polygon.
	    if no, add vectors to existing polygon, remove overlapping pair of vectors.
	    if yes, merge polygons, remove overlapping pairs of vectors."
	| touchingPolygonsSet vecsToBeRemoved newPolygon |
	
	vecsToBeRemoved := OrderedCollection new.
	
	"collect all touching polygons and mark all overlapping vectors"
	touchingPolygonsSet := self collectTouchingPolygons: vecCollection touchingVectors: vecsToBeRemoved.
	
	"merge any polygons that are now connected via the new vectors. update the dictionary as necessary"
	touchingPolygonsSet ifNotEmpty: [
		^self mergeWithPolygonSet: touchingPolygonsSet newVectors: vecCollection touchingVectors: vecsToBeRemoved
	].
	
	"create a new polygon and register the vectors in the dictionary"
	newPolygon := VMPolygon new.
	newPolygon addAll: vecCollection.
	newPolygon do: [ :each | dict at: each put: newPolygon ].
	polygons add: newPolygon.

]

{ #category : #'as yet unclassified' }
VMVecMapBuilder2 >> checkForDuplicates [
	polygons do: [ :p |
		p containsDuplicates ifTrue: [ 1 halt. ].
	].
]

{ #category : #'adding and merging' }
VMVecMapBuilder2 >> collectTouchingPolygons: vecCollection touchingVectors: vecsToBeRemoved [
	| touchingPolygonsSet |
	touchingPolygonsSet := Set new.
	
	vecCollection do: [ :vector |
		dict at: vector reversed
			ifPresent: [ :polygon |
				vecsToBeRemoved add: vector.
				touchingPolygonsSet add: polygon.
			]
	].
	
	^touchingPolygonsSet

]

{ #category : #'computation steps' }
VMVecMapBuilder2 >> createPolygons [
	dict := Dictionary new.
	
	1 to: img height - 2 do: [ :y |
		1 to: img width - 2 do: [ :x |
			((img colorAt: x @ y) brightness >= freeThreshold) ifTrue: [
				| vecCollection |
				vecCollection := self createVectorsForPoint: x @ y.
				self addVectorCollection: vecCollection.
				"polygons add: ((VMPolygon new) addAll: vecCollection)."
			].
		].
	].
	

]

{ #category : #'adding and merging' }
VMVecMapBuilder2 >> createVectorsForPoint: aPoint [
	"creates the line segments that encompase the pixel at the provided coordinates"
	^{
		VMLineSegment pointA: aPoint         pointB: aPoint + (1@0) type: (self typeOf: aPoint + (0 @ -1)).
		VMLineSegment pointA: aPoint + (1@0) pointB: aPoint + (1@1) type: (self typeOf: aPoint + (1 @ 0)).
		VMLineSegment pointA: aPoint + (1@1) pointB: aPoint + (0@1) type: (self typeOf: aPoint + (0 @ 1)).
		VMLineSegment pointA: aPoint + (0@1) pointB: aPoint         type: (self typeOf: aPoint + (-1 @ 0))
	}.
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder2 >> extractInnerPolygons: aPolygon [
	| collection newPolygon copy |
	
	copy := aPolygon copy.
	collection := VMPolygonCollection new.
	
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

{ #category : #accessing }
VMVecMapBuilder2 >> img [
	^img
]

{ #category : #accessing }
VMVecMapBuilder2 >> img: aForm [
	img := aForm
]

{ #category : #initialization }
VMVecMapBuilder2 >> initialize [
	polygons := VMPolygonCollection new.
	obstacleThreshold := 0.40.	"maximum brightness to consider a pixel an obstacle"
	freeThreshold := 0.95.		"minimum brightness to consider a pixel free space"
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder2 >> loadFromFile: filename [
	img := (ImageReadWriter formFromFileNamed: filename) flipHorizontally asGrayScale.
]

{ #category : #'computation steps' }
VMVecMapBuilder2 >> makeConsistent [
	"makes sure that polygons dont contain polygons inside. if a polygon consists of multiple simple polygons. they are seperated into multiple polygons"
	| newCollection |
	
	newCollection := VMPolygonCollection new.
	
	polygons do: [ :aPolygon |
		newCollection addAll: (self extractInnerPolygons: aPolygon).
	].
	
	polygons := newCollection.

	"Transcript show: 'makeConsistent p size=', polygons size printString; cr."

]

{ #category : #'adding and merging' }
VMVecMapBuilder2 >> mergeWithPolygonSet: touchingPolygonsSet newVectors: vecCollection touchingVectors: vecsToBeRemoved [
	| keepingPolygon |
	
	"'keeping' is the polygon that we keep. all others in the set will be merged into this one"
	keepingPolygon := touchingPolygonsSet anyOne.
	
	touchingPolygonsSet do: [ :touchingPolygon |
		touchingPolygon = keepingPolygon ifFalse: [
			"add vectors from touchingPolygon to keepingPolygon"
			keepingPolygon addAll: touchingPolygon.
			
			"mark the vectors from touchingPolygon to be now part of keepingPolygon"
			touchingPolygon do: [ :vec |
				dict at: vec put: keepingPolygon.
			].
			
			"remove touchingPolygon from our list of polygons"
			polygons remove: touchingPolygon.
		].
	].
		
	(vecCollection difference: vecsToBeRemoved) do: [ :vec |
		"add vectors to polygon"
		keepingPolygon add: vec.
		"associate new vectors with the polygon in the dictionary"
		dict at: vec put: keepingPolygon.
	].
		
	"remove vectors that were part of the original polygon(s)"
	"(vecsToBeRemoved collect: [ :obj | obj reversed ]) do: [ :obj | keepingPolygon remove: obj ]."
	vecsToBeRemoved do: [ :vec | keepingPolygon remove: vec reversed ].
		
	^self.

]

{ #category : #accessing }
VMVecMapBuilder2 >> polygons [
	^polygons
]

{ #category : #accessing }
VMVecMapBuilder2 >> polygons: aCollection [
	polygons := aCollection asVMPolygonCollection.
]

{ #category : #'adding and merging' }
VMVecMapBuilder2 >> simplifyPolygon: aPolygon [
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

{ #category : #'computation steps' }
VMVecMapBuilder2 >> simplifyPolygons [
	polygons := (polygons collect: [ :p | self simplifyPolygon: p ]) asVMPolygonCollection.
]

{ #category : #'as yet unclassified' }
VMVecMapBuilder2 >> typeOf: aPoint [
	"returns the type of the border for a pixel at 'aPoint' as an integer"
	| color |
	color := img colorAt: aPoint.
	(color brightness >= freeThreshold) ifTrue: [ ^3 ]. "free space, hence a sector border"
	(color brightness <= obstacleThreshold) ifTrue: [ ^1 ]. "occupied space, hence an obstacle border"
	^2 "unexplored space, hence a frontier"
]
