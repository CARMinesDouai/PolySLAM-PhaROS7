Class {
	#name : #VMPlotSearchPath,
	#superclass : #VMPlotObject,
	#instVars : [
		'color'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #accessing }
VMPlotSearchPath >> color [
	^ color
]

{ #category : #accessing }
VMPlotSearchPath >> color: aColor [
	color := aColor.
]

{ #category : #initialization }
VMPlotSearchPath >> initialize [
	super initialize.
	color := Color orange.
]

{ #category : #plotting }
VMPlotSearchPath >> plotParent: parent [
	| node edges |
	super plotParent: parent.
	
	node := model.
	edges := OrderedCollection new.
	
	[ node prev isNotNil ] whileTrue: [
		edges add: (node vertex asPoint vectorTo: node prev vertex asPoint).
		node := node prev.
	].
	
	self plotVectorCollection: edges extra: 'lt 1 dt 3 lw ', lineWidth printString, ' lc rgb ''#', color asHexString ,''' nohead notitle'.

]
