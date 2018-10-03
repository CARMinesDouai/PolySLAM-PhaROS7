Class {
	#name : #VMSimObject,
	#superclass : #Object,
	#instVars : [
		'parent',
		'tf',
		'id'
	],
	#category : #'PolySLAM-Extra-Simulator'
}

{ #category : #'as yet unclassified' }
VMSimObject class >> id: newId [
	^(self new)
		id: newId;
		yourself.
]

{ #category : #accessing }
VMSimObject >> id [
	^id.
]

{ #category : #accessing }
VMSimObject >> id: newId [
	id := newId.
]

{ #category : #initialization }
VMSimObject >> initialize [
	tf := (VMTransformationFrame new)
		id: self class name.
	
	parent := nil.
	
]

{ #category : #'as yet unclassified' }
VMSimObject >> parent: parentObj [
	parent := parentObj.
]

{ #category : #'as yet unclassified' }
VMSimObject >> spinOnce [
	" . . . "
]

{ #category : #accessing }
VMSimObject >> tf [
	^tf.
]

{ #category : #accessing }
VMSimObject >> tf: frame [
	tf := frame.
]
