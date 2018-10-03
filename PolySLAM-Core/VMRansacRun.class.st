Class {
	#name : #VMRansacRun,
	#superclass : #Object,
	#instVars : [
		'runs',
		'maxRuns'
	],
	#category : #'PolySLAM-Core-Line- & Vector Approximation'
}

{ #category : #public }
VMRansacRun >> compute: vectorCollection [
	| ransac |
	
	1 to: maxRuns do: [ :counter |
		ransac := VMRansac new.
		ransac computeForInput: vectorCollection.
		runs add: ransac.
	].
	
	runs sort: [ :a :b | a score > b score ].
	
	"1 halt."
	^runs first

]

{ #category : #public }
VMRansacRun >> compute: vectorCollection withSamplesFrom: sampleableVectors [
	| ransac |
	
	1 to: maxRuns do: [ :counter |
		ransac := VMRansac new.
		ransac computeForInput: vectorCollection withSamplesFrom: sampleableVectors.
		runs add: ransac.
	].
	
	runs sort: [ :a :b | a score > b score ].
	
	"1 halt."
	^runs first

]

{ #category : #initialization }
VMRansacRun >> initialize [
	runs := OrderedCollection new.
	maxRuns := 20.
]

{ #category : #accessing }
VMRansacRun >> maxRuns [
	^maxRuns
]

{ #category : #accessing }
VMRansacRun >> maxRuns: aNumber [
	maxRuns := aNumber
]

{ #category : #accessing }
VMRansacRun >> runs [
	^runs
]
