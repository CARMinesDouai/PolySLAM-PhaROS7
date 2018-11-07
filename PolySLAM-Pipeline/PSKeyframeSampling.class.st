Class {
	#name : #PSKeyframeSampling,
	#superclass : #PSBasePipelineModule,
	#instVars : [
		'scan_sub',
		'odom_sub',
		'scanTopic',
		'odomTopic',
		'lastScan',
		'lastOdom',
		'callback',
		'timeScale',
		'scanMan'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

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

{ #category : #accessing }
PSKeyframeSampling >> initialize [
	timeScale := 10 "milliSeconds".
	scanMan := PSScanManager new
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
	^scanMan obstacleDist
]

{ #category : #accessing }
PSKeyframeSampling >> obstacleDist: d [
	scanMan obstacleDist: d
]

{ #category : #accessing }
PSKeyframeSampling >> odomTopic [
	^ odomTopic
]

{ #category : #accessing }
PSKeyframeSampling >> odomTopic: anObject [
	odomTopic := anObject
]

{ #category : #accessing }
PSKeyframeSampling >> sample: rawScan odom: rawOdom [
	|localizedScan|
	localizedScan := scanMan validateScan: rawScan odom: rawOdom.
	localizedScan ifNotNil: [
		callback ifNotNil: [ callback value: localizedScan ]
	].
]

{ #category : #accessing }
PSKeyframeSampling >> scanTopic [
	^ scanTopic
]

{ #category : #accessing }
PSKeyframeSampling >> scanTopic: anObject [
	scanTopic := anObject
]

{ #category : #accessing }
PSKeyframeSampling >> simplifierTh [
	^scanMan simplifierTh
]

{ #category : #accessing }
PSKeyframeSampling >> simplifierTh: th [
	scanMan simplifierTh: th
]

{ #category : #accessing }
PSKeyframeSampling >> start [
	scan_sub :=  (self controller node buildConnectionFor: self scanTopic)
		typedAs: 'sensor_msgs/LaserScan';
		for:[:msg| self synchronize:msg];
		connect.
	odom_sub := (self controller node buildConnectionFor: self odomTopic )
		typedAs: 'nav_msgs/Odometry';
		for: [ :msg | self synchronize: msg. ];
		connect.
]

{ #category : #accessing }
PSKeyframeSampling >> stop [
	scan_sub ifNotNil: [ self controller node unsubscribe: scan_sub ].
	odom_sub ifNotNil: [ self controller node unsubscribe: odom_sub  ].
	lastOdom := nil.
	lastScan := nil
]

{ #category : #accessing }
PSKeyframeSampling >> synchronize:msg [
	self lock critical: [ 
		msg class = Sensor_msgsLaserScan ifTrue:[
			"it is a laser msg"
			self synchronizeScan: msg
		] ifFalse:[
			"it is an odometry msg"
			self synchronizeOdom: msg
		]
]
]

{ #category : #accessing }
PSKeyframeSampling >> synchronizeOdom: msg [
	lastOdom := msg.
	lastScan ifNil: [^self].
	self validate
]

{ #category : #accessing }
PSKeyframeSampling >> synchronizeScan: msg [
	lastScan := msg.
	lastOdom ifNil: [^self].
	self validate.
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

{ #category : #accessing }
PSKeyframeSampling >> validate [
	|duration|
	"verify the time stamp"
	duration := (lastOdom header stamp - lastScan header stamp).
	duration nanoSeconds abs < (self timeScale*1000000) ifTrue:[
		self sample: lastScan  odom: lastOdom.
		"Transcript show: 'New sync message with Duration :', duration asString; cr"
	]
]
