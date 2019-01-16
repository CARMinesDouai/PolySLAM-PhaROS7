Class {
	#name : #VMGridStorageExamples,
	#superclass : #Object,
	#category : #'PolySLAM-Extra-Examples'
}

{ #category : #'as yet unclassified' }
VMGridStorageExamples class >> examplePlot [
	| polygon grid builder graph |
	polygon := VMPolygon
		fromPoints: { 0.1@0.5.  0.3@0.5.  0.5@1.2.  0.7@0.3.  0.9@0.3.  0.9@1.5.  0.1@1.5 }
		withTypes: { 1.  1.  1.  1.  1.  1.  1 }.
	grid := VMGridStorage gridSize: 1.0 cellClass: VMGridCellBSP.
	grid insert: polygon.
	builder := VMGraphBuilder new.
	graph := builder loopOverGrid: grid.

	VMPlotter new
		range: (0 @ 0 extent: 1 @ 2);
		setRatio: -1;
		plotBackground;
		"plotChild: (VMPlotPolygonCollection model: result);"
		plotChild: (VMPlotGridStorage model: grid);
		plotChild: (VMPlotGraph model: graph);
		addInitLine: 'set term qt size 600,600 enhanced';
		plot.


]

{ #category : #'as yet unclassified' }
VMGridStorageExamples class >> examplePlot2 [
	| polygon grid builder graph |
	
	polygon := VMPolygon
		fromPoints: { 0.5@0.5.  1.9@0.5.  1.9@1.9.  0.5@1.9. }
		withTypes: { 1.  1.  1.  1. }.
	grid := VMGridStorage gridSize: 1.2 cellClass: VMGridCellBSP.
	grid insert: polygon.
	builder := VMGraphBuilder new.
	graph := builder loopOverGrid: grid.
	
	
	VMPlotter new
		range: (0 @ 0 extent: 2 @ 2);
		setRatio: -1;
		plotBackground;
		"plotChild: (VMPlotPolygonCollection model: result);"
		plotChild: (VMPlotGridStorage model: grid);
		plotChild: (VMPlotGraph model: graph);
		addInitLine: 'set term qt size 600,600 enhanced';
		plot.


]
