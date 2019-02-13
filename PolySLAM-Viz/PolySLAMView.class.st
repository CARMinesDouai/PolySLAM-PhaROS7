Class {
	#name : #PolySLAMView,
	#superclass : #RHModule,
	#instVars : [
		'sub',
		'SLAM',
		'mappingModule',
		'odom_keyframe_color',
		'myshapes',
		'correct_key_frame_color',
		'running',
		'mapshapes'
	],
	#category : #'PolySLAM-Viz'
}

{ #category : #drawing }
PolySLAMView >> canvasPos: realPost [
	^((realPost at:1) / self parent resolution) rounded @ ( 0 - ( (realPost at:2) / self parent resolution)) rounded.
]

{ #category : #accessing }
PolySLAMView >> correct_key_frame_color [
	<galleonProperty: #Color>
	^ correct_key_frame_color
]

{ #category : #accessing }
PolySLAMView >> correct_key_frame_color: anObject [
	correct_key_frame_color := anObject
]

{ #category : #initialization }
PolySLAMView >> desynchronize [
	|tmp|
	running := false.
	"flush the io stream"
	tmp := true.
	self undraw.
	SLAM stop.
	[tmp] whileTrue: [
		SLAM iostream atEnd ifFalse: [ 
			SLAM iostream next = true ifTrue: [ tmp := false ]
		] ifTrue:[100 milliSecond wait]].
	SLAM close.
	SLAM := nil
]

{ #category : #drawing }
PolySLAMView >> draw: scan [
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
	"draw map if any"
	"self updateMap."
]

{ #category : #drawing }
PolySLAMView >> drawArrowFrom: pos orientation: o color: aColor [
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

{ #category : #drawing }
PolySLAMView >> drawMap: collection [
	|shapes pointA pointB shape c|
	shapes := OrderedCollection new.
	collection do:[:polygon|
		polygon do:[ :line|
				c := (self queryColor: line).
				c ifNotNil: [ 
					pointA := { line pointA x. line pointA y. 0 .1 }.
					pointB := { line pointB x. line pointB y. 0 .1 }.
					shape := TRLineShape new from: (self canvasPos: pointA) to: (self canvasPos: pointB).
					shape color: c.
					shapes add: shape.
				]
		]
	].
	Transcript show: 'Drawing map';cr.
	self lock critical:[
		mapshapes do:[:l | self canvas removeShape: l].
		mapshapes := shapes.
		mapshapes do:[:l| self canvas addShape: l].
		self canvas signalUpdate
	].
]

{ #category : #initialization }
PolySLAMView >> initialize [
	super initialize.
	topic := '/scan_odom_sync'.
	odom_keyframe_color := Color blue.
	correct_key_frame_color := Color red.
	myshapes := OrderedCollection new.
	mapshapes := OrderedCollection new.
	running := false.
	mappingModule := PSMapping new.
	mappingModule onMapUpdate: [ :c| self drawMap: c ]
]

{ #category : #accessing }
PolySLAMView >> name [
	^ 'A PolySLAM map and trajectory view'
]

{ #category : #accessing }
PolySLAMView >> odom_keyframe_color [
	<galleonProperty: #Color>
	^ odom_keyframe_color 
]

{ #category : #accessing }
PolySLAMView >> odom_keyframe_color: anObject [
	odom_keyframe_color := anObject
]

{ #category : #event }
PolySLAMView >> propertyChange: prop [
	(prop name = #topic | prop name = #odom_topic ) ifFalse:[^self].
	self desynchronize.
	self synchronize 
]

{ #category : #drawing }
PolySLAMView >> queryColor: line [
		line type class caseOf: { 
			VMLineTypeObstacle -> [ ^Color black  ].
			VMLineTypeFrontier -> [ ^Color green ] 
	} otherwise: [ ^nil  ] 
]

{ #category : #sync }
PolySLAMView >> synchronize [
	SLAM := PolySLAMROS new.
	SLAM runOn: self topic.
	mappingModule start.
	running := true.
	[ self waitForKeyframe ] forkAt: Processor userBackgroundPriority 
]

{ #category : #drawing }
PolySLAMView >> undraw [
	self lock critical: [ 
		myshapes do:[:s| self canvas removeShape: s].
		self canvas signalUpdate
	].

]

{ #category : #sync }
PolySLAMView >> waitForKeyframe [
|scan|
[ running ] whileTrue: [ 
	SLAM iostream atEnd ifFalse:[
		scan := SLAM iostream next.
		mappingModule addKeyframe: scan.
		self draw: scan.
	]	
]
]
