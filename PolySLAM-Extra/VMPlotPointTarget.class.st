Class {
	#name : #VMPlotPointTarget,
	#superclass : #VMPlotObject,
	#instVars : [
		'labelText',
		'labelOffset',
		'pointColor'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #accessing }
VMPlotPointTarget >> color [
	^ pointColor
]

{ #category : #accessing }
VMPlotPointTarget >> color: aColor [
	pointColor := aColor.
]

{ #category : #initialization }
VMPlotPointTarget >> initialize [
	super initialize.
	pointColor := Color blue.
]

{ #category : #accessing }
VMPlotPointTarget >> label: text offset: aPoint [
	labelText := text.
	labelOffset := aPoint.
]

{ #category : #accessing }
VMPlotPointTarget >> labelOffset [
	^ labelOffset
]

{ #category : #accessing }
VMPlotPointTarget >> labelOffset: aPoint [
	labelOffset := aPoint.
]

{ #category : #accessing }
VMPlotPointTarget >> labelText [
	^ labelText
]

{ #category : #accessing }
VMPlotPointTarget >> labelText: text [
	labelText := text.
]

{ #category : #plotting }
VMPlotPointTarget >> plotParent: parent [
	super plotParent: parent.
	
	self plotPointCollection: { model } extra: 'pointtype 6 pointsize 1.33 lc rgb ''#', pointColor asHexString, ''' lw 2 notitle'.
	labelText ifNotNil: [
		| offset |
		offset := labelOffset.
		offset ifNil: [ offset := 0@0. ].
		self plotLabel: labelText at: (model + offset).
	].
	

]
