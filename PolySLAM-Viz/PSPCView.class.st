Class {
	#name : #PSPCView,
	#superclass : #RHModule,
	#instVars : [
		'sub',
		'cloud',
		'update_after_n_messages',
		'count'
	],
	#category : #'PolySLAM-Viz'
}

{ #category : #accessing }
PSPCView >> allShapes [
	^cloud
]

{ #category : #converting }
PSPCView >> asJSONObject [
	|d|
	d := super asJSONObject.
	d at: 'update_after_n_messages' put: self update_after_n_messages.
	^d	
]

{ #category : #drawing }
PSPCView >> canvasPos: realPost [
	^((realPost at:1) / self parent resolution) rounded @ ( 0 - ( (realPost at:2) / self parent resolution)) rounded.
]

{ #category : #drawing }
PSPCView >> cleanup [
	cloud ifNil: [ ^self ].
	cloud isEmpty ifTrue: [ ^self ].
	cloud do:[:p | self canvas removeShape: p].
	
]

{ #category : #initialization }
PSPCView >> desynchronize [
	self proxy controller node unsubscribe: sub.
	self undraw 
]

{ #category : #drawing }
PSPCView >> draw: msg [
	|pc tf pos point points tl|
	count := count + 1.
	count < update_after_n_messages ifTrue:[^self].
	count := 0.
	points := OrderedCollection new.
	pc := VMPointCloud2d new fromMsg: msg.
	tf := self tfFromParent.
	tl := (tf at:1 at:4)@ (tf at: 2 at:4).
	"tf at:1 at: 4 put:0."
	"tf at:2 at:4 put:0. "
	pc points do:[:p |
		pos := #(0 0 0 1).
		pos at: 1 put: 0 - p x.
		pos at: 2 put: 0 - p y.
		pos := tf+*pos.
		"pos at:1 put:(pos at:1) + tl x.
		pos at:2 put:(pos at:2) + tl y."
		"draw the point"
		point := TRBoxShape new
		extent: 1 @ 1;
		color: Color red;
		strokeWidth: 0;
		size: 1.0.
		points add:point.
		point translateTo: (self canvasPos: pos)
	].
	self lock critical:[
		self cleanup.
		cloud := points.
		cloud do:[:p | self canvas addShape: p].
		self canvas signalUpdate.
	].
]

{ #category : #initialization }
PSPCView >> initialize [
	super initialize.
	topic := '/scan'.
	localframe := 'laser'.
	cloud := OrderedCollection new.
	update_after_n_messages := 10.
	count := 0
]

{ #category : #accessing }
PSPCView >> name [
	^ 'A Pointcloud view'
]

{ #category : #initialization }
PSPCView >> propList [
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
				holder: self)
			}
]

{ #category : #initialization }
PSPCView >> synchronize [
	sub :=  (self proxy controller node buildConnectionFor: self topic)
		typedAs: 'sensor_msgs/LaserScan';
		for:[:msg| self draw: msg ];
		connect
]

{ #category : #drawing }
PSPCView >> undraw [
	self cleanup.
]

{ #category : #accessing }
PSPCView >> update_after_n_messages [
	^ update_after_n_messages
]

{ #category : #accessing }
PSPCView >> update_after_n_messages: anObject [
	update_after_n_messages := anObject
]
