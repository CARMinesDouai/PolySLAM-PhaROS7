"
This class is responsible to devide when a new keyframe should be created, based on input provided by the odometry (or any source that provides a VMTransform or VMTFMatrix object).


Public API and Key Messages

- hasNewKeyframe
	returns true or false. if it returns true, a new keyframe should be created. this function also automatically resets if it returns true, meaning that the next call of this method will return false, unless calls to #updatePose warent yet another keyframe
	
- updatePose: <a VMTransform or VMTFMatrix instance>
	uses the provided transformation to update the internal status of this instance.


Usage

The object is meant to be used to detect whether or not a new keyframe should be created, based on the odometry provided by the robot. For this, #updatePose should be called whenever the robot provides a pose update. #hasNewKeyframe can than be polled to check if the we want to create a new keyframe.

This class is used in VM
"
Class {
	#name : #VMKeyFrameSelector,
	#superclass : #Object,
	#instVars : [
		'keyPoseCollection',
		'triggerLength',
		'triggerAngle',
		'lastCheckSize'
	],
	#category : #'PolySLAM-PhaROS-Examples-Helper'
}

{ #category : #'as yet unclassified' }
VMKeyFrameSelector >> hasNewKeyframe [
	(keyPoseCollection size = lastCheckSize) ifTrue: [
		^false.
	].
	
	lastCheckSize := keyPoseCollection size.
	^true.

]

{ #category : #private }
VMKeyFrameSelector >> ifTriggersUpdate: delta do: aBlock [

	delta length >= triggerLength
		ifTrue: [
			aBlock value.
			^self.
		].
	
	delta angle abs >= triggerAngle
		ifTrue: [
			aBlock value.
			^self.
		].

]

{ #category : #initialization }
VMKeyFrameSelector >> initialize [

	keyPoseCollection := OrderedCollection new.
	
	triggerLength := 0.2. "0.2 meter"
	triggerAngle := (Float pi / 180) * 20. "20 degree"
	
	lastCheckSize := 0.
	

]

{ #category : #accessing }
VMKeyFrameSelector >> triggerAngle [
	^ triggerAngle
]

{ #category : #accessing }
VMKeyFrameSelector >> triggerAngle: radians [
	triggerAngle := radians
]

{ #category : #accessing }
VMKeyFrameSelector >> triggerLength [
	^ triggerLength
]

{ #category : #accessing }
VMKeyFrameSelector >> triggerLength: aFloat [
	triggerLength := aFloat
]

{ #category : #'as yet unclassified' }
VMKeyFrameSelector >> updatePose: aVMTransformOrVMTFMatrix [
	| delta |
	
	keyPoseCollection ifEmpty: [
		keyPoseCollection add: aVMTransformOrVMTFMatrix.
		self logCr: self class name, ' - keyframe added (', keyPoseCollection size printString, ')'.
		^self.
	].
	
	delta := (aVMTransformOrVMTFMatrix inverse) * keyPoseCollection last.
	
	self ifTriggersUpdate: delta do: [
		keyPoseCollection add: aVMTransformOrVMTFMatrix.
	].

]
