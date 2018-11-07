Class {
	#name : #PSBasePipelineModule,
	#superclass : #Object,
	#instVars : [
		'controller',
		'lock'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #accessing }
PSBasePipelineModule >> controller [
	^ controller
]

{ #category : #accessing }
PSBasePipelineModule >> controller: anObject [
	controller := anObject
]

{ #category : #accessing }
PSBasePipelineModule >> lock [
	lock ifNil: [ lock := Semaphore forMutualExclusion ].
	^ lock
]

{ #category : #accessing }
PSBasePipelineModule >> lock: anObject [
	lock := anObject
]

{ #category : #accessing }
PSBasePipelineModule >> restart [
	self stop.
	self start
]

{ #category : #accessing }
PSBasePipelineModule >> start [
	self subclassResponsibility 
]

{ #category : #accessing }
PSBasePipelineModule >> stop [
	self subclassResponsibility 
]
