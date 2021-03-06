"
Plots a polygon collection. The polygons are filled with white color, obstacles are painted in black.
"
Class {
	#name : #VMPlotPolygonCollection,
	#superclass : #VMPlotObject,
	#instVars : [
		'showLabels',
		'labelColor',
		'showSectors',
		'showFrontiers'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #initialization }
VMPlotPolygonCollection >> initialize [
	super initialize.
	showLabels := false.
	showFrontiers := true.
	showSectors := true.
	labelColor := Color blue.
]

{ #category : #accessing }
VMPlotPolygonCollection >> plotFrontiers [
	showFrontiers ifFalse: [ ^ self ].
	model do: [ :polygon |
		self plotVectorCollection: (polygon select: [ :v | v isFrontier ]) color: Color green ].

]

{ #category : #accessing }
VMPlotPolygonCollection >> plotObstacles [
	model do: [ :polygon |
		self plotVectorCollection: (polygon select: [ :v | v isObstacle ]) ].

]

{ #category : #plotting }
VMPlotPolygonCollection >> plotParent: parentPlotter [
	super plotParent: parentPlotter.
	
	model doWithIndex: [ :polygon :index |
		self plotFilledPolygon: polygon.
		showLabels ifTrue: [
			self plotLabel: index printString at: polygon centroid color: labelColor ].
		].
	
	self plotSectors.
	self plotObstacles.
	self plotFrontiers.
	

]

{ #category : #accessing }
VMPlotPolygonCollection >> plotSectors [
	showSectors ifFalse: [ ^self ].
	model do: [ :polygon |
		self plotVectorCollection: (polygon select: [ :v | v isSector ]) color: (Color r:0.95 g:0.85 b:0) ].

]

{ #category : #accessing }
VMPlotPolygonCollection >> showFrontiers [
	^ showFrontiers
]

{ #category : #accessing }
VMPlotPolygonCollection >> showFrontiers: boolean [
	showFrontiers := boolean.
]

{ #category : #accessing }
VMPlotPolygonCollection >> showLabels [
	^ showLabels
]

{ #category : #accessing }
VMPlotPolygonCollection >> showLabels: boolean [
	showLabels := boolean.
]

{ #category : #accessing }
VMPlotPolygonCollection >> showSectors [
	^ showSectors
]

{ #category : #accessing }
VMPlotPolygonCollection >> showSectors: boolean [
	showSectors := boolean.
]
