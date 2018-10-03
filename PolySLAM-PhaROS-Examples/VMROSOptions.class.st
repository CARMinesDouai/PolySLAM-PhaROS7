"
The VMROSOptions class handles the ROS related options such as topic name prefix for the robot.

Public API and Key Messages

- robotPrefix
	returns the prefix of the topic name for the robot, e.g. '/robot0'

"
Class {
	#name : #VMROSOptions,
	#superclass : #Object,
	#category : #'PolySLAM-PhaROS-Examples-Helper'
}

{ #category : #'as yet unclassified' }
VMROSOptions class >> robotPrefix [
	"^'/robot0'"
	^''
]
