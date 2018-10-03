Class {
	#name : #VMOfflineLight,
	#superclass : #VMProtoOffline,
	#instVars : [
		'odomGT',
		'map'
	],
	#category : #'PolySLAM-Core-Offline'
}

{ #category : #'map building' }
VMOfflineLight >> buildMapFrom: startIndex to: endIndex [
	^ self buildMapFrom: startIndex to: endIndex by: 1
]

{ #category : #'map building' }
VMOfflineLight >> buildMapFrom: startIndex to: endIndex by: stepSize [
	| polygon |
	
	Transcript show: 'building map from:', startIndex printString, ' to:', endIndex printString, ' by:', stepSize printString; cr.
	
	map ifNil: [ map := VMBSPLeaf new. ].
	startIndex to: endIndex by: stepSize do: [ :index |
		"polygon := (polygons at: index) transform: (icpTF at:index)."
		polygon := (self polygonAt: index) transform: (icpTF at:index).
		polygon := (VMVectorCollectionSimplifier compute: polygon inlierThreshold: simplifierThreshold) result.
		
		[
			VMBSPLeaf new insert: polygon.
			map := map insert: polygon.
		] on: Error do: [Transcript show: 'failed at index='; show: index printString; cr.].
	].
]

{ #category : #accessing }
VMOfflineLight >> distanceTraveled [
	^ self distanceTraveledFrom: 1 to: icpTF size
]

{ #category : #accessing }
VMOfflineLight >> distanceTraveledFrom: start to: end [
	"distance traveled fron start index to end index"
	| dist |
	dist := 0.0.
	
	start < 1 ifTrue: [ self error: 'invalid start index - must be greater than 0' ].
	end > icpTF size ifTrue: [ self error: 'invalid end index must not be greater than collection size (', icpTF size printString, ')' ].
	start >= end ifTrue: [ self error: 'end index must be greater than start index' ].
	
	start to: end -1 do: [ :index |
		| delta |
		delta := (icpTF at: index) inverse * (icpTF at: (index + 1)).
		dist := dist + (delta length).
	].
	^ dist
]

{ #category : #icp }
VMOfflineLight >> icpLoopIterationAt: index lastData: lastData [
	"loads the next piece of data and computes deltaOdom (with or without
	extra noise added) and calls #icpLoopIterationWithData:"
	| data lastOdom fullPath |
	
	lastOdom := lastData at: #odom.
	fullPath := pathPrefix, path.
	data := self loadDataAt: index path: fullPath.
	data at: #odomDelta put:
		(noiseGen isNil
			ifTrue: [ lastOdom inverse * (data at: #odom) ]
			ifFalse: [ lastOdom inverse * (data at: #odom) * noiseGen nextTfNoise ]).
	lastOdom := data at: #odom.
		
	self icpLoopIterationWithData: data.
	
	^ data
]

{ #category : #icp }
VMOfflineLight >> icpLoopIterationWithData: data [
	| polygon newPolygon resultPolygon sensorPoint |
	
	polygon := data at: #polygon.
	sensorPoint := polygon last pointA.
	icp compute:
			((polygon asPointCollection) removeLast; yourself)
		with: nnc
		"with: map"
		initialGuess: self lastICPTF * (data at: #odomDelta)
		sensorPoint: sensorPoint.
	
	icpTF add: icp finalTF.
	
	resultPolygon := polygon transform: icp finalTF.
	
	"Transcript show: '    finalTF='; show: icp finalTF printString; cr."
	newPolygon := (VMVectorCollectionSimplifier compute: resultPolygon  inlierThreshold: simplifierThreshold) result.
	nnc addAll: (newPolygon select: [ :vec | vec isObstacle ] as: VMLinearNNSVectorCollection).

]

{ #category : #icp }
VMOfflineLight >> initICPWithData: data index: startIndex [
	| startPolygon |

	[icpTF size + 1 < startIndex] whileTrue: [ icpTF add: nil ].
	
	startPolygon := (data at: #polygon) transform: (data at: #odom).
	startPolygon := (VMVectorCollectionSimplifier compute: startPolygon inlierThreshold: simplifierThreshold) result.
	nnc addAll: (startPolygon select: [ :vec | vec isObstacle ]).
	icpTF add: (data at: #odom).

]

{ #category : #initialization }
VMOfflineLight >> initialize [
	super initialize.
	map := VMBSPLeaf new.
	odomGT := OrderedCollection new.
	
]

{ #category : #accessing }
VMOfflineLight >> lastICPTF [
	icpTF size to: 1 do: [ :index |
		(icpTF at: index) ifNotNil: [ ^ icpTF at: index ]
	].
	self error: 'no non-nil entry found in icpTF'.
	^ nil.
]

{ #category : #loading }
VMOfflineLight >> loadDataAt: index path: fullPath [
	| odomTF pointCloud polygon |
	
	odomTF := (FLMaterializer materializeFromFileNamed: fullPath, 'odom_', (index printPaddedWith: $0 to: 4), '.VMTFMatrix.fuel').
	pointCloud := (FLMaterializer materializeFromFileNamed: fullPath, 'keyframe_', (index printPaddedWith: $0 to: 4), '.VMPointCloud2d.fuel').
	polygon := VMPolygon new fromPointCloud: pointCloud tf: (VMTFMatrix angle: Float halfPi translation: 0@0) obstacleDist: obstacleDistance.
	
	^ (SmallDictionary new)
		at: #polygon put: polygon;
		at: #pointCloud put: pointCloud;
		at: #odom put: odomTF;
		yourself.
]

{ #category : #'save & restore' }
VMOfflineLight >> loadFromFileNamed: aFilename [
	| dict |
	
	dict := FLMaterializer materializeFromFileNamed: aFilename.
	self initialize. "removes any old data"
	
	nnc addAll: (dict at: 'nncVectors').
	icpTF := dict at: 'icpTF'.
	pathPrefix := dict at: 'pathPrefix'.
	path := dict at: 'path'.
	dict at: 'paramString'. "todo: write method to set parameters from param string"

]

{ #category : #loading }
VMOfflineLight >> loadGroundTruthFrom: start to: stop by: stepSize path: pathString [
	"loads groundtruth odom data"
	| fullPath |
	path := pathString.
	fullPath := pathPrefix, pathString.
	
	stop < start ifTrue: [ self error: 'invalid data indices: start=', start printString, ' stop=', stop printString ].
	start to: stop by: stepSize do: [ :i |
		odomGT add: (FLMaterializer materializeFromFileNamed: fullPath, 'gtOdom_', (i printPaddedWith: $0 to: 4), '.VMTFMatrix.fuel').
	].

]

{ #category : #loading }
VMOfflineLight >> loadGroundTruthFrom: start to: stop path: pathString [
	"loads groundtruth odom data"
	^ self loadGroundTruthFrom: start to: stop by: 1 path: pathString


]

{ #category : #accessing }
VMOfflineLight >> map [
	^ map
]

{ #category : #accessing }
VMOfflineLight >> map: aBSPLeafOrNode [
	map := aBSPLeafOrNode.
]

{ #category : #accessing }
VMOfflineLight >> maxErrors [
	| maxDist maxAngle |
	
	icpTF size = odomGT size ifFalse: [ ^ self error: 'size mismatch between icpTF and odomGT collections' ].
	
	maxDist := 0.0.
	maxAngle := 0.0.
	
	1 to: icpTF size do: [ :index |
		| deltaTF |
		deltaTF := ((odomGT at: index) inverse) * (icpTF at: index).
		
		maxDist < deltaTF length ifTrue: [ maxDist := deltaTF length ].
		maxAngle < deltaTF angle abs ifTrue: [ maxAngle := deltaTF angle abs ].
	].
	
	^ { maxDist.  maxAngle }
]

{ #category : #accessing }
VMOfflineLight >> odomGT [
	^ odomGT
]

{ #category : #accessing }
VMOfflineLight >> polygonAt: index [
	"returns the polygon from 'polygons' or on error loads the point cloud from disk and creates the polygon from it"
	| fullPathAndFilename pointCloud |
	
	[
		fullPathAndFilename := pathPrefix, path, 'keyframe_', (index printPaddedWith: $0 to: 4), '.VMPointCloud2d.fuel'.
		pointCloud := FLMaterializer materializeFromFileNamed: fullPathAndFilename.
		^ VMPolygon new fromPointCloud: pointCloud tf: (VMTFMatrix angle: Float halfPi translation: 0@0) obstacleDist: obstacleDistance
	] on: Error
	do: [ :e |
		Transcript show: 'failed to load polygon at index=', index printString, ', ', e printString; cr.
		self error: e.
	].

]

{ #category : #rendering }
VMOfflineLight >> renderElements [
	^{
		"odom collect: [ :tf | tf asRenderableElement color: Color blue; lineWidth: 0.065. ].
		odomGT collect: [ :tf | tf asRenderableElement color: Color green; lineWidth: 0.05 ]."
		
		nnc asRenderableElement color: Color red.
		icpTF select: [ :tf | tf isNotNil ] thenCollect: [ :tf | tf asRenderableElement color: Color cyan; lineWidth: 0.045 ].
	} asRenderableElement
	
]

{ #category : #icp }
VMOfflineLight >> runICPFrom: startIndex to: endIndex by: stepSize path: pathString [
	"this method loads data on-the-fly as oposed to #runICP which expects data to be already loaded.
	point clouds & polygons are discarded after use, making this method require significantly less
	memory. nnc and icpTF are filled normaly."
	| data lastOdom dataIndex iterationCounter |
	path := pathString.
	dataIndex := 0.
	iterationCounter := 0.
	
	Transcript show: 'running offline ICP'; cr.
	
	data := self loadDataAt: startIndex path: pathPrefix, pathString.
	self initICPWithData: data index: startIndex.
	lastOdom := data at: #odom.
	
	[ startIndex+stepSize to: endIndex by: stepSize do: [ :index |
		dataIndex := index. "needed for the error message only"
		iterationCounter := iterationCounter + 1.
		
		Transcript show: ((iterationCounter \\\ 10 = 0) ifTrue: [ index printString ] ifFalse: [ '.' ]).
		(iterationCounter \\\ 40 = 0) ifTrue: [Transcript cr. ].
		
		[icpTF size + 1 < index] whileTrue: [ icpTF add: nil ].
		data := self icpLoopIterationAt: index lastData: data.
	]] on: Error do: [ :e | Transcript show: 'icp loop interrupted at index='; show: dataIndex printString; cr. Transcript show: e printString ].
	Transcript show: 'finished ICP'; cr.


]

{ #category : #'save & restore' }
VMOfflineLight >> saveToFileNamed: aFilename [
	| dict |
	
	dict := Dictionary new.
	dict at: 'nncVectors' put: nnc addedVectors.
	dict at: 'icpTF' put: icpTF.
	dict at: 'pathPrefix' put: pathPrefix.
	dict at: 'path' put: path.
	dict at: 'paramString' put: self paramString.
	
	FLSerializer serialize: dict toFileNamed: aFilename.
]
