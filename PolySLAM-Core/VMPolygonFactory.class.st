"
VMPolygonFactory

this class builds polygons from the provided vector map's vertices and edges.
"
Class {
	#name : #VMPolygonFactory,
	#superclass : #Object,
	#instVars : [
		'polygons',
		'vertices',
		'activeNeighborCount',
		'isolated',
		'closed',
		'chains',
		'origin'
	],
	#category : #'PolySLAM-Core-kernel'
}

{ #category : #'create polygons' }
VMPolygonFactory class >> createPolygons: verticesCollection [
	"returns an OrderedCollection of vertices"
	^(self new)
		vertices: verticesCollection;
		createPolygons.
]

{ #category : #'create polygons' }
VMPolygonFactory class >> createPolygons: verticesCollection expand: size [
	^(self new)
		vertices: verticesCollection;
		createPolygonsExpand: size.
]

{ #category : #'create polygons' }
VMPolygonFactory class >> createPolygons: verticesCollection origin: aPoint [
	"returns an OrderedCollection of vertices"
	^(self new)
		vertices: verticesCollection;
		origin: aPoint;
		createPolygons.
]

{ #category : #'create polygons' }
VMPolygonFactory class >> createPolygons: verticesCollection origin: aPoint expand: size [
	^(self new)
		vertices: verticesCollection;
		origin: aPoint;
		createPolygonsExpand: size.
]

{ #category : #'create polygons' }
VMPolygonFactory class >> createSimplePolygons: aCollection [

	| vertices isolated polyCount lines closed polygons size |
	
	size := 0.1.
	
	vertices := Set new.
	vertices addAll: aCollection.
	polyCount := OrderedCollection new.
	vertices do: [ :v |
		polyCount add: 0.
	].
	
	isolated := self createIsolatedPolygons: vertices isolated: (self collectIsolatedPoints: vertices).
	lines := self createLines: vertices polyCount: polyCount.
	closed := self createClosedPolygons: vertices polyCount: polyCount.
	lines addAll: (self createLines2: vertices polyCount: polyCount).
	
	
	self logCr: 'polygon stats: num_isolated=', (isolated size) printString,
		' num_lines=', (lines size) printString,
		' num_closed=', (closed size) printString.
	
	polygons := OrderedCollection new.
	
	isolated do: [ :p |
		| temp |
		temp := (p expand: size).
		temp makeCCW.
		
		polygons add: temp.
	].
	
	polygons addAll: lines.
	polygons addAll: closed.
	^polygons.
]

{ #category : #helper }
VMPolygonFactory >> collectIsolatedPoints [
	"returns an ordered collection with all vertices that have zero neighbors"
	| collectedVertices |
	
	collectedVertices := OrderedCollection new.
	
	vertices do: [ :v |
		(v neighbors size) = 0 ifTrue: [
			collectedVertices add: v.
		].
	].
	
	^collectedVertices.	

]

{ #category : #helper }
VMPolygonFactory >> createChainPolygons [
	
	vertices do: [ :v |
		(self freeNeighborsCount: v) == 1 ifTrue: [
			chains add: (VMPolygonChainFactory createWithVertex: v activeNeighborCount: activeNeighborCount).
		].
	].
	
	
]

{ #category : #helper }
VMPolygonFactory >> createClosedPolygons [
	
	vertices do: [ :v |
		| polygon |
		
		(self freeNeighborsCount: v) > 1 ifTrue: [
			polygon := VMClosedPolygonFactory createWithVertex: v activeNeighborCount: activeNeighborCount.
			polygon ifNotNil: [
				polygon setWindingOrderByOrigin: origin.
				closed add: polygon.
			].
		].
	].
]

{ #category : #helper }
VMPolygonFactory >> createIsolatedPolygons [
	"finds all vertices that have zero neighbors and creates VMIsolatedPoint objects for each of them. the new objects are stored in 'isolated'."
	| polygonCollection isolatedPoints |
	
	isolatedPoints := self collectIsolatedPoints.
	
	polygonCollection := OrderedCollection new.
	
	isolatedPoints do: [ :v |
		polygonCollection add: (VMIsolatedPoint fromVertex: v).
		vertices remove: v.
	].
	
	isolated := polygonCollection.

]

{ #category : #'public: create' }
VMPolygonFactory >> createPolygons [
	
	self logCr: 'creating isolated polygons'.
	self createIsolatedPolygons.
	self logCr: 'creating chain polygons (1)'.
	self createChainPolygons.
	self logCr: 'creating closed polygons'.
	self createClosedPolygons.
	self logCr: 'creating chain polygons (2)'.
	self createChainPolygons.
	
	self logCr: 'polygon stats: num_isolated=', (isolated size) printString,
		' num_lines=', (chains size) printString,
		' num_closed=', (closed size) printString,
		' origin=', origin asPoint printString.
	
	polygons addAll: isolated.
	polygons addAll: chains.
	polygons addAll: closed.
	^polygons.
]

{ #category : #'public: create' }
VMPolygonFactory >> createPolygonsExpand: size [
	| expandedPolygons |
	self createPolygons.
	
	expandedPolygons := OrderedCollection new.
	polygons do: [ :p |
		expandedPolygons add: (p expand: size).
	].
	
	^expandedPolygons.
]

{ #category : #private }
VMPolygonFactory >> freeNeighborsCount: vertex [
	^activeNeighborCount freeNeighborsCount: vertex.
]

{ #category : #initialize }
VMPolygonFactory >> initialize [
	vertices := Set new.
	isolated := OrderedCollection new.
	chains := OrderedCollection new.
	closed := OrderedCollection new.
	activeNeighborCount  := VMActiveNeighborCount new.
	polygons := OrderedCollection new.

]

{ #category : #setter }
VMPolygonFactory >> origin: aPoint [
	origin := aPoint.
]

{ #category : #helper }
VMPolygonFactory >> printDebug [
	Transcript
		show: self class name asString;
		cr.
	
	vertices do: [:v |
		Transcript
			show: '    ', v printString, ', free=', (activeNeighborCount freeNeighborsCount: v) printString;
			cr.
	].
	activeNeighborCount printString.
]

{ #category : #setter }
VMPolygonFactory >> vertices: vertexCollection [
	vertices := (OrderedCollection new)
		addAll: vertexCollection;
		yourself.

]
