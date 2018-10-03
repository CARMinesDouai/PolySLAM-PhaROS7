Class {
	#name : #VMPointCloudPlotter,
	#superclass : #VMPlotter,
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #'as yet unclassified' }
VMPointCloudPlotter >> multiPlot [
	| process |
	
	process := self plotInit.
	
	self multiplotSetup: process.
	
	self plotLaserOn: process.
	self plotExec: process.
	self stringStreamReset.
	
	self plotPolygonOn: process.
	self plotExec: process.
	self stringStreamReset.
	
	self plotSimplePolygonOn: process.
	self plotExec: process.
	self stringStreamReset.
	
	self multiplotFinish: process.
	
	self plotFinish: process.


]

{ #category : #'as yet unclassified' }
VMPointCloudPlotter >> multiplotFinish: process [
	
	process stdinStream
		nextPutAll: 'unset multiplot';
		nextPutAll: crlf.
]

{ #category : #'as yet unclassified' }
VMPointCloudPlotter >> multiplotSetup: process [
	
	process stdinStream
		nextPutAll: ' set multiplot layout 1,3';
		nextPutAll: crlf.
]

{ #category : #'as yet unclassified' }
VMPointCloudPlotter >> plotLaserOn: process [
	self plotLasers: model.
]

{ #category : #plotting }
VMPointCloudPlotter >> plotOn: aSubProcess [
	self plotLasers: model.
	self plotPointCollection: model points color: Color red.
	"self plotSensor: VMTFMatrix identity."
	
]

{ #category : #'as yet unclassified' }
VMPointCloudPlotter >> plotPolygonOn: process [
	| map polygons |
	
	map := VMLocalMap new fromPointCloud: model tf: VMTFMatrix identity.
	polygons := map asPolygonCollection.
	
	self plotVectorCollection: polygons first.
]

{ #category : #'as yet unclassified' }
VMPointCloudPlotter >> plotSimplePolygonOn: process [
	| map polygons simplePolygon |
	
	map := VMLocalMap new fromPointCloud: model tf: VMTFMatrix identity.
	polygons := map asPolygonCollection.
	simplePolygon := (VMVectorCollectionSimplifier compute: polygons first) result.
	
	self plotVectorCollection: simplePolygon.

]

{ #category : #'as yet unclassified' }
VMPointCloudPlotter >> stringStreamReset [
	self printDebug.
	plotCmd resetToStart.
	plotData resetToStart.
]
