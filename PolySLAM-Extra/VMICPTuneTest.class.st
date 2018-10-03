Class {
	#name : #VMICPTuneTest,
	#superclass : #Object,
	#instVars : [
		'minIndex',
		'maxIndex',
		'path',
		'polygons',
		'groundTruthTF',
		'resultHistory'
	],
	#category : #'PolySLAM-Extra-Playgrounds'
}

{ #category : #'as yet unclassified' }
VMICPTuneTest >> computeScore: matchHistory [
	| error inlierCount outlierCount score |
	
	error := 0.
	inlierCount := 0.
	outlierCount := 0.
	
	matchHistory do: [ :m |
		m do: [ :matchPair |
			matchPair outlier
				ifTrue: [ outlierCount := outlierCount + 1 ]
				ifFalse: [ inlierCount := inlierCount + 1 ].
		].
		inlierCount := inlierCount.
		error := error + (m squaredError).
	].
	
	score := (inlierCount / (inlierCount + outlierCount)) / error.
	^score.
]

{ #category : #initialization }
VMICPTuneTest >> initialize [
	super initialize.
	
	minIndex := 1.
	maxIndex := 512.
	path := '/opt/shared/developer/data/vector_maps/gazebo_office/run2.1/'.
	polygons := OrderedCollection new.
	resultHistory := OrderedCollection new.
	groundTruthTF := OrderedCollection new.

]

{ #category : #initialization }
VMICPTuneTest >> loadMaps [
	| timeSpent |
	timeSpent := [
		Transcript
			show: 'loading maps, startIndex=';
			show: minIndex printString;
			show: ', endIndex=';
			show: maxIndex printString;
			cr.
		minIndex to: maxIndex do: [ :index |
			| map |
			map := (VMSTONBuilder load: 'gt_', (index printPaddedWith: $0 to: 4) ,'.VMLocalMap.ston' path: path).
			groundTruthTF add polygons add: map tf inverse.
		].
		minIndex to: maxIndex do: [ :index |
			| map |
			map := (VMSTONBuilder load: 'keyframe_', (index printPaddedWith: $0 to: 4) ,'.VMLocalMap.ston' path: path).
			polygons add: ((VMPolygon fromVectors: map lineSegments) "applyTransform: map tf inverse").
		].
	] timeToRun.
	Transcript show: '  time spent:'; show: timeSpent totalSeconds asInteger printString; show: 's'; cr.
	
]

{ #category : #'basic algorithm' }
VMICPTuneTest >> loop [
	| icp maxIterations startThresholds outlierFalloff timeSpent totalTimeSpent |
	
	maxIterations := { 10 }.
	startThresholds := { 0.4.  0.8.  1.2.  1.6. }.
	outlierFalloff := { 0.1.  0.2.  0.4.  0.8.  1.2.  4.  8.  12 }.
	
	self loadMaps.
	
	totalTimeSpent := [ maxIterations do: [ :maxIter |
		startThresholds do: [ :st |
			outlierFalloff do: [ :falloff |
				Transcript
					show: 'ICP maxIter=';
					show: maxIter printString;
					show: ', startThreshold=';
					show: st printString;
					show: ', falloff=';
					show: falloff printString;
					cr.
				icp := VMVectorICP new.
				icp outlierStartThreshold: st.
				icp outlierThresholdFalloff: falloff.
				icp maxIterations: maxIter.
				
				timeSpent := [ resultHistory add: (self runICP: icp) ] timeToRun.
				Transcript show: '  time spend:'; show: (timeSpent totalSeconds asFloat round: 2) printString; cr.
			].
		].
	]] timeToRun.
	Transcript show: 'done ('; show: (totalTimeSpent totalSeconds asInteger) printString; show: 's)'; cr.

]

{ #category : #accessing }
VMICPTuneTest >> maxIndex: aNumber [
	maxIndex := aNumber.
]

{ #category : #accessing }
VMICPTuneTest >> minIndex: aNumber [
	minIndex := aNumber.

]

{ #category : #accessing }
VMICPTuneTest >> path: aPathString [
	path := aPathString
]

{ #category : #accessing }
VMICPTuneTest >> resultHistory [
	^ resultHistory
]

{ #category : #'as yet unclassified' }
VMICPTuneTest >> runICP: icp [
	| startPolygon nnc icpTF matchHistory cr |

	startPolygon := (VMVectorCollectionSimplifier compute: polygons first) result.
	nnc := VMNNVectorGrid new.
	nnc addAll: (startPolygon select: [ :vec | vec isObstacle ]).
	cr := VMCollectionRenderer new.
	cr collection add: (startPolygon asRenderableElement color: (Color byInteger: minIndex); lineWidth: 0.01).
	matchHistory := OrderedCollection new.

	icpTF := VMTFMatrix identity.
	2 to: (polygons size) do: [ :index |
		| p result newPolygon matches sensorPoint |
		p := (polygons at: index) transform: icpTF.
		sensorPoint := p last pointA.
		icp compute: ((p asPointCollection) removeLast; yourself) with: nnc sensorPoint: sensorPoint.
		icpTF := icp finalTF * icpTF.
		result := p transform: icp finalTF.
		newPolygon := (VMVectorCollectionSimplifier compute: result) result.
		"nnc := newPolygon select: [ :vec | vec isObstacle ] as: VMLinearNNSVectorCollection."
		nnc addAll: (newPolygon select: [ :vec | vec isObstacle ] as: VMLinearNNSVectorCollection).
		cr collection add: (newPolygon asRenderableElement color: (Color byInteger: (index+minIndex-1)); lineWidth: 0.01).
		icp createMatchPairs.
		icp markOutliers: 0.05.
		matches := icp matchHistory last.
		matchHistory add: matches.
	].
	
	^ {
		'maxIteration=', icp maxIterations printString, ', falloff=', icp outlierThresholdFalloff printString, ', startThreshold=', icp outlierStartThreshold printString.
		icp.
		self computeScore: matchHistory.
		matchHistory.
		(cr collection collect: [ :rr | rr model select: [ :v | v isObstacle] as: VMLineSegCollection ]) asRenderableElement.
	}
	

]
