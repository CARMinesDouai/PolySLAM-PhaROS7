Class {
	#name : #VMVectorCollectionPlotter,
	#superclass : #VMPlotter,
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #'as yet unclassified' }
VMVectorCollectionPlotter >> plotOn: aSubProcess [
	self plotArrowCollection: model.
	"self plotOn: aSubProcess vectorCollection: model."
	
]
