Class {
	#name : #VMTransformationMatrix,
	#superclass : #DhbMatrix,
	#category : #'PolySLAM-Extra-Simulator'
}

{ #category : #'as yet unclassified' }
VMTransformationMatrix >> translate [
	| vec |
	
	vec := OrderedCollection new.
	
	vec at: 1 put: (self at: 1 at: 4).
	vec at: 2 put: (self at: 2 at: 4).
	vec at: 3 put: (self at: 3 at: 4).

]

{ #category : #'as yet unclassified' }
VMTransformationMatrix >> translate: orderedCollectionOrVector [
	| vec |
	
	vec := orderedCollectionOrVector.
	
	self at: 1 at: 4 put: (vec at: 1).
	self at: 2 at: 4 put: (vec at: 2).
	self at: 3 at: 4 put: (vec at: 3).
	
]
