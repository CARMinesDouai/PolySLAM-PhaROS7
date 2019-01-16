Class {
	#name : #VMPlotPolygonSimplifier,
	#superclass : #VMPlotObject,
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #plotting }
VMPlotPolygonSimplifier >> plotInputPolygon [
	self plotFilledPolygon: model input extra: 'lc rgb ''#FFFFFF'''.
	self plotTypedVectorCollection: model input.
]

{ #category : #plotting }
VMPlotPolygonSimplifier >> plotParent: parentPlotter [
	| size color hue |
	super plotParent: parentPlotter.
	
	self plotInputPolygon.
	
	size := model resultCollection size.
	
	model resultCollection doWithIndex: [ :result :index |
		hue := 360 * index / size.
		color := Color h: hue s: 1.0 v: 1.0.
		self plotVectorCollection: {(model result at: index)} extra: 'lc rgb ''#CC', color asHexString , ''' lw 8 nohead t '''''.
		self plotLabel: index printString at: (model result at: index) center color: color.
	].

	self plotResultPolygon.
	

]

{ #category : #plotting }
VMPlotPolygonSimplifier >> plotResultPolygon [
	| polygon |
	polygon := model result.
	polygon ifNil: [ ^self ].
	
	self plotVectorCollection: polygon extra: 'lt 1 lw ', (lineWidth) printString, ' lc rgb ''#FF00FF'' notitle'
	
]
