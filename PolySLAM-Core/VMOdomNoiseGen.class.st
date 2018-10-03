Class {
	#name : #VMOdomNoiseGen,
	#superclass : #Object,
	#instVars : [
		'seed',
		'rng'
	],
	#category : #'PolySLAM-Core-Offline'
}

{ #category : #initialization }
VMOdomNoiseGen >> initialize [
	super initialize.
	
	rng := Random seed: 80085.

]

{ #category : #'as yet unclassified' }
VMOdomNoiseGen >> nextTfNoise [
	| noise |
	noise := VMTFMatrix identity.
	
	noise := noise * (VMTFMatrix angle: rng next * 0.01 translation: (rng next * 0.005) @ (rng next * 0.005)).

]
