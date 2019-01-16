Class {
	#name : #VMPlotSearchPath,
	#superclass : #VMPlotObject,
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

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
	
	self plotVectorCollection: edges extra: 'lt 1 dt 3 lw ', lineWidth printString, ' lc rgb ''#', Color orange asHexString ,''' nohead notitle'.

]
