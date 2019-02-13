Class {
	#name : #PolySLAM,
	#superclass : #Object,
	#instVars : [
		'samplingModule',
		'localizationModule',
		'time_scale_milliseconds',
		'obstacle_dist_m',
		'simplifier_th',
		'linear_delta_m',
		'angular_delta_deg',
		'running',
		'outlier_threshold_falloff',
		'outlier_threshold_start',
		'max_iteration',
		'onKeyframeAvailable',
		'pub',
		'map'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #accessing }
PolySLAM >> angular_delta_deg [
	<galleonProperty: #Number>
	^ angular_delta_deg
]

{ #category : #accessing }
PolySLAM >> angular_delta_deg: anObject [
	angular_delta_deg := anObject.
	samplingModule angularDelta: angular_delta_deg 
]

{ #category : #initialization }
PolySLAM >> initialize [
	super initialize.
	samplingModule := PSKeyframeSampling new.
	localizationModule := PSLocalization new.
	time_scale_milliseconds := samplingModule timeScale.
	angular_delta_deg := 20.
	linear_delta_m := samplingModule linearDelta.
	running := false.
	"localization module "
	outlier_threshold_falloff := 0.2.
	outlier_threshold_start := 0.1.
	obstacle_dist_m := samplingModule obstacleDist.
	simplifier_th := 0.02 squared.
	max_iteration := 20.
	samplingModule callback: [:k | localizationModule addKeyFrame: k ].
]

{ #category : #accessing }
PolySLAM >> linear_delta_m [
	^ linear_delta_m
]

{ #category : #accessing }
PolySLAM >> linear_delta_m: anObject [
	linear_delta_m := anObject.
	samplingModule linearDelta: linear_delta_m 
]

{ #category : #accessing }
PolySLAM >> map [
	^  map
]

{ #category : #accessing }
PolySLAM >> max_iteration [
	^ max_iteration
]

{ #category : #accessing }
PolySLAM >> max_iteration: anObject [
	max_iteration := anObject.
	localizationModule maxIterations: max_iteration 
]

{ #category : #accessing }
PolySLAM >> obstacle_dist_m [
	^ obstacle_dist_m
]

{ #category : #accessing }
PolySLAM >> obstacle_dist_m: anObject [
	obstacle_dist_m := anObject.
	samplingModule obstacleDist: obstacle_dist_m
]

{ #category : #accessing }
PolySLAM >> onKeyframeAvailable [
	^ onKeyframeAvailable
]

{ #category : #accessing }
PolySLAM >> onKeyframeAvailable: anObject [
	onKeyframeAvailable := anObject
]

{ #category : #accessing }
PolySLAM >> outlier_threshold_falloff [
	^ outlier_threshold_falloff
]

{ #category : #accessing }
PolySLAM >> outlier_threshold_falloff: anObject [
	outlier_threshold_falloff := anObject.
	localizationModule outlierThresholdFalloff: outlier_threshold_falloff 
]

{ #category : #accessing }
PolySLAM >> outlier_threshold_start [
	^ outlier_threshold_start
]

{ #category : #accessing }
PolySLAM >> outlier_threshold_start: anObject [
	outlier_threshold_start := anObject.
	localizationModule outlierStartThreshold: outlier_threshold_start 
]

{ #category : #processing }
PolySLAM >> processLocalizedData [
	[ running ]
		whileTrue: [ "self publishTF."
			localizationModule iostream ifNil: [ ^ self ].
			localizationModule iostream atEnd
				ifFalse: [ self processLocalizedKeyframe: localizationModule iostream next ]
			"mappingModule iostream atEnd ifFalse: [
		map := mappingModule iostream next.
		map inspect
	]" ]
]

{ #category : #processing }
PolySLAM >> processLocalizedKeyframe: 	anArray [
	|scan|
	"kf inspect."
	"tf := self tfFrom:'odom' to: self parent localframe."
	"trigger event"
	scan := samplingModule allScans at:( anArray at:1).
	scan correctPose: (anArray at:2).
	scan polygon: (anArray at:3).
	"self announcer announce: (MapAvailableEvent for: mappingModule map)."
	self onKeyframeAvailable ifNil: [ ^self ].
	self onKeyframeAvailable value: scan
	
]

{ #category : #processing }
PolySLAM >> publishTF [
	|tf q data scan|
	((pub isNil) & (self controller isNotNil)) ifTrue: [ pub := self controller node topicPublisher: '/tf' typedAs: 'tf2_msgs/TFMessage' ].
	pub ifNil: [ ^self ].
	scan := samplingModule lastScan.
	scan ifNil: [ ^self ].
	tf := (scan correctPose inverse)  * ( scan odomPose ).
	q := (PhaROS2DOrientation z: tf angle) asQuaternion .
	"pub publish"
	data := Geometry_msgsTransformStamped new.
	data child_frame_id: 'odom'.
	data header frame_id: 'map'.
	data header stamp: PhaROSTimestamp now.
	data transform rotation x: q x.
	data transform rotation y: q y.
	data transform rotation z: q z.
	data transform rotation w: q w.
	data transform translation x: (tf translate at:1).
	data transform translation y: (tf translate at:2).
	data transform translation z:0.0.
	pub send: [ :msg | msg transforms add:data].
]

{ #category : #initialization }
PolySLAM >> sample: scan odom: odom [
	samplingModule sample: scan odom: odom 
]

{ #category : #accessing }
PolySLAM >> simplifier_th [
	^ simplifier_th
]

{ #category : #accessing }
PolySLAM >> simplifier_th: anObject [
	simplifier_th := anObject.
	localizationModule simplifierTh: simplifier_th 
]

{ #category : #initialization }
PolySLAM >> start [
	running := true.
	samplingModule start.
	[ self processLocalizedData  ] forkAt: Processor userBackgroundPriority
]

{ #category : #initialization }
PolySLAM >> stop [
	samplingModule stop.
	localizationModule stop.
	running := false.
]

{ #category : #accessing }
PolySLAM >> time_scale_milliseconds [
	^ time_scale_milliseconds
]

{ #category : #accessing }
PolySLAM >> time_scale_milliseconds: anObject [
	time_scale_milliseconds := anObject.
	samplingModule timeScale: time_scale_milliseconds
]
