"
The VMOffline class allows to run ICP + map building in an offline fashion with data saved on disk (as opposed to live-capturing data)

Note (1)
	Keep in mind that the default paths set might need to be adjusted to your needs.
Note (2)
	The whole process can easily take tens of minutes, more than an hour on larger data sets. Progress
	will be indicated via Transcript messages. but these will not be visible until after the process finished
	unless you fork the process via ""[ ...] forkAt: 40"" for example.


EXAMPLE

	offline := (VMOffline new.)
		obstacleDistance: 0.2;
		loadDataFrom: 2 to: 662 by: 2 path: 'testmap_L/1c/'.
	(offline icp)
		outlierThresholdFalloff: 0.7; ""1.0""
		outlierStartThreshold: 0.4;
		maxIterations: 30.
	offline
		simplifierThreshold: 0.02 squared;
		runICPFrom: 2 to: 662 by: 2 path: 'benchmark_cross/1/';
	offline buildMapFrom: 1 to: offline polygons size by: 3.
	(VMPlotter new)
		range: (Rectangle point: -18@ -6 point: 20@12);
		plotHeadlessArrowCollection2: offline nnc addedVectors;
		setTerminal: 'eps size 5.0,8.0 enhanced' filename: '/opt/shared/imt_git/plots/testmap_L_nnc_662b.eps';
		plot


"
Class {
	#name : #VMOffline,
	#superclass : #Object,
	#instVars : [
		'pathPrefix',
		'path',
		'odom',
		'odomDelta',
		'pointClouds',
		'polygons',
		'icp',
		'nnc',
		'nncSizeHistory',
		'map',
		'icpTF',
		'icpScoreHistory',
		'odomGT',
		'simplifierThreshold',
		'obstacleDistance',
		'noiseGen',
		'offsetTF'
	],
	#category : #'PolySLAM-Core-Offline'
}

{ #category : #'save & restore' }
VMOffline class >> fullLoad: filename [
	| obj |
	[ obj := FLMaterializer materializeFromFileNamed: filename. ]
		on: Error
		do: [ :e | Transcript show: 'failed to load file ''', filename, ''''; cr; show: e printString; cr. ].
	
	Transcript
		show: 'loaded ', obj class name, ' (', filename, ')';
		cr;
		show: '> ', obj pathPrefix, obj path;
		cr;
		show: '> ', obj paramString, ', icpTF size=', obj icpTF size printString;
		cr.
	
	^obj
]

{ #category : #'save & restore' }
VMOffline class >> loadFromFileNamed: filename [
	^self new loadFromFileNamed: filename
]

{ #category : #adding }
VMOffline >> addOdomNoise [
	| noise rng |
	
	noise := VMTFMatrix identity.
	rng := Random seed: 80085.
	
	odom := odom collect: [ :tf |
		noise := noise * (VMTFMatrix angle: rng next * 0.01 translation: (rng next * 0.005) @ (rng next * 0.005)).
		tf * noise
	].
]

{ #category : #'map building' }
VMOffline >> buildMapFrom: startIndex to: endIndex [
	^ self buildMapFrom: startIndex to: endIndex by: 1
]

{ #category : #'map building' }
VMOffline >> buildMapFrom: startIndex to: endIndex by: stepSize [
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

{ #category : #'map building' }
VMOffline >> buildMapLazyFrom: startIndex to: endIndex by: stepSize [
	^ self buildMapLazyFrom: startIndex to: endIndex by: stepSize tfStepSize: 1
]

{ #category : #'map building' }
VMOffline >> buildMapLazyFrom: startIndex to: endIndex by: stepSize tfStepSize: tfStepSize [
	| polygon  tfIndex |
	
	tfIndex := 1.
	Transcript
		show: 'building map from:'; show: startIndex printString;
		show: ' to:'; show: endIndex printString;
		show: ' by:'; show: stepSize printString;
		show: ' tfStepSize:'; show: tfStepSize printString; cr.
	
	map ifNil: [ map := VMBSPLeaf new. ].
	"{0.  2.  1.  4} do: [ :k |"
		tfIndex := 1.
		startIndex to: endIndex by: stepSize do: [ :index |
			"(index/stepSize \\ 4 = k) ifTrue: ["
				polygon := (self polygonAt: index) transform: (icpTF at: tfIndex).
				polygon := (VMVectorCollectionSimplifier compute: polygon inlierThreshold: simplifierThreshold) result debugCopy.
				[ VMBSPLeaf new insert: polygon. ]
					on: Error
					do: [ :e |
						Transcript show: 'failed pre-test at index=';
							show: index printString;
							show: ' e=', e printString;
							cr.
							"1 halt." ].
				[ map := map insert: polygon. ]
					on: Error
					do: [ :e |
						Transcript show: 'failed map-building at index=';
							show: index printString;
							show: ' e=', e printString; cr.
							"1 halt." ].
			"]."
			tfIndex := tfIndex + tfStepSize.
		].
	"]."
]

{ #category : #'map building' }
VMOffline >> buildMapWG [
	| polygon startIndex endIndex stepSize tfIndex |
	
	startIndex := 2.
	endIndex := 5100.
	stepSize := 2.
	tfIndex := 1.
	Transcript show: 'building map from:', startIndex printString, ' to:', endIndex printString, ' by:', stepSize printString; cr.
	
	map ifNil: [ map := VMBSPLeaf new. ].
	{0.  "6.  3.  9"} do: [ :k |
		tfIndex := 1.
		startIndex to: endIndex by: stepSize do: [ :index |
			(index \\ 12 = k) ifTrue: [
				polygon := (self polygonAt: index) transform: (icpTF at: tfIndex).
				polygon := (VMVectorCollectionSimplifier compute: polygon inlierThreshold: simplifierThreshold) result.
				[
					VMBSPLeaf new insert: polygon.
					map := map insert: polygon.
				] on: Error do: [Transcript show: 'failed at index='; show: index printString; cr.].
			].
			tfIndex := tfIndex + 1.
		].
	].
]

{ #category : #'map building' }
VMOffline >> buildWithProgressBarFrom: startIndex to: endIndex by: stepSize tfStepSize: tfStepSize [
	| tfIndex polygon |
	map ifNil: [ map := VMBSPLeaf new. ].
	tfIndex := 1.
	
	SystemProgressMorph show: self class asString from: startIndex to: endIndex during: [ :bar |
		startIndex to: endIndex by: stepSize do: [ :index |
			bar current: index.
			bar label: self class asString, ' ', index printString, '/', endIndex printString.
				polygon := (self polygonAt: index) transform: (icpTF at: tfIndex).
				polygon := (VMVectorCollectionSimplifier compute: polygon inlierThreshold: simplifierThreshold) result debugCopy.
				[ VMBSPLeaf new insert: polygon. ]
					on: Error
					do: [ :e |
						Transcript show: 'failed pre-test at index=';
							show: index printString;
							show: ' e=', e printString;
							cr. ].
				[ map := map insert: polygon. ]
					on: Error
					do: [ :e |
						Transcript show: 'failed map-building at index=';
							show: index printString;
							show: ' e=', e printString; cr. ].
			tfIndex := tfIndex + tfStepSize. ]. ].

]

{ #category : #accessing }
VMOffline >> distanceTraveled [
	^ self distanceTraveledFrom: 1 to: icpTF size
]

{ #category : #accessing }
VMOffline >> distanceTraveledFrom: start to: end [
	"distance traveled fron start index to end index"
	| dist collection |
	dist := 0.0.
	
	start < 1 ifTrue: [ self error: 'invalid start index - must be greater than 0' ].
	end > icpTF size ifTrue: [ self error: 'invalid end index must not be greater than collection size (', icpTF size printString, ')' ].
	start >= end ifTrue: [ self error: 'end index must be greater than start index' ].
	
	collection := (icpTF collect: [:t|t] from: start to: end) select: [:tf|tf isNotNil].
	
	start to: end -1 do: [ :index |
		| delta |
		delta := (collection at: index) inverse * (collection at: (index + 1)).
		dist := dist + (delta length).
	].
	^ dist
]

{ #category : #'save & restore' }
VMOffline >> fullLoad: filename [
	"note: returns a new VMOffline instance. the current instance is NOT modified"
	^self class fullLoad: filename
]

{ #category : #accessing }
VMOffline >> fullPath [
	^ pathPrefix, path
]

{ #category : #'save & restore' }
VMOffline >> fullSave: filename [
	FLSerializer serialize: self toFileNamed: filename.
]

{ #category : #accessing }
VMOffline >> icp [
	^ icp
]

{ #category : #icp }
VMOffline >> icpLoopIteration: index [
	| polygon newPolygon resultPolygon sensorPoint |
	
	polygon := polygons at: index.
	sensorPoint := polygon last pointA.
	icp compute:
			((polygon asPointCollection) removeLast; yourself)
		with: nnc
		"with: map"
		initialGuess: icpTF last * (odomDelta at: index - 1)
		sensorPoint: sensorPoint.
	
	icpTF add: icp finalTF.
	
	resultPolygon := polygon transform: icp finalTF.
	
	"Transcript show: '    finalTF='; show: icp finalTF printString; cr."
	newPolygon := (VMVectorCollectionSimplifier compute: resultPolygon  inlierThreshold: simplifierThreshold) result.
	nnc addAll: (newPolygon select: [ :vec | vec isObstacle ] as: VMLinearNNSVectorCollection).

]

{ #category : #icp }
VMOffline >> icpLoopIterationAt: index lastData: lastData [
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
	
	icpScoreHistory add: (VMAlignmentScore computeScoreIcp: icp).
	
	^ data
]

{ #category : #icp }
VMOffline >> icpLoopIterationWithData: data [
	| polygon newPolygon resultPolygon sensorPoint |
	
	polygon := data at: #polygon.
	offsetTF ifNotNil: [ polygon := polygon transform: offsetTF ].
	sensorPoint := polygon last pointA.
	icp compute:
			((polygon asPointCollection) removeLast; yourself)
		with: nnc
		"with: map"
		initialGuess: icpTF last * (data at: #odomDelta)
		sensorPoint: sensorPoint.
	
	icpTF add: icp finalTF.
	
	resultPolygon := polygon transform: icp finalTF.
	
	"Transcript show: '    finalTF='; show: icp finalTF printString; cr."
	newPolygon := (VMVectorCollectionSimplifier compute: resultPolygon  inlierThreshold: simplifierThreshold) result.
	nnc addAll: (newPolygon select: [ :vec | vec isObstacle ] as: VMLinearNNSVectorCollection).

]

{ #category : #metrics }
VMOffline >> icpMaxScoreIndex [
	"returns the index of the highest entry in icpScoreHistory.
	note, that the index i represents the (i+1)th keyframe, since
	the first keyframe is not processed via ICP"
	| maxScore maxScoreIndex |
	
	maxScore := 0.
	maxScoreIndex := nil.
	
	icpScoreHistory doWithIndex: [ :s :i |
		s last > maxScore ifTrue: [ maxScoreIndex := i. maxScore := s last. ].
	].
	^ maxScoreIndex.
]

{ #category : #accessing }
VMOffline >> icpScoreHistory [
	^icpScoreHistory
]

{ #category : #accessing }
VMOffline >> icpTF [
	^ icpTF
]

{ #category : #accessing }
VMOffline >> icpTF: aTFCollection [
	icpTF := aTFCollection.
]

{ #category : #metrics }
VMOffline >> icpTFReport [
	| deltaTF maxDeltaDist maxDeltaTheta |
	
	maxDeltaDist := 0.0.
	maxDeltaTheta := 0.0.
	
	deltaTF := icpTF collectNeighbors: [:current :next | current inverse * next ].
	deltaTF doWithIndex: [ :tf :index |
		maxDeltaDist < tf length ifTrue: [ maxDeltaDist := tf length ].
		maxDeltaTheta < tf angle abs ifTrue: [ maxDeltaTheta := tf angle abs ].
	].
	
	Transcript
		show: 'max delta: ';
		show: (maxDeltaDist printShowingDecimalPlaces: 2);
		show: ' / ';
		show: (maxDeltaTheta printShowingDecimalPlaces: 2);
		show: '(';
		show: ((maxDeltaTheta * 360 / Float twoPi) printShowingDecimalPlaces: 1);
		show: ')';
		cr.

]

{ #category : #icp }
VMOffline >> initICP [
	| startPolygon |
	
	startPolygon := polygons first transform: odom first.
	startPolygon := (VMVectorCollectionSimplifier compute: startPolygon inlierThreshold: simplifierThreshold) result.
	nnc addAll: (startPolygon select: [ :vec | vec isObstacle ]).
	icpTF add: odom first.

]

{ #category : #icp }
VMOffline >> initICPWithData: data [
	| startPolygon |
	
	startPolygon := data at: #polygon.
	offsetTF ifNotNil: [ startPolygon := startPolygon transform: offsetTF ].
	startPolygon := startPolygon transform: (data at: #odom).
	startPolygon := (VMVectorCollectionSimplifier compute: startPolygon inlierThreshold: simplifierThreshold) result.
	nnc addAll: (startPolygon select: [ :vec | vec isObstacle ]).
	icpTF add: (data at: #odom).

]

{ #category : #initialization }
VMOffline >> initialize [
	pathPrefix := '/opt/shared/developer/data/vector_maps/'.
	path := ''.
	odom := OrderedCollection new.
	odomGT := OrderedCollection new.
	odomDelta := OrderedCollection new.
	pointClouds := OrderedCollection new.
	polygons := VMPolygonCollection new.
	obstacleDistance := 0.5.
	simplifierThreshold := nil. "nil = use default"
	icp := (VMVectorICP new)
		outlierThresholdFalloff: 1;
		outlierStartThreshold: 0.7;
		maxIterations: 20;
		yourself.

	icpTF := OrderedCollection new.
	icpScoreHistory := OrderedCollection new.
	nnc := PSFFINNCollection new.
	nncSizeHistory := OrderedCollection new.
	map := VMBSPLeaf new.
	noiseGen := nil.
]

{ #category : #loading }
VMOffline >> loadDataAt: index path: fullPath [
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

{ #category : #loading }
VMOffline >> loadDataFrom: start to: stop by: stepSize path: pathString [
	"loads point clouds and odom data, and additionally converts point clouds to polygons (no odom applied)"
	| fullPath index |
	path := pathString.
	fullPath := pathPrefix, pathString.
	index := nil.
	
	stop < start ifTrue: [ self error: 'invalid data indices: start=', start printString, ' stop=', stop printString ].
	[ start to: stop by: stepSize do: [ :i |
		index := i.
		odom add: (FLMaterializer materializeFromFileNamed: fullPath, 'odom_', (i printPaddedWith: $0 to: 4), '.VMTFMatrix.fuel').
		pointClouds add: (FLMaterializer materializeFromFileNamed: fullPath, 'keyframe_', (i printPaddedWith: $0 to: 4), '.VMPointCloud2d.fuel').
	]] on: Error do: [ :e | Transcript show: 'breaking loop at index=', index printString, ' error=', e printString ].
	"self addOdomNoise."
	2 to: odom size do: [ :i |
		odomDelta add: ((odom at: (i-1)) inverse * (odom at: i)).
	].
	
	polygons := pointClouds collect: [ :pc | VMPolygon new fromPointCloud: pc tf: (VMTFMatrix angle: Float halfPi translation: 0@0) obstacleDist: obstacleDistance ].
	
	[
		self loadGroundTruthFrom: start to: stop path: pathString.
	] on: Error,FileException do: [ Transcript show: 'failed to load groundtruth'; cr. ]
	
]

{ #category : #loading }
VMOffline >> loadDataFrom: start to: stop path: pathString [
	"loads point clouds and odom data, and additionally converts point clouds to polygons (no odom applied)"
	^ self loadDataFrom: start to: stop by: 1 path: pathString

]

{ #category : #'save & restore' }
VMOffline >> loadFromFileNamed: aFilename [
	| dict |
	
	dict := FLMaterializer materializeFromFileNamed: aFilename.
	self initialize. "removes any old data"
	
	nnc addAll: (dict at: 'nncVectors').
	icpTF := dict at: 'icpTF'.
	odom := dict at: 'odom'.
	polygons := dict at: 'polygons'.

]

{ #category : #loading }
VMOffline >> loadGroundTruthFrom: start to: stop by: stepSize path: pathString [
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
VMOffline >> loadGroundTruthFrom: start to: stop path: pathString [
	"loads groundtruth odom data"
	^ self loadGroundTruthFrom: start to: stop by: 1 path: pathString


]

{ #category : #loading }
VMOffline >> loadOdomFrom: start to: stop by: stepSize path: pathString [
	"loads groundtruth odom data"
	| fullPath |
	path := pathString.
	fullPath := pathPrefix, pathString.
	
	odom := OrderedCollection new.
	stop < start ifTrue: [ self error: 'invalid data indices: start=', start printString, ' stop=', stop printString ].
	start to: stop by: stepSize do: [ :i |
		odom add: (FLMaterializer materializeFromFileNamed: fullPath, 'odom_', (i printPaddedWith: $0 to: 4), '.VMTFMatrix.fuel').
	].

	^ odom

]

{ #category : #accessing }
VMOffline >> map [
	^ map
]

{ #category : #accessing }
VMOffline >> map: aBSPLeafOrNode [
	map := aBSPLeafOrNode.
]

{ #category : #accessing }
VMOffline >> maxErrors [
	| maxDist maxAngle |
	
	icpTF size > odomGT size ifTrue: [ ^ self error: 'size mismatch between icpTF and odomGT collections' ].
	
	maxDist := 0.0.
	maxAngle := 0.0.
	
	1 to: icpTF size do: [ :index |
		| deltaTF |
		(icpTF at: index) ifNotNil: [
			deltaTF := ((odomGT at: index) inverse) * (icpTF at: index).
			
			maxDist < deltaTF length ifTrue: [ maxDist := deltaTF length ].
			maxAngle < deltaTF angle abs ifTrue: [ maxAngle := deltaTF angle abs ].
		].
	].
	
	^ { maxDist.  maxAngle }
]

{ #category : #accessing }
VMOffline >> nnc [
	"nearest-neighbor-collection used in ICP"
	^ nnc
]

{ #category : #accessing }
VMOffline >> nnc: aNNCollection [
	"nearest-neighbor-collection used in ICP"
	nnc := aNNCollection.
]

{ #category : #accessing }
VMOffline >> nncSizeHistory [
	^nncSizeHistory
]

{ #category : #accessing }
VMOffline >> noiseGen [
	^ noiseGen
]

{ #category : #accessing }
VMOffline >> noiseGen: aVMTfNoiseGen [
	noiseGen := aVMTfNoiseGen
]

{ #category : #accessing }
VMOffline >> obstacleDistance [
	^ obstacleDistance
]

{ #category : #accessing }
VMOffline >> obstacleDistance: aNumber [
	obstacleDistance := aNumber
]

{ #category : #accessing }
VMOffline >> odom [
	^ odom
]

{ #category : #accessing }
VMOffline >> odomDelta [
	^odomDelta
]

{ #category : #accessing }
VMOffline >> odomGT [
	^ odomGT
]

{ #category : #accessing }
VMOffline >> offsetTF [
	^ offsetTF
]

{ #category : #accessing }
VMOffline >> offsetTF: tf [
	offsetTF := tf.
]

{ #category : #accessing }
VMOffline >> paramString [
	"string that contains the parameters used"
	^ 'otf=', icp outlierThresholdFalloff printString,
		', ost=', icp outlierStartThreshold printString,
		', mi=', icp maxIterations printString,
		', usp=', icp useSensorPoint printString,
		', st=', simplifierThreshold printString,
		', od=', obstacleDistance printString
]

{ #category : #accessing }
VMOffline >> paramString: aString [
	| tokens |
	tokens := aString splitOn: $,.
	tokens do: [ :tok |
		| pair |
		pair := tok trimBoth splitOn: $=.
		[self setParamByName: pair first value: pair second asNumber.] on: Error do: [self setParamByName: pair first value: pair second asBoolean].
	].
]

{ #category : #accessing }
VMOffline >> path [
	^ path
]

{ #category : #accessing }
VMOffline >> path: aString [
	path := aString
]

{ #category : #accessing }
VMOffline >> pathPrefix [
	^ pathPrefix
]

{ #category : #accessing }
VMOffline >> pathPrefix: aString [
	pathPrefix := aString
]

{ #category : #accessing }
VMOffline >> pointClouds [
	^ pointClouds
]

{ #category : #accessing }
VMOffline >> polygonAt: index [
	"returns the polygon from 'polygons' or on error loads the point cloud from disk and creates the polygon from it"
	[ ^ polygons at: index ]
		on: Error
		do: [
			| fullPathAndFilename pointCloud |
			fullPathAndFilename := pathPrefix, path, 'keyframe_', (index printPaddedWith: $0 to: 4), '.VMPointCloud2d.fuel'.
			pointCloud := FLMaterializer materializeFromFileNamed: fullPathAndFilename.
			^ VMPolygon new fromPointCloud: pointCloud tf: (VMTFMatrix angle: Float halfPi translation: 0@0) obstacleDist: obstacleDistance
		].
]

{ #category : #accessing }
VMOffline >> polygons [
	^ polygons
]

{ #category : #rendering }
VMOffline >> renderElements [
	^{
		odom collect: [ :tf | tf asRenderableElement color: Color blue; lineWidth: 0.065. ].
		"odomGT collect: [ :tf | tf asRenderableElement color: Color green; lineWidth: 0.05 ]."
		
		nnc asRenderableElement color: Color red.
		icpTF collect: [ :tf | tf asRenderableElement color: Color orange; lineWidth: 0.045 ].
	} asRenderableElement
]

{ #category : #icp }
VMOffline >> runICP [
	self initICP.
	
	2 to: polygons size do: [ :index |
		Transcript show: ((index \\\ 10 = 0) ifTrue: [ index printString ] ifFalse: [ '.' ]).
		(index \\\ 40 = 0) ifTrue: [Transcript cr. ].
		
		self icpLoopIteration: index.
	].
	Transcript show: 'finished ICP'; cr.

]

{ #category : #icp }
VMOffline >> runICPFrom: startIndex to: endIndex by: stepSize path: pathString [
	"this method loads data on-the-fly as oposed to #runICP which expects data to be already loaded.
	point clouds & polygons are discarded after use, making this method require significantly less
	memory. nnc and icpTF are filled normaly."
	| fullPath data iterationCounter |
	path := pathString.
	fullPath := pathPrefix, pathString.
	iterationCounter := 0.
	
	Transcript show: 'running offline ICP'; cr.
	
	data := self loadDataAt: startIndex path: fullPath.
	self initICPWithData: data.
	
	"[" startIndex+stepSize to: endIndex by: stepSize do: [ :index |
		iterationCounter := iterationCounter + 1.
		nncSizeHistory add: nnc addedVectors size.
		
		Transcript show: ((iterationCounter \\\ 10 = 0) ifTrue: [ index printString ] ifFalse: [ '.' ]).
		(iterationCounter \\\ 40 = 0) ifTrue: [Transcript cr. ].
		
		data := self icpLoopIterationAt: index lastData: data.
	]"] on: Error do: [ :e | Transcript show: 'icp loop interrupted'; cr; show: e printString. ]".
	Transcript show: 'finished ICP'; cr.


]

{ #category : #'save & restore' }
VMOffline >> saveToFileNamed: aFilename [
	| dict |
	
	dict := Dictionary new.
	dict at: 'nncVectors' put: nnc addedVectors.
	dict at: 'icpTF' put: icpTF.
	dict at: 'odom' put: odom.
	dict at: 'polygons' put: polygons.
	
	FLSerializer serialize: dict toFileNamed: aFilename.
]

{ #category : #accessing }
VMOffline >> setParamByName: nameString value: value [
	
	nameString = 'otf' ifTrue: [ icp outlierThresholdFalloff: value. ^ self ].
	nameString = 'ost' ifTrue: [ icp outlierStartThreshold: value. ^ self ].
	nameString = 'mi' ifTrue: [ icp maxIterations: value. ^ self ].
	nameString = 'usp' ifTrue: [ icp useSensorPoint: value. ^ self ].
	nameString = 'st' ifTrue: [ simplifierThreshold := value. ^ self ].
	nameString = 'od' ifTrue: [ obstacleDistance := value. ^ self ].
	
	Transcript show: 'warning: param "'; show: nameString; show: '" not recognized'; cr.

]

{ #category : #accessing }
VMOffline >> simplePolygonAt: index [
	^ (VMVectorCollectionSimplifier compute: (self polygonAt: index) inlierThreshold: simplifierThreshold) result
]

{ #category : #accessing }
VMOffline >> simplifierThreshold [
	^ simplifierThreshold
]

{ #category : #accessing }
VMOffline >> simplifierThreshold: aNumber [
	simplifierThreshold := aNumber
]

{ #category : #transformation }
VMOffline >> transform: tf [
	| copy |
	copy := self copy.
	copy nnc: ((nnc species new)
		addAll: (nnc addedVectors collect: [:v|v transform: tf]);
		yourself).
	copy icpTF: (icpTF collect: [:t|tf * t]).
	^ copy
]
