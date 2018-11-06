Class {
	#name : #PSKeyframeView,
	#superclass : #RHModule,
	#instVars : [
		'sub',
		'update_after_n_messages',
		'count',
		'obstacle_distance',
		'obstacle_color',
		'frontier_color',
		'simplifier_threshold',
		'segs'
	],
	#category : #'PolySLAM-Viz'
}

{ #category : #drawing }
PSKeyframeView >> canvasPos: realPost [
	^((realPost at:1) / self parent resolution) rounded @ ( 0 - ( (realPost at:2) / self parent resolution)) rounded.
]

{ #category : #drawing }
PSKeyframeView >> cleanup [
	segs ifNil: [ ^self ].
	segs isEmpty ifTrue: [ ^self ].
	segs do:[:l | self canvas removeShape: l].
	
]

{ #category : #sync }
PSKeyframeView >> desynchronize [
	self proxy controller node unsubscribe: sub.
	self undraw 
]

{ #category : #drawing }
PSKeyframeView >> drawKeyframe: polygon [
	|tf collection pointA pointB shape|
	collection := OrderedCollection new.
	tf := self tfFromParent.
	polygon do: [ :line|
		pointA := { 0 - line pointA x. 0 - line pointA y. 0 .1 }.
		pointB := { 0 - line pointB x. 0 - line pointB y. 0 .1 }.
		pointA := tf+*pointA.
		pointB := tf+*pointB.
		shape := TRLineShape new from: (self canvasPos: pointA) to: (self canvasPos: pointB).
		shape color: (self queryColor: line).
		collection add:shape.
	].
	self lock critical:[
		self cleanup.
		segs := collection.
		segs do:[:p | self canvas addShape: p].
		self canvas signalUpdate.
	].
]

{ #category : #drawing }
PSKeyframeView >> fallbackColor [
	^ Color green
]

{ #category : #accessing }
PSKeyframeView >> frontier_color [
	^ frontier_color
]

{ #category : #accessing }
PSKeyframeView >> frontier_color: anObject [
	frontier_color := anObject
]

{ #category : #sync }
PSKeyframeView >> initialize [
	super initialize.
	topic := '/scan'.
	localframe := 'laser'.
	update_after_n_messages := 10.
	obstacle_color := Color red.
	frontier_color := Color green.
	obstacle_distance := 0.4.
	simplifier_threshold := 0.02 squared.
	segs := OrderedCollection new.
	count := 0
]

{ #category : #accessing }
PSKeyframeView >> name [
	^ 'A keyframe view'
]

{ #category : #accessing }
PSKeyframeView >> obstacle_color [
	^ obstacle_color
]

{ #category : #accessing }
PSKeyframeView >> obstacle_color: anObject [
	obstacle_color := anObject
]

{ #category : #accessing }
PSKeyframeView >> obstacle_distance [
	^ obstacle_distance
]

{ #category : #accessing }
PSKeyframeView >> obstacle_distance: anObject [
	obstacle_distance := anObject
]

{ #category : #sync }
PSKeyframeView >> process: msg [
	|pc polygon|
	count := count + 1.
	count < update_after_n_messages ifTrue:[^self].
	count := 0.
	pc := VMPointCloud2d new fromMsg: msg.
	polygon := VMPolygon new fromPointCloud: pc tf: nil  obstacleDist: self obstacle_distance.
	polygon := (VMVectorCollectionSimplifier compute: polygon  inlierThreshold: self simplifier_threshold) result.
	self drawKeyframe: polygon.
	"self desynchronize."
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
					{(#name -> #localframe).
					(#type -> String)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #update_after_n_messages ).
					(#type -> Number)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #obstacle_color   ).
					(#type -> Color)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #frontier_color).
					(#type -> Color)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #obstacle_distance).
					(#type -> Number)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #simplifier_threshold).
					(#type -> Number)}
				holder: self)
			}
]

{ #category : #drawing }
PSKeyframeView >> queryColor: line [
	line type class caseOf: { 
		VMLineTypeObstacle -> [ ^self obstacle_color ].
		VMLineTypeFrontier -> [ ^self frontier_color ] 
	} otherwise: [ ^self fallbackColor  ] 
]

{ #category : #accessing }
PSKeyframeView >> simplifier_threshold [
	^ simplifier_threshold
]

{ #category : #accessing }
PSKeyframeView >> simplifier_threshold: anObject [
	simplifier_threshold := anObject
]

{ #category : #sync }
PSKeyframeView >> synchronize [
	sub :=  (self proxy controller node buildConnectionFor: self topic)
		typedAs: 'sensor_msgs/LaserScan';
		for:[:msg| self process: msg ];
		connect
]

{ #category : #sync }
PSKeyframeView >> undraw [
	self cleanup 
]

{ #category : #accessing }
PSKeyframeView >> update_after_n_messages [
	^ update_after_n_messages
]

{ #category : #accessing }
PSKeyframeView >> update_after_n_messages: anObject [
	update_after_n_messages := anObject
]
