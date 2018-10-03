Class {
	#name : #VMExampleLevelOfDetailPlotter,
	#superclass : #VMPlotter,
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #plotting }
VMExampleLevelOfDetailPlotter >> plotOn: aSubProcess [
	
	range ifNotNil: [ self plotFilledPolygon: (VMPolygon fromRectangle: range) extra: 'lc rgb "#CCCCCC"' ].
	
	self plotFilledPolygon: model extra: 'lc rgb "#ffffff"'.
	self plotArrowCollection: model.
]
