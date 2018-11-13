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
	timeScale := 50 "milliSeconds".
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

{ #category : #accessing }
PSKeyframeSampling >> odomTopic [
	^ odomTopic
]

{ #category : #accessing }
PSKeyframeSampling >> odomTopic: anObject [
	odomTopic := anObject
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
PSKeyframeSampling >> sample: rawScan odom: rawOdom [
	|localizedScan|
	localizedScan := scanMan validateScan: rawScan odom: rawOdom.
	localizedScan ifNotNil: [
		dev ifNil: [ dev := localizedScan device  ].
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

{ #category : #process }
PSKeyframeSampling >> start [
	queue := SharedQueue new.
	scan_sub :=  (self controller node buildConnectionFor: self scanTopic)
		typedAs: 'sensor_msgs/LaserScan';
		for:[:msg| self synchronize:msg];
		connect.
	odom_sub := (self controller node buildConnectionFor: self odomTopic )
		typedAs: 'nav_msgs/Odometry';
		for: [ :msg | self synchronize: msg. ];
		connect.
	running := true.
	[ self process ] forkAt: Processor userBackgroundPriority 
]

{ #category : #process }
PSKeyframeSampling >> stop [
	scan_sub ifNotNil: [ self controller node unsubscribe: scan_sub ].
	odom_sub ifNotNil: [ self controller node unsubscribe: odom_sub  ].
	lastOdom := nil.
	lastScan := nil.
	running := false.
	queue := nil.
]

{ #category : #process }
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

{ #category : #process }
PSKeyframeSampling >> synchronizeOdom: msg [
	lastOdom := msg.
	lastScan ifNil: [^self].
	self validate
]

{ #category : #process }
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

{ #category : #process }
PSKeyframeSampling >> validate [
	|duration|
	"verify the time stamp"
	duration := (lastOdom header stamp - lastScan header stamp).
	duration nanoSeconds abs < (self timeScale*1000000) ifTrue:[
		queue nextPut:{lastScan. lastOdom }
		"Transcript show: 'New sync message with Duration :', duration asString; cr"
	]
	"queue nextPut:{lastScan. lastOdom }.""
	self sample: lastScan   odom:lastOdom ."
]
