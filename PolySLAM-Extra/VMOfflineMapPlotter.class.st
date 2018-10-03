Class {
	#name : #VMOfflineMapPlotter,
	#superclass : #VMPlotter,
	#instVars : [
		'startIndex',
		'stepSize',
		'stopIndex'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #plotting }
VMOfflineMapPlotter >> plotOn: aSubProcess [
	startIndex ifNil: [ startIndex := 2. ].
	stepSize ifNil: [ stepSize := 2. ].
	stopIndex ifNil: [ stopIndex := model icpTF size - startIndex / stepSize. ].
	
	self
		setRatio: -1;
		plotBackground; "gray background"
		plotPolygonsOffline: model from: startIndex to: stopIndex by: stepSize; "explored area in white"
		plotHeadlessArrowCollection2: model nnc addedVectors; "obstacles in from nearest-neighbor collection in black"
		plotPoseCollection: model icpTF rainbowFrom: 0.0 to: 680 pointSize: 0.3. "trajectory in color array"
		"title: offline paramString,
			'\ndistance traveled=', (offline distanceTraveled round: 1) printString;
		setTerminal: 'eps size 10.0,16.0 enhanced font ''Arial.ttf,30''' filename: '/opt/shared/developer/data/plots/foobar.eps'".

]

{ #category : #accessing }
VMOfflineMapPlotter >> start: start stop: stop by: by [
	self startIndex: start.
	self stopIndex: stop.
	self stepSize: by.
]

{ #category : #accessing }
VMOfflineMapPlotter >> startIndex [
	^ startIndex
]

{ #category : #accessing }
VMOfflineMapPlotter >> startIndex: anInteger [
	startIndex := anInteger.
]

{ #category : #accessing }
VMOfflineMapPlotter >> stepSize [
	^ stepSize
]

{ #category : #accessing }
VMOfflineMapPlotter >> stepSize: anInteger [
	stepSize := anInteger
]

{ #category : #accessing }
VMOfflineMapPlotter >> stopIndex [
	^ stopIndex
]

{ #category : #accessing }
VMOfflineMapPlotter >> stopIndex: anInteger [
	stopIndex := anInteger.
]
