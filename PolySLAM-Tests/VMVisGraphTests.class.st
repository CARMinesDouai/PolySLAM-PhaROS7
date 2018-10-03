Class {
	#name : #VMVisGraphTests,
	#superclass : #Object,
	#instVars : [
		'maps'
	],
	#category : #'PolySLAM-Tests'
}

{ #category : #'as yet unclassified' }
VMVisGraphTests >> dataCollection [
	| dataSelectors |
	dataSelectors := self class allSelectors select: [: aSymbol | aSymbol beginsWith: 'dataMap_'].
	^dataSelectors asSortedCollection collect: [: selector| self perform: selector]
]

{ #category : #running }
VMVisGraphTests >> setUp [
	
	super setUp.
	
	"not needed at the moment" 
	"maps := self dataCollection collect: [ :each | VMMapFactory fromData: each ]"
	
]

{ #category : #tests }
VMVisGraphTests >> testAddIsolatedPoints [
	"here we are testing the addPolygon method of the visibility graph by adding two VMIsolatedPoint objects."
	| visGraph points isolated |
	
	visGraph := VMVisGraph fromMap:(VMMapFactory fromData: VMDataSet dataMap_5).
	points := { 0@ -2. 5@3. }.
	isolated := OrderedCollection new.
	
	points do: [ :p |
		isolated add: ( VMIsolatedPoint fromPoint: p ).
	].
	
	isolated do: [ :i |
		visGraph addPolygon: i.
	].
	
	"the map should provide exactly 3 polygons, of which one is a closed polygon and two are isolated points"
	self assert: (visGraph polygons size = 3).
	
	"every vertex of the graph should be connected with every other vertex in this toy example"
	visGraph vertices do: [ :v |
		self assert: ( v neighbors size = 5).
	].
	
]

{ #category : #tests }
VMVisGraphTests >> testCreateVisGraph [
	| visGraph |
	
	visGraph := VMVisGraph fromMap:(VMMapFactory fromData: VMDataSet dataMap_5).
	
	"the map should provide exactly 1 polygon, which we then used to buid the graph"
	self assert: (visGraph polygons size = 1).
	
	"every vertex of the graph should be connected with every other vertex in this toy example"
	visGraph vertices do: [ :v |
		self assert: ( v neighbors size = 3).
	].
	
]

{ #category : #tests }
VMVisGraphTests >> testExtendedPolygons [
	| visGraph map infoStr vertexStr edgeStr |
	
	infoStr := '7 6 0.01'.
	vertexStr := '-1 -1 1 20 0 1 20 20 1 0 20 1',		"outter map boundary"
		' 15 5 1 10 7.5 1 5 7.5 1'.		"line segments"
	edgeStr := '1 2 2 3 3 4 4 1',
		' 5 6 6 7'.
	
	map := VMMapFactory fromStrings: infoStr vertices: vertexStr edges: edgeStr.
	
	visGraph := VMVisGraph fromMap: map.

	"the map should provide exactly 1 polygon, which we then used to buid the graph"
	self assert: visGraph polygons size equals: 1.
	
	"every vertex of the graph should be connected with every other vertex in this toy example"
	visGraph vertices do: [ :v |
		self assert: ( v neighbors size = 3).
	].
	
]
