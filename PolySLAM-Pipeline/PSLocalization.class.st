Class {
	#name : #PSLocalization,
	#superclass : #PSBasePipelineModule,
	#instVars : [
		'running',
		'outlierThresholdFalloff',
		'outlierStartThreshold',
		'maxIterations',
		'obstacleDistance',
		'simplifierTh',
		'nnc',
		'icp',
		'lastScan',
		'outputCollection',
		'inputCollection'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #initialization }
PSLocalization >> initialize [
	super initialize.
	running := false.
	obstacleDistance := 0.5.
	simplifierTh	 :=  0.02 squared.
	outlierThresholdFalloff := 1.
	outlierStartThreshold := 0.7.
	maxIterations := 20.
	outputCollection := PSSharedCollection new.
]

{ #category : #accessing }
PSLocalization >> inputCollection [
	^ inputCollection
]

{ #category : #accessing }
PSLocalization >> keyframes [
	^collection 
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
PSLocalization >> obstacleDistance [
	^ obstacleDistance
]

{ #category : #accessing }
PSLocalization >> obstacleDistance: anObject [
	obstacleDistance := anObject
]

{ #category : #accessing }
PSLocalization >> outlierStartThreshold [
	^ outlierStartThreshold
]

{ #category : #accessing }
PSLocalization >> outlierStartThreshold: anObject [
	outlierStartThreshold := anObject
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
	|scan|
	scan := inputCollection next.
	scan ifNil: [ ^self ].
	"no tf from that point"
	scan createPolygonWith: obstacleDistance simplifierTh: simplifierTh  tf: (VMTFMatrix angle: Float halfPi translation: 0@0).
	lastScan ifNil: [
		nnc addAll: (scan polygon select:[:v| v isObstacle]).
		outputCollection add: scan.
		lastScan := scan.
		^self
	].
	"run icp"
	icp compute: scan cloud  with: nnc  initialGuess: (lastScan correctPose * (scan tf)) sensorPoint: scan polygon last pointA.
	scan correctPose: icp finalTF.
	scan polygon: (scan polygon transform: icp finalTF).
	scan polygon: (VMVectorCollectionSimplifier compute: scan polygon inlierThreshold: simplifierTh ) result.
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
	nnc := VMNNVectorGrid new.
	lastScan := nil.
	inputCollection := SharedQueue new.
	outputCollection := PSSharedCollection new.
	[self process] forkAt: Processor userBackgroundPriority 
]

{ #category : #accessing }
PSLocalization >> stop [
	running := false.
	icp := nil.
	nnc := nil.
	lastScan := nil.
	outputCollection := nil.
]
