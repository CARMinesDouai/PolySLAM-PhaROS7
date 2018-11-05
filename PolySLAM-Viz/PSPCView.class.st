Class {
	#name : #PSPCView,
	#superclass : #RHModule,
	#instVars : [
		'sub'
	],
	#category : #'PolySLAM-Viz'
}

{ #category : #processing }
PSPCView >> createKeyFrameFrom: msg [
	|pc|
	pc := VMPointCloud2d new fromMsg: msg.
	pc inspect.
	self desynchronize
]

{ #category : #initialization }
PSPCView >> desynchronize [
	self proxy controller node unsubscribe: sub.
	self undraw 
]

{ #category : #drawing }
PSPCView >> draw: data [
]

{ #category : #initialization }
PSPCView >> initialize [
	super initialize.
	topic := '/scan'
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
				holder: self)}
]

{ #category : #initialization }
PSPCView >> synchronize [
	sub :=  (self proxy controller node buildConnectionFor: self topic)
		typedAs: 'sensor_msgs/LaserScan';
		for:[:msg| self createKeyFrameFrom: msg];
		connect
]

{ #category : #drawing }
PSPCView >> undraw [ 
]
