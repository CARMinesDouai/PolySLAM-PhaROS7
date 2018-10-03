Class {
	#name : #VMParticleRenderer,
	#superclass : #VMElementRenderer,
	#instVars : [
		'kfcRenderer'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMParticleRenderer >> initialize [
	super initialize.
]

{ #category : #'as yet unclassified' }
VMParticleRenderer >> renderOn: canvas [
	
	kfcRenderer ifNil: [
		self model ifNotNil: [
			kfcRenderer := VMKeyFrameCollectionRenderer model: self model keyFrameCollection.
		].
	].
	
	kfcRenderer ifNotNil: [
		kfcRenderer renderOn: canvas.
	].
]
