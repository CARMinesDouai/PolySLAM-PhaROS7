Class {
	#name : #PSKeyframeView,
	#superclass : #RHModule,
	#instVars : [
		'module',
		'odom_topic',
		'keyframe_color',
		'time_scale_milliseconds',
		'obstacle_dist_m',
		'simplifier_th',
		'linear_delta_m',
		'angular_delta_deg',
		'myshapes',
		'running'
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
	module angularDelta: angular_delta_deg 
]

{ #category : #drawing }
PSKeyframeView >> canvasPos: realPost [
	^((realPost at:1) / self parent resolution) rounded @ ( 0 - ( (realPost at:2) / self parent resolution)) rounded.
]

{ #category : #initialization }
PSKeyframeView >> desynchronize [
	module stop.
	self undraw
]

{ #category : #initialization }
PSKeyframeView >> initialize [
	super initialize.
	module := PSKeyframeSampling new.
	topic := '/scan'.
	odom_topic := '/odom'.
	keyframe_color := Color blue.
	time_scale_milliseconds := 10.
	angular_delta_deg := 20.
	obstacle_dist_m := 0.4.
	linear_delta_m := module linearDelta.
	simplifier_th := 0.02 squared.
	module scanTopic: topic; odomTopic: odom_topic.
	myshapes := OrderedCollection new.
	running := false.
	"module "
]

{ #category : #accessing }
PSKeyframeView >> keyframe_color [
	<galleonProperty: #Color>
	^ keyframe_color
]

{ #category : #accessing }
PSKeyframeView >> keyframe_color: anObject [
	keyframe_color := anObject
]

{ #category : #accessing }
PSKeyframeView >> linear_delta_m [
	<galleonProperty: #Number>
	^ linear_delta_m
]

{ #category : #accessing }
PSKeyframeView >> linear_delta_m: anObject [
	linear_delta_m := anObject.
	module linearDelta: linear_delta_m 
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

{ #category : #initialization }
PSKeyframeView >> process [
[ running ] whileTrue: [ 
	module allScans ifNotNil: [ 
		module allScans atEnd ifFalse:[
			self processKeyframe: module allScans next	
		]
	]	
]
]

{ #category : #initialization }
PSKeyframeView >> processKeyframe:k [
	|tf tl l pos|
	tf := self tfFrom:'odom' to: self parent localframe.
	tl := k odomPose translation.
	tl := {tl x. tl y. 0. 1 }.
	tl := tf+*tl.
	pos := self canvasPos: tl.
	"shape := TREllipseShape new size: 10.
	shape strokeWidth: 0.
	shape color: self keyframe_color.
	shape translateTo: pos."
	l := self arrowFrom: pos orientation: k odomPose orientation. 
	self lock critical: [
		l do:[:line|
			myshapes add: line.
			line color: self keyframe_color.
			self canvas addShape: line.
		]. 
		self canvas signalUpdate
	].
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
]

{ #category : #initialization }
PSKeyframeView >> synchronize [
	module controller: self proxy controller.
	module scanTopic: self topic.
	module odomTopic: self odom_topic.
	"module callback: [:k | self processKeyframe:k ]."
	module start.
	running := true.
	"process the new keyframe in the background"
	[ self process ] forkAt: Processor userBackgroundPriority
]

{ #category : #accessing }
PSKeyframeView >> time_scale_milliseconds [
	<galleonProperty: #Number>
	^ time_scale_milliseconds
]

{ #category : #accessing }
PSKeyframeView >> time_scale_milliseconds: anObject [
	time_scale_milliseconds := anObject.
	module timeScale: time_scale_milliseconds
]

{ #category : #drawing }
PSKeyframeView >> undraw [
	self lock critical: [ 
		myshapes do:[:s| self canvas removeShape: s].
		self canvas signalUpdate
	].

]
