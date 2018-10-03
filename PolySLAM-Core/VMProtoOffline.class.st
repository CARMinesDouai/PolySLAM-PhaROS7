Class {
	#name : #VMProtoOffline,
	#superclass : #Object,
	#instVars : [
		'pathPrefix',
		'path',
		'icp',
		'nnc',
		'icpTF',
		'simplifierThreshold',
		'obstacleDistance',
		'noiseGen'
	],
	#category : #'PolySLAM-Core-Offline'
}

{ #category : #accessing }
VMProtoOffline >> icp [
	^ icp
]

{ #category : #accessing }
VMProtoOffline >> icpTF [
	^ icpTF
]

{ #category : #initialization }
VMProtoOffline >> initialize [
	super initialize.
	pathPrefix := '/opt/shared/developer/data/vector_maps/'.
	path := ''.
	obstacleDistance := 0.5.
	simplifierThreshold := nil. "nil = use default"
	icp := (VMVectorICP new)
		outlierThresholdFalloff: 1;
		outlierStartThreshold: 0.7;
		maxIterations: 20;
		yourself.

	icpTF := OrderedCollection new.
	nnc := VMNNVectorGrid new.
	noiseGen := nil.
]

{ #category : #accessing }
VMProtoOffline >> nnc [
	"nearest-neighbor-collection used in ICP"
	^ nnc
]

{ #category : #accessing }
VMProtoOffline >> noiseGen [
	^ noiseGen
]

{ #category : #accessing }
VMProtoOffline >> noiseGen: aVMTfNoiseGen [
	noiseGen := aVMTfNoiseGen
]

{ #category : #accessing }
VMProtoOffline >> obstacleDistance [
	^ obstacleDistance
]

{ #category : #accessing }
VMProtoOffline >> obstacleDistance: aNumber [
	obstacleDistance := aNumber
]

{ #category : #accessing }
VMProtoOffline >> paramString [
	"string that contains the parameters used"
	^ 'otf=', icp outlierThresholdFalloff printString,
		', ost=', icp outlierStartThreshold printString,
		', mi=', icp maxIterations printString,
		', st=', simplifierThreshold printString,
		', od=', obstacleDistance printString
]

{ #category : #accessing }
VMProtoOffline >> pathPrefix: aString [
	pathPrefix := aString
]

{ #category : #accessing }
VMProtoOffline >> simplifierThreshold [
	^ simplifierThreshold
]

{ #category : #accessing }
VMProtoOffline >> simplifierThreshold: aNumber [
	simplifierThreshold := aNumber
]
