Class {
	#name : #PSPGridMapExample,
	#superclass : #Object,
	#instVars : [
		'path',
		'start',
		'goal',
		'data',
		'nodeCollection',
		'graph'
	],
	#category : #'PolySLAM-Papers-2019IntelliSys'
}

{ #category : #computing }
PSPGridMapExample >> buildNodes [
	| timeSpent |
	
	nodeCollection := OrderedCollection new.
	
	Transcript show: 'building nodes'; cr.
	timeSpent := [
		0 to: data height - 1 do:[:j|
		    0 to: data width -1 do:[:i|
		        (data pixelValueAt: i@j) >= 250 ifTrue:[
 		           data colorAt: i@j put: Color white.
 		           nodeCollection add: (VMGraphNode sector:(VMPolygon fromRectangle: ( Rectangle center: i@j extent: 2@2  ) )).
 		       ] ifFalse:[
 		           data colorAt: i@j put: Color black.
 		           nodeCollection add: nil ]. ]. ]. ] timeToRun.
	Transcript
		show: 'time spent on node building: ';
		show: timeSpent totalSeconds asFloat asTimeString;
		cr.
	
	^ nodeCollection
	
]

{ #category : #computing }
PSPGridMapExample >> checkGraph [
	nodeCollection := nodeCollection select: [ :e | e isNotNil ].
	graph:= VMGraph new addAll: nodeCollection; yourself.
	
	Transcript show: 'graph size='; show: graph size printString; cr.
	graph := (VMConnectedGraphs compute: graph) first.
	Transcript show: 'connected graph size='; show: graph size printString; cr.

]

{ #category : #computing }
PSPGridMapExample >> computePath [
	| timeSpent |
	
	timeSpent := [
		path := VMPathSearch compute: graph from: start to: goal. ] timeToRun.
	Transcript
		show: 'time spent on graph search: ';
		show: timeSpent totalSeconds asFloat asTimeString;
		cr.

]

{ #category : #computing }
PSPGridMapExample >> connectingNeighbors [
	| getv addnb timeSpent centerNode neighborNode |
	getv := [ :i :j | nodeCollection at:(j* data width) + i + 1 ifAbsent: [nil] ].
	addnb := [ :nodeA :nodeB |
		(nodeA isNotNil  & nodeB isNotNil) ifTrue: [
 			nodeA neighbors add: nodeB ]].

	Transcript show: 'connecting neighbors'; cr.
	timeSpent := [
	0 to: data height - 1 do:[:j|
		"Transcript show: j printString; show: ' '."
	    0 to: data width -1 do:[:i|
	        (data pixelValueAt: i@j) >= 250 ifTrue:[
	                centerNode := getv value:i value:j.
	                neighborNode :=     getv value:i value:j+1.
	                addnb value: centerNode value: neighborNode.
	                neighborNode :=     getv value:i value:j-1.
	                addnb value: centerNode value: neighborNode.
	                neighborNode :=     getv value:i+1 value:j.
	                addnb value: centerNode value: neighborNode.
	                neighborNode :=     getv value:i-1 value:j.
	                addnb value: centerNode value: neighborNode.
	                neighborNode :=     getv value:i+1 value:j-1.
	                addnb value: centerNode value: neighborNode.
	                neighborNode :=     getv value:i-1 value:j+1.
	                addnb value: centerNode value: neighborNode.
	                neighborNode :=     getv value:i+1 value:j+1.
	                addnb value: centerNode value: neighborNode.                
	                neighborNode :=     getv value:i-1 value:j-1.
	                addnb value: centerNode value: neighborNode. ]]]]timeToRun.
	Transcript "cr;"
		show: 'time spent on connecting neighbors: ';
		show: timeSpent totalSeconds asFloat asTimeString;
		cr.

]

{ #category : #acccessing }
PSPGridMapExample >> getNodeX: x y: y [
	^ nodeCollection at:(x* data width) + y + 1 ifAbsent: [nil]
]

{ #category : #plotting }
PSPGridMapExample >> plot [
	| timeSpent |
	timeSpent := [(VMPlotter new)
	   backend: #OSSubprocess; "system backend does not work for me"
	   range: (0 @ 0 extent: 320 @ 320); "area to be plotted"
	   setRatio: -1; "keep aspect ratio as 1:1"
	   plotBackground; "gray background, remove if you want white background"
	   "plotChild: (VMPlotPolygonCollection model: map asVMPolygonCollection);"
	   "plotChild: (VMPlotGridStorage model: map);"
	   "plotChild: (VMPlotBSPTree model: map);" "if map is a BSP-Tree instead of a PolyGridMap"
	   "plotChild: ((VMPlotGraph model: graph) nodeSize: 0.15; nodeColor: (Color r: 1 g: 0.667 b: 1); edgeColor: (Color r: 1 g: 0.8 b: 1));"
	   plotChild: ((VMPlotSearchPath model: path) lineWidth: 2);
	   plotChild: (VMPlotPointTarget model: start asPoint);
	   plotChild: (VMPlotPointTarget model: goal asPoint);
	   "setTerminal: 'eps size 20.0,32.0 enhanced font ''Arial.ttf,14''' filename: '/opt/shared/developer/data/plots/officeGraphOccupancyGrid.eps';"
		setTerminal: 'png size 1000,1000 enhanced font ''Arial.ttf,18''' filename: '/opt/shared/developer/data/plots/testOffice_graphGridMap2.png';
	   "addInitLine: 'set term qt size 900,900 enhanced';"
	   plot. 

	] timeToRun.

	Transcript
		show: 'time spent on plotting: ';
		show: timeSpent totalSeconds asFloat asTimeString;
		cr.

]

{ #category : #reading }
PSPGridMapExample >> readGridMap [
	| fullFilename timeSpent |
	
	fullFilename := '/opt/shared/developer/data/grid_maps/officeMap_mini.png'.
	timeSpent := [
		data := fullFilename asFileReference binaryReadStreamDo: [ :stream| PNGReadWriter formFromStream: stream ]. ] timeToRun.
	
	Transcript
		show: 'opened file=';
		show: fullFilename;
		show: ' (';
		show: timeSpent printTotalSeconds;
		show: ')'; cr.
	Transcript
		show: '  width=';
		show: data width printString;
		show: ', height=';
		show: data height printString;
		cr.
	
	^ data

]

{ #category : #running }
PSPGridMapExample >> run [
	self readGridMap.
	self buildNodes.
	self connectingNeighbors.
	self checkGraph.

	start := self getNodeX: 87 y: 293.
	goal := self getNodeX: 110 y: 12.
	"start := self getNodeX: 20 y: 50.
	goal := self getNodeX: 45 y: 5."
	self computePath.
	
	path printStats.

	self plot.

]
