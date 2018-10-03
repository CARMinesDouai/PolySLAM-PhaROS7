Class {
	#name : #VMSensor,
	#superclass : #VMSimObject,
	#category : #'PolySLAM-Extra-Simulator'
}

{ #category : #'rendering support' }
VMSensor class >> rendererClass [
	^ VMSensorRenderer 
]

{ #category : #'as yet unclassified' }
VMSensor >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #accessing }
VMSensor >> centerPoint [
	^tf frame position.
]

{ #category : #'as yet unclassified' }
VMSensor >> map [
	^parent map.
]

{ #category : #'as yet unclassified' }
VMSensor >> parent: aRobot [
	parent := aRobot.
	
	tf linkWithParent: parent tf.
]

{ #category : #initialization }
VMSensor >> point [
	^tf position.
]

{ #category : #'as yet unclassified' }
VMSensor >> spinOnce [
	self subclassResponsibility.
]
