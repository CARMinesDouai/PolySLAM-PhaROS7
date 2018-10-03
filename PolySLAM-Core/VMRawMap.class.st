Class {
	#name : #VMRawMap,
	#superclass : #Object,
	#instVars : [
		'vertices',
		'edges',
		'origin',
		'bounds',
		'lineSegments'
	],
	#category : #'PolySLAM-Core-kernel'
}

{ #category : #'instance creation' }
VMRawMap class >> fromFile: filename [ 
	"returns a new VMMap object using the data found in the provided file"
	^(self new)
		fromFile: filename.

]

{ #category : #'instance creation' }
VMRawMap class >> fromStringArray: data [
	"returns a new VMMap object using the data found in the provided file"
	^(self new)
		fromStringArray: data.

]

{ #category : #accessing }
VMRawMap >> bounds [
	^bounds.
]

{ #category : #computing }
VMRawMap >> computeBounds [
	
	"computes the map boundaries and stores the reult in 'bounds'."
	
	| minX minY maxX maxY |
	
	"check if we have any vertices at all. if no, then we have to exit here. in that case we set the bounds to zero"
	(vertices size) < 1
		ifTrue: [
			"bounds := Rectangle origin: (0@0) corner: (0@0)."
			bounds := nil.
			 ^self.
		].
	
	"initialize the bounds with the first vertex from the list"
	minX := ((vertices first) x).
	minY := ((vertices first) y).
	maxX := ((vertices first) x).
	maxY :=(( vertices first) y).
	
	
	vertices do: [ :v |
		minX > v x
			ifTrue: [ minX := v x ].
		maxX < v x
			ifTrue: [ maxX := v x ].
		minY > v y
			ifTrue: [ minY := v y ].
		maxY < v y
			ifTrue: [ maxY := v y ].
	].
	
	bounds := Rectangle origin: (minX@minY) corner: (maxX@maxY).
]

{ #category : #computing }
VMRawMap >> computeLineSegments [
	"creates a collection of VMLineSegment objects which will be stored at lineSegList"
	
	| list pointA pointB |
	
	list := OrderedCollection new.
	
	edges do: [ :e |
		pointA := vertices at: (e at: 1).
		pointB := vertices at: (e at: 2).
		list add: (VMLineSegment from: pointA to: pointB).
	].
	
	lineSegments := list.

]

{ #category : #computing }
VMRawMap >> computeNeighbors [
	| neighborCounts |
	edges do: [ :e |
		(vertices at: (e at: 1)) addNeighbor: (vertices at: (e at: 2)).
		(vertices at: (e at: 2)) addNeighbor: (vertices at: (e at: 1)).
	].
	
	"statistics"
	neighborCounts := SmallDictionary new.
	vertices do: [ :v |
		| count |
		count := v neighbors size.
		neighborCounts at: count
			ifPresent: [ :value |
				neighborCounts at: count put: (value + 1).
			] ifAbsent: [
				neighborCounts at: count put: 1.
			].
	].
	
	self logCr: 'RawMap vertices statistics:'.
	neighborCounts keysAndValuesDo: [ :k :v |
		self logCr: '  neighbors=', k printString, ' vertices count=', v printString.
	].
]

{ #category : #'instance creation' }
VMRawMap >> fromFile: fileName [
	"reads from a *.vmap file and initialzes the data of this object"

	| fileStream lineArray lineNr stringsArray |
	
	fileStream := FileStream fileNamed: fileName.
	lineArray := OrderedCollection new.
	lineNr := 0.	"todo: check if file exists and can be read from"
	
	"read all lines from the file"
	[ fileStream atEnd ] whileFalse: [ 
		lineNr := lineNr + 1.
		lineArray add: fileStream nextLine.
	].
	
	"check if we have the old file format (*.vmap) or the new file format (*.vm)."
	(fileName endsWith: '.vmap') ifTrue: [ 
		"if we read less than three lines then there was an error (e.g. wrong file format)"
		lineNr < 3 ifTrue: [ 
			Transcript
				show: 'error: expected at least 3 lines in file "', fileName, '" but found ' , lineNr printString, ' lines';
				cr.
			^ self.
		].
		stringsArray := { lineArray at: 1. lineArray at: 2. lineArray at: 3. }.
	] ifFalse: [ 
		(fileName endsWith: '.vm') 	ifTrue: [ 
			"if we read less than four lines then there was an error (e.g. wrong file format)"
			lineNr < 4 ifTrue: [ 
				Transcript
					show: 'error: expected at least 4 lines in file "', fileName, '" but found ' , lineNr printString, ' lines';
					cr.
				^ self.
			].
			stringsArray := { lineArray at: 2. lineArray at: 3. lineArray at: 4. }.
		].
	].
	
	^self fromStringArray: stringsArray.
	

]

{ #category : #'instance creation' }
VMRawMap >> fromStringArray: data [
	| strInfo strVertices strEdges info |
	
	strInfo := data at: 1.
	strVertices := data at: 2.
	strEdges := data at: 3.
	
	info := self parseInfoLine: strInfo.
	vertices := (self parseVertexLine: strVertices) asOrderedCollection.
	edges := (self parseEdgeLine: strEdges) asOrderedCollection.

	self computeBounds.
	self computeLineSegments.
	self computeNeighbors.
	"self computeVisGraph."
	
	"print summary"
	self logCr:
		'read map from strings. ',
		' num_vertices=', (info at: 1) printString, ' / ', (vertices size)printString,
		' num_edges=', (info at: 2) printString, ' / ', (edges size)printString,
		' map bounds=(', (bounds)printString, ')'.
	
	^self.
]

{ #category : #'as yet unclassified' }
VMRawMap >> lineSegments [
	^lineSegments.
]

{ #category : #parsing }
VMRawMap >> parseEdgeLine: string [

	"reads a string containing edges. the format is the same as in the third line of the vmap file: every edge
	is a pair of integers, which are the indices of the edge's vertices.
	
	returns an OrderedCollection containing the edges as array of two integers."
	
	| tokens list index |
	
	tokens := string findTokens: ' '.
	list := OrderedCollection new.
	
	index := 1 + ((tokens size ) \\ 2).		"should always be 1, i.e. the number of tokens should be even"
	
	index to: ((tokens size)-1) by: 2 do: [ :i |
		"todo: check if these number are actually integers and throw an exception if not"
		list add: { (tokens at: i) asNumber. (tokens at: (i+1)) asNumber }.
	].

	^list.

]

{ #category : #parsing }
VMRawMap >> parseInfoLine: string [

	"reads the info string (first line in the vmap file format). the string should contain three tokens: number of vertices, number of edges, and epsilon.
	
	returns an array containing the three tokens as Number objects. on errors, the numbers returned are all zero."
	
	| tokens numVertices numEdges epsilon |
	
	tokens := string findTokens: ' '.
	
	"check if we have at least three tokens in this string"
	tokens size < 3
		ifTrue: [
			Transcript show: 'expected at least 3 tokens in the info string (num_vertex, num_edge, epsilon) but found only ',
				(tokens size printString),
				' tokens instead'; cr.
			^{0, 0, 0}.
		].
	
	"read the tokens from the first line: map size (x,y) and epsilon"
	numVertices := ((tokens at: 1) asNumber).
	numEdges := ((tokens at: 2) asNumber).
	epsilon := ((tokens at: 3) asNumber).
	
	^{ numVertices. numEdges. epsilon }.

]

{ #category : #parsing }
VMRawMap >> parseVertexLine: string [

	"reads a string containing vertices. the format is the same as in the second line of the vmap file: every vertex
	is a tripplet of numbers, i.e. two floats (x and y coordinates) and an integer (the type, e.g. obstacle or frontier).
	
	returns an OrderedCollection containing the vertices as VMGraphVertex objects."
	
	| tokens list index start point vertex |
	
	tokens := string findTokens: ' '.
	list := OrderedCollection new.
	
	index := 1.
	start := 1 + ((tokens size) \\ 3).
	
	start to: ((tokens size)-2) by: 3 do: [ :i |
		point := ((tokens at: i) asNumber)@((tokens at: (i+1)) asNumber).
		vertex := VMGraphVertex point: point.
		vertex type: (tokens at: (i+2)) asNumber.
		
		(vertex type = 0) ifTrue: [
			"note: if no origin is present, the origin can be assumed to be at 0@0, which is the default value set by initialize"
			vertex index: 0.
			origin := vertex.
		] ifFalse: [
			vertex id: index.
			vertex index: index.
			list add: vertex.
			index := index + 1.
		].
	].

	^list.

]

{ #category : #accessing }
VMRawMap >> vertices [
	^vertices.
]
