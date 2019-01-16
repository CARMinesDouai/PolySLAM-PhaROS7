"
This is an ordered collection with added functionallity to handle polygons.
"
Class {
	#name : #VMPolygonCollection,
	#superclass : #OrderedCollection,
	#category : #'PolySLAM-Core-Collections'
}

{ #category : #'rendering support' }
VMPolygonCollection class >> rendererClass [
	^VMPolygonCollectionRenderer
]

{ #category : #converting }
VMPolygonCollection >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #converting }
VMPolygonCollection >> asVMPolygonCollection [
	^self.
]

{ #category : #accessing }
VMPolygonCollection >> bounds [
	"answers the boundary of the polygon collection. used for rendering support."
	| rect |
	
	self ifEmpty: [ ^VMRectangle origin: 0@0 corner: 0@0 ].
	
	rect := self first bounds.
	self allButFirstDo: [ :element |
		rect := rect merge: element bounds.
	].
	
	^rect


]

{ #category : #'GT Inspector' }
VMPolygonCollection >> gtInspectorRenderedIn: composite [
	<gtInspectorPresentationOrder: 50>
	
	(composite morph)
		title: 'Viewer';
		morph: [
			(VMViewer openWindowlessOn: { self asRenderableElement })
				autozoom.
		].
]

{ #category : #inserting }
VMPolygonCollection >> insert: p [
	1 halt
]

{ #category : #testing }
VMPolygonCollection >> polygonIsIsolated: aPolygon [
	"a polygon is considered isolated if all line segments are frontiers"
	^ aPolygon allSatisfy: [ :lineSeg | lineSeg type isFrontier ]
]

{ #category : #printing }
VMPolygonCollection >> printStatistics [
	| polygonCount lineSegCount |
	
	polygonCount := self size.
	lineSegCount := 0.
	
	self do: [ :p | lineSegCount := lineSegCount + p size ].
	
	Transcript show: 'Map Statistics:'; cr.
	Transcript show: '  polygon count=', polygonCount printString; cr.
	Transcript show: '  vector count=', lineSegCount printString; cr.

]

{ #category : #'as yet unclassified' }
VMPolygonCollection >> removeIsolated [
	"| isolatedPolygons |
	
	isolatedPolygons := self select: [ :p | self polygonIsIsolated: p ].
	Transcript show: 'found ', isolatedPolygons size printString, ' isolated polygons'; cr.
	self removeAll: isolatedPolygons."
	
	| removed |
	removed := self removeAll: (self select: [ :p | self polygonIsIsolated: p ]).
	Transcript show: 'found and removed ', removed size printString, ' isolated polygon(s)'; cr.
	
]

{ #category : #'import / export' }
VMPolygonCollection >> writeToFile: filename [
	"writes the polygonCollection to a binary file. all values are treated as integers for the moment"
	filename asFileReference writeStreamDo: [ :stream |
		stream binary.
		
		self do: [ :polygon |
			stream nextPutAll: polygon size as32ByteArray.
			polygon do: [ :vec |
				stream nextPutAll: vec pointA x asInteger as32ByteArray.
				stream nextPutAll: vec pointA y asInteger as32ByteArray.
				stream nextPut: vec type asInteger.
			].
		].
		stream close.
	].
]
