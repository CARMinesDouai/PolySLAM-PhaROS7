"
The VMPlotObject class is meant to plot 'complex' data sets that go beyond a single line of code. They are added to a VMPlotter instance via #plotChild:


EXAMPLE:
	""plot a topological graph of a small simple map""
	
	root := VMBSPNode parent: nil plane: (VMLine pointA: 0@0 pointB: 0.8@2).
	root leftChild: (VMBSPNode parent: root plane: (VMLine pointA: -2@2.1 pointB: 0@2.1)).
	root rightChild: (VMBSPNode parent: root plane: (VMLine pointA: 0@0 pointB: 1.5@ -0.4)).
	root rightChild rightChild: (VMBSPNode parent: root rightChild plane: (VMLine pointA: 2@0 pointB: 2@ -1)).

	polygon := VMPolygon fromRectangle: (-3@ -3 extent: 6@6).
	polygon do: [:v|v type: 1].

	root insert: polygon.
	polyCollection := root asCollectionOfSectors.
	graph := VMGraphBuilder new buildGraph: root.

	(VMPlotter new)
		range: (-4 @ -4 extent: 8 @ 8);
		setRatio: -1;
		plotBackground;
		plotChild: (VMPlotPolygonCollection model: root asCollectionOfSectors);
		plotChild: (VMPlotGraph model: graph);
		plot.
"
Class {
	#name : #VMPlotObject,
	#superclass : #Object,
	#instVars : [
		'model',
		'lineWidth',
		'plotter'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #constructing }
VMPlotObject class >> model: anObject [
	^ self new
		model: anObject;
		yourself
]

{ #category : #accessing }
VMPlotObject >> cmdStream [
	^ plotter cmdStream
]

{ #category : #accessing }
VMPlotObject >> dataStream [
	^ plotter dataStream
]

{ #category : #accessing }
VMPlotObject >> initStream [
	^ plotter initStream
]

{ #category : #initialization }
VMPlotObject >> initialize [
	super initialize.
	lineWidth := 1.

]

{ #category : #accessing }
VMPlotObject >> lineWidth [
	^ lineWidth
]

{ #category : #accessing }
VMPlotObject >> lineWidth: aNumber [
	lineWidth := aNumber.
]

{ #category : #accessing }
VMPlotObject >> model [
	^ model
]

{ #category : #accessing }
VMPlotObject >> model: anObject [
	model := anObject.
]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotObject >> plotFilledPolygon: polygon [
	"note: the polygon outline is not plottet, only the interior"
	^ self plotFilledPolygon: polygon extra: 'lc rgb "#FFFFFF"'.


]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotObject >> plotFilledPolygon: polygon extra: extraString [
	"note: the polygon outline is not plottet, only the interior"
	self cmdStream
		nextPutAll: (self cmdStream isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', ''-'' ' ]);
		nextPutAll: 'using 1:2 with filledcurves closed notitle ';
		nextPutAll: extraString.

	polygon do: [ :vec |
		self dataStream
			nextPutAll: vec pointA x printString;
			nextPutAll: ' ';
			nextPutAll: vec pointA y printString;
			crlf.
	].
	self dataStream nextPutAll: 'e'; crlf.

]

{ #category : #plotting }
VMPlotObject >> plotParent: parentPlotter [
	plotter := parentPlotter.
]

{ #category : #'plotting - helper - points & dots' }
VMPlotObject >> plotPointCollection: aCollection [
	
	^ self plotPointCollection: aCollection extra: 'pointtype 7 pointsize 0.33 notitle'

]

{ #category : #'plotting - helper - points & dots' }
VMPlotObject >> plotPointCollection: aCollection extra: extraString [
	"note:
		pointtype 1: +      pointtype 6: hollow circle
		pointtype 2: x      pointtype 7: solid circle
	"
	self cmdStream
		nextPutAll: (self cmdStream isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', "" ' ]);
		nextPutAll: 'using 1:2 with points ';
		nextPutAll: extraString.
	
	aCollection do: [ :aPoint |
		self dataStream
			nextPutAll: aPoint x printString;
			nextPutAll: ' ';
			nextPutAll: aPoint y printString;
			crlf.	].
	
	self dataStream nextPutAll: 'e'; crlf.

]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotObject >> plotVectorCollection: aCollection [
	
	"^ self plotVectorCollection: aCollection extra: 'lc rgb ''black'' nohead notitle lw ', self lineWidth printString."
	^ self plotVectorCollection: aCollection extra: 'lt 1 lw ', lineWidth printString, ' lc rgb ''black'' nohead notitle'.

]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotObject >> plotVectorCollection: aCollection color: aColor [
	
	^ self plotVectorCollection: aCollection extra: 'lt 1 lw ', lineWidth printString, ' lc rgb ''#', aColor asHexString ,''' nohead notitle'.

]

{ #category : #'plotting - helper - vectors & vector collections' }
VMPlotObject >> plotVectorCollection: aCollection extra: extraString [
	
	self cmdStream
		nextPutAll: (self cmdStream isEmpty ifTrue: [ 'plot ''-'' '] ifFalse: [ ', ''-'' ' ]);
		nextPutAll: 'using 1:2:3:4 with vectors ';
		nextPutAll: extraString.

	aCollection doWithIndex: [ :vec :index |
		self dataStream
			nextPutAll: vec pointA x printString;
			nextPutAll: ' ';
			nextPutAll: vec pointA y printString;
			nextPutAll: ' ';
			nextPutAll: vec direction x printString;
			nextPutAll: ' ';
			nextPutAll: vec direction y printString;
			crlf.].
	
	self dataStream nextPutAll: 'e'; crlf.

]
