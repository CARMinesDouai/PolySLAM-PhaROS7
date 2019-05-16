Class {
	#name : #PSScanManager,
	#superclass : #Object,
	#instVars : [
		'streams',
		'devices',
		'linearDelta',
		'angularDelta',
		'obDist',
		'maxRange'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #accessing }
PSScanManager >> addScan: localizedScan [
	(streams at: localizedScan device devName) add: localizedScan.
	localizedScan id: (streams at: localizedScan device devName) size
]

{ #category : #accessing }
PSScanManager >> angularDelta [
	^ angularDelta
]

{ #category : #accessing }
PSScanManager >> angularDelta: anObject [
	angularDelta := (Float pi / 180)* anObject
]

{ #category : #accessing }
PSScanManager >> devices [
	^ devices
]

{ #category : #accessing }
PSScanManager >> devices: anObject [
	devices := anObject
]

{ #category : #accessing }
PSScanManager >> getAllScansOf:dev [
	|name|
	name := dev.
	dev class = ByteString ifFalse:[ name := dev devName ].
	^streams at: name ifAbsent: [ nil ].
]

{ #category : #accessing }
PSScanManager >> getDevice: aRawScan [
	|dev|
	^ self devices at: aRawScan header frame_id ifAbsent:[
		dev := PSLaserRangeFinder from: aRawScan.
		self devices at: aRawScan header frame_id put: dev.
		streams at: aRawScan header frame_id put: PSSharedCollection new.
		^dev
	]
]

{ #category : #accessing }
PSScanManager >> getLastScanOf: name [
	|scans|
	scans := self getAllScansOf: name.
	scans ifNil: [ ^nil ].
	^scans last 
]

{ #category : #initialization }
PSScanManager >> initialize [
	devices := Dictionary new.
	streams := Dictionary new.
	obDist := 0.15."0.4meter"
	linearDelta := 0.4"meter".
	maxRange := 10. "10 meter"
	angularDelta := (Float pi / 180) * 20 "degree".
]

{ #category : #accessing }
PSScanManager >> linearDelta [
	^ linearDelta
]

{ #category : #accessing }
PSScanManager >> linearDelta: anObject [
	linearDelta := anObject
]

{ #category : #accessing }
PSScanManager >> maxRange [
	^ maxRange
]

{ #category : #accessing }
PSScanManager >> maxRange: anObject [
	maxRange := anObject
]

{ #category : #accessing }
PSScanManager >> obDist [
	^ obDist
]

{ #category : #accessing }
PSScanManager >> obDist: anObject [
	obDist := anObject
]

{ #category : #accessing }
PSScanManager >> sensorNames [
	^ devices keys
]

{ #category : #validating }
PSScanManager >> validateScan: rawScan odom: rawOdom [
	|lastScan od delta localizedScan dev|
	dev := self getDevice: rawScan.
	lastScan := self getLastScanOf: rawScan header frame_id.
	od := (VMTransform fromOdomMsg: rawOdom) asVMTFMatrix.
	delta := VMTFMatrix identity .
	lastScan ifNotNil: [
		delta := (lastScan odomPose inverse)* od.
		((delta length < self linearDelta) & (delta angle abs < self angularDelta)) ifTrue:[^nil].
	].
		"create new localized scan polygon"
	self validateScanRange: rawScan.
	localizedScan := PSLocalizedScan 
			from: rawScan obstacleDist: obDist.
			"obstacleDist: self obstacleDist
			simplifierTh: self simplifierTh."
	localizedScan odomPose: od.
	localizedScan correctPose: od.
	localizedScan tf: delta.
	localizedScan device: dev.
	self addScan: localizedScan.
	^localizedScan 
]

{ #category : #validating }
PSScanManager >> validateScanRange:msg [
	1 to: msg ranges size do:[:i|
		(msg ranges at: i) > maxRange ifTrue:[msg ranges at:i put: Float nan]
	].
]
