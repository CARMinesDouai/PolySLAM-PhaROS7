"
Plots a topological graph. Default colors are pink.
"
Class {
	#name : #VMPlotGraph,
	#superclass : #VMPlotObject,
	#instVars : [
		'nodeColor',
		'edgeColor'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #accessing }
VMPlotGraph >> edgeColor [
	^ edgeColor

]

{ #category : #accessing }
VMPlotGraph >> edgeColor: aColor [
	edgeColor := aColor.

]

{ #category : #initialization }
VMPlotGraph >> initialize [
	super initialize.
	
	nodeColor := Color r: 1 g: 0 b: 1.
	edgeColor := Color r: 1 g: 0.5 b: 1.

]

{ #category : #accessing }
VMPlotGraph >> nodeColor [
	^ nodeColor
]

{ #category : #accessing }
VMPlotGraph >> nodeColor: aColor [
	nodeColor := aColor
]

{ #category : #plotting }
VMPlotGraph >> plotParent: parent [
	| edges points nodeSet |
	super plotParent: parent.
	
	nodeSet := Set new.
	edges := OrderedCollection new.
	
	model do: [ :node |
		nodeSet add: node.
		node neighbors do: [ :neighbor |
			(nodeSet includes: neighbor)
				ifFalse: [
					edges add: (node center vectorTo: neighbor center) ]. ]. ].
	
	self plotVectorCollection: edges color: edgeColor.
	
	points := model collect: [ :node |
		node center ].
	
	self plotPointCollection: points extra: 'pointtype 7 pointsize 0.75 lc rgb ''#', nodeColor asHexString, ''' notitle'

]
