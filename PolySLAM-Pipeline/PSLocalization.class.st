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
		'lastCorrectPose'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #accessing }
PSLocalization >> addKeyFrame: scan [
	self iostream ifNil: [ ^self ].
	self iostream isOpen ifFalse:[^self].
	Transcript show: 'Key frame added: ', scan id asString;cr.
	self iostream nextPut: { scan id. scan odomPose. scan tf. scan polygon }
]

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

{ #category : #processing }
PSLocalization >> process [
	icp ifNil: [  
		icp := (VMVectorICP new)
			outlierThresholdFalloff: outlierThresholdFalloff ;
			outlierStartThreshold: outlierStartThreshold ;
			maxIterations: maxIterations ;
			yourself.
	].
	nnc ifNil: [
		nnc := PSFFINNCollection new.
	].
	[[ self iostream isOpen  ] whileTrue: [ 
		self iostream atEnd ifTrue: [ 50 milliSeconds wait ] ifFalse:[
			self processNextKeyFrame
		]
	]] fork.
]

{ #category : #processing }
PSLocalization >> processNextKeyFrame [
	|data guess polygon odomPose tf|
	data := self iostream next.
	data ifNil: [ ^self ].
	odomPose := data at:2.
	tf := data at:3.
	polygon := data at:4.
	"no tf from that point"
	Transcript show: 'Process keyframe: ', (data at:1) asString;cr.
	lastCorrectPose ifNil: [
		polygon:= polygon transform: odomPose.
		polygon:= (VMVectorCollectionSimplifier compute: polygon inlierThreshold: simplifierTh ) result.
		nnc addAll: (polygon select:[:v| v isObstacle]).
		"nnc inspect."
		lastCorrectPose := odomPose.
		self iostream nextPut: {data at:1. odomPose. polygon}.
		^self
	].
	guess := (lastCorrectPose *  tf).
	"run icp"
	icp compute: ((polygon asPointCollection) removeLast;yourself)  with: nnc  initialGuess: guess sensorPoint: polygon last pointA.
	polygon:= polygon transform: icp finalTF.
	polygon:= (VMVectorCollectionSimplifier compute: polygon inlierThreshold: simplifierTh ) result.
	Transcript show: 'icp score is ', (VMAlignmentScore computeScoreIcp: icp) asString;cr.
	"scan score:(VMAlignmentScore computeScoreIcp: icp)."
	nnc addAll: (polygon select:[:v| v isObstacle]).
	lastCorrectPose := icp finalTF.
	self iostream nextPut: {data at:1. icp finalTF. polygon}.
	
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
	lastCorrectPose := nil.
	self teleport process.
]

{ #category : #accessing }
PSLocalization >> stop [
	"nnc cleanup."
	running := false.
	icp := nil.
	nnc := nil.
	lastCorrectPose := nil.
	self close.
	self iostream: nil
]
