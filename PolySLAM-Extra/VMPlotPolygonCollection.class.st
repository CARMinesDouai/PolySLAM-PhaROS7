"
Plots a polygon collection. The polygons are filled with white color, obstacles are painted in black.
"
Class {
	#name : #VMPlotPolygonCollection,
	#superclass : #VMPlotObject,
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #accessing }
VMPlotPolygonCollection >> plotFrontiers [
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
	
	model do: [ :polygon |
		self plotFilledPolygon: polygon. ].
	
	self plotSectors.
	self plotObstacles.
	self plotFrontiers.
	

]

{ #category : #accessing }
VMPlotPolygonCollection >> plotSectors [
	model do: [ :polygon |
		self plotVectorCollection: (polygon select: [ :v | v isSector ]) color: (Color r:0.95 g:0.85 b:0) ].

]
