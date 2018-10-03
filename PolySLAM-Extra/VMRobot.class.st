Class {
	#name : #VMRobot,
	#superclass : #VMSimObject,
	#instVars : [
		'speed',
		'radius',
		'sensors',
		'map'
	],
	#category : #'PolySLAM-Extra-Simulator'
}

{ #category : #'as yet unclassified' }
VMRobot class >> rendererClass [
	^ VMRobotRenderer 
]

{ #category : #adding }
VMRobot >> addSensor: sensor [
	sensors add: sensor.
	sensor parent: self.

]

{ #category : #converting }
VMRobot >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #initialization }
VMRobot >> initialize [
	super initialize.
	speed := 0@0.
	radius := 0.25.
	sensors := OrderedCollection new.

]

{ #category : #accessing }
VMRobot >> map [
	^map.
]

{ #category : #accessing }
VMRobot >> map: aMap [
	map := aMap.
]

{ #category : #accessing }
VMRobot >> orientation [
	^tf orientation.
]

{ #category : #accessing }
VMRobot >> orientation: radians [
	tf orientation: radians.
]

{ #category : #accessing }
VMRobot >> position [
	^tf position.
]

{ #category : #accessing }
VMRobot >> position: aPoint [
	tf position: aPoint.
]

{ #category : #accessing }
VMRobot >> radius [
	^radius.
]

{ #category : #accessing }
VMRobot >> radius: aFloat [
	radius := aFloat.
]

{ #category : #accessing }
VMRobot >> sensors [
	^sensors.
]

{ #category : #accessing }
VMRobot >> speed [
	^speed.
]

{ #category : #accessing }
VMRobot >> speed: aPoint [
	"forward/backward speed: aPoint x,
	turning speed: aPoint y"
	speed := aPoint.
]

{ #category : #spinning }
VMRobot >> spinOnce [
	| dt |
	dt := 0.1.	"hard-coded duration for testing"
	
	tf position: tf position + (  (0@1 * dt * (speed x)) rotateBy: (tf orientation) about: 0@0  ).
	
	tf orientation: tf orientation + speed y.
	
	sensors do: [ :sensor |
		sensor spinOnce.
	].
]
