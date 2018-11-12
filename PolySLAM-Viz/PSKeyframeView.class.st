Class {
	#name : #PSKeyframeView,
	#superclass : #RHModule,
	#instVars : [
		'samplingModule',
		'localizationModule',
		'odom_topic',
		'odom_keyframe_color',
		'time_scale_milliseconds',
		'obstacle_dist_m',
		'simplifier_th',
		'linear_delta_m',
		'angular_delta_deg',
		'myshapes',
		'running',
		'correct_key_frame_color',
		'outlier_threshold_falloff',
		'outlier_threshold_start',
		'max_iteration'
	],
	#category : #'PolySLAM-Viz'
}

{ #category : #accessing }
PSKeyframeView >> angular_delta_deg [
	<galleonProperty: #Number>
	^ angular_delta_deg
]

{ #category : #accessing }
PSKeyframeView >> angular_delta_deg: anObject [
	angular_delta_deg := anObject.
	samplingModule angularDelta: angular_delta_deg 
]

{ #category : #drawing }
PSKeyframeView >> canvasPos: realPost [
	^((realPost at:1) / self parent resolution) rounded @ ( 0 - ( (realPost at:2) / self parent resolution)) rounded.
]

{ #category : #accessing }
PSKeyframeView >> correct_key_frame_color [
	<galleonProperty: #Color>
	^ correct_key_frame_color
]

{ #category : #accessing }
PSKeyframeView >> correct_key_frame_color: anObject [
	correct_key_frame_color := anObject
]

{ #category : #initialization }
PSKeyframeView >> desynchronize [
	samplingModule stop.
	localizationModule stop.
	self undraw
]

{ #category : #drawing }
PSKeyframeView >> drawArrowFrom: pos orientation: o color: aColor [
	|l|
	l := self arrowFrom: pos orientation: o. 
	self lock critical: [
		l do:[:line|
			myshapes add: line.
			line color: aColor.
			self canvas addShape: line.
		]. 
		self canvas signalUpdate
	].
]

{ #category : #initialization }
PSKeyframeView >> initialize [
	super initialize.
	samplingModule := PSKeyframeSampling new.
	localizationModule := PSLocalization new.
	topic := '/scan'.
	odom_topic := '/odom'.
	odom_keyframe_color := Color blue.
	correct_key_frame_color := Color red.
	time_scale_milliseconds := 10.
	angular_delta_deg := 20.
	linear_delta_m := samplingModule linearDelta.
	samplingModule  scanTopic: topic; odomTopic: odom_topic.
	myshapes := OrderedCollection new.
	running := false.
	"localization module "
	outlier_threshold_falloff := localizationModule outlierThresholdFalloff.
	outlier_threshold_start := localizationModule outlierStartThreshold.
	obstacle_dist_m := localizationModule obstacleDistance.
	simplifier_th := localizationModule simplifierTh.
	max_iteration := localizationModule maxIterations 
]

{ #category : #accessing }
PSKeyframeView >> linear_delta_m [
	<galleonProperty: #Number>
	^ linear_delta_m
]

{ #category : #accessing }
PSKeyframeView >> linear_delta_m: anObject [
	linear_delta_m := anObject.
	samplingModule linearDelta: linear_delta_m 
]

{ #category : #accessing }
PSKeyframeView >> max_iteration [
	<galleonProperty: #Number>
	^ max_iteration
]

{ #category : #accessing }
PSKeyframeView >> max_iteration: anObject [
	max_iteration := anObject.
	localizationModule maxIterations: max_iteration 
]

{ #category : #accessing }
PSKeyframeView >> name [
	^ 'A keyframe view'
]

{ #category : #accessing }
PSKeyframeView >> obstacle_dist_m [
	<galleonProperty: #Number>
	^ obstacle_dist_m
]

{ #category : #accessing }
PSKeyframeView >> obstacle_dist_m: anObject [
	obstacle_dist_m := anObject.
	localizationModule obstacleDistance: obstacle_dist_m
]

{ #category : #accessing }
PSKeyframeView >> odom_keyframe_color [
	<galleonProperty: #Color>
	^ odom_keyframe_color 
]

{ #category : #accessing }
PSKeyframeView >> odom_keyframe_color: anObject [
	odom_keyframe_color := anObject
]

{ #category : #accessing }
PSKeyframeView >> odom_topic [
	<galleonProperty: #String>
	^ odom_topic
]

{ #category : #accessing }
PSKeyframeView >> odom_topic: anObject [
	odom_topic := anObject
]

{ #category : #accessing }
PSKeyframeView >> outlier_threshold_falloff [
	<galleonProperty: #Number>
	^ outlier_threshold_falloff
]

{ #category : #accessing }
PSKeyframeView >> outlier_threshold_falloff: anObject [
	outlier_threshold_falloff := anObject.
	localizationModule outlierThresholdFalloff: outlier_threshold_falloff 
]

{ #category : #accessing }
PSKeyframeView >> outlier_threshold_start [
	<galleonProperty: #Number>
	^ outlier_threshold_start
]

{ #category : #accessing }
PSKeyframeView >> outlier_threshold_start: anObject [
	outlier_threshold_start := anObject.
	localizationModule outlierStartThreshold: outlier_threshold_start 
]

{ #category : #processing }
PSKeyframeView >> processLocalizedData [
[ running ] whileTrue: [ 
	localizationModule outputCollection atEnd ifFalse:[
		self processLocalizedKeyframe: localizationModule outputCollection next	
	] ifTrue:[ 150 milliSeconds wait ]
]
]

{ #category : #processing }
PSKeyframeView >> processLocalizedKeyframe: kf [
	|tf tl pos|
	"kf inspect."
	tf := self tfFrom:'odom' to: self parent localframe.
	tl := kf correctPose translation.
	tl := {tl x. tl y. 0. 1 }.
	tl := tf+*tl.
	pos := self canvasPos: tl.
	self drawArrowFrom: pos orientation: kf correctPose orientation color: self correct_key_frame_color 
]

{ #category : #processing }
PSKeyframeView >> processOdomKeyframe:k [
	|tf tl pos|
	tf := self tfFrom:'odom' to: self parent localframe.
	tl := k odomPose translation.
	tl := {tl x. tl y. 0. 1 }.
	tl := tf+*tl.
	pos := self canvasPos: tl.
	self drawArrowFrom: pos orientation: k odomPose orientation color: self odom_keyframe_color
]

{ #category : #processing }
PSKeyframeView >> processSamplingData [
|scan|
[ running ] whileTrue: [ 
	samplingModule allScans ifNotNil: [
		localizationModule running ifFalse:[
			"this happend only once"
			localizationModule start ].
		samplingModule allScans atEnd ifFalse:[
			scan := samplingModule allScans next.
			localizationModule inputCollection nextPut: scan.
			self processOdomKeyframe: scan
		] ifTrue:[ 150 milliSeconds wait ]
	] ifNil: [ 150 milliSeconds wait ]
]
]

{ #category : #event }
PSKeyframeView >> propertyChange: prop [
	(prop name = #topic | prop name = #odom_topic ) ifFalse:[^self].
	self desynchronize.
	self synchronize 
]

{ #category : #accessing }
PSKeyframeView >> simplifier_th [
	<galleonProperty: #Number>
	^ simplifier_th
]

{ #category : #accessing }
PSKeyframeView >> simplifier_th: anObject [
	simplifier_th := anObject.
	localizationModule simplifierTh: simplifier_th 
]

{ #category : #initialization }
PSKeyframeView >> synchronize [
	samplingModule controller: self proxy controller.
	samplingModule scanTopic: self topic.
	samplingModule odomTopic: self odom_topic.
	"module callback: [:k | self processKeyframe:k ]."
	samplingModule start.
	running := true.
	"process the new keyframe in the background"
	[ self processSamplingData ] forkAt: Processor userBackgroundPriority.
	[ self processLocalizedData  ] forkAt: Processor userBackgroundPriority
]

{ #category : #accessing }
PSKeyframeView >> time_scale_milliseconds [
	<galleonProperty: #Number>
	^ time_scale_milliseconds
]

{ #category : #accessing }
PSKeyframeView >> time_scale_milliseconds: anObject [
	time_scale_milliseconds := anObject.
	samplingModule timeScale: time_scale_milliseconds
]

{ #category : #drawing }
PSKeyframeView >> undraw [
	self lock critical: [ 
		myshapes do:[:s| self canvas removeShape: s].
		self canvas signalUpdate
	].

]
