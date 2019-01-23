Class {
	#name : #PSKeyframeView,
	#superclass : #RHModule,
	#instVars : [
		'sub',
		'SLAM',
		'odom_keyframe_color',
		'time_scale_milliseconds',
		'obstacle_dist_m',
		'simplifier_th',
		'linear_delta_m',
		'angular_delta_deg',
		'myshapes',
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
	SLAM angular_delta_deg: angular_delta_deg 
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
	SLAM stop.
	self proxy controller node unsubscribe: sub.
	self undraw
]

{ #category : #drawing }
PSKeyframeView >> draw: scan [
| tl pos|
	tl := scan correctPose translate.
	tl := {tl at:1. tl at:2. 0. 1 }.
	"tl := tfOff+*tl."
	pos := self canvasPos: tl.
	self drawArrowFrom: pos orientation: scan correctPose angle color: self correct_key_frame_color.
	tl := scan odomPose translate.
	tl := {tl at:1. tl at:2. 0. 1 }.
	"tl := tf+*tl."
	pos := self canvasPos: tl.
	self drawArrowFrom: pos orientation: scan odomPose angle color: self odom_keyframe_color.
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
	SLAM := PolySLAM new.
	topic := '/scan_odom_sync'.
	odom_keyframe_color := Color blue.
	correct_key_frame_color := Color red.
	time_scale_milliseconds := SLAM time_scale_milliseconds.
	angular_delta_deg := 20.
	linear_delta_m := SLAM linear_delta_m.
	myshapes := OrderedCollection new.
	"localization module "
	outlier_threshold_falloff := 0.2.
	outlier_threshold_start := 0.1.
	obstacle_dist_m := SLAM obstacle_dist_m.
	simplifier_th := 0.02 squared.
	max_iteration := 20
]

{ #category : #accessing }
PSKeyframeView >> linear_delta_m [
	<galleonProperty: #Number>
	^ linear_delta_m
]

{ #category : #accessing }
PSKeyframeView >> linear_delta_m: anObject [
	linear_delta_m := anObject.
	SLAM linear_delta_m: linear_delta_m 
]

{ #category : #accessing }
PSKeyframeView >> max_iteration [
	<galleonProperty: #Number>
	^ max_iteration
]

{ #category : #accessing }
PSKeyframeView >> max_iteration: anObject [
	max_iteration := anObject.
	SLAM max_iteration: max_iteration 
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
	SLAM obstacle_dist_m: obstacle_dist_m
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
PSKeyframeView >> outlier_threshold_falloff [
	<galleonProperty: #Number>
	^ outlier_threshold_falloff
]

{ #category : #accessing }
PSKeyframeView >> outlier_threshold_falloff: anObject [
	outlier_threshold_falloff := anObject.
	SLAM outlier_threshold_falloff: outlier_threshold_falloff 
]

{ #category : #accessing }
PSKeyframeView >> outlier_threshold_start [
	<galleonProperty: #Number>
	^ outlier_threshold_start
]

{ #category : #accessing }
PSKeyframeView >> outlier_threshold_start: anObject [
	outlier_threshold_start := anObject.
	SLAM outlier_threshold_start: outlier_threshold_start 
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
	SLAM simplifier_th: simplifier_th 
]

{ #category : #sync }
PSKeyframeView >> synchronize [
	SLAM controller: self proxy controller.
	SLAM onKeyframeAvailable: [:kf| self draw:kf].
	SLAM start.
	"process the new keyframe in the background"
	sub :=  (self proxy controller node buildConnectionFor: self topic)
		typedAs: 'scan_odom_sync/ScanOdomSync';
		for:[:msg| SLAM sample: msg scan odom: msg odom  ];
		connect
]

{ #category : #accessing }
PSKeyframeView >> time_scale_milliseconds [
	<galleonProperty: #Number>
	^ time_scale_milliseconds
]

{ #category : #accessing }
PSKeyframeView >> time_scale_milliseconds: anObject [
	time_scale_milliseconds := anObject.
	SLAM time_scale_milliseconds: time_scale_milliseconds
]

{ #category : #drawing }
PSKeyframeView >> undraw [
	self lock critical: [ 
		myshapes do:[:s| self canvas removeShape: s].
		self canvas signalUpdate
	].

]
