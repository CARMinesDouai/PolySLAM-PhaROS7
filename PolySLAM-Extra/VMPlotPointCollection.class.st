Class {
	#name : #VMPlotPointCollection,
	#superclass : #VMPlotObject,
	#instVars : [
		'labelBlock',
		'labelColor',
		'pointSize',
		'colorBlock'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #accessing }
VMPlotPointCollection >> colorBlock: aBlockClosure [
	"supports up to two parameters:
		1) current Index (starting with 1)
		2) total number of points
	see #initialize for an example"
	colorBlock := aBlockClosure.
]

{ #category : #initialization }
VMPlotPointCollection >> initialize [
	super initialize.
	
	pointSize := 0.2.
	colorBlock := [ :index :size |
		Color
			h: (360 / (size + 1)) * index
			s: 1.0
			v: 1.0 ].
]

{ #category : #plotting }
VMPlotPointCollection >> plotParent: parent [
	| hue deltaHue |
	super plotParent: parent.
	
	hue := 0.0.
	deltaHue := 360 / (model size + 1).
	
	model doWithIndex: [ :point :index |
		self plotPointCollection: { point }
			extra: 'pointtype 7 pointsize ', pointSize printString,
				' lc rgb ''#', (colorBlock cull: index cull: model size) asHexString, ''' notitle'.
		hue := hue + deltaHue. ].
]
