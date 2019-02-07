Class {
	#name : #VMPlotPointCollection,
	#superclass : #VMPlotObject,
	#instVars : [
		'labelBlock',
		'labelColor',
		'pointSize'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #initialization }
VMPlotPointCollection >> initialize [
	super initialize.
	
	pointSize := 0.2.
]

{ #category : #plotting }
VMPlotPointCollection >> plotParent: parent [
	| hue deltaHue |
	super plotParent: parent.
	
	hue := 0.0.
	deltaHue := 360 / (model size + 1).
	
	model do: [ :point |
		self plotPointCollection: { point }
			extra: 'pointtype 7 pointsize ', pointSize printString,
				' lc rgb ''#', (Color h: hue s: 1.0 v: 1.0) asHexString, ''' notitle'.
		hue := hue + deltaHue. ].
]
