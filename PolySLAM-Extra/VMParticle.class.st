Class {
	#name : #VMParticle,
	#superclass : #Object,
	#instVars : [
		'keyFrameCollection',
		'nnCollection',
		'icp'
	],
	#category : #'PolySLAM-Extra-SLAM - Particle Filter'
}

{ #category : #'as yet unclassified' }
VMParticle class >> rendererClass [
	^VMParticleRenderer.
]

{ #category : #adding }
VMParticle >> addKeyFrame: aKeyFrame [
	
	keyFrameCollection collection ifEmpty: [
		keyFrameCollection add: aKeyFrame.
		"ToDo: transform the points from the scan data (from the sensor's frame to the robot's frame"
		nnCollection addAll: (aKeyFrame data first collection).
		nnCollection := nnCollection root.
		^self.
	].
	
	self processKeyFrame: aKeyFrame.

]

{ #category : #converting }
VMParticle >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #accessing }
VMParticle >> icp [
	^icp.
]

{ #category : #initialization }
VMParticle >> initialize [
	keyFrameCollection := VMKeyFrameCollection new.
	nnCollection := VMQuadTreeNode size: (1@1) center: (0@0).

]

{ #category : #accessing }
VMParticle >> keyFrameCollection [
	^keyFrameCollection.
]

{ #category : #adding }
VMParticle >> processKeyFrame: aKeyFrame [
	icp := VMICP_old new.
	
	icp alignPointCollection: (aKeyFrame data first collection) withNNCollection: nnCollection.

]
