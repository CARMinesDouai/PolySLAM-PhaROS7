Class {
	#name : #VMFullOfflineSLAM,
	#superclass : #Object,
	#instVars : [
		'offline'
	],
	#category : #'PolySLAM-Papers-ThesisDichtl'
}

{ #category : #initialization }
VMFullOfflineSLAM >> initialize [
	super initialize.
	
	offline := VMOffline new.
]

{ #category : #'as yet unclassified' }
VMFullOfflineSLAM >> plotNNC [
	| bounds path filename |
	
	path := '/opt/shared/developer/data/plots/'.
	filename := 'experiment_', offline path asFileName.
	
	bounds := offline nnc bounds expandBy: 0.8.
	(VMPlotter new)
	   backend: #OSSubprocess;
	   range: bounds;
	   setRatio: -1;
		"title: titleString;"
		plotBackground;
		plotChild: (VMPlotBackgroundGrid new);
	   plotChild: (VMPlotVectorCollection model: offline nnc addedVectors);
		setTerminal: 'eps size 10.0,16.0 enhanced font ''Arial.ttf,34''' filename: path,filename, '.eps';
		"setTerminal: 'png size 2000,2000 enhanced font ''Arial.ttf,24''' filename: path,filename, '.png';"
		"addInitLine: 'set term qt size 900,900 enhanced';"
		plot.


]

{ #category : #running }
VMFullOfflineSLAM >> run [
	{
		"{'benchmark_loop/1/'. 2.  1445. 2.}."
		{'benchmark_cross/1/'. 2.  2820. 2.}.
		"{'benchmark_maze/1/'. 2.  4683. 2.}."
		"{'benchmark_zigzag/1/'. 2.  3580. 2.}."
		"{'benchmark_wg/1/'. 2.  5100. 2.}."
	} do: [ :dataSet |
		self runPath: dataSet first from: dataSet second to: dataSet third by: dataSet fourth.
	].

]

{ #category : #running }
VMFullOfflineSLAM >> runPath: dataPath from: startIndex to: endIndex by: stepSize [
	| timeSpentOnICP timeSpentOnMapping |
	offline := (VMOffline new).
	timeSpentOnICP := [
		offline
			"offsetTF: (VMTFMatrix angle: Float halfPi translation: 0@0);"
			obstacleDistance: 0.1;
			nnc: VMNNVectorGrid new;
			simplifierThreshold: 0.02 squared.
		(offline icp)
			outlierThresholdFalloff: 0.9;
			outlierStartThreshold: 0.15;"0.73"
			maxIterations: 40.
		offline runICPFrom: startIndex to: endIndex by: stepSize path: dataPath.
	] timeToRun.
	Transcript show: 'time spend on ICP: '; show: timeSpentOnICP totalSeconds asTimeString; show: ' (', offline path, ')'; cr.
	offline fullSave: '/opt/shared/developer/data/offline_objects/experiment_'.(DateAndTime new asUnixTime printString).'.fuel'.
	
	self plotNNC.
	offline nnc: nil.
	Smalltalk garbageCollect.

	timeSpentOnMapping := [
		offline map: ((VMGridStorage gridSize: 4.0) cellClass: VMGridCellBSP; yourself).
		offline buildWithProgressBarFrom: startIndex to: endIndex by: stepSize * 2 tfStepSize: stepSize.
	] timeToRun.
	Transcript show: 'time spend on mapping: '; show: timeSpentOnMapping totalSeconds asFloat asTimeString; show: ' (', offline path, ')'; cr.
	offline map printStats.


]
