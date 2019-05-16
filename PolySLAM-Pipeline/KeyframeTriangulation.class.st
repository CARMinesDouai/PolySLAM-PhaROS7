Class {
	#name : #KeyframeTriangulation,
	#superclass : #OrderedCollection,
	#instVars : [
		'keyframe'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
KeyframeTriangulation class >> from: aKeyframe [
	^self new keyframe: aKeyframe; yourself
]

{ #category : #accessing }
KeyframeTriangulation >> keyframe [
	^ keyframe
]

{ #category : #accessing }
KeyframeTriangulation >> keyframe: anObject [
	keyframe := anObject.
	self triangular
]

{ #category : #operation }
KeyframeTriangulation >> triangular [
	|triangle origin startline size idx|
	origin := (self keyframe correctPose at:1 at:3)@(self keyframe correctPose at:2 at:3).
	startline := VMLineSegment from: origin to: self keyframe polygon first pointA type: 2.
	size := self keyframe polygon size.
	idx := 1.
	[ idx < size ] whileTrue:[
		triangle := VMPolygon new.
		triangle add: startline.
		triangle add: (self keyframe polygon at: idx).
		startline := VMLineSegment from: origin to: triangle last pointB type:3.
		triangle add: (VMLineSegment from: triangle last pointB to: origin type:((idx = (size -1)) ifTrue:[2] ifFalse:[3])).
		idx := idx + 1.
		self add: triangle 
	]
]
