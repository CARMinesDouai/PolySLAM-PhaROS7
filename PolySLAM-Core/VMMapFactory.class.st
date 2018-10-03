Class {
	#name : #VMMapFactory,
	#superclass : #Object,
	#instVars : [
		'info',
		'vertices',
		'edges',
		'polygons',
		'lineSegments',
		'bounds',
		'epsilon',
		'origin',
		'visGraph'
	],
	#category : #'PolySLAM-Core-kernel'
}

{ #category : #'instance creation api' }
VMMapFactory class >> fromData: data [
	"creates a new map object. 'data' is an array containing three strings (info, vertices, and
	edges), similar to the format used in 'fromString'.
	
	returns the newly created VMMap object."
	^(self new)
		fromStringsInfo: (data at: 1)
			vertices: (data at: 2)
			edges: (data at: 3).

]

{ #category : #'instance creation api' }
VMMapFactory class >> fromFile: filename [ 
	"returns a new VMMap object using the data found in the provided file"
	^(self new)
		fromFile: filename.

]

{ #category : #'instance creation api' }
VMMapFactory class >> fromStrings: info vertices: vertices edges: edges [ 
	"returns a new VMMap object, using the provided  info-, vertices- and edges-strings."
	^(self new)
		fromStringsInfo: info vertices: vertices edges: edges.

]

{ #category : #computing }
VMMapFactory >> computeBounds [
	
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
VMMapFactory >> computeLineSegments [
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
VMMapFactory >> computeNeighbors [
	"set the neighobrs for all vertices according to the edges defined in edgeList"
	
	edges do: [ :e |
		((e at: 1) = (e at: 2)) ifTrue: [
			Transcript show: 'ignoring vertex self reference (edge from ', (e at: 1)printString, ' to ', (e at: 2)printString; cr.
		] ifFalse: [
			(vertices at: (e at: 1)) addNeighbor: (vertices at: (e at: 2)).
			(vertices at: (e at: 2)) addNeighbor: (vertices at: (e at: 1)).
		].
	].
]

{ #category : #computing }
VMMapFactory >> computePolygons [
	polygons := VMPolygonFactory createPolygons: vertices origin: origin.
	"polygons := VMPolygonFactory createPolygons: vertices origin: origin expand: 0.1."
	
	"self setPolygonsWindingOrder.
	self sortPolygons.
	"
	polygons do: [ :p |
		self logCr: 'polygon: ', p printString.
	].
]

{ #category : #computing }
VMMapFactory >> computeVisGraph [
	visGraph := VMVisGraph fromMap: self.
]

{ #category : #'TestCase helper' }
VMMapFactory >> edges: edgeCollection [
	edges := edgeCollection asOrderedCollection.
]

{ #category : #construction }
VMMapFactory >> fromFile: fileName [
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

{ #category : #construction }
VMMapFactory >> fromStringArray: stringsArray [
	^self fromStringsInfo: (stringsArray at: 1) vertices: (stringsArray at: 2) edges: (stringsArray at: 3).
]

{ #category : #construction }
VMMapFactory >> fromStringsInfo: strInfo vertices: strVertices edges: strEdges [
	"creates a map from three strings:
		info <String>
			a string with three numbers: num_vertices, num_edges, and epsilon
		vertices <String>
			a string that contains the vertices. every vertex contains three numbers: x, y, and type
		edges <String>
			a string that defines the edges between vertices. the numbers in this string are indices of the vertices, and every pair of indices defines an edge.
	"
	info := self parseInfoLine: strInfo.
	vertices := (self parseVertexLine: strVertices) asOrderedCollection.
	edges := (self parseEdgeLine: strEdges) asOrderedCollection.

	self computeBounds.
	self computeLineSegments.
	self computeNeighbors.
	self computePolygons.
	"self computeVisGraph."
	
	"print summary"
	self logCr:
		'read map from strings. ',
		' num_vertices=', (info at: 1) printString, ' / ', (vertices size)printString,
		' num_edges=', (info at: 2) printString, ' / ', (edges size)printString,
		' map bounds=(', (bounds)printString, ')',
		' origin=', origin asPoint printString.
	
	^(VMPolygonMap new)
		"vertices: vertices;"
		polygons: polygons;
		bounds: bounds;
		origin: origin;
		setPolygonsWindingOrder;
		sortPolygons;
		computeVisGraph;
		yourself.
]

{ #category : #initialization }
VMMapFactory >> initialize [
	super initialize.
	
	info := nil.
	vertices := OrderedCollection new.
	edges := OrderedCollection new.
	polygons := OrderedCollection new.
	lineSegments := OrderedCollection new.
	bounds := nil.
	visGraph := nil.
	epsilon := 0.01.
	origin := 0@0.
]

{ #category : #parsing }
VMMapFactory >> parseEdgeLine: string [

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
VMMapFactory >> parseInfoLine: string [

	"reads the info string (first line in the vmap file format). the string should contain three tokens: number of vertices, number of edges, and epsilon.
	
	returns an array containing the three tokens as Number objects. on errors, the numbers returned are all zero."
	
	| tokens numVertices numEdges |
	
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
VMMapFactory >> parseVertexLine: string [

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

{ #category : #'TestCase helper' }
VMMapFactory >> vertices [
	"only used for the tests, not in the production code"
	^vertices.
]

{ #category : #'TestCase helper' }
VMMapFactory >> vertices: vertexCollection [
	vertices := vertexCollection asOrderedCollection.
]
