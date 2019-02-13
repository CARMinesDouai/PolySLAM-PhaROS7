Class {
	#name : #PolySLAMROS,
	#superclass : #InterVMChannel,
	#instVars : [
		'controller',
		'slam',
		'sub'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #accessing }
PolySLAMROS >> cleanup [
	Transcript show:'Stopping polySLAMROS slave'; cr.
	slam ifNotNil: [ self slam stop  ].
	slam := nil.
	controller ifNil: [ ^self ].
	sub ifNotNil: [ self controller node unsubscribe: sub ].
]

{ #category : #accessing }
PolySLAMROS >> controller [
	controller ifNil: [ controller := PhaROSPackage new controller ].
	^ controller
]

{ #category : #accessing }
PolySLAMROS >> processData: topic [
	Transcript show: 'running SLAM on topic', topic; cr.
	self cleanup.
	self slam start.
	sub :=  (self controller node buildConnectionFor: topic)
		typedAs: 'scan_odom_sync/ScanOdomSync';
		for:[:msg| self slam sample: msg scan odom: msg odom  ];
		connect
]

{ #category : #accessing }
PolySLAMROS >> runOn: topic [
	<master>
	self iostream nextPut: topic
]

{ #category : #accessing }
PolySLAMROS >> slam [
	slam ifNil: [ 
		slam :=  PolySLAM new.
		"slam controller: self controller."
		slam onKeyframeAvailable: [:kf| self iostream nextPut: kf]].
	^ slam
]

{ #category : #accessing }
PolySLAMROS >> stop [
	self cleanup.
	self iostream nextPut: true
]
