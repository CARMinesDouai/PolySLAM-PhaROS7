Class {
	#name : #VMTFServer,
	#superclass : #Object,
	#instVars : [
		'dict'
	],
	#category : #'PolySLAM-Extra-Simulator'
}

{ #category : #'as yet unclassified' }
VMTFServer class >> singleton [
	^uniqueInstance ifNil: [uniqueInstance := self basicNew initialize]
]

{ #category : #'as yet unclassified' }
VMTFServer >> add: aFrame [
	
	dict
		at: (aFrame id)
		ifPresent: [
			| oldFrame newFrame |	"for nicer debugging"
			oldFrame := dict at: (aFrame id).
			newFrame := aFrame.
			
			self error: 'error: trying to register a transformation frame with an id that is already in use'.
		]
		ifAbsent: [
			dict at: (aFrame id) put: aFrame.
		].
]

{ #category : #'as yet unclassified' }
VMTFServer >> addAll: aCollection [
	
	aCollection do: [ :frame |
		self add: frame.
	].
]

{ #category : #'as yet unclassified' }
VMTFServer >> at: frameId [
	dict at: frameId
		ifPresent: [ :obj | ^obj ]
		ifAbsent: [ ^nil ].
]

{ #category : #'as yet unclassified' }
VMTFServer >> fromParent: parentId toChild: childId [
	| childFrame parentFrame currentFrame newFrame |
	
	dict at: childId
		ifPresent: [ :entry | childFrame := entry ]
		ifAbsent: [ self error: 'failed to find frame id "', childId,'" at the TFServer' ].
	
	dict at: parentId
		ifPresent: [ :entry | parentFrame := entry ]
		ifAbsent: [ self error: 'failed to find frame id "', parentId, '" at the TFServer' ].
	
	newFrame := childFrame copy.
	currentFrame := childFrame.
	[ currentFrame parent id ~= parentId ] whileTrue: [
		currentFrame := currentFrame parent.
		newFrame := newFrame multiplyLeft: currentFrame.
	].
	
	newFrame id: (parentId, ' --> ', childId).
	^newFrame.
	

]

{ #category : #'as yet unclassified' }
VMTFServer >> initialize [
	dict := Dictionary new.
	self reset.

]

{ #category : #'as yet unclassified' }
VMTFServer >> print [

	Transcript
		show: 'VMTFServer content:';
		cr.
		
	dict keysDo: [ :key |
		Transcript
			show: '  ', key;
			cr.
	].
]

{ #category : #'as yet unclassified' }
VMTFServer >> reset [
	dict removeAll.
	
	self add: (VMTransformationFrame position: 0@0 orientation: 0 id: 'world').
	
	
]
