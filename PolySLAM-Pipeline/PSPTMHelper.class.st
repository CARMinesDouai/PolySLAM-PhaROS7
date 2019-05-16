Class {
	#name : #PSPTMHelper,
	#superclass : #PSPolygonOperationHelper,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #public }
PSPTMHelper >> perform [
	|size collection matrix idx peak peakf cocollection Q helper intersections|
	((polygonA isNil ) | (polygonB isNil )) ifTrue:[^self error: 'Please set the two input polygons'].
	" first calculate the intersetion point"
	"((polygonA isCCW) & (polygonB isCCW ) ) ifTrue:[isReversal := false]."
	"now create the adjacent matrix"
	Q := BTree order: 4.
	idx := 1.
	collection := OrderedCollection new.
	cocollection := OrderedCollection new.
	peak := nil.
	peakf := [:anEdge| 
		peak
			ifNil:[ peak := anEdge ]
			ifNotNil: [
				( (anEdge value pointA y) > (peak value pointA y) ) ifTrue:[peak := anEdge]].
	].
	polygonA linksDo:[:e|
		e id:idx.
		collection add:e.
		peakf value:e.
		idx := idx +1.
		e asPSVertices do:[:v| Q at: (PSVertexKeyY from:v) put: v ]].
	polygonB linksDo:[:e| e id:idx. collection add:e. peakf value:e. idx := idx +1.].
	matrix := PSAdjacencyMatrix fromLines: collection probabilityHelper: PSInflateColinearProbability.
	matrix := matrix binaryAdjacencyMatrix makeSymetric.
	
	size := matrix numberOfRows.
	
	
	1 to: size do:[:i| |line|
		(matrix rowAt: i) sum = 0
			ifTrue:[
				line := collection at: i.
				line chain = polygonB ifTrue:[
						line asPSVertices do:[:v| Q at: (PSVertexKeyY from:v) put: v ]
				]	
			]
			ifFalse:[
			i to: size do:[:j|
				(matrix at: i at:j) = 1
					ifTrue:[
						cocollection add: (collection at:i); add: (collection at: j)
					]	
			]
		]
	].
	
	helper := PSPolygonIntersectionHelper new.
	helper perform: Q.
	intersections := helper intersections. 
	
	matrix inspect.
	collection asRenderableElement inspect.
	{cocollection. intersections } asRenderableElement inspect.
]
