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
		'angular_delta_deg'
	],
	#category : #'PolySLAM-Viz'
}

{ #category : #accessing }
PSKeyframeView >> angular_delta_deg [
	^ angular_delta_deg
]

{ #category : #accessing }
PSKeyframeView >> angular_delta_deg: anObject [
	angular_delta_deg := anObject
]

{ #category : #converting }
PSKeyframeView >> asJSONObject [
	|d|
	d := super asJSONObject.
	d at: 'odom_topic'  put: self odom_topic .
	d at: 'keyframe_color' put: self keyframe_color.
	d at: 'time_scale_milliseconds' put: self time_scale_milliseconds.
	d at: 'angular_delta_deg' put: self angular_delta_deg.
	d at: 'linear_delta_m' put: self linear_delta_m.
	d at: 'obstacle_dist_m' put: self obstacle_dist_m.
	d at: 'simplifier_th' put: self simplifier_th.
	^d	
]

{ #category : #initialization }
PSKeyframeView >> desynchronize [
	module stop.
	"self undraw"
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
	obstacle_dist_m := module obstacleDist.
	linear_delta_m := module linearDelta.
	simplifier_th := module simplifierTh.
	
	module scanTopic: topic; odomTopic: odom_topic.
	"module "
]

{ #category : #accessing }
PSKeyframeView >> keyframe_color [
	^ keyframe_color
]

{ #category : #accessing }
PSKeyframeView >> keyframe_color: anObject [
	keyframe_color := anObject
]

{ #category : #accessing }
PSKeyframeView >> linear_delta_m [
	^ linear_delta_m
]

{ #category : #accessing }
PSKeyframeView >> linear_delta_m: anObject [
	linear_delta_m := anObject
]

{ #category : #accessing }
PSKeyframeView >> name [
	^ 'A keyframe view'
]

{ #category : #accessing }
PSKeyframeView >> obstacle_dist_m [
	^ obstacle_dist_m
]

{ #category : #accessing }
PSKeyframeView >> obstacle_dist_m: anObject [
	obstacle_dist_m := anObject
]

{ #category : #accessing }
PSKeyframeView >> odom_topic [
	^ odom_topic
]

{ #category : #accessing }
PSKeyframeView >> odom_topic: anObject [
	odom_topic := anObject
]

{ #category : #initialization }
PSKeyframeView >> processKeyframe:k [
	Transcript show: 'New keyframe found.';cr
]

{ #category : #initialization }
PSKeyframeView >> propList [
	^ super propList
		,
			{
			(RHProperty
				from:
					{(#name -> #topic).
					(#type -> String)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #odom_topic).
					(#type -> String)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #keyframe_color).
					(#type -> Color)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #time_scale_milliseconds).
					(#type -> Number)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #angular_delta_deg).
					(#type -> Number)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #linear_delta_m ).
					(#type -> Number)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #obstacle_dist_m ).
					(#type -> Number)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #simplifier_th ).
					(#type -> Number)}
				holder: self).
			}
]

{ #category : #event }
PSKeyframeView >> propertyChange: prop [
	(prop name = #topic | prop name = #odom_topic ) ifFalse:[^self].
	self desynchronize.
	self synchronize 
]

{ #category : #accessing }
PSKeyframeView >> simplifier_th [
	^ simplifier_th
]

{ #category : #accessing }
PSKeyframeView >> simplifier_th: anObject [
	simplifier_th := anObject
]

{ #category : #initialization }
PSKeyframeView >> synchronize [
	module controller: self proxy controller.
	module scanTopic: self topic.
	module odomTopic: self odom_topic.
	module callback: [:k | self processKeyframe:k ].
	module start.
]

{ #category : #accessing }
PSKeyframeView >> time_scale_milliseconds [
	^ time_scale_milliseconds
]

{ #category : #accessing }
PSKeyframeView >> time_scale_milliseconds: anObject [
	time_scale_milliseconds := anObject.
	module timeScale: time_scale_milliseconds
]
