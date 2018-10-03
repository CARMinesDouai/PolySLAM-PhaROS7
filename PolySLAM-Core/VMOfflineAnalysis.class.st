Class {
	#name : #VMOfflineAnalysis,
	#superclass : #Object,
	#instVars : [
		'offline',
		'start',
		'stop',
		'stepSize'
	],
	#category : #'PolySLAM-Core-Offline'
}

{ #category : #'as yet unclassified' }
VMOfflineAnalysis class >> offline: offlineObj start: startIndex stop: stopIndex by: by [
	^ self new
		offline: offlineObj start: startIndex stop: stopIndex by: by
]

{ #category : #'as yet unclassified' }
VMOfflineAnalysis >> loadOdomGt [
	| fullPath odomCollection |
	fullPath := offline fullPath.
	odomCollection := OrderedCollection new.
	
	
	start to: stop by: stepSize do: [ :i |
		odomCollection add: (FLMaterializer materializeFromFileNamed: fullPath, 'gtOdom_', (i printPaddedWith: $0 to: 4), '.VMTFMatrix.fuel').
	].
	
	^ odomCollection


]

{ #category : #'as yet unclassified' }
VMOfflineAnalysis >> loadOdomGtDelta [
	| fullPath lastOdom deltas |
	fullPath := offline fullPath.
	deltas := OrderedCollection new.
	
	lastOdom := FLMaterializer materializeFromFileNamed: fullPath, 'gtOdom_', (start printPaddedWith: $0 to: 4), '.VMTFMatrix.fuel'.
	
	start+stepSize to: stop by: stepSize do: [ :i |
		| odom |
		odom := (FLMaterializer materializeFromFileNamed: fullPath, 'gtOdom_', (i printPaddedWith: $0 to: 4), '.VMTFMatrix.fuel').
		deltas add: lastOdom inverse * odom.
		lastOdom := odom.
	].
	
	^ deltas


]

{ #category : #'as yet unclassified' }
VMOfflineAnalysis >> offline: offlineObj start: startIndex stop: stopIndex by: by [
	offline := offlineObj.
	start := startIndex.
	stop := stopIndex.
	stepSize := by.
]

{ #category : #'as yet unclassified' }
VMOfflineAnalysis >> poseError [
	| icpTF odomGt deltas |
	icpTF := offline icpTF.
	odomGt := self loadOdomGt.
	
	icpTF size = odomGt size
		ifFalse: [
			Transcript
				show: 'collection size mismatch: icpTF size=';
				show: icpTF size printString;
				show: ', gt size=';
				show: odomGt size printString;
				cr.
			^ self ].
	
	deltas := icpTF withIndexCollect: [ :iTF :index |
		iTF inverse * (odomGt at: index)
	].
	
	^ deltas.

]

{ #category : #'as yet unclassified' }
VMOfflineAnalysis >> savePoseErrorToFileNamed: filename [
	| errors |
	errors := self poseError.
	
]
