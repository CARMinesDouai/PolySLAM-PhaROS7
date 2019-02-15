Extension { #name : #VMPolygon }

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMPolygon >> calculateIntersectionOn: L do: aBlock [
	|lastline vertex|
	L isEmpty ifTrue: [ ^self ].
	lastline := nil.
	L do: [ :e|
		lastline
			ifNotNil: [ 
				vertex := PSVertex intersectionOf: lastline  and: e.
				vertex ifNotNil: [ aBlock value: vertex].
			].
		lastline := e
	]
	
]

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMPolygon >> mergeWith: anotherPolygon [
|Q L intersections vertex lut|
Q := BTree order: 4.
L := BTree order: 4.
lut := Dictionary new.
intersections := OrderedCollection new.
"push all events to Q, a B-Tree, each event coresponding to a vertex of the two polygon"
self do:[:line| line asPSVertices do:[:v| Q at: v y put: v ]].
anotherPolygon do:[:line| line asPSVertices do:[:v| Q at: v y put: v ]].
"get first, calculate intersection"
[ Q isEmpty ] whileFalse: [ 
	vertex := Q root first.
	Q removeKey: vertex y.
	"sweep line event at vertex"
	self sweepEventAt: vertex on:L lut: lut.
	"find intersection points"
	self calculateIntersectionOn: L do: [:e|
		"Q at: e y put: e."
		intersections add: e	
	].
].
"visualize two polygon and intersections point"
^{ self asRenderableElement. anotherPolygon asRenderableElement. intersections asRenderableElement } asOrderedCollection asRenderableElement 
]

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMPolygon >> sweepEventAt: vertex on:L lut: lut [
	|line line1|
	line := vertex segments at: 1.
	vertex type caseOf: {
		"start so insert it to L"
		[ 0 ] -> [ L at: vertex x put: line. lut at: line put: vertex x].
		"end so remove it from L"
		[ 1 ] -> [ L removeKey: (lut at: line) ].
		"intersetct so swap the two line segment"
		[ -1 ] -> [
			line1 := vertex segments at: 2.
			L removeKey: (lut at: line).
			L removeKey: (lut at: line1).
			L at: line pointA x put: line1.
			lut at:line1 put: line pointA x.
			L at: line1 pointA x put: line.
			lut at: line put: line1 pointA x.
		]
	} otherwise: [  ]
]
