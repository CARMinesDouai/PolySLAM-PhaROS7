"
This object represents a ROS node that handles keyframe selection. It subscribes to odom and scan data. if the robot has moved enough (based on the odom input) then we create a local map from the scan input and publish it (to be used by the map merger).


Public API and Key Messages

- node: aNode
	sets the controller node. typically called on instance creation.
- processLaserScan: aScanMsg
	subscriber callback method for the laser scan topic. creates and publishes local maps from the laser scan data on every keyframe
- reset 
	resets the state of the node as if it has just been initialized. topic subscriptions and publishers remain untouched. this method is mainly meant for debugging, allowing to reset the node without having to deal with a clean shutdown or the result of an unclean shutdown.
- processOdomMsg: anOdomMsg
	subscriber callback method for the odom topic. determines if we have moved enough to create another key frame.
- publish: aScanMsg
	publishes a local map based on the scan message. uses ICP to align the scan with the previous keyframe
- subscribeToTopics
	simply subscribes to the ROS topics (laser scan data & odometry)


example(s) for instance creation can be found at the package script  'scriptKeyFrameNode'


Object members:

- icp
	a VMICP instance for correcting the position of the laser scan transformation.
- lastKeyPose
	a VMTransform instance that holds the pose (position and orientation) of the robot at the last key frame
- lastKeyTf
	translation from the robots starting position to the last key frame.
-  readyForKeyFrame
	true if the laser scan topic handler should create a new keyframe. false otherwise
- odomKeyDelta
	the transform from the last key frame to the current keyframe, according to odometry. used as initial guess for the ICP correction


"
Class {
	#name : #VMKeyframeNode,
	#superclass : #VMBaseNode,
	#instVars : [
		'icp',
		'publisher',
		'keyframeSelector',
		'keyframeCounter',
		'lastOdomPose',
		'currentOdomPose',
		'lastKeyPose',
		'lastKeyPointCloud',
		'icpViewer',
		'logLaser',
		'logPC',
		'currentGtOdomPose',
		'logGt',
		'logPath'
	],
	#category : #'PolySLAM-PhaROS-Examples-Nodes'
}

{ #category : #'keyframe creation' }
VMKeyframeNode >> createKeyFrameWithPointCloud: pc [
	| scanMap currentKeyPose deltaOdom |
	
	keyframeCounter := keyframeCounter + 1.
	
	lastKeyPointCloud
		ifNil: [
			deltaOdom := VMTFMatrix identity.
			currentKeyPose := currentOdomPose asVMTFMatrix.
			"transformedPc := VMPointCloud2d new points: (pc points collect: [ :aPoint | currentKeyPose applyToPoint: aPoint copy ])."
			
			"self logCr: '  currentKeyPose=', currentKeyPose asVMTFMatrix printString."
		]
		ifNotNil: [
			| deltaTf |
			
			"deltaOdom is the transformation estimate from the last keyframe up to now, based on the robot's odometry.
			it is used as an initial guess for the ICP correction."
			deltaOdom := (lastOdomPose inverse) * (currentOdomPose).
			
			"self log: 'saving ...'.
			GenSTONBuilder save: deltaOdom asVMTFMatrix inverse prefix: 'debug/kf_', keyframeCounter printString.
			GenSTONBuilder save: pc prefix: 'debug/kf_', keyframeCounter printString.
			self logCr: ' done'."
			
			"deltaTF is the final estimate of the transformation of the point cloud into the map frame."
			icp
				ifNil: [ deltaTf := deltaOdom asVMTFMatrix. ]
				ifNotNil: [
					deltaTf := self performICP: pc guess: deltaOdom asVMTFMatrix.
				].
			
			currentKeyPose := lastKeyPose * (deltaTf).
			"currentKeyPose := currentOdomPose asVMTFMatrix."
			"
			self logCr: '  lastKeyPose=', lastKeyPose asVMTFMatrix printString.
			self logCr: '  lastOdomPose=', lastOdomPose asVMTFMatrix printString.
			self logCr: '  currentKeyPose=', currentKeyPose asVMTFMatrix printString.
			self logCr: '  currentOdomPose=', currentOdomPose asVMTFMatrix printString.
			self logCr: '  deltaOdom=', deltaOdom asVMTFMatrix printString.
			self logCr: '  deltaTf=', deltaTf asVMTFMatrix printString.
			"
		].
	
	scanMap := VMLocalMap new fromPointCloud: pc tf: currentKeyPose asVMTFMatrix.
	lastOdomPose := currentOdomPose. "pose of the last odom message before we created the last point cloud & scanMap"
	lastKeyPose := currentKeyPose. "pose of the last scanMap, global frame (from this robots point of view)"
	lastKeyPointCloud := pc.
	
	self logPointCloud: pc.
	self logFuelOdom: currentOdomPose.
	self logDeltaOdom: deltaOdom.
	self logFuelOdomGt.
	self logCr: 'publishing map for keyframe ', keyframeCounter printString.
	self publish: scanMap.
	

]

{ #category : #initialization }
VMKeyframeNode >> initialize [
	super initialize.
	
	self reset.
	
	"note: the caller should call 'subsribeToTopics' (which also calls 'setupPublisher') after the instance creation to complete initialization."

]

{ #category : #accessing }
VMKeyframeNode >> keyframeSelector [
	^keyframeSelector.
]

{ #category : #logging }
VMKeyframeNode >> logDeltaOdom: deltaOdom [
	"writing to a file via FUEL because STON fails when class names contain underscores and other issues"
	| tf path filename type extension |
	
	tf := deltaOdom asVMTFMatrix.
	path := logPath.
	filename := 'deltaOdom_', (keyframeCounter printPaddedWith: $0 to: 4).
	type := '.', tf class name.
	extension := '.fuel'.
	
	FLSerializer serialize: tf toFileNamed: path, filename, type, extension.


]

{ #category : #logging }
VMKeyframeNode >> logFuelLaserMsg: aMsg [
	"note: keyFrameCounter has +1 added, because this mehtod is called before the counter
	is incremented, unlike the other logger methods."
	| path filename type extension |
	
	path := logPath.
	filename := 'keyframe_', (keyframeCounter + 1 printPaddedWith: $0 to: 4).
	type := '.', aMsg class name.
	extension := '.fuel'.
	
	FLSerializer serialize: aMsg toFileNamed: path, filename, type, extension.

]

{ #category : #logging }
VMKeyframeNode >> logFuelOdom: odom [
	"writing to a file via FUEL because STON fails when class names contain underscores and other issues"
	| tf path filename type extension |
	
	tf := odom asVMTFMatrix.
	path := logPath.
	filename := 'odom_', (keyframeCounter printPaddedWith: $0 to: 4).
	type := '.', tf class name.
	extension := '.fuel'.
	
	FLSerializer serialize: tf toFileNamed: path, filename, type, extension.


]

{ #category : #logging }
VMKeyframeNode >> logFuelOdomGt [
	| tf path filename type extension |
	
	tf := currentGtOdomPose asVMTFMatrix.
	path := logPath.
	filename := 'gtOdom_', (keyframeCounter printPaddedWith: $0 to: 4).
	type := '.', tf class name.
	extension := '.fuel'.
	
	FLSerializer serialize: tf toFileNamed: path, filename, type, extension.

]

{ #category : #accessing }
VMKeyframeNode >> logLaser [
	^logLaser
]

{ #category : #accessing }
VMKeyframeNode >> logLaser: aBoolean [
	logLaser := aBoolean.
]

{ #category : #logging }
VMKeyframeNode >> logPointCloud: aPC [
	"writing to a file via FUEL because STON fails when class names contain underscores and other issues"
	| path filename type extension |
	
	path := logPath.
	filename := 'keyframe_', (keyframeCounter printPaddedWith: $0 to: 4).
	type := '.', aPC class name.
	extension := '.fuel'.
	
	FLSerializer serialize: aPC toFileNamed: path, filename, type, extension.


]

{ #category : #logging }
VMKeyframeNode >> logToFile: anObj [
	"logs an object (e.g. a VMLocalMap instance) to a file in the path specified below.
	STON is used to serialize the object."
	| path filename type extension file fullPath handle |
	
	"path := '/opt/shared/developer/data/vector_maps/boxworld_v1/2018-06-13/'."
	"path := '/opt/shared/developer/data/vector_maps/gazebo_office/run2.1/'."
	path := logPath.
	filename := 'keyframe_', (keyframeCounter printPaddedWith: $0 to: 4).
	type := '.', anObj class name.
	extension := '.ston'.
	
	fullPath := path, filename, type, extension.
	
	file := File named: fullPath.
	
	handle := file openForWrite.
	
	handle truncate;
		nextPutAll: (STON toString: anObj);
		close.
	
	Transcript show: 'logged at: '; show: fullPath; cr.	

]

{ #category : #'ICP computation' }
VMKeyframeNode >> performICP: aPointCloud guess: initialTf [
	"run ICP on the last point cloud and the provided point cloud, using 'guess' as an initial guess for the transformation.
	the resulting transformation should be added to lasyKeyTf, and lastKeyPointCloud should be replaced by 'aPointCloud'."
	
	icp alignPointCollection: aPointCloud points with: lastKeyPointCloud points initialGuess: initialTf asVMTFMatrix.
	
	self logCr: 'icp final error=', icp computeError printString.
	
	^icp tfMatrix.
	

]

{ #category : #'as yet unclassified' }
VMKeyframeNode >> processGtOdomMsg: msg [
	
	currentGtOdomPose := VMTransform fromOdomMsg: msg.

	




]

{ #category : #'topic handler' }
VMKeyframeNode >> processLaserScan: aMsg [
	"note: we process the scan data for keyframe creation only. obstacle detection and mapping is not done here."
	| pc |
	
	keyframeSelector hasNewKeyframe ifFalse: [ ^self. ].
	
	logLaser ifTrue: [
		self logFuelLaserMsg: aMsg.
	].
	
	pc := VMPointCloud2d new fromMsg: aMsg.
	
	"debug code"
	"self logFuelOdom: aMsg."
	"self logToFile: aMsg."
	(pc points size < 1) ifTrue: [
		Transcript show: 'dropping empty laser scan'; cr.
		^self.
	].
	
	self createKeyFrameWithPointCloud: pc.

]

{ #category : #'topic handler' }
VMKeyframeNode >> processOdomMsg: msg [
	
	currentOdomPose := VMTransform fromOdomMsg: msg.
	keyframeSelector updatePose: currentOdomPose.

	




]

{ #category : #'topic handler' }
VMKeyframeNode >> publish: aVMLocalMap [
	
	publisher send: [ :obj |
		aVMLocalMap lineSegments do: [ :lineSeg |
			"add pointA"
			obj vertices add: ( Vector_mapsvm_vertex new
				x: lineSeg pointA x;
				y: lineSeg pointA y;
				type: lineSeg type asInteger;
				flags: 0).
			
			"add pointB"
			obj vertices add: ( Vector_mapsvm_vertex new
				x: lineSeg pointB x;
				y: lineSeg pointB y;
				type: lineSeg type asInteger;
				flags: 0).

		].
	].
	
	"self logToFile: aVMLocalMap."
	
	
	
	

]

{ #category : #'private - debugging' }
VMKeyframeNode >> republish [
	lastKeyPointCloud ifNotNil: [ 
		self createKeyFrameWithPointCloud: lastKeyPointCloud.
	].
]

{ #category : #initialization }
VMKeyframeNode >> reset [
	
	keyframeSelector := VMKeyFrameSelector new.
	"icp := VMICP new."
	icp := nil.
	keyframeCounter := 0.
	
	logGt := true.
	logLaser := false.
	logPC := true.
	"'/opt/shared/developer/data/vector_maps/sang/auto_gmapping/'"
	logPath := '/opt/shared/developer/data/vector_maps/benchmark_wg/1/'.
	
	lastKeyPose := nil.
	lastOdomPose := nil.
	currentOdomPose := nil.
	currentGtOdomPose := VMTransform zero.
	lastKeyPointCloud := nil.
	
	
	icpViewer := nil.

]

{ #category : #initialization }
VMKeyframeNode >> setupPublisher [

	publisher := node 
						topicPublisher: self robotPrefix, '/scanMap' 
						typedAs: 'vector_maps/vm_map'.
	
	"note: vm_vertex is part of vm_map. both are required to publish."
	self assert: (Smalltalk hasClassNamed: 'Vector_mapsvm_vertex').
	self assert: (Smalltalk hasClassNamed: 'Vector_mapsvm_map').
	

]

{ #category : #visualization }
VMKeyframeNode >> showICPViewer [
	
	icpViewer ifNotNil: [  ^self. ].
	icp ifNil: [ ^self. ].
	
	icpViewer := (VMMapViewer
		openOn: { icp asRenderableElement }
		extent: 800@800)
			zoomFactor: 50 at: 0@0;
			panTo: 300@350.


]

{ #category : #initialization }
VMKeyframeNode >> subscribeToTopics [
	"todo:
		- support custom topic names
		- support multiple sensors
	"
	self logCr: self class name, ': subscribing to topics'.
	self assert: node isNotNil.
	
	"gazebo sim: /laser/scan  &  /odom  &  /odom_groundtruth
	 turtlebot hokuyo laser: /scan  &  /odom  (no odom groundtruth)"
	(node buildConnectionFor: self robotPrefix, '/laser/scan')
		typedAs: 'sensor_msgs/LaserScan';
		for: [ :msg | self processLaserScan: msg. ];
		connect.
	
	(node buildConnectionFor: self robotPrefix, '/odom')
		typedAs: 'nav_msgs/Odometry';
		for: [ :msg | self processOdomMsg: msg. ];
		connect.
	
	logGt ifTrue: [
		(node buildConnectionFor: self robotPrefix, '/odom_groundtruth')
			typedAs: 'nav_msgs/Odometry';
			for: [ :msg | self processGtOdomMsg: msg. ];
			connect.
	].
	
	self setupPublisher.
	

]
