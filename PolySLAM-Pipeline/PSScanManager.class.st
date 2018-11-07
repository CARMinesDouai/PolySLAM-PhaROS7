Class {
	#name : #PSScanManager,
	#superclass : #Object,
	#instVars : [
		'lastScans',
		'devices',
		'linearDelta',
		'angularDelta',
		'obstacleDist',
		'simplifierTh'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

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

{ #category : #initialization }
PSScanManager >> getDevice: aRawScan [
	|dev|
	^ self devices at: aRawScan header frame_id ifAbsent:[
		dev := PSLaserRangeFinder from: aRawScan.
		self devices at: aRawScan header frame_id put: dev.
		^dev
	]
]

{ #category : #initialization }
PSScanManager >> getLastScanOf: name [
	^ lastScans at:name ifAbsent: [ ^nil ] 
]

{ #category : #initialization }
PSScanManager >> hasMoveEnough: rawScan odom: rawOdom [
	|lastScan od delta|
	lastScan := self getLastScanOf: rawScan header frame_id.
	lastScan ifNil: [ ^true ].
	od := VMTransform fromOdomMsg: rawOdom.
	delta := (od inverse) * lastScan odomPose.
	delta length > self linearDelta ifFalse:[^false].
	
	
	
]

{ #category : #initialization }
PSScanManager >> initialize [
	lastScans := Dictionary new.
	devices := Dictionary new.
	linearDelta := 0.2"meter".
	angularDelta := (Float pi / 180) * 20 "degree".
	simplifierTh := 0.02 squared.
	obstacleDist := 0.4 "meter"
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
PSScanManager >> obstacleDist [
	^ obstacleDist
]

{ #category : #accessing }
PSScanManager >> obstacleDist: anObject [
	obstacleDist := anObject
]

{ #category : #initialization }
PSScanManager >> sensorNames [
	^ lastScans keys
]

{ #category : #initialization }
PSScanManager >> setLastScan: value [
	lastScans at: value device devName put: value
]

{ #category : #accessing }
PSScanManager >> simplifierTh [
	^ simplifierTh
]

{ #category : #accessing }
PSScanManager >> simplifierTh: anObject [
	simplifierTh := anObject
]

{ #category : #initialization }
PSScanManager >> validateScan: rawScan odom: rawOdom [
	|lastScan od delta localizedScan dev|
	dev := self getDevice: rawScan.
	lastScan := self getLastScanOf: rawScan header frame_id.
	od := VMTransform fromOdomMsg: rawOdom.
	lastScan ifNotNil: [
		delta := (od inverse) * lastScan odomPose.
		delta length > self linearDelta ifFalse:[^nil].
		delta angle abs > self angularDelta ifFalse:[^nil].
	].
		"create new localized scan polygon"
	localizedScan := PSLocalizedScanPolygon 
			from: rawScan
			obstacleDist: self obstacleDist
			simplifierTh: self simplifierTh.
	localizedScan odomPose: od.
	localizedScan correctPose: od.
	localizedScan device: dev.
	self setLastScan: localizedScan.
	^localizedScan 
]
