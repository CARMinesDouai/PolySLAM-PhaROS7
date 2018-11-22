Class {
	#name : #PSLocalization,
	#superclass : #PSBasePipelineModule,
	#instVars : [
		'running',
		'outlierThresholdFalloff',
		'outlierStartThreshold',
		'maxIterations',
		'simplifierTh',
		'nnc',
		'icp',
		'lastScan',
		'outputCollection',
		'inputCollection'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #accessing }
PSLocalization >> icp [
	^ icp
]

{ #category : #initialization }
PSLocalization >> initialize [
	super initialize.
	running := false.
	simplifierTh	 :=  0.02 squared.
	outlierThresholdFalloff := 0.2.
	outlierStartThreshold := 0.1.
	maxIterations := 20.
	outputCollection := PSSharedCollection new.
]

{ #category : #accessing }
PSLocalization >> inputCollection [
	^ inputCollection
]

{ #category : #accessing }
PSLocalization >> maxIterations [
	^ maxIterations
]

{ #category : #accessing }
PSLocalization >> maxIterations: anObject [
	maxIterations := anObject
]

{ #category : #accessing }
PSLocalization >> nnc [
	^ nnc
]

{ #category : #accessing }
PSLocalization >> outlierStartThreshold [
	^ outlierStartThreshold
]

{ #category : #accessing }
PSLocalization >> outlierStartThreshold: anObject [
	outlierStartThreshold := anObject.
	icp ifNil: [ ^self ].
	icp outlierStartThreshold: outlierStartThreshold 
]

{ #category : #accessing }
PSLocalization >> outlierThresholdFalloff [
	^ outlierThresholdFalloff
]

{ #category : #accessing }
PSLocalization >> outlierThresholdFalloff: anObject [
	outlierThresholdFalloff := anObject
]

{ #category : #accessing }
PSLocalization >> outputCollection [
	^ outputCollection
]

{ #category : #processing }
PSLocalization >> process [
	[ self running  ] whileTrue: [ 
		inputCollection atEnd ifTrue: [ 150 milliSeconds wait ] ifFalse:[
			self processNextKeyFrame
		]
	]
]

{ #category : #processing }
PSLocalization >> processNextKeyFrame [
	|scan guess|
	scan := inputCollection next.
	scan ifNil: [ ^self ].
	"no tf from that point"
	lastScan ifNil: [
		scan polygon: (scan polygon transform: (scan odomPose)).
		"The first polygon"
		nnc addAll: (scan polygon select:[:v| v isObstacle]).
		"nnc inspect."
		outputCollection add: scan.
		lastScan := scan.
		^self
	].
	guess := (lastScan correctPose * (scan tf)) .
	"run icp"
	icp compute: ((scan polygon asPointCollection) removeLast;yourself)  with: nnc  initialGuess: guess sensorPoint: scan polygon last pointA.
	scan correctPose: icp finalTF.
	scan polygon: (scan polygon transform: icp finalTF).
	scan polygon: (VMVectorCollectionSimplifier compute: scan polygon inlierThreshold: simplifierTh ) result.
	scan score:(VMAlignmentScore computeScoreIcp: icp).
	nnc addAll: (scan polygon select:[:v| v isObstacle]).
	lastScan := scan.
	outputCollection add: scan.
	
]

{ #category : #accessing }
PSLocalization >> running [
	^ running
]

{ #category : #accessing }
PSLocalization >> running: anObject [
	running := anObject
]

{ #category : #accessing }
PSLocalization >> simplifierTh [
	^ simplifierTh
]

{ #category : #accessing }
PSLocalization >> simplifierTh: anObject [
	simplifierTh := anObject
]

{ #category : #accessing }
PSLocalization >> start [
	running := true.
	icp := (VMVectorICP new)
		outlierThresholdFalloff: outlierThresholdFalloff ;
		outlierStartThreshold: outlierStartThreshold ;
		maxIterations: maxIterations ;
		yourself.
	nnc := PSFFINNCollection new.
	lastScan := nil.
	inputCollection := SharedQueue new.
	outputCollection := PSSharedCollection new.
	[self process] forkAt: Processor userBackgroundPriority 
]

{ #category : #accessing }
PSLocalization >> stop [
	nnc cleanup.
	running := false.
	icp := nil.
	nnc := nil.
	lastScan := nil.
	outputCollection := nil.
]
