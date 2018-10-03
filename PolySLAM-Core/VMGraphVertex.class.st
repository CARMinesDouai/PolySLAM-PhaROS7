"
VMGraphVertex
This class is used to represent a single vortex in the graph.


It is derived from the Point class and uses the coordinates from the Point class as the 2D position of the vertex. every vertex stores its immediate neighbors in the 'neighbors' instance variable. Note that the class provides a class-side constructor using a point as parameter.


instance methods:

- addNeighbor: <VMGraphVertex>
	adds another vertex to be a neighbor of this vertex. does not add duplicates.
- id
	returns the id of the vertex
- id: <String or Number>
	sets the id of the vertex
- index
	returns the index of the vertex in the ordered collection of vertices in the VMMap instance
- index <Integer (or derived)>
	sets the index of the vertex. the index must be the actual index of the vertex in the VMMap instance.
- neighbors
	getter function, returns the collection of neighboring vertices
- point: <Point>
	sets the coordinates to the one of the provided point
- polygons
	returns the Set instance that contains reverences to all VMPolygon instance that this vertex is part of
- printString
	returns a string with the coordinates, the type, and the number of neighbors
- render: <VMRenderOptions>
	draws the vertex at its coordinates, and also draws the id as text next to it.
- type
	returns the type of the vertex. the currently supported types are:
		0: orgin of the robot
		1: border/obstacle
		2: frontier
- type: <Integer (or derived)>
	sets the type of the vertex
- weight: <VMGraphVertex>
	returns the edge wight to the neighbor provided via the argument, or nil if the provided vertex is not a neighbor

	
class side methods:

- point: <Point> (class-side)
	constructor that sets the coordinates of the vortex to the points coordinates.


Internal Representation and Key Implementation Points.

    Instance Variables:

	neighbors		<OrderedCollection>
			collection of connected verices
	type				<Number (e.g. SmallInteger)>
			type of the vertex: 0=origin. 1=border, 2=frontier
	id					<Number or String>
			identifier. used for visual debugging
	index 			<Integer (or derived)>
			the index of the vertex in the maps vertex collection
	polygons		<Set of (VMPolygon or derived class)>
			collection of polygons that contain this vertex
	edgeWeight	<Dictionary of [VMGraphVertex --> Float] >
			an associative array that stores the edge weight for each neighbor


TODO:
	- check with real world examples if a SmallDictionary performs better than the currently used Dictionary
	- check if storing the neighbors in an OrderedCollection instead of a Set gives a better performance






"
Class {
	#name : #VMGraphVertex,
	#superclass : #Point,
	#instVars : [
		'neighbors',
		'type',
		'id',
		'index',
		'polygons',
		'edgeWeight'
	],
	#category : #'PolySLAM-Core-kernel'
}

{ #category : #'instance creation' }
VMGraphVertex class >> point: a [ 
	"returns a new VMGraphVertex object with the point set"
	^(self new)
		point: a;
		yourself.

]

{ #category : #'instance creation' }
VMGraphVertex class >> point: a id: id [
	"returns a new VMGraphVertex object with the point set"
	^(self new)
		point: a;
		id: id;
		yourself.

]

{ #category : #'instance creation' }
VMGraphVertex class >> point: p type: t [
	"returns a new VMGraphVertex object with the point set"
	^(self new)
		point: p;
		type: t;
		yourself.

]

{ #category : #'rendering support' }
VMGraphVertex class >> rendererClass [
	^ VMGraphPointRenderer 
]

{ #category : #adding }
VMGraphVertex >> addNeighbor: vertex [
	"adds a vertex to the list of neighbors. if the vertex is already present in the collection it will not be added again."
	
	(neighbors includes: vertex) ifFalse: [
		neighbors add: vertex.
		edgeWeight at: vertex put: (self dist: vertex).
	].

]

{ #category : #'as yet unclassified' }
VMGraphVertex >> asPoint [
	^self point.
]

{ #category : #'rendering support' }
VMGraphVertex >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #accessing }
VMGraphVertex >> id [
	^id.
]

{ #category : #accessing }
VMGraphVertex >> id: name [
	id := name
]

{ #category : #accessing }
VMGraphVertex >> index [
	^index.
]

{ #category : #accessing }
VMGraphVertex >> index: i [
	index := i.
]

{ #category : #initialization }
VMGraphVertex >> initialize [
	super initialize.
	
	"neighbors := OrderedCollection new."
	neighbors := Set new.
	edgeWeight := Dictionary new.
	type := 0.
	id := 0.
	index := nil.	"should rise a signal if as an index without proper initialization"
	polygons := Set new.
]

{ #category : #accessing }
VMGraphVertex >> neighbors [
	"getter function, returning the neighbors collection (a Set)"
	^neighbors.
]

{ #category : #accessing }
VMGraphVertex >> point [
	"returns a copy of the coordinates as a Point object"
	^( x @ y ).
]

{ #category : #accessing }
VMGraphVertex >> point: p [
	"sets the coordinates of the vertex to the provided point"
	x := p x.
	y := p y.
]

{ #category : #accessing }
VMGraphVertex >> polygons [
	^polygons.
]

{ #category : #printing }
VMGraphVertex >> printOn: aStream [ 
	index ifNil: [
		'noIndex' printOn: aStream.
	] ifNotNil: [
		index printOn: aStream.
	].
]

{ #category : #printing }
VMGraphVertex >> printPoint [
	^( '(', x printString, '@', y printString, ')' ).
	
]

{ #category : #printing }
VMGraphVertex >> printString [
	
	^(super printString),' t=', (type printString), ', n=', (neighbors size)printString.
	
]

{ #category : #accessing }
VMGraphVertex >> type [
	"getter function, returns the type of the vertex"
	^type.

]

{ #category : #accessing }
VMGraphVertex >> type: t [
	"setter function, sets the type of the vertex"
	
	type := t.
]

{ #category : #accessing }
VMGraphVertex >> weight: vertex [
	"returns the edge weight from this vertex to the vertex provided by the argument.
	returns nil if the edge is not a neighbor."
	^(edgeWeight at: vertex ifAbsent: [ nil ]).
]
