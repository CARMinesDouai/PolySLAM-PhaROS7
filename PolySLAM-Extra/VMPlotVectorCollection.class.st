Class {
	#name : #VMPlotVectorCollection,
	#superclass : #VMPlotObject,
	#instVars : [
		'color'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #initialization }
VMPlotVectorCollection >> initialize [
	super initialize.
	color := Color black.
]

{ #category : #plotting }
VMPlotVectorCollection >> plotParent: parent [
	super plotParent: parent.
	
	self plotVectorCollection: model color: color

]
