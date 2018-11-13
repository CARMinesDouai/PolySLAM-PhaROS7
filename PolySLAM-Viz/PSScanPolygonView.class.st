Class {
	#name : #PSScanPolygonView,
	#superclass : #RHModule,
	#instVars : [
		'sub',
		'update_after_n_messages',
		'count',
		'obstacle_distance',
		'obstacle_color',
		'frontier_color',
		'simplifier_threshold',
		'segs',
		'max_range'
	],
	#category : #'PolySLAM-Viz'
}

{ #category : #drawing }
PSScanPolygonView >> canvasPos: realPost [
	^((realPost at:1) / self parent resolution) rounded @ ( 0 - ( (realPost at:2) / self parent resolution)) rounded.
]

{ #category : #drawing }
PSScanPolygonView >> cleanup [
	segs ifNil: [ ^self ].
	segs isEmpty ifTrue: [ ^self ].
	segs do:[:l | self canvas removeShape: l].
	
]

{ #category : #sync }
PSScanPolygonView >> desynchronize [
	self proxy controller node unsubscribe: sub.
	self undraw 
]

{ #category : #drawing }
PSScanPolygonView >> drawKeyframe: polygon [
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
PSScanPolygonView >> fallbackColor [
	^ Color green
]

{ #category : #accessing }
PSScanPolygonView >> frontier_color [
	<galleonProperty: #Color>
	^ frontier_color
]

{ #category : #accessing }
PSScanPolygonView >> frontier_color: anObject [
	frontier_color := anObject
]

{ #category : #sync }
PSScanPolygonView >> initialize [
	super initialize.
	topic := '/scan'.
	localframe := 'laser'.
	update_after_n_messages := 10.
	obstacle_color := Color red.
	frontier_color := Color green.
	obstacle_distance := 0.4.
	simplifier_threshold := 0.02 squared.
	segs := OrderedCollection new.
	max_range := 10.
	count := 0
]

{ #category : #accessing }
PSScanPolygonView >> max_range [
	<galleonProperty: #Number>
	^ max_range
]

{ #category : #accessing }
PSScanPolygonView >> max_range: anObject [
	max_range := anObject
]

{ #category : #accessing }
PSScanPolygonView >> name [
	^ 'A scan polygon view'
]

{ #category : #accessing }
PSScanPolygonView >> obstacle_color [
	<galleonProperty: #Color>
	^ obstacle_color
]

{ #category : #accessing }
PSScanPolygonView >> obstacle_color: anObject [
	obstacle_color := anObject
]

{ #category : #accessing }
PSScanPolygonView >> obstacle_distance [
	<galleonProperty: #Number>
	^ obstacle_distance
]

{ #category : #accessing }
PSScanPolygonView >> obstacle_distance: anObject [
	obstacle_distance := anObject
]

{ #category : #sync }
PSScanPolygonView >> process: msg [
	|pc polygon|
	count := count + 1.
	count < update_after_n_messages ifTrue:[^self].
	count := 0.
	self validateScan:msg.
	pc := VMPointCloud2d new fromMsg: msg.
	polygon := VMPolygon new fromPointCloud: pc tf: nil  obstacleDist: self obstacle_distance.
	polygon := (VMVectorCollectionSimplifier compute: polygon  inlierThreshold: self simplifier_threshold) result.
	self drawKeyframe: polygon.
	"self desynchronize."
]

{ #category : #drawing }
PSScanPolygonView >> queryColor: line [
	line type class caseOf: { 
		VMLineTypeObstacle -> [ ^self obstacle_color ].
		VMLineTypeFrontier -> [ ^self frontier_color ] 
	} otherwise: [ ^self fallbackColor  ] 
]

{ #category : #accessing }
PSScanPolygonView >> simplifier_threshold [
	<galleonProperty: #Number>
	^ simplifier_threshold
]

{ #category : #accessing }
PSScanPolygonView >> simplifier_threshold: anObject [
	simplifier_threshold := anObject
]

{ #category : #sync }
PSScanPolygonView >> synchronize [
	sub :=  (self proxy controller node buildConnectionFor: self topic)
		typedAs: 'sensor_msgs/LaserScan';
		for:[:msg| self process: msg ];
		connect
]

{ #category : #sync }
PSScanPolygonView >> undraw [
	self lock critical:[	self cleanup. self canvas signalUpdate].

]

{ #category : #accessing }
PSScanPolygonView >> update_after_n_messages [
	<galleonProperty: #Number>
	^ update_after_n_messages
]

{ #category : #accessing }
PSScanPolygonView >> update_after_n_messages: anObject [
	update_after_n_messages := anObject
]

{ #category : #sync }
PSScanPolygonView >> validateScan:msg [
	1 to: msg ranges size do:[:i|
		(msg ranges at: i) > max_range ifTrue:[msg ranges at:i put: Float nan]
	].
]
