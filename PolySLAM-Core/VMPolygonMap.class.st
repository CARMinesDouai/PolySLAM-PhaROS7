"
VMMap objects store all the relevant data for a single map.


instance variables:
	info <Array (or compatible collection>
		array that holds the map information that is usually found in the vmap text file: num_vertices, num_edges & epsilon
	vertices <OrderedCollection>
		a collection of all vertices of the map
	edges <OrderedCollection>
		a collection of all edges of the map
	polygons <OrderedCollection>
		a collection of all polygons
	lineSegments <OrderedCollection>
		a collection of all line segments
	bounds <Rectangle>
		bounds of the map
	epsilon <Number (typically Float)>
		unused
	origin <VMGraphVertex>
		the map origin. the vertex always is on traversable space
	visGraph <VMVisGraph>
		the visibility graph for this map
"
Class {
	#name : #VMPolygonMap,
	#superclass : #Object,
	#instVars : [
		'polygons',
		'bounds',
		'origin',
		'visGraph'
	],
	#category : #'PolySLAM-Core-kernel'
}

{ #category : #'rendering support' }
VMPolygonMap class >> rendererClass [
	^ VMPolygonMapRenderer 
]

{ #category : #'rendering support' }
VMPolygonMap >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #accessing }
VMPolygonMap >> bounds [
	^ bounds
]

{ #category : #accessing }
VMPolygonMap >> bounds: aRectangle [
	bounds := aRectangle
]

{ #category : #computing }
VMPolygonMap >> computeBounds [
	
	"computes the map boundaries and stores the reult in 'bounds'."
	
	| newBounds |
	
	"check if we have any vertices at all. if no, then we have to exit here. in that case we set the bounds to zero"
	(polygons size) < 1
		ifTrue: [
			"bounds := Rectangle origin: (0@0) corner: (0@0)."
			bounds := nil.
			 ^self.
		].
	
	"initialize the bounds with the first polygon. we don't create a copy because the merge function below will always create a new rectangle"
	newBounds := polygons first bounds.
	
	"merge with all bounds to receive the bounds over all polygons"
	polygons do: [ :p |
		newBounds merge: p bounds.
	].
	
	bounds := newBounds.
]

{ #category : #computing }
VMPolygonMap >> computeVisGraph [
	visGraph := VMVisGraph fromMap: self.
]

{ #category : #computing }
VMPolygonMap >> expand: size [
	| newMap newPolygons |
	
	newMap := VMPolygonMap new.
	newPolygons := OrderedCollection new.
	
	polygons do: [ :p |
		newPolygons add: (p expand: size).
	].
	
	^newMap
		polygons: newPolygons;
		computeBounds;
		yourself.
]

{ #category : #initialize }
VMPolygonMap >> initialize [
	super initialize.
	
	polygons := OrderedCollection new.
	bounds := nil.
	visGraph := nil.
	origin := 0@0.

]

{ #category : #'as yet unclassified' }
VMPolygonMap >> lineSegments [
	| lineSegCollection |
	
	lineSegCollection := OrderedCollection new.
	
	polygons do: [ :p |
		lineSegCollection addAll: p lineSegments.
	].

	^lineSegCollection.
]

{ #category : #accessing }
VMPolygonMap >> origin [
	^ origin
]

{ #category : #accessing }
VMPolygonMap >> origin: aPoint [
	origin := aPoint
]

{ #category : #accessing }
VMPolygonMap >> polygons [
	^ polygons
]

{ #category : #accessing }
VMPolygonMap >> polygons: polygonCollection [
	polygons := polygonCollection asOrderedCollection.
]

{ #category : #computing }
VMPolygonMap >> setPolygonsWindingOrder [
	"sets the winding order of all polygons in 'polygons' according to the position of 'origin'."
	
	polygons do: [ :p |
		(p isPointInside: origin) ifTrue: [
			p makeCW.
		] ifFalse: [
			p makeCCW.
		].
	].
]

{ #category : #computing }
VMPolygonMap >> sortPolygons [
	"sorts the OrderedCollection 'polygons', so that all polygons with ccw winding order appear first (i.e. have a
	lower index than the rest). Polygons with a ccw winding order are passable inside and obstacles/unkown on
	the outside."
	| left right temp |
	
	left := 1.
	right := polygons size.
	
	[left < right] whileTrue: [
		(polygons at: left) cw ifTrue: [
			"this case means that the current element at 'left' has the correct order: cw"
			left := left + 1.
		] ifFalse: [
			"this case means that the current element at 'left' has a ccw order, and we are looking for an element with cw order to switch with"
			(polygons at: right) cw ifTrue: [
				"swap the two entries"
				temp := polygons at: left.
				polygons at: left put: (polygons at: right).
				polygons at: right put: temp.
				left := left + 1.
				right := right - 1.
			] ifFalse: [
				right:= right - 1.
			].
		].
	].
]

{ #category : #accessing }
VMPolygonMap >> visGraph [
	^ visGraph
]

{ #category : #accessing }
VMPolygonMap >> visGraph: graph [
	visGraph := graph
]
