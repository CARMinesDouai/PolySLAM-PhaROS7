Class {
	#name : #VMPointCollectionPlotter,
	#superclass : #VMPlotter,
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #'as yet unclassified' }
VMPointCollectionPlotter >> plotOn: aSubProcess [
	self plotPointCollection: model
]
