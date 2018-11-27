Class {
	#name : #PSKeyframeSampling,
	#superclass : #PSBasePipelineModule,
	#instVars : [
		'callback',
		'timeScale',
		'scanMan',
		'dev',
		'queue',
		'running'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #accessing }
PSKeyframeSampling >> allScans [
	dev ifNil: [ ^nil ].
	^ scanMan getAllScansOf: dev
]

{ #category : #accessing }
PSKeyframeSampling >> angularDelta [
	^scanMan angularDelta
]

{ #category : #accessing }
PSKeyframeSampling >> angularDelta: d [
	scanMan angularDelta: d
]

{ #category : #accessing }
PSKeyframeSampling >> callback [
	^ callback
]

{ #category : #accessing }
PSKeyframeSampling >> callback: anObject [
	callback := anObject
]

{ #category : #initialization }
PSKeyframeSampling >> initialize [
	timeScale := 100 "milliSeconds".
	scanMan := PSScanManager new.
]

{ #category : #accessing }
PSKeyframeSampling >> linearDelta [
	^scanMan linearDelta
]

{ #category : #accessing }
PSKeyframeSampling >> linearDelta: d [
	scanMan linearDelta: d
]

{ #category : #accessing }
PSKeyframeSampling >> obstacleDist [
	^scanMan obDist
]

{ #category : #accessing }
PSKeyframeSampling >> obstacleDist:v [
	^scanMan obDist:v
]

{ #category : #process }
PSKeyframeSampling >> process [
	|it|
	[ running  ] whileTrue: [ 
		queue ifNil: [ ^self ].
		queue atEnd ifTrue: [ 100 milliSeconds wait ] ifFalse: [ 
			it := queue next.
			self sample: (it at:1)  odom: (it at: 2).
		]
	]
]

{ #category : #process }
PSKeyframeSampling >> registerScan: rawScan withOdom: rawOdom [
	queue nextPut: { rawScan. rawOdom }
]

{ #category : #process }
PSKeyframeSampling >> sample: rawScan odom: rawOdom [
	|localizedScan|
	localizedScan := scanMan validateScan: rawScan odom: rawOdom.
	localizedScan ifNotNil: [
		dev ifNil: [ dev := localizedScan device  ].
		callback ifNotNil: [ callback value: localizedScan ]
	].
]

{ #category : #process }
PSKeyframeSampling >> start [
	queue := SharedQueue new.
	running := true.
	"[ self process ] forkAt: 60 "
]

{ #category : #process }
PSKeyframeSampling >> stop [
	running := false.
	queue := nil.
]

{ #category : #accessing }
PSKeyframeSampling >> timeScale [
	^ timeScale
]

{ #category : #accessing }
PSKeyframeSampling >> timeScale: anObject [
	"inmillisecond"
	timeScale := anObject
]
