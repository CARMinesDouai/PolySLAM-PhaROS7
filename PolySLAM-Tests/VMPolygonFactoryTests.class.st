Class {
	#name : #VMPolygonFactoryTests,
	#superclass : #Object,
	#instVars : [
		'map'
	],
	#category : #'PolySLAM-Tests'
}

{ #category : #running }
VMPolygonFactoryTests >> setUp [
	| data vertices edges infoStr verticesStr edgesStr |
	
	super setUp.
	
	data := VMDataSet dataMap_3.
	infoStr := data at: 1..
	verticesStr := data at: 2.
	edgesStr := data at: 3.
	map := VMMapFactory new.
	
	"we read the data 'by hand' instead of relying on the readFromString functions to bypass the polygon
	creation process that would otherwise be performed automatically."
	
	vertices := (map parseVertexLine: verticesStr).
	edges := (map parseEdgeLine: edgesStr).
	
	map vertices: vertices.
	map edges: edges.

	map computeBounds.
	map computeLineSegments.
	map computeNeighbors.
	

]

{ #category : #tests }
VMPolygonFactoryTests >> testClosedPolygons [
	| vertices polyCount polygonLines polygonChains calculatedClosedPolygons expectedPolygons matching expectedIndices |
	
	vertices := Set new addAll: (map vertices).
	
	"we store the indices of the verices for each expected polygon"
	expectedIndices := {
		{1. 2. 3. 4}.
		{10. 11. 12}.
		{13. 14. 15. 19}.
		{15. 16. 17. 18}.
		{20. 21. 22}.
		{23. 24. 25. 26}
	}.
	expectedPolygons := OrderedCollection new.
	expectedIndices do: [ :e |
		expectedPolygons add: (self verticesFromIndices: e vertices: vertices).
	].
	
	polyCount := OrderedCollection new.
	vertices do: [ :v |
		polyCount add: 0.
	].
	
	"call createIsolatedPolygons in order to remove all isolated points from the vertices collection"
	polygonLines := VMPolygonFactory createIsolatedPolygons: vertices isolated: (VMPolygonFactory collectIsolatedPoints: (vertices)).
	
	"call createLines to remove poly-lines that have at least one loose end"
	polygonChains := VMPolygonFactory createLines: (vertices) polyCount: polyCount.
	
	"finally call createClosedPolygons to create all closed polygons"
	calculatedClosedPolygons := VMPolygonFactory createClosedPolygons: vertices polyCount: polyCount.
	
	"check if we found athe right number of polygons"
	self assert: (calculatedClosedPolygons size = expectedPolygons size).
	
	"check if the polygons contain the correct vertices
	
	note: we do not check if every expected polygon is present. it could be, for example, that
	all calculate polygons are identical to the first expected polygon, which would be an error."
	calculatedClosedPolygons do: [ :c |
		matching := false.
		expectedPolygons do: [ :e |
			((c vertices includesAll: e) & (e includesAll: c vertices)) ifTrue: [
				matching := true.
			].
		].
		self assert: matching.
	].

]

{ #category : #tests }
VMPolygonFactoryTests >> testIsolatedPoints [
	| calcultedIsolatedPoints expectedIsolatedPoints expectedIndices vertices |
	
	vertices := Set new addAll:( map vertices).
	
	expectedIndices := { 27. 28 }.
	expectedIsolatedPoints := self verticesFromIndices: expectedIndices vertices: vertices.
	"expectedIsolatedPoints := OrderedCollection new.
	map vertexList do: [ :v |
		(expectedIndices includes: (v index)) ifTrue: [ expectedIsolatedPoints add: v. ].
	]".
	
	calcultedIsolatedPoints := VMPolygonFactory collectIsolatedPoints: vertices.
	
	self assertCollection: calcultedIsolatedPoints hasSameElements: expectedIsolatedPoints
]

{ #category : #tests }
VMPolygonFactoryTests >> testPolygonChain [
	|  polyCount vertices calculatedPolygonChains chain1Indices chain2Indices chain1Vertices chain2Vertices |
	
	chain1Indices := { 5. 6. 7 }.
	chain2Indices := { 8. 9. 10 }.
	
	vertices := Set new addAll: (map vertices).
	
	chain1Vertices := self verticesFromIndices: chain1Indices vertices: vertices.
	chain2Vertices := self verticesFromIndices: chain2Indices vertices: vertices.
	
	polyCount := OrderedCollection new.
	vertices do: [ :v |
		polyCount add: 0.
	].
	
	"call createIsolatedPolygons in order to remove all isolated points from the vertices collection"
	VMPolygonFactory createIsolatedPolygons: vertices isolated: (VMPolygonFactory collectIsolatedPoints: vertices).
	
	calculatedPolygonChains := VMPolygonFactory createLines: vertices polyCount: polyCount.
	
	"test if the number of polygon chains is as expected"
	self assert: calculatedPolygonChains size = 2.
	
	"test if the polygon chains contain exactly the expected elements"
	calculatedPolygonChains do: [ :p |
		self assert: (
			((p vertices includesAll: chain1Vertices) & (chain1Vertices includesAll: p vertices))  | 
			((p vertices includesAll: chain2Vertices) & (chain2Vertices includesAll: p vertices))
		).
	].


]

{ #category : #tests }
VMPolygonFactoryTests >> testPolygonChain2 [
	|  polyCount vertices calculatedPolygonChains chainIndices chainVertices polygonLines polygonChains ClosedPolygons |
	
	chainIndices := { 22. 23 }.
	
	vertices := Set new addAll: (map vertices).
	
	chainVertices := self verticesFromIndices: chainIndices vertices: vertices.
	
	polyCount := OrderedCollection new.
	vertices do: [ :v |
		polyCount add: 0.
	].
	
	"call createIsolatedPolygons in order to remove all isolated points from the vertices collection"
	polygonLines := VMPolygonFactory createIsolatedPolygons: vertices isolated: (VMPolygonFactory collectIsolatedPoints: (vertices)).
	
	"call createLines to remove poly-lines that have at least one loose end"
	polygonChains := VMPolygonFactory createLines: (vertices) polyCount: polyCount.
	
	"call createClosedPolygons to remove all vertices that are fully occupied"
	ClosedPolygons := VMPolygonFactory createClosedPolygons: vertices polyCount: polyCount.
	
	"call createLines again to pick up the reminder. after this there should be no vertices left"
	calculatedPolygonChains := VMPolygonFactory createLines2: vertices polyCount: polyCount.
	
	"test if the number of polygon chains is as expected"
	self assert: calculatedPolygonChains size = 1.
	self assert: ((vertices size) = 0).
	
	"test if the polygon chains contain exactly the expected elements"
	calculatedPolygonChains do: [ :p |
		self assert: (
			((p vertices includesAll: chainVertices) & (chainVertices includesAll: p vertices))
		).
	].


]

{ #category : #'as yet unclassified' }
VMPolygonFactoryTests >> verticesFromIndices: collection vertices: vertices [
	"returns a new collection that contains the vertices associated with the indices from 'collection'."
	| result |
	
	result := OrderedCollection new.
	
	collection do: [ :i |
		result addAll: (vertices select: [ :v | v index = i. ]).
	].
	
	^result.
]
