Class {
	#name : #VMPlotSearchPath,
	#superclass : #VMPlotObject,
	#instVars : [
		'color',
		'nodeSize',
		'nodeColor'
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
	color := Color blue.
	
	nodeColor := Color r: 1 g: 0 b: 1.
	nodeSize := 0.75.

]

{ #category : #accessing }
VMPlotSearchPath >> nodeColor [
	^ nodeColor
]

{ #category : #accessing }
VMPlotSearchPath >> nodeColor: aColor [
	nodeColor := aColor.
]

{ #category : #accessing }
VMPlotSearchPath >> nodeSize [
	^ nodeSize
]

{ #category : #accessing }
VMPlotSearchPath >> nodeSize: float [
	nodeSize := float.
]

{ #category : #plotting }
VMPlotSearchPath >> plotParent: parent [
	| node allEdges allNodes |
	super plotParent: parent.
	
	node := model.
	allEdges := OrderedCollection new.
	allNodes := OrderedCollection new.
	
	allNodes add: node vertex asPoint.
	
	[ node prev isNotNil ] whileTrue: [
		allEdges add: (node vertex asPoint vectorTo: node prev vertex asPoint).
		allNodes add: node prev vertex asPoint.
		node := node prev.
	].
	
	self plotVectorCollection: allEdges extra: 'lt 1 dt 3 lw ', lineWidth printString, ' lc rgb ''#', color asHexString ,''' nohead notitle'.
	self plotPointCollection: allNodes
		extra: 'pointtype 7 pointsize ', nodeSize printString ,' lc rgb ''#', nodeColor asHexString, ''' notitle'


]
