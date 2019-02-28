Class {
	#name : #VMPlotBackgroundGrid,
	#superclass : #VMPlotObject,
	#instVars : [
		'colorBackground',
		'colorMajor',
		'colorMinor',
		'sizeMajor',
		'sizeMinor'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #initialization }
VMPlotBackgroundGrid >> initialize [
	super initialize.
	
	colorBackground := Color fromHexString: 'CCCCCC'.
	colorMajor := Color fromHexString: '999999'.
	colorMinor := Color fromHexString: 'AAAAAA'.
	
	sizeMajor := 1.0. "meters"
	sizeMinor := nil. "nil = don't show minor grid lines"
]

{ #category : #plotting }
VMPlotBackgroundGrid >> plotBackground [
	colorBackground ifNil: [ ^ self ].
	
	self plotFilledPolygon: (VMPolygon fromRectangle: plotter range)
		extra: 'lc rgb "#', colorBackground asHexString ,'"'.
]

{ #category : #plotting }
VMPlotBackgroundGrid >> plotGrid: range [
	| vectors |
	vectors := VMRenderCollection new.
	range left to: range right by: sizeMajor do: [ :x |
		vectors add: (x @ range top vectorTo: x @  range bottom). ].
	
	range top to: range bottom by: sizeMajor do: [ :y |
		vectors add: (range left @ y vectorTo: range right @ y). ].
	
	self plotVectorCollection: vectors color: colorMajor.

]

{ #category : #plotting }
VMPlotBackgroundGrid >> plotParent: parent [
	| range newRange |
	super plotParent: parent.
	
	range := plotter range.
	newRange := VMRectangle
		point: (((range left // sizeMajor) - 1) * sizeMajor) @
			(((range top // sizeMajor) - 1) * sizeMajor)
		point: (((range right // sizeMajor) + 1) * sizeMajor) @
			(((range bottom // sizeMajor) + 1) * sizeMajor).
	
	self plotGrid: newRange.
]
