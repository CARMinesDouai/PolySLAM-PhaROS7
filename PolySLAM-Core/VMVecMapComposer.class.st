"
This class is resposible for building  a PolyMap from a grid map. It therefor utilizes VMVecMapBuilder2, but slizes the grid map up into smaller tiles to increase the performance. The individual tiles are then merged, cleaned up and the final map returned to the user.
"
Class {
	#name : #VMVecMapComposer,
	#superclass : #Object,
	#instVars : [
		'img',
		'polygons'
	],
	#category : #'PolySLAM-Core-temp'
}

{ #category : #'as yet unclassified' }
VMVecMapComposer >> extractInnerPolygons: aPolygon [
	| collection newPolygon copy |
	
	copy := aPolygon copy.
	collection := VMPolygonCollection new.
	
	"take a line segment from 'aPolygon copy', build a new polygon by finding connected line segments, and remove all involved line segments from 'copy'."
	[copy isEmpty] whileFalse: [
		| lineSeg |
		
		newPolygon := VMPolygon new.
		lineSeg := copy anyOne.
		copy remove: lineSeg.
		newPolygon add: lineSeg.
		
		"add/remove line segments until the end point matches the starting point"
		[lineSeg pointB = newPolygon first pointA] whileFalse: [
			lineSeg := copy nextLineSeg: lineSeg.
			newPolygon add: lineSeg.
			copy remove: lineSeg.
		].
	
		collection add: newPolygon.
	].
	
	^collection
]

{ #category : #'as yet unclassified' }
VMVecMapComposer >> loadFromFile: filename [
	img := (ImageReadWriter formFromFileNamed: filename) flipHorizontally asGrayScale.
]

{ #category : #'as yet unclassified' }
VMVecMapComposer >> map [
	| tileSize deplacementFactor polygonCollection subForm tileResult |
	
	tileSize := 32.
	deplacementFactor := 1.0. "set to something like 1.1 to see the seperate tiles"
	polygonCollection := VMPolygonCollection new.
	
	1 to: img height + 1 by: tileSize do: [ :y |
		1 to: img width + 1 by: tileSize do: [ :x |
			subForm := img copy: (x @ y extent: (tileSize+2) @ (tileSize+2)).
			tileResult := (VMVecMapBuilder2 new)
				img: subForm;
				createPolygons;
				checkForDuplicates;
				makeConsistent;
				checkForDuplicates;
				simplifyPolygons;
				checkForDuplicates;
				polygons.
				
			polygonCollection addAll: (
				tileResult collect: [ :polygon | polygon moveBy: (deplacementFactor* x) @ (deplacementFactor * y) ])
		].
	].
	
	^polygonCollection

]

{ #category : #'as yet unclassified' }
VMVecMapComposer >> mapReduce [
	^self reduce: self map
]

{ #category : #'as yet unclassified' }
VMVecMapComposer >> mergePolygons: aCollection [
	| dict mergeSet polygonsToBeAdded |
	
	dict := Dictionary new.
	polygonsToBeAdded := VMPolygonCollection new.
	
	aCollection do: [ :polygon |
		| borderVectors |
		
		borderVectors := OrderedCollection new.
		mergeSet := IdentitySet new.
		
		"iterate over all sector vectors, collecting all polygons that contain the reversed vector"
		polygon do: [ :vec |
			vec type isSector ifTrue: [
				dict at: vec reversed ifPresent: [ :neighboringPolygon |
					mergeSet add: neighboringPolygon.
					borderVectors add: vec.] ] ].
		
		"if any neighbors were found, we merge them into the current polygon"
		mergeSet
			ifNotEmpty: [
				mergeSet do: [ :mergingPolygon |
					polygonsToBeAdded remove: mergingPolygon.
					polygon addAll: mergingPolygon. ].
				
				borderVectors do: [ :vec |
					polygon remove: vec.
					polygon remove: vec reversed.
				].
					
				polygon do: [ :vec | dict at: vec put: polygon].
			].
		
		polygon do: [ :vec | dict at: vec put: polygon].
		polygonsToBeAdded add: polygon.
	].

	^polygonsToBeAdded

]

{ #category : #'as yet unclassified' }
VMVecMapComposer >> polygons [
	^polygons
]

{ #category : #'as yet unclassified' }
VMVecMapComposer >> reduce: aCollection [
	| newCollection mergingPolygons |
	
	newCollection := VMPolygonCollection new.
	mergingPolygons := VMPolygonCollection new.
	
	"select all polygons that contain sector borders. pass along all that don't"
	aCollection do: [ :polygon |
		(polygon contains: [ :vec | vec type isSector ])
			ifTrue: [ mergingPolygons add: polygon ]
			ifFalse: [ newCollection add: polygon ].
	].

	(self mergePolygons: mergingPolygons) do: [ :polygon | newCollection addAll: (self extractInnerPolygons: polygon) ].
	
	^newCollection
]
