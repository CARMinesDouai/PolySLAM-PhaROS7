"
VMVisGraph

represents the visibility graph for a given map.
"
Class {
	#name : #VMVisGraph,
	#superclass : #Object,
	#instVars : [
		'vertices',
		'polygons'
	],
	#category : #'PolySLAM-Core-kernel'
}

{ #category : #'instance creation' }
VMVisGraph class >> fromMap: map [ 
	"returns a new VMGraphVertex object with the point set"
	^(self new)
		polygons: (map polygons);
		computeGraph;
		yourself.

]

{ #category : #'rendering support' }
VMVisGraph class >> rendererClass [
	^ VMVisGraphRenderer 
]

{ #category : #'add / remove' }
VMVisGraph >> addPolygon: polygon [
	polygons add: polygon.
	self computeUpdate: polygon.
	
]

{ #category : #'rendering support' }
VMVisGraph >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #computing }
VMVisGraph >> computeGraph [
	"computes the visibility graph"
	
	| allPolygons numEdges |
	
	allPolygons := Set new.
	allPolygons addAll: polygons.
	numEdges := 0.
	
	"iterate over all polygons"
	polygons do: [ :polygon |
		Transcript show: 'visGraph polygon size=', (polygon vertices size)printString, ', cw=', (polygon testCW)printString; cr.
		
		allPolygons do: [ :setPolygon |
			numEdges := numEdges + (self computeLoop: polygon polygon: setPolygon allPolygons: allPolygons).
		].
		
		"allPolygons remove: polygon."
	].
	
	vertices := OrderedCollection new.
	polygons do: [ :p |
		p vertices do: [ :v |
			vertices add: v.
		].
	].
	
	Transcript show: 'number of edges=', (numEdges printString); cr.
	Transcript show: 'VisGraph structure (vertex :: neighbors)', (self printString2); cr.

]

{ #category : #computing }
VMVisGraph >> computeLoop: polygonA polygon: polygonB allPolygons: allPolygons [
	"loop that test if the vertices from polygonA can reach any vertices from polygonB.
	parameters:
		polygonA <OrderedCollection of VMClosedPolygons>
			the source polygon for out tests
		polygonB <OrderedCollection of VMClosedPolygons>
			the destination polygon for our tests
		allPolygons <Collection of VMClosedPolygons>
			a collection of all polygons, used to test for intersections
	"
	| numEdges |
	numEdges := 0.
	
	"iterate over all vertices of the first polygon"
	polygonA vertices doWithIndex: [ :aV :aI |
		
		"iterate over all vertices of the second polygon"
		polygonB vertices doWithIndex: [ :bV :bI |
			
			( aV = bV ) ifFalse: [
				((polygonA pointsInward: ( bV - aV ) index: aI) or: (polygonB pointsInward: ( aV - bV ) index: bI)) ifFalse: [
					(self intersectionTestLoop: allPolygons from: aV to: bV) ifTrue: [
						"do nothing, the line segment is intersecting with some other line segment"
					] ifFalse: [
						"create a bi-directional edge between the two vertices"
						aV addNeighbor: bV.
						bV addNeighbor: aV.
						numEdges := numEdges + 1.
					].
				].
			].
		].
	].
	
	^numEdges.
]

{ #category : #computing }
VMVisGraph >> computeUpdate: polygon [
	"needs to be optimized"
	vertices removeAll.
	self computeGraph.
]

{ #category : #initialization }
VMVisGraph >> initialize [
	vertices := OrderedCollection new.
	polygons := OrderedCollection  new.
]

{ #category : #computing }
VMVisGraph >> intersectionTestLoop: allPolygons from: aV to: bV [
	"tests if the line segment connecting aV and bV is intersecting with any polygon from allPolygons"
	| lineSeg |
	
	lineSeg := VMLineSegment from: aV to: bV.
	
	allPolygons do: [ :polygon |
		(polygon intersectsWithLine: lineSeg) ifTrue: [ ^true. ].
	].
	
	^false.
]

{ #category : #logging }
VMVisGraph >> logCr: text [
	"do nothing"
]

{ #category : #accessing }
VMVisGraph >> polygons [
	^polygons.
]

{ #category : #accessing }
VMVisGraph >> polygons: aCollection. [
	polygons addAll: aCollection.
]

{ #category : #printing }
VMVisGraph >> printString [
	"returns a string with all vertices and all neighbors for each vertex. the string contains multiple lines."
	| string |
	
	string := ''.
	
	vertices do: [ :v |
		string := string, String cr,'(', (v x)printString, '@', (v y)printString, ') ::'.
		
		(v neighbors) do: [ :n |
			string := string, ' ', (n point)printString.
		].
	].
	
	^string.
]

{ #category : #printing }
VMVisGraph >> printString2 [
	"returns a string with all vertices and all neighbors for each vertex. the string contains multiple lines.
	unlike with printString, this function only prints the vertices' ids instead of the coordinates."
	| string |
	
	string := ''.
	
	vertices do: [ :v |
		string := string, String cr,'  (', (v id)printString, ') ::'.
		
		(v neighbors) do: [ :n |
			string := string, ' ', (n id)printString.
		].
	].
	
	^string.
]

{ #category : #'add / remove' }
VMVisGraph >> removePolygon: polygon [
	polygons remove: polygon.
	self computeUpdate: polygon.
	
]

{ #category : #'GUI rendering' }
VMVisGraph >> render: renderOpt [
	"renders the visibility graph"
	
	| fillColor borderWidth borderColor  path stroke surface lw matrix |
	
	surface := renderOpt surface.
	fillColor:= Color green.
	borderWidth := 1.
	borderColor := Color white.
	lw := 0.1.
	matrix := renderOpt pathTransform getMatrix.
	
	path := surface createPath: [ :builder |
		builder absolute.
			
		vertices do: [ :v |
			"draw a circle around the position of the vertex"
			"self pathPoint: builder at: v radius: 0.333."
			
			"draw lines from the vertex to all its neighbors"
			(v neighbors) do: [ :neighbor |
				builder
					moveTo: v;
					lineTo: neighbor.
			].
		].
	].
	
	surface drawDuring: [ :canvas |
		canvas pathTransform loadAffineTransform: matrix.
		
		stroke := canvas setStrokePaint: Color green.
		stroke width: 0.1.
		"canvas setPaint: ( Color black )."
		canvas drawShape: path.
	].
	
]

{ #category : #'GUI rendering' }
VMVisGraph >> render: renderOpt style: styleOpt [
	"renders the visibility graph"
	
	| fillColor borderWidth borderColor  path stroke surface lw matrix |
	
	surface := renderOpt surface.
	fillColor:= Color green.
	borderWidth := 1.
	borderColor := Color white.
	lw := styleOpt get: 'lineWidth' default: 0.025.
	matrix := renderOpt pathTransform getMatrix.
	
	path := surface createPath: [ :builder |
		builder absolute.
			
		vertices do: [ :v |
			"draw a circle around the position of the vertex"
			"self pathPoint: builder at: v radius: 0.333."
			
			"draw lines from the vertex to all its neighbors"
			v neighbors do: [ :neighbor |
				builder
					moveTo: v;
					lineTo: neighbor.
			].
		].
	].
	
	surface drawDuring: [ :canvas |
		canvas pathTransform loadAffineTransform: matrix.
		
		stroke := canvas setStrokePaint: Color green.
		stroke width: lw.
		"canvas setPaint: ( Color black )."
		canvas drawShape: path.
	].
	
]

{ #category : #accessing }
VMVisGraph >> vertices [
	^vertices.
]
